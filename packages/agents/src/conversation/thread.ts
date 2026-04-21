export interface ConversationMessage { id: string; agentId?: string; agentName?: string; content: string; timestamp: string; isUser: boolean }
export interface ConversationThread { id: string; projectId: string; messages: ConversationMessage[]; activeAgents: string[] }
export function createThread(projectId: string): ConversationThread { return { id: `thread_${Date.now()}`, projectId, messages: [], activeAgents: [] } }
export function addUserMessage(t: ConversationThread, content: string): ConversationThread { return { ...t, messages: [...t.messages, { id: `msg_${Date.now()}`, content, timestamp: new Date().toISOString(), isUser: true }] } }
export function addAgentMessage(t: ConversationThread, agentId: string, agentName: string, content: string): ConversationThread { return { ...t, messages: [...t.messages, { id: `msg_${Date.now()}`, agentId, agentName, content, timestamp: new Date().toISOString(), isUser: false }] } }
