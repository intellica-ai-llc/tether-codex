import * as fs from 'fs/promises'
import * as path from 'path'
import * as yaml from 'yaml'
import { createHash, randomBytes } from 'crypto'

const SKILL_LIMITS = {
  MAX_NAME_LENGTH: 64,
  MAX_CONTENT_CHARS: 50_000,
}

const VALID_NAME_RE = /^[a-z0-9][a-z0-9._-]*$/
const INJECTION_PATTERNS = [
  'ignore previous instructions', 'ignore all previous', 'you are now',
  'disregard your', 'forget your instructions', '<system>', ']]>'
]

export class SkillManageTool {
  private skillsDir: string
  private manifestPath: string
  private securityDir: string
  private quarantineDir: string
  private auditLogPath: string

  constructor(basePath: string = '.tether') {
    this.skillsDir = path.join(basePath, 'skills')
    this.manifestPath = path.join(this.skillsDir, '.manifest.json')
    this.securityDir = path.join(this.skillsDir, '.security')
    this.quarantineDir = path.join(this.securityDir, 'quarantine')
    this.auditLogPath = path.join(this.securityDir, 'audit.log')
  }

  async create(params: {
    name: string; content: string; category?: string; agent: string; taskId?: string
  }): Promise<{ success: boolean; message?: string; error?: string; path?: string }> {
    const nameError = this.validateName(params.name)
    if (nameError) return { success: false, error: nameError }
    if (params.category) {
      const catErr = this.validateCategory(params.category)
      if (catErr) return { success: false, error: catErr }
    }
    const fmErr = await this.validateFrontmatter(params.content)
    if (fmErr) return { success: false, error: fmErr }
    if (params.content.length > SKILL_LIMITS.MAX_CONTENT_CHARS) {
      return { success: false, error: `Content exceeds ${SKILL_LIMITS.MAX_CONTENT_CHARS} chars` }
    }

    const existing = await this.findSkill(params.name)
    if (existing) return { success: false, error: `Skill '${params.name}' already exists` }

    const skillDir = params.category
      ? path.join(this.skillsDir, params.category, params.name)
      : path.join(this.skillsDir, params.name)
    await fs.mkdir(skillDir, { recursive: true })

    const skillMdPath = path.join(skillDir, 'SKILL.md')
    const qPath = await this.quarantineWrite(skillMdPath, params.content)
    const scanErr = await this.securityScan(qPath)
    if (scanErr) {
      await fs.rm(qPath, { recursive: true, force: true })
      await this.logAudit('BLOCKED', params.name, 'create', scanErr)
      return { success: false, error: scanErr }
    }
    await fs.rename(qPath, skillMdPath)

    const hash = await this.computeHash(params.content)
    await this.updateManifest(params.name, {
      name: params.name, category: params.category || '', agent: params.agent,
      version: '1.0.0', description: '', tags: [], created_from: params.taskId,
      times_used: 0, success_rate: null, patch_count: 0,
      origin_hash: hash, current_hash: hash,
      created_at: new Date().toISOString(), updated_at: new Date().toISOString()
    } as any)
    await this.logAudit('CREATED', params.name, 'create', null)
    return { success: true, message: `Skill '${params.name}' created`, path: skillMdPath }
  }

  async patch(params: {
    name: string; old_string: string; new_string: string; file_path?: string; replace_all?: boolean
  }): Promise<{ success: boolean; error?: string; message?: string; match_count?: number }> {
    if (!params.old_string) return { success: false, error: 'old_string required' }
    const existing = await this.findSkill(params.name)
    if (!existing) return { success: false, error: `Skill '${params.name}' not found` }

    const targetPath = params.file_path
      ? path.join(existing.path, params.file_path)
      : path.join(existing.path, 'SKILL.md')

    const content = await fs.readFile(targetPath, 'utf-8')
    const { newContent, matchCount, error } = this.fuzzyReplace(content, params.old_string, params.new_string, params.replace_all || false)
    if (error) return { success: false, error }

    const qPath = await this.quarantineWrite(targetPath, newContent)
    const scanErr = await this.securityScan(qPath)
    if (scanErr) {
      await fs.rm(qPath, { recursive: true, force: true })
      return { success: false, error: scanErr }
    }
    await fs.rename(qPath, targetPath)

    const newHash = await this.computeHash(newContent)
    await this.updateManifest(params.name, {
      updated_at: new Date().toISOString(),
      current_hash: newHash,
      patch_count: (existing.manifest.patch_count || 0) + 1
    } as any)
    return { success: true, message: `Patched (${matchCount} replacement${matchCount>1?'s':''})`, match_count: matchCount }
  }

  async list(): Promise<any[]> {
    const manifest = await this.loadManifest()
    return Object.values(manifest.skills)
  }

  private validateName(name: string): string | null {
    if (!name) return 'Name required'
    if (name.length > SKILL_LIMITS.MAX_NAME_LENGTH) return `Name exceeds ${SKILL_LIMITS.MAX_NAME_LENGTH} chars`
    if (!VALID_NAME_RE.test(name)) return 'Invalid name. Use lowercase, hyphens, dots, underscores'
    return null
  }

