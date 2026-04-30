import { Hono } from 'hono'
import { AgentOrchestrator } from '@tether/agents'
import { TetherMemoryStorage, SupabaseMemoryStorage } from '@tether/memory'

function getStorage(projectId: string, env: any) {
  if (env.SUPABASE_URL && env.SUPABASE_ANON_KEY)
    return new SupabaseMemoryStorage(projectId, env.SUPABASE_URL, env.SUPABASE_ANON_KEY)
  return new TetherMemoryStorage(projectId)
}

const agent = new Hono()
agent.post('/', async c => {
  const { message } = await c.req.json()
  const id = c.req.header('X-Project-ID') || 'default'
  const storage = getStorage(id, c.env)
  if (storage instanceof TetherMemoryStorage) await storage.initialize()
  const orch = new AgentOrchestrator(id, storage)
  return c.json(await orch.processMessage(message, {
    projectId: id, workspacePath: '', userMessage: message,
    userId: c.req.header('X-User-ID') || 'api-user',
    sessionId: c.req.header('X-Session-ID') || `api-${Date.now()}`
  }))
})
export default agent