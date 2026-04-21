import { TetherMemoryStorage } from './storage.js'
import { HandoffPackage, ArchitecturalDecision } from '@tether/shared-types'

export class TetherHandoffPackager {
  constructor(private storage: TetherMemoryStorage) {}

  async export(projectId: string, projectName: string): Promise<HandoffPackage> {
    const decisions = await this.storage.getDecisions(100)
    const patterns = await this.storage.getPatterns(7)

    const decisionObjects: ArchitecturalDecision[] = decisions.map(d => ({
      id: d.key,
      key: d.key,
      decision: d.insight,
      context: '',
      alternatives: [],
      tradeoffs: [],
      constraints: [],
      confidence: d.confidence,
      verdict: 'HOLD' as const,
      layer: 'logical' as const,
      recorded_at: d.ts,
      recorded_by: d.source
    }))

    return {
      version: '1.0.0',
      exported_at: new Date().toISOString(),
      project: { id: projectId, name: projectName },
      memory: { decisions: decisionObjects, patterns },
      documents: {}
    }
  }

  async import(pkg: HandoffPackage): Promise<number> {
    let count = 0
    for (const decision of pkg.memory.decisions) {
      await this.storage.append({
        type: 'decision',
        key: decision.key,
        insight: decision.decision,
        confidence: decision.confidence,
        source: 'handoff',
        tags: ['imported', decision.layer]
      })
      count++
    }
    for (const pattern of pkg.memory.patterns) {
      await this.storage.append({
        type: 'pattern',
        key: pattern.key,
        insight: pattern.insight,
        confidence: pattern.confidence,
        source: 'handoff',
        tags: ['imported']
      })
      count++
    }
    return count
  }
}
