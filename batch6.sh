#!/bin/bash
# BATCH 6/6: TETHER CODEX — FRONTEND + API + CI/CD + FINAL INTEGRATION
set -e
echo "🚀 TETHER CODEX — BATCH 6/6: Frontend + API + CI/CD + Final Integration"
echo "========================================================================="

# -------------------------------------------------------------------
# FRONTEND — APPS/WEB
# -------------------------------------------------------------------
cat > apps/web/package.json << 'EOF'
{
  "name": "@tether/web",
  "version": "3.0.0",
  "private": true,
  "type": "module",
  "scripts": { "dev": "vite", "build": "vite build", "preview": "vite preview" },
  "dependencies": {
    "react": "^18.3.0", "react-dom": "^18.3.0", "react-router-dom": "^6.0.0",
    "@supabase/supabase-js": "^2.0.0", "@tether/shared-types": "workspace:*",
    "zustand": "^4.0.0", "@tanstack/react-query": "^5.0.0"
  },
  "devDependencies": {
    "@tether/tsconfig": "workspace:*", "@vitejs/plugin-react": "^4.0.0",
    "vite": "^5.0.0", "tailwindcss": "^3.0.0", "typescript": "^5.0.0",
    "@types/react": "^18.0.0", "@types/react-dom": "^18.0.0"
  }
}
EOF

cat > apps/web/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/react.json", "compilerOptions": { "outDir": "./dist" }, "include": ["src/**/*"], "references": [{ "path": "../../packages/shared-types" }] }
EOF

cat > apps/web/vite.config.ts << 'EOF'
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
export default defineConfig({ plugins: [react()], server: { port: 3000 } })
EOF

cat > apps/web/tailwind.config.js << 'EOF'
export default { content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'], theme: { extend: {} }, plugins: [] }
EOF

cat > apps/web/postcss.config.js << 'EOF'
export default { plugins: { tailwindcss: {}, autoprefixer: {} } }
EOF

cat > apps/web/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head><meta charset="UTF-8" /><meta name="viewport" content="width=device-width, initial-scale=1.0" /><title>Tether Codex</title></head>
<body><div id="root"></div><script type="module" src="/src/app/entry.client.tsx"></script></body>
</html>
EOF

cat > apps/web/src/app/entry.client.tsx << 'EOF'
import React from 'react'
import ReactDOM from 'react-dom/client'
import { App } from './root'
ReactDOM.createRoot(document.getElementById('root')!).render(<App />)
EOF

cat > apps/web/src/app/root.tsx << 'EOF'
import React from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient()

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<div className="p-8"><h1 className="text-4xl font-bold">Tether Codex</h1><p className="mt-4">Autonomous Software Organization</p></div>} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  )
}
EOF

cat > apps/web/src/components/agent/AgentConsole.tsx << 'EOF'
import React, { useState } from 'react'

export function AgentConsole() {
  const [message, setMessage] = useState('')
  const [responses, setResponses] = useState<string[]>([])

  const sendMessage = async () => {
    if (!message.trim()) return
    setResponses([...responses, `You: ${message}`])
    try {
      const res = await fetch('/api/agent', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ message }) })
      const data = await res.json()
      setResponses(prev => [...prev, ...data.responses.map((r: any) => `[${r.agentName}] ${r.content}`)])
    } catch (e) {
      setResponses(prev => [...prev, 'Error connecting to agent'])
    }
    setMessage('')
  }

  return (
    <div className="border rounded-lg p-4">
      <div className="h-96 overflow-y-auto mb-4 space-y-2">
        {responses.map((r, i) => <div key={i} className="p-2 bg-gray-100 rounded">{r}</div>)}
      </div>
      <div className="flex gap-2">
        <input className="flex-1 border rounded px-3 py-2" value={message} onChange={e => setMessage(e.target.value)} onKeyDown={e => e.key === 'Enter' && sendMessage()} placeholder="@MAE, I want to build..." />
        <button className="px-4 py-2 bg-blue-600 text-white rounded" onClick={sendMessage}>Send</button>
      </div>
    </div>
  )
}
EOF

cat > apps/web/src/hooks/useAgent.ts << 'EOF'
import { useState } from 'react'

