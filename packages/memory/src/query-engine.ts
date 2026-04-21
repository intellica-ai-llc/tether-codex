import { TetherMemoryStorage } from './storage.js'

export class TetherMemoryQueryEngine {
  constructor(private storage: TetherMemoryStorage) {}

  async getContextForCapability(capability: 'architecture' | 'implementation' | 'debugging' | 'planning'): Promise<string> {
    const sections: string[] = []

    switch (capability) {
      case 'architecture':
        const consolidated = await this.storage.getConsolidated()
        if (consolidated) sections.push(consolidated.slice(0, 2000))
        const decisions = await this.storage.getDecisions(10)
        if (decisions.length) sections.push('## Key Decisions\n' + decisions.map(d => `- ${d.key}: ${d.insight}`).join('\n'))
        break
      case 'implementation':
        const patterns = await this.storage.getPatterns(7)
        if (patterns.length) sections.push('## Proven Patterns\n' + patterns.map(p => `- ${p.key}: ${p.insight}`).join('\n'))
        const pitfalls = await this.storage.getPitfalls(10)
        if (pitfalls.length) sections.push('## Pitfalls to Avoid\n' + pitfalls.map(p => `- ${p.key}: ${p.insight}`).join('\n'))
        break
      case 'debugging':
        const recentPitfalls = await this.storage.getPitfalls(20)
        if (recentPitfalls.length) sections.push('## Known Pitfalls\n' + recentPitfalls.map(p => `- ${p.key}: ${p.insight}`).join('\n'))
        break
      case 'planning':
        const openQuestions = await this.storage.query({ type: 'question', limit: 20 })
        if (openQuestions.length) sections.push('## Open Questions\n' + openQuestions.map(q => `- ${q.key}: ${q.insight}`).join('\n'))
        break
    }

    return sections.join('\n\n')
  }
}
