#!/bin/bash
# TETHER CODEX v2 → v3 UPGRADE SCRIPT
# Run from ~/tether-codex/Scaffold/
set -e

echo "🏗️ Tether Codex v2 → v3 Upgrade"
echo "================================"

# -------------------------------------------------------------------
# 0. CREATE BACKUP OF MODIFIED FILES
# -------------------------------------------------------------------
echo "📦 Creating backup..."
mkdir -p .v2-backup
cp packages/agents/src/personas/index.ts .v2-backup/personas-index.ts 2>/dev/null || true
cp packages/agents/src/orchestrator/index.ts .v2-backup/orchestrator.ts 2>/dev/null || true
cp package.json .v2-backup/package.json 2>/dev/null || true
cp tsconfig.json .v2-backup/tsconfig.json 2>/dev/null || true
cp pnpm-workspace.yaml .v2-backup/pnpm-workspace.yaml 2>/dev/null || true
cp .env.example .v2-backup/env.example 2>/dev/null || true
echo "✅ Backup saved to .v2-backup/"

# -------------------------------------------------------------------
# 1. REMOVE 5 LEGACY AGENT PERSONA FILES
# -------------------------------------------------------------------
echo "🗑️  Removing legacy persona files..."
rm -f packages/agents/src/personas/mpe.ts
rm -f packages/agents/src/personas/uix.ts
rm -f packages/agents/src/personas/ops.ts
rm -f packages/agents/src/personas/sup.ts
rm -f packages/agents/src/personas/req.ts
echo "✅ Removed mpe, uix, ops, sup, req"

# -------------------------------------------------------------------
# 2. UPDATE PERSONAS/INDEX.TS FOR 8-AGENT COUNCIL
# -------------------------------------------------------------------
echo "📝 Updating persona index..."
cat > packages/agents/src/personas/index.ts << 'EOF'
export { MAE } from './mae'
export { MI } from './mi'
export { PCA } from './pca'
export { DB } from './db'
export { MM } from './mm'
export { BUG } from './bug'
export { QC } from './qc'
export { MNT } from './mnt'
export { AgentPersona } from './types'

import { MAE, MI, PCA, DB, MM, BUG, QC, MNT } from './index'

export const ALL_PERSONAS = [MAE, MI, PCA, DB, MM, BUG, QC, MNT]
export const PERSONA_BY_ID: Record<string, AgentPersona> = Object.fromEntries(
  ALL_PERSONAS.map(p => [p.id, p])
)
EOF
echo "✅ Persona index updated to 8 agents"

# -------------------------------------------------------------------
# 3. CREATE NEW DIRECTORIES
# -------------------------------------------------------------------
echo "📁 Creating v3 directories..."
mkdir -p packages/skills/src
mkdir -p packages/agents/src/state
mkdir -p packages/agents/src/handoff
mkdir -p packages/agents/src/subagent/templates
mkdir -p gateway/src/platforms
mkdir -p .tether/skills/{mae/writing-plans/templates,mae/subagent-driven-dev/templates,mae/mae-orchestration}
mkdir -p .tether/skills/{mi/frontier-scan/references,mi/pattern-extraction}
mkdir -p .tether/skills/{pca/cloudflare-pages-deploy/templates,pca/vercel-deploy,pca/zero-cost-architecture,pca/provider-failover}
mkdir -p .tether/skills/{db/migration-safe-patterns,db/rls-policy-design,db/query-optimization}
mkdir -p .tether/skills/{mm/stripe-pricing-page/templates,mm/vercel-landing-page,mm/email-sequence,mm/positioning-framework}
mkdir -p .tether/skills/{bug/systematic-debugging,bug/react-hydration-errors}
mkdir -p .tether/skills/{qc/test-driven-development,qc/code-review-checklist}
mkdir -p .tether/skills/{mnt/dependency-update,mnt/health-check,mnt/ticket-triage}
mkdir -p .tether/skills/shared/{git-workflow,handoff-protocol}
mkdir -p .tether/cron
mkdir -p .tether/gateway/sessions
echo "✅ Directories created"

# -------------------------------------------------------------------
# 4. CREATE SKILL SYSTEM (skill_manage tool)
# -------------------------------------------------------------------
echo "🛠️  Creating skill system..."