export function useAgent() {
  const [loading, setLoading] = useState(false)
  const send = async (msg: string) => { setLoading(true); const res = await fetch('/api/agent', { method: 'POST', body: JSON.stringify({ message: msg }) }); setLoading(false); return res.json() }
  return { send, loading }
}
EOF

cat > apps/web/src/lib/supabase.ts << 'EOF'
import { createClient } from '@supabase/supabase-js'
export const supabase = createClient(import.meta.env.VITE_SUPABASE_URL!, import.meta.env.VITE_SUPABASE_ANON_KEY!)
EOF

cat > apps/web/src/lib/api.ts << 'EOF'
export const api = { agent: { chat: async (msg: string) => fetch('/api/agent', { method: 'POST', body: JSON.stringify({ message: msg }) }).then(r => r.json()) } }
EOF

cat > apps/web/wrangler.toml << 'EOF'
name = "tether-web"
compatibility_date = "2025-01-01"
assets = { directory = "./dist", binding = "ASSETS" }
[site]
bucket = "./dist"
EOF

# -------------------------------------------------------------------
# API — APPS/API
# -------------------------------------------------------------------
cat > apps/api/package.json << 'EOF'
{
  "name": "@tether/api",
  "version": "3.0.0",
  "private": true,
  "type": "module",
  "scripts": { "dev": "wrangler dev", "deploy": "wrangler deploy", "build": "tsc" },
  "dependencies": {
    "hono": "^4.0.0", "@supabase/supabase-js": "^2.0.0", "zod": "^3.0.0",
    "@tether/shared-types": "workspace:*", "@tether/memory": "workspace:*", "@tether/agents": "workspace:*",
    "@tether/mcp": "workspace:*", "@tether/platform": "workspace:*", "@tether/database": "workspace:*",
    "@tether/export": "workspace:*", "stripe": "^14.0.0"
  },
  "devDependencies": { "@tether/tsconfig": "workspace:*", "@cloudflare/workers-types": "^4.0.0", "wrangler": "^3.0.0", "typescript": "^5.0.0" }
}
EOF

cat > apps/api/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/base.json", "compilerOptions": { "outDir": "./dist", "types": ["@cloudflare/workers-types"] }, "include": ["src/**/*"] }
EOF

cat > apps/api/wrangler.toml << 'EOF'
name = "tether-api"
main = "src/index.ts"
compatibility_date = "2025-01-01"
[env.production]
vars = { SUPABASE_URL = "", SUPABASE_ANON_KEY = "" }
EOF

cat > apps/api/src/index.ts << 'EOF'
import { Hono } from 'hono'
import { cors } from 'hono/cors'
import { logger } from 'hono/logger'
import agent from './routes/agent'
import memory from './routes/memory'
import billing from './routes/billing'

const app = new Hono()
app.use('*', logger())
app.use('*', cors())
app.get('/health', c => c.json({ status: 'ok', timestamp: new Date().toISOString() }))
app.route('/api/agent', agent)
app.route('/api/memory', memory)
app.route('/api/billing', billing)

export default app
EOF

cat > apps/api/src/routes/agent.ts << 'EOF'
import { Hono } from 'hono'
import { AgentOrchestrator } from '@tether/agents'

const agent = new Hono()

agent.post('/', async c => {
  const { message } = await c.req.json()
  const projectId = c.req.header('X-Project-ID') || 'default'
  const orch = new AgentOrchestrator(projectId)
  const response = await orch.processMessage(message, { projectId, workspacePath: '', userMessage: message, userId: 'user' })
  return c.json(response)
})

export default agent
EOF

cat > apps/api/src/routes/memory.ts << 'EOF'
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
EOF

cat > apps/api/src/routes/billing.ts << 'EOF'
import { Hono } from 'hono'
import Stripe from 'stripe'

const billing = new Hono()

billing.post('/create-checkout', async c => {
  const { priceId, successUrl, cancelUrl } = await c.req.json()
  const stripe = new Stripe(c.env.STRIPE_SECRET_KEY as string, { httpClient: Stripe.createFetchHttpClient() })
  const session = await stripe.checkout.sessions.create({ line_items: [{ price: priceId, quantity: 1 }], mode: 'subscription', success_url: successUrl, cancel_url: cancelUrl })
  return c.json({ url: session.url })
})

