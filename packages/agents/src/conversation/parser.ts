export function parseMessage(message: string): { mentions: string[]; content: string; isQuestion: boolean } {
  const mentions = Array.from(message.matchAll(/@(\w+)/g)).map(m => m[1].toLowerCase())
  return { mentions, content: message.replace(/@(\w+)/g, '').trim(), isQuestion: message.trim().endsWith('?') }
}
export function formatAgentResponse(agentName: string, content: string): string { return `**${agentName}**\n${content}` }