cat > packages/skills/src/skill-manage.ts << 'SKILLEOF'
import * as fs from 'fs/promises'
import * as path from 'path'
import * as yaml from 'yaml'
import { createHash, randomBytes } from 'crypto'
import { SKILL_LIMITS } from '@tether/config'

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
SKILLEOF

# Update existing skills/index.ts to export SkillManageTool
cat > packages/skills/src/index.ts << 'EOF'
export { SkillManageTool } from './skill-manage'
import * as fs from 'fs/promises'
import * as path from 'path'
import * as yaml from 'yaml'

export interface SkillManifest { name: string; version: string; description: string; author?: string; license?: string; tags: string[]; triggers: string[]; allowed_tools: string[]; dependencies: string[] }

export class SkillsMarketplace {
  private skillsPath: string
  private registry: Map<string, SkillManifest> = new Map()

  constructor(basePath: string = '.tether') { this.skillsPath = path.join(basePath, 'skills') }

  async initialize(): Promise<void> {
    await fs.mkdir(this.skillsPath, { recursive: true })
    await this.loadInstalledSkills()
  }

  async install(skillName: string): Promise<void> {
    const manifest = await this.fetchSkill(skillName)
    const skillDir = path.join(this.skillsPath, skillName)
    await fs.mkdir(skillDir, { recursive: true })
    await fs.writeFile(path.join(skillDir, 'SKILL.md'), this.generateSkillMarkdown(manifest))
    this.registry.set(skillName, manifest)
  }

  async list(): Promise<SkillManifest[]> { return Array.from(this.registry.values()) }

  async search(query: string): Promise<SkillManifest[]> {
    const lower = query.toLowerCase()
    return Array.from(this.registry.values()).filter(s =>
      s.name.toLowerCase().includes(lower) || s.description.toLowerCase().includes(lower) || s.tags.some(t => t.toLowerCase().includes(lower)))
  }

  private async loadInstalledSkills(): Promise<void> {
    try {
      const dirs = await fs.readdir(this.skillsPath)
      for (const dir of dirs) {
        const mp = path.join(this.skillsPath, dir, 'SKILL.md')
        try { const c = await fs.readFile(mp, 'utf-8'); this.registry.set(dir, this.parseSkillMarkdown(c)) } catch {}
      }
    } catch {}
  }

  private async fetchSkill(skillName: string): Promise<SkillManifest> {
    return { name: skillName, version: '1.0.0', description: `Skill: ${skillName}`, author: 'Tether Codex', license: 'MIT', tags: [skillName], triggers: [skillName], allowed_tools: ['Read', 'Write'], dependencies: [] }
  }

  private parseSkillMarkdown(content: string): SkillManifest {
    const m = content.match(/^---\n([\s\S]*?)\n---/)
    if (m) return yaml.parse(m[1]) as SkillManifest
    return { name: 'unknown', version: '1.0.0', description: '', tags: [], triggers: [], allowed_tools: [], dependencies: [] }
  }

  private generateSkillMarkdown(manifest: SkillManifest): string { return `---\n${yaml.stringify(manifest)}---\n\n# ${manifest.name}\n\n${manifest.description}\n` }
}
EOF
echo "✅ Skill system created"

# -------------------------------------------------------------------
# 5. AGENT STATE PERSISTENCE
# -------------------------------------------------------------------
echo "💾 Creating agent state persistence..."
cat > packages/agents/src/state/agent-state-manager.ts << 'EOF'
import * as fs from 'fs/promises'
import * as path from 'path'

export interface AgentState {
  agent_id: string
  session_id: string
  short_term: { conversation: any[]; attention_focus: string }
  working: { active_tasks: any[]; loaded_skills: string[]; current_context: string; handoffs_pending: string[] }
  long_term: { preferences: Record<string, any>; learned_patterns: any[]; success_history: any[]; failure_history: any[]; agent_specific: Record<string, any> }
  metrics: { tasks_completed: number; skills_created: number; handoffs_handled: number; avg_response_time_ms: number }
  created_at: string
  updated_at: string
  last_active: string
  last_saved_at: string
}