billing.post('/webhook', async c => {
  const body = await c.req.text()
  const signature = c.req.header('stripe-signature')
  const stripe = new Stripe(c.env.STRIPE_SECRET_KEY as string)
  try {
    const event = await stripe.webhooks.constructEventAsync(body, signature!, c.env.STRIPE_WEBHOOK_SECRET as string)
    console.log('Stripe webhook:', event.type)
  } catch (err) { return c.json({ error: 'Invalid signature' }, 400) }
  return c.json({ received: true })
})

export default billing
EOF

cat > apps/api/src/middleware/auth.ts << 'EOF'
import { createMiddleware } from 'hono/factory'
import { createClient } from '@supabase/supabase-js'

export const authMiddleware = createMiddleware(async (c, next) => {
  const authHeader = c.req.header('Authorization')
  if (!authHeader) return c.json({ error: 'Unauthorized' }, 401)
  const token = authHeader.replace('Bearer ', '')
  const supabase = createClient(c.env.SUPABASE_URL as string, c.env.SUPABASE_ANON_KEY as string)
  const { data: { user }, error } = await supabase.auth.getUser(token)
  if (error || !user) return c.json({ error: 'Invalid token' }, 401)
  c.set('user', user)
  await next()
})
EOF

cat > apps/api/src/services/llm-router.ts << 'EOF'
export async function generateWithRouter(prompt: string, capability: string): Promise<{ content: string; provider: string }> {
  return { content: `Response for: ${prompt.slice(0, 50)}...`, provider: 'clawrouter' }
}
EOF

# -------------------------------------------------------------------
# CI/CD WORKFLOWS
# -------------------------------------------------------------------
cat > .github/workflows/deploy-web.yml << 'EOF'
name: Deploy Web
on: { push: { branches: [main], paths: ['apps/web/**', 'packages/**'] } }
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4; with: { node-version: '20', cache: 'pnpm' }
      - run: pnpm install && pnpm --filter web build
      - uses: cloudflare/pages-action@v1; with: { apiToken: '${{ secrets.CLOUDFLARE_API_TOKEN }}', accountId: '${{ secrets.CLOUDFLARE_ACCOUNT_ID }}', projectName: tether-codex, directory: apps/web/dist }
EOF

cat > .github/workflows/deploy-api.yml << 'EOF'
name: Deploy API
on: { push: { branches: [main], paths: ['apps/api/**', 'packages/**'] } }
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4; with: { node-version: '20', cache: 'pnpm' }
      - run: pnpm install
      - run: pnpm --filter api deploy; env: { CLOUDFLARE_API_TOKEN: '${{ secrets.CLOUDFLARE_API_TOKEN }}' }
EOF

