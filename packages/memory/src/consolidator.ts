import { TetherMemoryStorage } from './storage.js'
import { TetherMemoryEntry, ConfidenceLevel } from '@tether/shared-types'
import { AUTODREAM_INTERVALS, AUTODREAM_PHASES } from '@tether/config'

export interface ConsolidationResult {
  phase: string
  patternsExtracted: number
  entriesProcessed: number
  causalLinks?: number
}

export class AutoDreamConsolidator {
  private storage: TetherMemoryStorage
  private lastLight: Date = new Date(0)
  private lastREM: Date = new Date(0)
  private lastDeep: Date = new Date(0)

  constructor(storage: TetherMemoryStorage) {
    this.storage = storage
  }

  async tick(): Promise<ConsolidationResult | null> {
    const now = new Date()

    if (now.getTime() - this.lastDeep.getTime() >= AUTODREAM_INTERVALS.DEEP_SLEEP_SECONDS * 1000) {
      const result = await this.deepSleep()
      this.lastDeep = now
      return result
    }
    if (now.getTime() - this.lastREM.getTime() >= AUTODREAM_INTERVALS.REM_SLEEP_SECONDS * 1000) {
      const result = await this.remSleep()
      this.lastREM = now
      return result
    }
    if (now.getTime() - this.lastLight.getTime() >= AUTODREAM_INTERVALS.LIGHT_SLEEP_SECONDS * 1000) {
      const result = await this.lightSleep()
      this.lastLight = now
      return result
    }
    return null
  }

  private async lightSleep(): Promise<ConsolidationResult> {
    const entries = await this.storage.query({ orderBy: 'recency', limit: 100 })
    const patterns = this.extractPatterns(entries)

    for (const pattern of patterns) {
      if (pattern.confidence >= 5) {
        const conf = Math.min(10, Math.max(1, pattern.confidence)) as ConfidenceLevel
        await this.storage.append({
          type: 'pattern',
          key: pattern.key,
          insight: pattern.insight,
          confidence: conf,
          source: 'autoDream',
          tags: ['consolidated', 'light-sleep']
        })
      }
    }
    return { phase: AUTODREAM_PHASES.LIGHT_SLEEP, patternsExtracted: patterns.length, entriesProcessed: entries.length }
  }

  private async remSleep(): Promise<ConsolidationResult> {
    const entries = await this.storage.query({ orderBy: 'recency', limit: 500 })
    const links = this.discoverCausalLinks(entries)

    for (const link of links) {
      const conf = Math.min(10, Math.max(1, link.confidence)) as ConfidenceLevel
      await this.storage.append({
        type: 'observation',
        key: `causal-${link.source}-${link.target}`,
        insight: `${link.source} led to ${link.target}`,
        confidence: conf,
        source: 'autoDream',
        tags: ['causal-link', 'rem-sleep']
      })
    }
    return { phase: AUTODREAM_PHASES.REM_SLEEP, patternsExtracted: 0, entriesProcessed: entries.length, causalLinks: links.length }
  }

  private async deepSleep(): Promise<ConsolidationResult> {
    const entries = await this.storage.query({ orderBy: 'recency', limit: 1000 })
    const consolidated = this.extractPatterns(entries)

    await this.storage.append({
      type: 'observation',
      key: 'deep-sleep-consolidation',
      insight: `Consolidated ${entries.length} entries into memory`,
      confidence: 10 as ConfidenceLevel,
      source: 'autoDream',
      tags: ['consolidation', 'deep-sleep']
    })

    return { phase: AUTODREAM_PHASES.DEEP_SLEEP, patternsExtracted: consolidated.length, entriesProcessed: entries.length }
  }

  private extractPatterns(entries: TetherMemoryEntry[]): { key: string; insight: string; confidence: number }[] {
    const byKey: Record<string, TetherMemoryEntry[]> = {}
    for (const e of entries) {
      if (!byKey[e.key]) byKey[e.key] = []
      byKey[e.key].push(e)
    }
    return Object.entries(byKey)
      .filter(([_, es]) => es.length >= 3)
      .map(([key, es]) => ({
        key,
        insight: es[0].insight,
        confidence: Math.min(10, Math.floor(es.reduce((s, e) => s + e.confidence, 0) / es.length))
      }))
  }

  private discoverCausalLinks(_entries: TetherMemoryEntry[]): { source: string; target: string; confidence: number }[] {
    return []
  }
}