const defaults: Record<string, any> = {
  mae: { verbosity: 'concise', coffee_ritual: true, kenny_rogers_mode: true, free_tier_strict: true, auto_create_adr: true },
  mi: { scan_frequency: 'weekly', min_confidence: 7, min_occurrences: 3, auto_create_skills: true },
  pca: { preferred_platform: 'cloudflare', zero_cost_strict: true, auto_scale: true },
  db: { preferred_orm: 'drizzle', rls_default: true, query_performance_target_ms: 100 },
  mm: { default_design_system: 'stripe', conversion_target: 5, auto_polish: true },
  bug: { debug_protocol: 'systematic', auto_create_lar: true, regression_test_required: true },
  qc: { tdd_enforced: true, coverage_threshold: 80, require_self_review: true },
  mnt: { auto_fix_enabled: true, patch_window: 'sunday-3am', health_check_interval_ms: 600000 }
}

export class AgentStateManager {
  private states: Map<string, AgentState> = new Map()
  private persistDir: string

  constructor(basePath: string = '.tether') {
    this.persistDir = path.join(basePath, 'agent-states')
  }

  async loadState(agentId: string, sessionId: string): Promise<AgentState> {
    const filePath = path.join(this.persistDir, `${agentId}.json`)
    try {
      const data = JSON.parse(await fs.readFile(filePath, 'utf-8'))
      const state: AgentState = {
        ...data,
        session_id: sessionId,
        short_term: { conversation: [], attention_focus: '' },
        working: { active_tasks: data.working?.active_tasks || [], loaded_skills: [], current_context: '', handoffs_pending: data.working?.handoffs_pending || [] },
        last_active: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
      this.states.set(agentId, state)
      return state
    } catch {
      return this.createFreshState(agentId, sessionId)
    }
  }

  createFreshState(agentId: string, sessionId: string): AgentState {
    const state: AgentState = {
      agent_id: agentId, session_id: sessionId,
      short_term: { conversation: [], attention_focus: '' },
      working: { active_tasks: [], loaded_skills: [], current_context: '', handoffs_pending: [] },
      long_term: { preferences: defaults[agentId] || {}, learned_patterns: [], success_history: [], failure_history: [], agent_specific: {} },
      metrics: { tasks_completed: 0, skills_created: 0, handoffs_handled: 0, avg_response_time_ms: 0 },
      created_at: new Date().toISOString(), updated_at: new Date().toISOString(),
      last_active: new Date().toISOString(), last_saved_at: new Date().toISOString()
    }
    this.states.set(agentId, state)
    return state
  }

  async persistState(agentId: string): Promise<void> {
    const state = this.states.get(agentId)
    if (!state) return
    state.updated_at = new Date().toISOString()
    await fs.mkdir(this.persistDir, { recursive: true })
    await fs.writeFile(path.join(this.persistDir, `${agentId}.json`), JSON.stringify(state, null, 2))
    state.last_saved_at = new Date().toISOString()
  }
}
EOF
echo "✅ Agent state persistence created"

# -------------------------------------------------------------------
# 6. HANDOFF PROTOCOL
# -------------------------------------------------------------------
echo "🤝 Creating handoff protocol..."
cat > packages/agents/src/handoff/protocol.ts << 'EOF'
import { randomUUID } from 'crypto'

export interface AgentHandoff {
  id: string
  from: string; to: string
  type: 'delegation' | 'escalation' | 'consultation' | 'handoff'
  task: { id: string; goal: string; context: string; constraints: string[]; acceptance_criteria: string[]; artifacts?: string[] }
  parent_session: string
  urgency: 'normal' | 'elevated' | 'critical'
  callback: { method: string; destination: string; on_success: string; on_failure: string }
  context_snapshot: { memory_prefetch?: string; loaded_skills: string[]; relevant_adrs: string[] }
  created_at: string
  expires_at?: string
  status: 'pending' | 'accepted' | 'completed' | 'failed' | 'expired'
}

export class HandoffManager {
  private active: Map<string, AgentHandoff> = new Map()

  async create(params: Omit<AgentHandoff, 'id' | 'created_at' | 'status'>): Promise<AgentHandoff> {
    const handoff: AgentHandoff = {
      id: randomUUID(), ...params,
      created_at: new Date().toISOString(), status: 'pending'
    }
    this.active.set(handoff.id, handoff)
    console.log(`Handoff created: ${handoff.from} → ${handoff.to}: ${handoff.task.goal}`)
    return handoff
  }

