import { createClient, SupabaseClient } from '@supabase/supabase-js'
import type { TetherMemoryEntry } from '@tether/shared-types'
import type { MemoryQueryOptions } from './schema.js'

export class SupabaseMemoryStorage {
  private supabase: SupabaseClient
  private projectId: string

  constructor(projectId: string, supabaseUrl: string, supabaseKey: string) {
    this.supabase = createClient(supabaseUrl, supabaseKey)
    this.projectId = projectId
  }

  async append(entry: Omit<TetherMemoryEntry, 'ts'> & { ts?: string }): Promise<TetherMemoryEntry> {
    const fullEntry: TetherMemoryEntry = { ts: new Date().toISOString(), ...entry }
    const { error } = await this.supabase.from('learnings').insert({
      project_id: this.projectId, ...fullEntry
    })
    if (error) throw new Error(`Failed to append learning: ${error.message}`)
    return fullEntry
  }

  async query(options: MemoryQueryOptions = {}): Promise<TetherMemoryEntry[]> {
    let query = this.supabase.from('learnings').select('*').eq('project_id', this.projectId)
    if (options.type) {
      const types = Array.isArray(options.type) ? options.type : [options.type]
      query = query.in('type', types)
    }
    if (options.minConfidence) query = query.gte('confidence', options.minConfidence)
    if (options.key) query = query.eq('key', options.key)
    if (options.tags?.length) query = query.contains('tags', options.tags)
    if (options.limit) query = query.limit(options.limit)
    query = query.order(options.orderBy === 'confidence' ? 'confidence' : 'ts', { ascending: options.orderBy !== 'confidence' })
    const { data, error } = await query
    if (error) throw new Error(`Failed to query learnings: ${error.message}`)
    return (data || []).map(this.mapRow)
  }

  async getDecisions(limit = 50): Promise<TetherMemoryEntry[]> { return this.query({ type: 'decision', orderBy: 'recency', limit }) }
  async getPatterns(minConfidence: 7): Promise<TetherMemoryEntry[]> { return this.query({ type: 'pattern', minConfidence, orderBy: 'confidence' }) }
  async getPitfalls(limit = 30): Promise<TetherMemoryEntry[]> { return this.query({ type: 'pitfall', orderBy: 'recency', limit }) }
  async searchByText(q: string, limit = 20): Promise<TetherMemoryEntry[]> {
    const { data, error } = await this.supabase.from('learnings').select('*')
      .eq('project_id', this.projectId)
      .or(`key.ilike.%${q}%,insight.ilike.%${q}%`)
      .limit(limit)
    if (error) throw new Error(`Failed to search learnings: ${error.message}`)
    return (data || []).map(this.mapRow)
  }
  async getConsolidated() { return null }

  private mapRow(row: any): TetherMemoryEntry {
    return { ts: row.ts, type: row.type, key: row.key, insight: row.insight,
      confidence: row.confidence, source: row.source,
      architectural_layer: row.architectural_layer,
      decision_context: row.decision_context,
      alternatives_considered: row.alternatives_considered || [],
      constraints_applied: row.constraints_applied || [],
      relates_to: row.relates_to || [], tags: row.tags || [] }
  }
}
