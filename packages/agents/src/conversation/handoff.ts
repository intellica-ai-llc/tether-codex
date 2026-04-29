import { PERSONA_BY_ID } from '../personas/index.js';
import { ConversationThread, addAgentMessage } from './thread.js'

export function detectHandoff(message: string): string | null { const m = message.match(/hand(?:ing)? off to @(\w+)/i); return m ? m[1].toLowerCase() : null }
export function executeHandoff(t: ConversationThread, targetId: string): ConversationThread { const target = PERSONA_BY_ID[targetId]; return target ? addAgentMessage(t, target.id, target.name, `Handoff received.`) : t }
