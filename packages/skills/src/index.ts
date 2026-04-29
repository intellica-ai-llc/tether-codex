export { SkillManageTool } from './skill-manage.js'
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