cat > .github/workflows/quality-gates.yml << 'EOF'
name: Quality Gates
on: [pull_request, push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4; with: { node-version: '20', cache: 'pnpm' }
      - run: pnpm install && pnpm test && pnpm lint
EOF

cat > .github/workflows/migrate-db.yml << 'EOF'
name: Migrate DB
on: { push: { branches: [main], paths: ['supabase/migrations/**'] } }
jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: supabase/setup-cli@v1
      - run: supabase link --project-ref ${{ secrets.SUPABASE_PROJECT_REF }} && supabase db push; env: { SUPABASE_ACCESS_TOKEN: '${{ secrets.SUPABASE_ACCESS_TOKEN }}', SUPABASE_DB_PASSWORD: '${{ secrets.SUPABASE_DB_PASSWORD }}' }
EOF

cat > .github/workflows/auto-fix.yml << 'EOF'
name: Auto-Fix
on: { issues: { types: [opened, labeled] }, schedule: [{ cron: '0 */6 * * *' }] }
jobs:
  fix:
    runs-on: ubuntu-latest
    if: github.event.label.name == 'bug' || github.event_name == 'schedule'
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4; with: { node-version: '20', cache: 'pnpm' }
      - run: pnpm install && node packages/agents/dist/cli/index.js @BUG "Scan for errors and auto-fix"
        env: { OPENAI_API_KEY: '${{ secrets.OPENAI_API_KEY }}', ANTHROPIC_API_KEY: '${{ secrets.ANTHROPIC_API_KEY }}' }
EOF

cat > .github/workflows/maintenance-scan.yml << 'EOF'
name: Maintenance Scan
on: { schedule: [{ cron: '0 0 * * *' }], workflow_dispatch: }
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: pnpm/action-setup@v2
      - uses: actions/setup-node@v4; with: { node-version: '20', cache: 'pnpm' }
      - run: pnpm install && pnpm outdated || true && pnpm audit || true
      - run: node packages/agents/dist/cli/index.js @MNT "Run maintenance scan and report"
        env: { OPENAI_API_KEY: '${{ secrets.OPENAI_API_KEY }}' }
EOF

# -------------------------------------------------------------------
# FINAL SCRIPTS
# -------------------------------------------------------------------
cat > scripts/deploy.sh << 'EOF'
#!/bin/bash
set -e
echo "🚀 Deploying Tether Codex..."
pnpm build
pnpm --filter api deploy
echo "✅ Deploy complete."
EOF
chmod +x scripts/deploy.sh

cat > scripts/export.sh << 'EOF'
#!/bin/bash
set -e
echo "📦 Exporting Tether Codex project..."
pnpm agent export
echo "✅ Export complete."
EOF
chmod +x scripts/export.sh

# -------------------------------------------------------------------
# COMPLETION
# -------------------------------------------------------------------
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅ TETHER CODEX v3.0 — COMPLETE SCAFFOLD GENERATED"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📦 Batches: 6"
echo "📁 Files: ~200+"
echo ""
echo "🏛️ The 13-Agent Council:"
echo "   @MAE  — Master Architect Essence"
echo "   @MI   — Master Innovator"
echo "   @MPE  — Master Product Engineer"
echo "   @PCA  — Platform Compute Agent"
echo "   @DB   — Database Expert"
echo "   @UIX  — UI/UX Engineer"
echo "   @MM   — Master Marketer"
echo "   @BUG  — Debugging Agent"
echo "   @QC   — Quality Control Agent"
echo "   @OPS  — DevOps Engineer"
echo "   @MNT  — Maintenance Master"
echo "   @SUP  — Support Agent"
echo "   @REQ  — Requirements Engineer"
echo ""
echo "📦 Packages (19):"
echo "   shared-types, config, tsconfig, memory, agents, mcp, preview,"
echo "   voice, platform, database, skills, experience, learning, export,"
echo "   maintenance, ast, ui, web, api"
echo ""
echo "🧠 Memory Substrate: .tether/"
echo "🌙 autoDream: Light/REM/Deep sleep consolidation"
echo "💰 Zero-cost compute until revenue (PCA)"
echo "✅ 5 Quality Gates (QC)"
echo "🔄 Learning Attribution Records (LARs)"
echo "🃏 Experience Cards (cross-project knowledge)"
echo "🛒 Skills Marketplace"
echo "🔌 MCP Client + Server"
echo "🌐 WebContainers Preview"
echo "🎤 Voice Interface"
echo "📦 Vercel/Netlify/ZIP Export"
echo ""
echo "🚀 Next Steps:"
echo "   1. pnpm install"
echo "   2. pnpm build"
echo "   3. pnpm dev"
echo "   4. pnpm agent chat \"@MAE, I want to build...\""
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🏗️ Tether Codex v3.0 — The Magnus Opus is ready."
echo "═══════════════════════════════════════════════════════════════"
EOF

echo ""
echo "✅ Batch 6/6 complete — Frontend + API + CI/CD + Final Integration"
echo "   • @tether/web (React + Vite + Tailwind)"
echo "   • @tether/api (Hono on Cloudflare Workers)"
echo "   • AgentConsole component"
echo "   • API routes (agent, memory, billing)"
echo "   • 6 CI/CD workflows (deploy, quality-gates, migrate, auto-fix, maintenance)"
echo "   • Final scripts (deploy.sh, export.sh)"
echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "🎉 ALL 6 BATCHES COMPLETE"
echo "═══════════════════════════════════════════════════════════════"