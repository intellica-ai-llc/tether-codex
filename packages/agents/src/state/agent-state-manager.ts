import * as fs from 'fs/promises'
import * as path from 'path'

export interface AgentState {
  agent_id: string
  session_id: string
  short_term: { conversation: any[]; attention_focus: string }
  working: { active_tasks: any[]; loaded_skills: string[]; current_context: string; handoffs_pending: string[] }
  long_term: { preferences: Record<string, any>; learned_patterns: any[]; success_history: any[]; failure_history: any[]; agent_specific: Record<string, any> }
  metrics: { tasks_completed: number; skills_created: number; handoffs_handled: number; avg_response_time_ms: number }
  created_at: string
  updated_at: string
  last_active: string
  last_saved_at: string
}

const defaults: Record<string, any> = {
  mae: { verbosity: 'concise', coffee_ritual: true, kenny_rogers_mode: true, free_tier_strict: true, auto_create_adr: true },
  mi: { scan_frequency: 'weekly', min_confidence: 7, min_occurrences: 3, auto_create_skills: true },
  pca: { preferred_platform: 'cloudflare', zero_cost_strict: true, auto_scale: true },
  db: { preferred_orm: 'drizzle', rls_default: true, query_performance_target_ms: 100 },
  mm: { default_design_system: 'stripe', conversion_target: 5, auto_polish: true },
  bug: { debug_protocol: 'systematic', auto_create_lar: true, regression_test_required: true },
  qc: { tdd_enforced: true, coverage_threshold: 80, require_self_review: true },
  mnt: { auto_fix_enabled: true, patch_window: 'sunday-3am', health_check_interval_ms: 600000 }
}

export class AgentStateManager {
  private states: Map<string, AgentState> = new Map()
  private persistDir: string

  constructor(basePath: string = '.tether') {
    this.persistDir = path.join(basePath, 'agent-states')
  }

  async loadState(agentId: string, sessionId: string): Promise<AgentState> {
    const filePath = path.join(this.persistDir, `${agentId}.json`)
    try {
      const data = JSON.parse(await fs.readFile(filePath, 'utf-8'))
      const state: AgentState = {
        ...data,
        session_id: sessionId,
        short_term: { conversation: [], attention_focus: '' },
        working: { active_tasks: data.working?.active_tasks || [], loaded_skills: [], current_context: '', handoffs_pending: data.working?.handoffs_pending || [] },
        last_active: new Date().toISOString(),
        updated_at: new Date().toISOString()
      }
      this.states.set(agentId, state)
      return state
    } catch {
      return this.createFreshState(agentId, sessionId)
    }
  }

  createFreshState(agentId: string, sessionId: string): AgentState {
    const state: AgentState = {
      agent_id: agentId, session_id: sessionId,
      short_term: { conversation: [], attention_focus: '' },
      working: { active_tasks: [], loaded_skills: [], current_context: '', handoffs_pending: [] },
      long_term: { preferences: defaults[agentId] || {}, learned_patterns: [], success_history: [], failure_history: [], agent_specific: {} },
      metrics: { tasks_completed: 0, skills_created: 0, handoffs_handled: 0, avg_response_time_ms: 0 },
      created_at: new Date().toISOString(), updated_at: new Date().toISOString(),
      last_active: new Date().toISOString(), last_saved_at: new Date().toISOString()
    }
    this.states.set(agentId, state)
    return state
  }

  async persistState(agentId: string): Promise<void> {
    const state = this.states.get(agentId)
    if (!state) return
    state.updated_at = new Date().toISOString()
    await fs.mkdir(this.persistDir, { recursive: true })
    await fs.writeFile(path.join(this.persistDir, `${agentId}.json`), JSON.stringify(state, null, 2))
    state.last_saved_at = new Date().toISOString()
  }
}
