import { TetherMemoryEntry, MemoryType, ConfidenceLevel } from '@tether/shared-types'

export interface MemoryQueryOptions {
  type?: MemoryType | MemoryType[]
  minConfidence?: ConfidenceLevel
  key?: string
  tags?: string[]
  limit?: number
  orderBy?: 'recency' | 'confidence'
}

export function validateMemoryEntry(entry: Partial<TetherMemoryEntry>): string[] {
  const errors: string[] = []
  if (!entry.ts) errors.push('ts required')
  if (!entry.type) errors.push('type required')
  if (!entry.key) errors.push('key required')
  if (!entry.insight) errors.push('insight required')
  if (!entry.confidence) errors.push('confidence required')
  return errors
}

export function createDecision(key: string, insight: string, _context: string, confidence: ConfidenceLevel): TetherMemoryEntry {
  return {
    ts: new Date().toISOString(),
    type: 'decision',
    key,
    insight,
    confidence,
    source: 'agent',
    tags: ['decision']
  }
}

export function createPattern(key: string, insight: string, confidence: ConfidenceLevel): TetherMemoryEntry {
  return {
    ts: new Date().toISOString(),
    type: 'pattern',
    key,
    insight,
    confidence,
    source: 'agent',
    tags: ['pattern']
  }
}

export function createPitfall(key: string, insight: string): TetherMemoryEntry {
  return {
    ts: new Date().toISOString(),
    type: 'pitfall',
    key,
    insight,
    confidence: 8,
    source: 'agent',
    tags: ['pitfall', 'warning']
  }
}