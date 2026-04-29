import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import agent from './routes/agent.js'
import memory from './routes/memory.js'
import billing from './routes/billing.js'

const app = new Hono()
app.use('*', logger())
app.use('*', cors())
app.get('/health', c => c.json({ status: 'ok', timestamp: new Date().toISOString() }))
app.route('/api/agent', agent)
app.route('/api/memory', memory)
app.route('/api/billing', billing)

export default app
