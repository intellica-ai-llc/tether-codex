import * as fs from 'fs/promises'
import * as path from 'path'
import { TetherMemoryEntry } from '@tether/shared-types'
import { MemoryQueryOptions } from './schema.js'

export class TetherMemoryStorage {
  private memoryDir: string
  private learningsFile: string
  private consolidatedFile: string

  constructor(projectId: string, basePath: string = '.tether') {
    this.memoryDir = path.join(basePath, 'memory', projectId)
    this.learningsFile = path.join(this.memoryDir, 'learnings.jsonl')
    this.consolidatedFile = path.join(this.memoryDir, 'consolidated.md')
  }

  async initialize(): Promise<void> {
    await fs.mkdir(this.memoryDir, { recursive: true })
    try { await fs.access(this.learningsFile) } catch { await fs.writeFile(this.learningsFile, '') }
  }

  async append(entry: Omit<TetherMemoryEntry, 'ts'> & { ts?: string }): Promise<TetherMemoryEntry> {
    const fullEntry: TetherMemoryEntry = { ts: new Date().toISOString(), ...entry }
    const line = JSON.stringify(fullEntry) + '\n'
    await fs.appendFile(this.learningsFile, line, 'utf-8')
    return fullEntry
  }

  async query(options: MemoryQueryOptions = {}): Promise<TetherMemoryEntry[]> {
    const entries = await this.readAll()
    let filtered = entries

    if (options.type) {
      const types = Array.isArray(options.type) ? options.type : [options.type]
      filtered = filtered.filter(e => types.includes(e.type))
    }
    if (options.minConfidence !== undefined) {
      filtered = filtered.filter(e => e.confidence >= options.minConfidence!)
    }
    if (options.key) filtered = filtered.filter(e => e.key === options.key)
    if (options.tags) filtered = filtered.filter(e => options.tags!.some(t => e.tags.includes(t)))

    filtered.sort((a, b) => options.orderBy === 'confidence' ? b.confidence - a.confidence : b.ts.localeCompare(a.ts))
    return filtered.slice(0, options.limit || 50)
  }

  async getDecisions(limit: number = 50): Promise<TetherMemoryEntry[]> {
    return this.query({ type: 'decision', orderBy: 'recency', limit })
  }

  async getPatterns(minConfidence: 7): Promise<TetherMemoryEntry[]> {
    return this.query({ type: 'pattern', minConfidence, orderBy: 'confidence' })
  }

  async getPitfalls(limit: number = 30): Promise<TetherMemoryEntry[]> {
    return this.query({ type: 'pitfall', orderBy: 'recency', limit })
  }

  async searchByText(query: string, limit: number = 20): Promise<TetherMemoryEntry[]> {
    const entries = await this.readAll()
    const q = query.toLowerCase()
    const scored = entries.map(e => {
      let score = 0
      if (e.key.toLowerCase().includes(q)) score += 10
      if (e.insight.toLowerCase().includes(q)) score += 5
      if (e.tags.some(t => t.toLowerCase().includes(q))) score += 3
      return { entry: e, score }
    })
    return scored.filter(s => s.score > 0).sort((a, b) => b.score - a.score).slice(0, limit).map(s => s.entry)
  }

  async getConsolidated(): Promise<string | null> {
    try { return await fs.readFile(this.consolidatedFile, 'utf-8') } catch { return null }
  }

  async saveConsolidated(content: string): Promise<void> {
    await fs.writeFile(this.consolidatedFile, content, 'utf-8')
  }

  private async readAll(): Promise<TetherMemoryEntry[]> {
    try {
      const content = await fs.readFile(this.learningsFile, 'utf-8')
      return content.split('\n').filter(l => l.trim()).map(l => JSON.parse(l)).reverse()
    } catch { return [] }
  }
}
