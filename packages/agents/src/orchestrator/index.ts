import { AgentPersona, ALL_PERSONAS, PERSONA_BY_ID } from '../personas/index.js'
import { TetherMemoryStorage } from '@tether/memory'

export interface OrchestratorContext { projectId: string; workspacePath: string; userMessage: string }
export interface AgentResponse { agentId: string; agentName: string; content: string; action?: 'act' | 'wait' }

export class AgentOrchestrator {
  private memory: TetherMemoryStorage
  constructor(projectId: string) { this.memory = new TetherMemoryStorage(projectId) }

  async processMessage(message: string, _context: OrchestratorContext): Promise<{ agents: AgentPersona[]; responses: AgentResponse[] }> {
    await this.memory.initialize()
    const agents = this.classifyIntent(message)
    const responses = await Promise.all(agents.map(a => this.invokeAgent(a, message)))
    return { agents, responses }
  }

  private classifyIntent(message: string): AgentPersona[] {
    const lower = message.toLowerCase()
    const matched = ALL_PERSONAS.filter(a => a.triggers.some(t => lower.includes(t)))
    if (matched.length === 0) return [PERSONA_BY_ID['mae'], PERSONA_BY_ID['mi'], PERSONA_BY_ID['req']]
    const mentions = lower.match(/@(\w+)/g)?.map(m => m.slice(1)) || []
    const mentioned = mentions.map(id => PERSONA_BY_ID[id]).filter(Boolean)
    return mentioned.length > 0 ? mentioned : matched
  }

  private async invokeAgent(agent: AgentPersona, _message: string): Promise<AgentResponse> {
    return { agentId: agent.id, agentName: agent.name, content: `[${agent.name}] ${agent.signature[0]}`, action: 'wait' }
  }
}
