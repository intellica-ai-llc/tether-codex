import { ArchitecturalDecision, TetherMemoryEntry } from './index'
export interface Project { id: string; user_id: string; name: string; description?: string; repo_url?: string; tech_stack: string[]; constraints: string[]; current_step: number; created_at: string; updated_at: string }
export interface Document { id: string; project_id: string; doc_type: 'ARCHITECTURE' | 'IMPLEMENTATION_PLAN' | 'HANDOFF' | 'USER_FLOW'; content: string; version: number; generated_by: string; created_at: string }
export interface AgentSession { id: string; project_id: string; messages: ChatMessage[]; created_at: string; expires_at: string }
export interface ChatMessage { id: string; agent_id?: string; agent_name?: string; content: string; timestamp: string; is_user: boolean; metadata?: Record<string, unknown> }
export interface HandoffPackage { version: string; exported_at: string; project: { id: string; name: string }; memory: { decisions: ArchitecturalDecision[]; patterns: TetherMemoryEntry[] }; documents: { architecture?: string; implementation?: string } }