  private validateCategory(cat?: string): string | null {
    if (!cat) return null
    if (cat.includes('/')) return 'Category must be single directory name'
    if (!VALID_NAME_RE.test(cat)) return 'Invalid category'
    return null
  }

  private async validateFrontmatter(content: string): Promise<string | null> {
    if (!content.startsWith('---')) return 'SKILL.md must start with YAML frontmatter'
    const endMatch = content.slice(3).match(/\n---\s*\n/)
    if (!endMatch) return 'Frontmatter not closed'
    try {
      const parsed = yaml.parse(content.slice(3, endMatch.index! + 3))
      if (!parsed.name) return 'Frontmatter missing name'
      if (!parsed.description) return 'Frontmatter missing description'
    } catch (e) { return `YAML parse error: ${e}` }
    return null
  }

  private fuzzyReplace(content: string, oldStr: string, newStr: string, replaceAll: boolean) {
    if (content.includes(oldStr)) {
      const cnt = content.split(oldStr).length - 1
      if (cnt > 1 && !replaceAll) return { newContent: content, matchCount: cnt, error: `Found ${cnt} matches. Use replace_all: true or add context.` }
      const nc = replaceAll ? content.replaceAll(oldStr, newStr) : content.replace(oldStr, newStr)
      return { newContent: nc, matchCount: cnt, error: null }
    }
    const normContent = content.replace(/\s+/g, ' ')
    const normOld = oldStr.replace(/\s+/g, ' ')
    if (normContent.includes(normOld)) {
      const words = oldStr.trim().split(/\s+/).map(w => w.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'))
      const re = new RegExp(words.join('\\s+'), 'g')
      const matches = content.match(re)
      if (matches) {
        if (matches.length > 1 && !replaceAll) return { newContent: content, matchCount: matches.length, error: `Found ${matches.length} fuzzy matches. Use replace_all: true.` }
        return { newContent: content.replace(re, newStr), matchCount: matches.length, error: null }
      }
    }
    return { newContent: content, matchCount: 0, error: 'String not found in file' }
  }

  private async securityScan(targetPath: string): Promise<string | null> {
    const files = await this.walkDir(targetPath)
    for (const f of files) {
      const content = (await fs.readFile(f, 'utf-8')).toLowerCase()
      for (const p of INJECTION_PATTERNS) if (content.includes(p)) return `Security: injection pattern "${p}"`
    }
    return null
  }

  private async quarantineWrite(targetPath: string, content: string): Promise<string> {
    await fs.mkdir(this.quarantineDir, { recursive: true })
    const suffix = randomBytes(8).toString('hex')
    const qPath = path.join(this.quarantineDir, `${path.basename(targetPath)}.${suffix}`)
    if (path.basename(targetPath) === 'SKILL.md') {
      const qDir = path.join(this.quarantineDir, `skill.${suffix}`)
      await fs.mkdir(qDir, { recursive: true })
      await fs.writeFile(path.join(qDir, 'SKILL.md'), content, 'utf-8')
      return qDir
    }
    await fs.writeFile(qPath, content, 'utf-8')
    return qPath
  }

  private async loadManifest(): Promise<any> {
    try { return JSON.parse(await fs.readFile(this.manifestPath, 'utf-8')) }
    catch { return { skills: {}, last_updated: new Date().toISOString() } }
  }

  private async updateManifest(name: string, updates: any): Promise<void> {
    const m = await this.loadManifest()
    m.skills[name] = { ...(m.skills[name] || {}), ...updates }
    m.last_updated = new Date().toISOString()
    await fs.mkdir(path.dirname(this.manifestPath), { recursive: true })
    await fs.writeFile(this.manifestPath, JSON.stringify(m, null, 2), 'utf-8')
  }

  private async findSkill(name: string): Promise<{ path: string; manifest: any } | null> {
    const m = await this.loadManifest()
    const e = m.skills[name]
    if (!e) return null
    const p = e.category ? path.join(this.skillsDir, e.category, name) : path.join(this.skillsDir, name)
    try { await fs.access(path.join(p, 'SKILL.md')); return { path: p, manifest: e } }
    catch { return null }
  }

  private async logAudit(action: string, skill: string, op: string, error: string | null): Promise<void> {
    await fs.mkdir(path.dirname(this.auditLogPath), { recursive: true })
    await fs.appendFile(this.auditLogPath, JSON.stringify({ ts: new Date().toISOString(), action, skill, op, error }) + '\n')
  }

  private async computeHash(content: string): Promise<string> {
    return createHash('sha256').update(content).digest('hex')
  }

  private async walkDir(dir: string): Promise<string[]> {
    const files: string[] = []
    const walk = async (d: string) => {
      for (const e of await fs.readdir(d, { withFileTypes: true })) {
        const fp = path.join(d, e.name)
        if (e.isDirectory()) await walk(fp); else files.push(fp)
      }
    }
    await walk(dir); return files
  }
}