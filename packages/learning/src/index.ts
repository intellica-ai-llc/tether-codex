import * as fs from 'fs/promises'
import * as path from 'path'
import { TetherMemoryStorage } from '@tether/memory'
import { LearningAttributionRecord, ConfidenceLevel } from '@tether/shared-types'

export class LearningAttributionSystem {
  private attributionsPath: string
  private storage: TetherMemoryStorage

  constructor(projectId: string, basePath: string = '.tether') {
    this.attributionsPath = path.join(basePath, 'learnings', 'attributions')
    this.storage = new TetherMemoryStorage(projectId)
  }

  async record(record: Omit<LearningAttributionRecord, 'id' | 'created_at' | 'status'>): Promise<LearningAttributionRecord> {
    const full: LearningAttributionRecord = {
      id: `lar_${Date.now()}`,
      ...record,
      status: 'pending',
      created_at: new Date().toISOString()
    }
    const filePath = path.join(this.attributionsPath, `${full.id}.json`)
    await fs.writeFile(filePath, JSON.stringify(full, null, 2))
    return full
  }

  async getPending(target_agent?: string): Promise<LearningAttributionRecord[]> {
    const files = await fs.readdir(this.attributionsPath).catch(() => [])
    const records: LearningAttributionRecord[] = []
    for (const file of files.filter(f => f.endsWith('.json'))) {
      const record = JSON.parse(await fs.readFile(path.join(this.attributionsPath, file), 'utf-8'))
      if (record.status === 'pending' && (!target_agent || record.target_agent === target_agent)) {
        records.push(record)
      }
    }
    return records
  }

  async consolidate(id: string): Promise<void> {
    const filePath = path.join(this.attributionsPath, `${id}.json`)
    const record: LearningAttributionRecord = JSON.parse(await fs.readFile(filePath, 'utf-8'))
    record.status = 'consolidated'
    record.consolidated_at = new Date().toISOString()
    await fs.writeFile(filePath, JSON.stringify(record, null, 2))

    const confidenceLevel = Math.min(10, Math.max(1, record.confidence)) as ConfidenceLevel
    await this.storage.append({
      type: 'pattern',
      key: `lar-${record.source_agent}-to-${record.target_agent}`,
      insight: record.prevention,
      confidence: confidenceLevel,
      source: 'agent',
      tags: ['lar', record.source_agent, record.target_agent]
    })
  }

  async reject(id: string, reason: string): Promise<void> {
    const filePath = path.join(this.attributionsPath, `${id}.json`)
    const record = JSON.parse(await fs.readFile(filePath, 'utf-8'))
    record.status = 'rejected'
    await fs.writeFile(filePath, JSON.stringify({ ...record, rejection_reason: reason }, null, 2))
  }
}