import { Hono } from 'hono'
import { TetherMemoryStorage } from '@tether/memory'

const memory = new Hono()

memory.get('/', async c => {
  const projectId = c.req.header('X-Project-ID') || 'default'
  const storage = new TetherMemoryStorage(projectId)
  await storage.initialize()
  const entries = await storage.query({ limit: 50 })
  return c.json({ entries })
})

memory.get('/decisions', async c => {
  const projectId = c.req.header('X-Project-ID') || 'default'
  const storage = new TetherMemoryStorage(projectId)
  await storage.initialize()
  const decisions = await storage.getDecisions()
  return c.json({ decisions })
})

memory.get('/patterns', async c => {
  const projectId = c.req.header('X-Project-ID') || 'default'
  const storage = new TetherMemoryStorage(projectId)
  await storage.initialize()
  const patterns = await storage.getPatterns(7)
  return c.json({ patterns })
})

export default memory
