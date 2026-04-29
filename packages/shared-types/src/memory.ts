import { MemoryType } from './index.js'
export interface MemoryStats { totalEntries: number; byType: Record<MemoryType, number>; byLayer: Record<string, number>; byConfidence: Record<number, number>; averageConfidence: number; oldestEntry: string | null; newestEntry: string | null; storageSizeBytes: number }
export interface ConsolidatedMemory { content: string; generated_at: string; entries_consolidated: number; compression_ratio: number }
export interface LearningAttributionRecord { id: string; source_agent: string; target_agent: string; incident: string; root_cause: string; prevention: string; confidence: number; status: 'pending' | 'consolidated' | 'rejected'; created_at: string; consolidated_at?: string; project_id?: string }
