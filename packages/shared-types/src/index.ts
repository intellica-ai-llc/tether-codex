export type MemoryType = 'pattern' | 'decision' | 'constraint' | 'pitfall' | 'observation' | 'architecture' | 'risk' | 'tradeoff' | 'question' | 'milestone'
export type ConfidenceLevel = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10
export type AgentPhase = 'discovery' | 'architecture' | 'implementation' | 'deployment' | 'maintenance' | 'support'
export type GateStatus = 'pending' | 'passed' | 'failed'
export type KennyRogersVerdict = 'HOLD' | 'FOLD' | 'WALK_AWAY' | 'RUN'
export type ArchitecturalLayer = 'conceptual' | 'logical' | 'physical' | 'process'
export type SourceType = 'agent' | 'user' | 'generation' | 'handoff' | 'autoDream' | 'signal'

export interface TetherMemoryEntry {
  ts: string
  type: MemoryType
  key: string
  insight: string
  confidence: ConfidenceLevel
  source: SourceType
  architectural_layer?: ArchitecturalLayer
  decision_context?: string
  alternatives_considered?: string[]
  constraints_applied?: string[]
  relates_to?: string[]
  tags: string[]
  embedding?: number[]
}

export interface ArchitecturalDecision {
  id: string
  key: string
  decision: string
  context: string
  alternatives: string[]
  tradeoffs: string[]
  constraints: string[]
  confidence: ConfidenceLevel
  verdict: KennyRogersVerdict
  layer: ArchitecturalLayer
  recorded_at: string
  recorded_by: string
}

export interface QualityGate {
  gate_name: string
  status: GateStatus
  validated_at: string | null
  validated_by: string | null
  issues: string[]
}

export interface AgentMetrics {
  agent_id: string
  primary_metric_name: string
  primary_metric_value: number
  primary_metric_target: number
  secondary_metric_name: string
  secondary_metric_value: number
  secondary_metric_target: number
  recorded_at: string
  project_id?: string
}

export * from './api'
export * from './database'
export * from './memory'
export * from './agent'
