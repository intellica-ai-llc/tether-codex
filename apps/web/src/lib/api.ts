export const api = { agent: { chat: async (msg: string) => fetch('/api/agent', { method: 'POST', body: JSON.stringify({ message: msg }) }).then(r => r.json()) } }
