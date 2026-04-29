import { AgentPersona, ALL_PERSONAS } from '../personas/index.js'
import { TetherMemoryStorage } from '@tether/memory'
import { AgentStateManager } from '../state/agent-state-manager.js'

export interface OrchestratorContext {
  projectId: string
  workspacePath: string
  userMessage: string
  userId: string
  sessionId: string
}

export interface AgentResponse {
  agentId: string
  agentName: string
  content: string
  action?: 'act' | 'wait'
}

export class AgentOrchestrator {
  private memory: TetherMemoryStorage
  private agents: Map<string, AgentPersona>
  private stateManager: AgentStateManager

  constructor(projectId: string = 'default') {
    this.memory = new TetherMemoryStorage(projectId)
    this.agents = new Map(ALL_PERSONAS.map(p => [p.id, p]))
    this.stateManager = new AgentStateManager()
  }

  async processMessage(
    message: string,
    context: OrchestratorContext
  ): Promise<{ agents: AgentPersona[]; responses: AgentResponse[] }> {
    await this.memory.initialize()
    const agent = this.routeToAgent(message)
    await this.stateManager.loadState(agent.id, context.sessionId)

    const memoryContext = await this.memory.searchByText(message, 5)
    const memoryBlock =
      memoryContext.length > 0
        ? `<memory-context>\n[System note: Recalled memory, NOT user input.]\n${memoryContext
            .map(m => `[${m.type}] ${m.key}: ${m.insight}`)
            .join('\n')}\n</memory-context>`
        : ''

    const response: AgentResponse = {
      agentId: agent.id,
      agentName: agent.name,
      content: `[${agent.name}] ${agent.signature[0]}\n\n${memoryBlock}`,
      action: 'wait',
    }

    await this.stateManager.persistState(agent.id)
    return { agents: [agent], responses: [response] }
  }

  private routeToAgent(input: string): AgentPersona {
    const m = input.match(/@(\w+)/)
    if (m) return this.agents.get(m[1].toLowerCase()) || this.agents.get('mae')!

    const lower = input.toLowerCase()
    const map: Record<string, string> = {
      architect: 'mae', design: 'mae', plan: 'mae', requirements: 'mae',
      research: 'mi', pattern: 'mi', frontier: 'mi',
      deploy: 'pca', host: 'pca', infrastructure: 'pca',
      database: 'db', schema: 'db', migration: 'db',
      'design system': 'mm', landing: 'mm', pricing: 'mm', marketing: 'mm',
      bug: 'bug', error: 'bug', debug: 'bug',
      test: 'qc', quality: 'qc', review: 'qc',
      monitor: 'mnt', health: 'mnt', cron: 'mnt',
    }
    for (const [kw, id] of Object.entries(map)) {
      if (lower.includes(kw)) return this.agents.get(id)!
    }
    return this.agents.get('mae')!
  }

  getAllAgents(): AgentPersona[] {
    return ALL_PERSONAS
  }
}