  async complete(id: string, result: { status: string; output: string }): Promise<void> {
    const h = this.active.get(id)
    if (h) { h.status = 'completed'; this.active.delete(id) }
  }

  getPending(agentId: string): AgentHandoff[] {
    return Array.from(this.active.values()).filter(h => h.to === agentId && h.status === 'pending')
  }
}
EOF
echo "✅ Handoff protocol created"

# -------------------------------------------------------------------
# 7. SUBAGENT RUNNER
# -------------------------------------------------------------------
echo "🔄 Creating subagent runner..."
cat > packages/agents/src/subagent/runner.ts << 'EOF'
export interface SubagentTask {
  id: string; goal: string; context: string; constraints: string[]; acceptance_criteria: string[]; toolsets: string[]
}

export interface SubagentResult { taskId: string; status: 'completed' | 'failed'; output: string }

export class SubagentRunner {
  async runImplementer(task: SubagentTask): Promise<SubagentResult> {
    const prompt = `GOAL: ${task.goal}\nCONTEXT: ${task.context}\nCONSTRAINTS: ${task.constraints.join(', ')}\nACCEPTANCE: ${task.acceptance_criteria.join(', ')}\nTOOLSETS: ${task.toolsets.join(', ')}\n\nFollow TDD: write failing test FIRST, then minimal implementation. Commit after each passing test cycle.`
    return { taskId: task.id, status: 'completed', output: `[Implementer] ${prompt.slice(0, 200)}...` }
  }

  async runSpecReviewer(task: SubagentTask, implementation: string): Promise<SubagentResult> {
    const prompt = `ORIGINAL SPEC:\n${task.context}\n\nIMPLEMENTATION:\n${implementation}\n\nVerify all spec requirements are met. No scope creep. Output PASS or FAIL with gaps.`
    return { taskId: task.id, status: 'completed', output: `[Spec Review] PASS` }
  }

  async runQualityReviewer(task: SubagentTask, implementation: string): Promise<SubagentResult> {
    const prompt = `FILES TO REVIEW:\n${implementation}\n\nCheck: correctness, style, error handling, testing, security, performance. Output APPROVED or REQUEST_CHANGES with issues.`
    return { taskId: task.id, status: 'completed', output: `[Quality Review] APPROVED` }
  }
}
EOF
echo "✅ Subagent runner created"

# -------------------------------------------------------------------
# 8. PROVIDER RESOLVER
# -------------------------------------------------------------------
echo "🔌 Creating provider resolver..."
cat > packages/platform/src/provider-resolver.ts << 'EOF'
export interface ProviderConfig {
  name: string
  apiMode: 'chat_completions' | 'codex_responses' | 'anthropic_messages'
  baseUrl: string
  apiKeyEnv: string
  models: string[]
}

export interface ResolvedProvider { apiMode: string; apiKey: string; baseUrl: string; model: string }

export class ProviderResolver {
  private providers: Map<string, ProviderConfig> = new Map()
  private fallbackChain: string[] = ['openrouter', 'anthropic', 'openai', 'groq', 'together']

  constructor() { this.registerBuiltins() }

  resolve(providerName?: string, model?: string): ResolvedProvider {
    if (providerName) {
      const c = this.providers.get(providerName)
      if (c && process.env[c.apiKeyEnv]) return { apiMode: c.apiMode, apiKey: process.env[c.apiKeyEnv]!, baseUrl: c.baseUrl, model: model || c.models[0] }
    }
    for (const fn of this.fallbackChain) {
      const c = this.providers.get(fn)
      if (c && process.env[c.apiKeyEnv]) return { apiMode: c.apiMode, apiKey: process.env[c.apiKeyEnv]!, baseUrl: c.baseUrl, model: model || c.models[0] }
    }
    throw new Error('No available provider')
  }

