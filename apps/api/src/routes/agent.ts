import { Hono } from 'hono'
import { AgentOrchestrator } from '@tether/agents'

const agent = new Hono()

agent.post('/', async c => {
  const { message } = await c.req.json()
  const projectId = c.req.header('X-Project-ID') || 'default'
  const orch = new AgentOrchestrator(projectId)
  const response = await orch.processMessage(message, { projectId, workspacePath: '', userMessage: message })
  return c.json(response)
})

export default agent
