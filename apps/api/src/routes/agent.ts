import { Hono } from 'hono'
import { AgentOrchestrator } from '@tether/agents'
import { TetherMemoryStorage, SupabaseMemoryStorage } from '@tether/memory'

const agent = new Hono()

function getStorage(
  projectId: string,
  env: any
): TetherMemoryStorage | SupabaseMemoryStorage {
  if (env.SUPABASE_URL && env.SUPABASE_ANON_KEY) {
    return new SupabaseMemoryStorage(
      projectId,
      env.SUPABASE_URL,
      env.SUPABASE_ANON_KEY
    )
  }
  return new TetherMemoryStorage(projectId)
}

agent.post('/', async c => {
  const { message } = await c.req.json()
  const projectId = c.req.header('X-Project-ID') || 'default'
  const userId = c.req.header('X-User-ID') || 'api-user'
  const sessionId = c.req.header('X-Session-ID') || `api-${Date.now()}`

  const storage = getStorage(projectId, c.env)
  if (storage instanceof TetherMemoryStorage) {
    await storage.initialize()
  }

  const orch = new AgentOrchestrator(projectId)
  const response = await orch.processMessage(message, {
    projectId,
    workspacePath: '',
    userMessage: message,
    userId,
    sessionId,
  })

  return c.json(response)
})

export default agent