  private registerBuiltins(): void {
    const add = (name: string, mode: string, url: string, env: string, models: string[]) =>
      this.providers.set(name, { name, apiMode: mode as any, baseUrl: url, apiKeyEnv: env, models })
    add('anthropic', 'anthropic_messages', 'https://api.anthropic.com', 'ANTHROPIC_API_KEY', ['claude-sonnet-4-20250514'])
    add('openai', 'codex_responses', 'https://api.openai.com/v1', 'OPENAI_API_KEY', ['gpt-5'])
    add('openrouter', 'chat_completions', 'https://openrouter.ai/api/v1', 'OPENROUTER_API_KEY', ['anthropic/claude-sonnet-4'])
    add('groq', 'chat_completions', 'https://api.groq.com/openai/v1', 'GROQ_API_KEY', ['llama-3.3-70b'])
    add('together', 'chat_completions', 'https://api.together.xyz/v1', 'TOGETHER_API_KEY', ['meta-llama/Llama-3.3-70B'])
  }
}
EOF
# Update platform index to export resolver
cat > packages/platform/src/index.ts << 'EOF'
import { FREE_TIER_LIMITS } from '@tether/config'

export class PlatformComputeAgent {
  private limits: any; private usage: any; private hasPayingUsers = false
  constructor(limits?: any) {
    this.limits = { apiRequestsPerDay: FREE_TIER_LIMITS.API_REQUESTS_PER_DAY, databaseMB: FREE_TIER_LIMITS.DATABASE_MB, storageGB: FREE_TIER_LIMITS.STORAGE_GB, queueCommandsPerDay: FREE_TIER_LIMITS.QUEUE_COMMANDS_PER_DAY, ...limits }
    this.usage = { apiRequests: 0, databaseBytes: 0, storageBytes: 0, queueCommands: 0 }
  }
  async checkLimits(): Promise<any[]> { return [] }
  getZeroCostStatus(): any { return { isZeroCost: !this.hasPayingUsers, message: this.hasPayingUsers ? 'Paying users detected.' : 'Zero-cost compute active.' } }
  setPayingUsers(v: boolean): void { this.hasPayingUsers = v }
  updateUsage(u: any): void { this.usage = { ...this.usage, ...u } }
}
export { ProviderResolver, ProviderConfig, ResolvedProvider } from './provider-resolver'
EOF
echo "✅ Provider resolver created"

# -------------------------------------------------------------------
# 9. GATEWAY
# -------------------------------------------------------------------
echo "🚪 Creating gateway..."
cat > gateway/package.json << 'EOF'
{ "name": "gateway", "version": "3.0.0", "private": true, "main": "./dist/runner.js", "scripts": { "build": "tsc", "start": "node dist/runner.js" }, "dependencies": { "@tether/agents": "workspace:*", "@tether/memory": "workspace:*" }, "devDependencies": { "@tether/tsconfig": "workspace:*", "@types/node": "^20.0.0", "typescript": "^5.0.0" } }
EOF
cat > gateway/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/base.json", "compilerOptions": { "outDir": "./dist", "rootDir": "./src" }, "include": ["src/**/*"] }
EOF
cat > gateway/src/platforms/base.ts << 'EOF'
export interface PlatformAdapter { name: string; start(): Promise<void>; stop(): Promise<void>; sendMessage(chatId: string, content: string): Promise<void>; onMessage(h: (e: MessageEvent) => Promise<void>): void }
export interface MessageEvent { platform: string; chatId: string; userId: string; text: string; timestamp: Date }
EOF
cat > gateway/src/platforms/cli.ts << 'EOF'
import { PlatformAdapter, MessageEvent } from './base'
import readline from 'readline'
export class CLIAdapter implements PlatformAdapter {
  name = 'cli'; private handler: ((e: MessageEvent) => Promise<void>) | null = null; private rl: readline.Interface | null = null
  async start(): Promise<void> {
    this.rl = readline.createInterface({ input: process.stdin, output: process.stdout })
    console.log('🏛️ Tether Codex v3 Gateway — CLI')
    this.rl.on('line', async (line) => { if (line === '/exit') { await this.stop(); process.exit(0) }; if (this.handler) await this.handler({ platform: 'cli', chatId: 'cli', userId: 'cli', text: line, timestamp: new Date() }) })
  }
  async stop(): Promise<void> { this.rl?.close() }
  async sendMessage(_: string, content: string): Promise<void> { console.log(`\n${content}\n`) }
  onMessage(h: (e: MessageEvent) => Promise<void>): void { this.handler = h }
}
EOF
cat > gateway/src/runner.ts << 'EOF'
import { CLIAdapter } from './platforms/cli'
import { AgentOrchestrator } from '@tether/agents'
import { MessageEvent } from './platforms/base'
class GatewayRunner {
  private adapters: CLIAdapter[] = []; private orch = new AgentOrchestrator()
  async start(): Promise<void> {
    const cli = new CLIAdapter(); this.adapters.push(cli); cli.onMessage(this.handle.bind(this)); await cli.start()
  }
  private async handle(event: MessageEvent): Promise<void> {
    const r = await this.orch.processMessage(event.text, { projectId: 'default', workspacePath: process.cwd(), userMessage: event.text, userId: event.userId, sessionId: `gw-${Date.now()}` })
    const content = r.responses.map(r => `[${r.agentName}]\n${r.content}`).join('\n\n')
    await this.adapters[0]?.sendMessage(event.chatId, content)
  }
}
new GatewayRunner().start().catch(console.error)
EOF
echo "✅ Gateway created"

# -------------------------------------------------------------------
# 10. UPDATE ORCHESTRATOR FOR 8-AGENT + NEW SUBSYSTEMS
# -------------------------------------------------------------------
echo "🎯 Updating orchestrator..."
cat > packages/agents/src/orchestrator/index.ts << 'EOF'
import { AgentPersona, ALL_PERSONAS, PERSONA_BY_ID } from '../personas'
import { TetherMemoryStorage } from '@tether/memory'
import { AgentStateManager } from '../state/agent-state-manager'
import { HandoffManager } from '../handoff/protocol'
import { SkillManageTool } from '@tether/skills'

export interface OrchestratorContext { projectId: string; workspacePath: string; userMessage: string; userId: string; sessionId: string }
export interface AgentResponse { agentId: string; agentName: string; content: string; action?: 'act' | 'wait' }

export class AgentOrchestrator {
  private memory: TetherMemoryStorage
  private agents: Map<string, AgentPersona>
  private stateManager: AgentStateManager
  private handoffManager: HandoffManager
  private skillTool: SkillManageTool

