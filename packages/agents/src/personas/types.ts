import { AgentPhase } from '@tether/shared-types'

export interface AgentPersona {
  id: string
  name: string
  role: string
  phase: AgentPhase
  triggers: string[]
  systemPrompt: string
  outputPath: string
  metrics: { primary: string; primaryTarget: number; secondary: string; secondaryTarget: number }
  signature: string[]
}
