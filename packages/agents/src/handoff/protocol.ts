import { randomUUID } from 'crypto'

export interface AgentHandoff {
  id: string
  from: string
  to: string
  type: 'delegation' | 'escalation' | 'consultation' | 'handoff'
  task: {
    id: string
    goal: string
    context: string
    constraints: string[]
    acceptance_criteria: string[]
    artifacts?: string[]
  }
  parent_session: string
  urgency: 'normal' | 'elevated' | 'critical'
  callback: {
    method: string
    destination: string
    on_success: string
    on_failure: string
  }
  context_snapshot: {
    memory_prefetch?: string
    loaded_skills: string[]
    relevant_adrs: string[]
  }
  created_at: string
  expires_at?: string
  status: 'pending' | 'accepted' | 'completed' | 'failed' | 'expired'
}

export class HandoffManager {
  private active: Map<string, AgentHandoff> = new Map()

  async create(
    params: Omit<AgentHandoff, 'id' | 'created_at' | 'status'>
  ): Promise<AgentHandoff> {
    const handoff: AgentHandoff = {
      id: randomUUID(),
      ...params,
      created_at: new Date().toISOString(),
      status: 'pending',
    }
    this.active.set(handoff.id, handoff)
    console.log(
      `Handoff created: ${handoff.from} → ${handoff.to}: ${handoff.task.goal}`
    )
    return handoff
  }

  async complete(
    id: string,
    _result: { status: string; output: string }
  ): Promise<void> {
    const h = this.active.get(id)
    if (h) {
      h.status = 'completed'
      this.active.delete(id)
    }
  }

  getPending(agentId: string): AgentHandoff[] {
    return Array.from(this.active.values()).filter(
      h => h.to === agentId && h.status === 'pending'
    )
  }
}