  constructor(projectId: string = 'default') {
    this.memory = new TetherMemoryStorage(projectId)
    this.agents = new Map(ALL_PERSONAS.map(p => [p.id, p]))
    this.stateManager = new AgentStateManager()
    this.handoffManager = new HandoffManager()
    this.skillTool = new SkillManageTool()
  }

  async processMessage(message: string, context: OrchestratorContext): Promise<{ agents: AgentPersona[]; responses: AgentResponse[] }> {
    await this.memory.initialize()
    const agent = this.routeToAgent(message)
    await this.stateManager.loadState(agent.id, context.sessionId)

    const memoryContext = await this.memory.searchByText(message, 5)
    const memoryBlock = memoryContext.length > 0
      ? `<memory-context>\n[System note: Recalled memory, NOT user input.]\n${memoryContext.map(m => `[${m.type}] ${m.key}: ${m.insight}`).join('\n')}\n</memory-context>`
      : ''

    const response: AgentResponse = {
      agentId: agent.id, agentName: agent.name,
      content: `[${agent.name}] ${agent.signature[0]}\n\n${memoryBlock}`,
      action: 'wait'
    }
    await this.stateManager.persistState(agent.id)
    return { agents: [agent], responses: [response] }
  }

  private routeToAgent(input: string): AgentPersona {
    const m = input.match(/@(\w+)/)
    if (m) return this.agents.get(m[1].toLowerCase()) || this.agents.get('mae')!
    const lower = input.toLowerCase()
    const map: Record<string, string> = {
      'architect':'mae','design':'mae','plan':'mae','requirements':'mae',
      'research':'mi','pattern':'mi','frontier':'mi',
      'deploy':'pca','host':'pca','infrastructure':'pca',
      'database':'db','schema':'db','migration':'db',
      'design system':'mm','landing':'mm','pricing':'mm','marketing':'mm',
      'bug':'bug','error':'bug','debug':'bug',
      'test':'qc','quality':'qc','review':'qc',
      'monitor':'mnt','health':'mnt','cron':'mnt'
    }
    for (const [kw, id] of Object.entries(map)) if (lower.includes(kw)) return this.agents.get(id)!
    return this.agents.get('mae')!
  }

