import { AgentPhase } from './index'
export interface AgentPersona { id: string; name: string; role: string; phase: AgentPhase; triggers: string[]; systemPrompt: string; outputPath: string; metrics: AgentMetricsConfig; signature: string[] }
export interface AgentMetricsConfig { primary: string; primaryTarget: number; secondary: string; secondaryTarget: number }
export interface OrchestratorContext { projectId: string; workspacePath: string; userMessage: string; userId: string }
export interface OrchestratorResponse { agents: AgentPersona[]; responses: AgentResponse[]; memory_updates: string[]; thread_id: string }
export interface AgentResponse { agentId: string; agentName: string; content: string; action?: 'act' | 'wait'; learning?: { type: string; key: string; insight: string; confidence: number } }
export interface ConversationThread { id: string; projectId: string; messages: ConversationMessage[]; activeAgents: string[]; phase: AgentPhase }
export interface ConversationMessage { id: string; agentId?: string; agentName?: string; content: string; timestamp: string; isUser: boolean; metadata?: Record<string, unknown> }