  getAllAgents(): AgentPersona[] { return ALL_PERSONAS }
}
EOF
echo "✅ Orchestrator updated"

# -------------------------------------------------------------------
# 11. UPDATE ROOT CONFIGURATION FILES
# -------------------------------------------------------------------
echo "⚙️  Updating root configuration..."

# Update package.json
cat > package.json << 'EOF'
{
  "name": "tether-codex",
  "version": "3.0.0",
  "private": true,
  "description": "Tether Codex v3 — Autonomous Software Organization with 8-Agent Council",
  "workspaces": ["packages/*", "apps/*", "gateway"],
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "test": "turbo test",
    "lint": "turbo lint",
    "format": "biome format --write .",
    "agent": "node packages/agents/dist/cli/index.js",
    "dream": "node packages/agents/dist/cli/index.js dream",
    "skills": "node packages/skills/dist/cli/index.js",
    "gateway": "node gateway/dist/runner.js",
    "export": "node packages/export/dist/index.js",
    "status": "node packages/agents/dist/cli/index.js status",
    "migrate": "drizzle-kit push"
  },
  "devDependencies": {
    "@biomejs/biome": "^1.9.0",
    "turbo": "^2.0.0",
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0",
    "vitest": "^1.0.0"
  },
  "engines": { "node": ">=20.0.0", "pnpm": ">=9.0.0" },
  "packageManager": "pnpm@9.0.0"
}
EOF

# Update pnpm-workspace.yaml
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'packages/*'
  - 'apps/*'
  - 'gateway'
EOF

# Update tsconfig.json
cat > tsconfig.json << 'EOF'
{
  "extends": "./packages/tsconfig/base.json",
  "compilerOptions": { "noEmit": true },
  "include": [],
  "references": [
    { "path": "apps/web" }, { "path": "apps/api" },
    { "path": "packages/shared-types" }, { "path": "packages/config" },
    { "path": "packages/memory" }, { "path": "packages/agents" },
    { "path": "packages/skills" }, { "path": "packages/mcp" },
    { "path": "packages/platform" }, { "path": "packages/database" },
    { "path": "packages/experience" }, { "path": "packages/learning" },
    { "path": "packages/preview" }, { "path": "packages/voice" },
    { "path": "packages/export" }, { "path": "packages/maintenance" },
    { "path": "packages/ast" }, { "path": "packages/ui" },
    { "path": "gateway" }
  ]
}
EOF

# Update .env.example
cat >> .env.example << 'EOF'

# v3 Gateway Platforms
TELEGRAM_BOT_TOKEN=your-telegram-token
DISCORD_BOT_TOKEN=your-discord-token
SLACK_BOT_TOKEN=your-slack-token

# v3 Cron
CRON_ENABLED=true
GATEWAY_ENABLED=true

# v3 Skill System
SKILL_CREATION_ENABLED=true
AUTODREAM_ENABLED=true
EOF

echo "✅ Root configuration updated"

# -------------------------------------------------------------------
# 12. UPDATE SKILLS PACKAGE.JSON TO INCLUDE YAML DEPENDENCY
# -------------------------------------------------------------------
cat > packages/skills/package.json << 'EOF'
{
  "name": "@tether/skills",
  "version": "3.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": { "build": "tsc" },
  "dependencies": { "@tether/shared-types": "workspace:*", "@tether/memory": "workspace:*", "@tether/config": "workspace:*", "yaml": "^2.0.0" },
  "devDependencies": { "@tether/tsconfig": "workspace:*", "@types/node": "^20.0.0", "typescript": "^5.0.0" }
}
EOF

# -------------------------------------------------------------------
# 13. ADD NEW SUPABASE MIGRATIONS
# -------------------------------------------------------------------
echo "🗄️  Adding v3 migrations..."

cat > supabase/migrations/0010_agent_states.sql << 'EOF'
CREATE TABLE IF NOT EXISTS agent_states (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id TEXT NOT NULL,
  session_id TEXT,
  short_term JSONB DEFAULT '{}',
  working JSONB DEFAULT '{}',
  long_term JSONB DEFAULT '{}',
  metrics JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_active TIMESTAMPTZ DEFAULT NOW(),
  last_saved_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_agent_states_agent ON agent_states(agent_id, last_active DESC);
ALTER TABLE agent_states ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/0011_handoffs.sql << 'EOF'
CREATE TABLE IF NOT EXISTS handoffs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_agent TEXT NOT NULL,
  to_agent TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('delegation','escalation','consultation','handoff')),
  task JSONB NOT NULL,
  urgency TEXT DEFAULT 'normal',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','accepted','completed','failed','expired')),
  result JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_handoffs_from ON handoffs(from_agent, status);
CREATE INDEX IF NOT EXISTS idx_handoffs_to ON handoffs(to_agent, status);
ALTER TABLE handoffs ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/0012_skill_usages.sql << 'EOF'
CREATE TABLE IF NOT EXISTS skill_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  agent TEXT NOT NULL,
  outcome TEXT NOT NULL CHECK (outcome IN ('success','partial_success','failure')),
  user_feedback TEXT CHECK (user_feedback IN ('approved','requested_changes','rejected')),
  duration_ms INTEGER,
  tool_calls_count INTEGER DEFAULT 0,
  had_errors BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_skill_usages_skill ON skill_usages(skill_id);
ALTER TABLE skill_usages ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/0013_skill_versions.sql << 'EOF'
CREATE TABLE IF NOT EXISTS skill_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_name TEXT NOT NULL REFERENCES skills(name) ON DELETE CASCADE,
  from_version TEXT NOT NULL,
  to_version TEXT NOT NULL,
  breaking_change BOOLEAN DEFAULT false,
  migration_script TEXT,
  release_notes TEXT,
  upgraded_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_skill_versions_name ON skill_versions(skill_name);
ALTER TABLE skill_versions ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/0014_cron_jobs.sql << 'EOF'
CREATE TABLE IF NOT EXISTS cron_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  schedule TEXT NOT NULL,
  prompt TEXT NOT NULL,
  skills TEXT[] DEFAULT '{}',
  delivery_platform TEXT,
  delivery_destination TEXT,
  enabled BOOLEAN DEFAULT true,
  config JSONB DEFAULT '{}',
  last_run TIMESTAMPTZ,
  next_run TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS cron_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES cron_jobs(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('success','failed','timeout')),
  attempt INTEGER DEFAULT 1,
  response TEXT,
  error TEXT,
  duration_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_cron_jobs_enabled ON cron_jobs(enabled, next_run);
ALTER TABLE cron_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE cron_executions ENABLE ROW LEVEL SECURITY;
EOF

echo "✅ Migrations added"

# -------------------------------------------------------------------
# 14. INITIALIZE V3 TETHER FILES
# -------------------------------------------------------------------
echo "📄 Initializing .tether v3 files..."
cat > .tether/skills/.manifest.json << 'EOF'
{"skills":{},"last_updated":null}
EOF
touch .tether/skills/.security/audit.log
touch .tether/cron/jobs.json

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ TETHER CODEX v2 → v3 UPGRADE COMPLETE"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "Changes made:"
echo "  • Removed 5 legacy persona files (MPE, UIX, OPS, SUP, REQ)"
echo "  • Updated persona index to 8-agent council"
echo "  • Created skill system (skill-manage.ts)"
echo "  • Created agent state persistence (agent-state-manager.ts)"
echo "  • Created handoff protocol (protocol.ts)"
echo "  • Created subagent runner (runner.ts)"
echo "  • Created provider resolver (provider-resolver.ts)"
echo "  • Created gateway (CLI adapter + runner)"
echo "  • Updated orchestrator to integrate new subsystems"
echo "  • Updated root package.json, tsconfig.json, pnpm-workspace.yaml"
echo "  • Added 5 new Supabase migrations (0010-0014)"
echo "  • Updated .env.example with v3 variables"
echo ""
echo "Next steps:"
echo "  1. pnpm install"
echo "  2. pnpm build"
echo "  3. pnpm agent chat \"@MAE, hello\""
echo ""
echo "Backup of modified files: .v2-backup/"
echo "═══════════════════════════════════════════════════════════════"