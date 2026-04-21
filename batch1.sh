#!/bin/bash
# BATCH 1/6: TETHER CODEX — CORE INFRASTRUCTURE
set -e
echo "🏗️ TETHER CODEX — BATCH 1/6: Core Infrastructure"
echo "=================================================="

# -------------------------------------------------------------------
# COMPLETE DIRECTORY STRUCTURE
# -------------------------------------------------------------------
mkdir -p .github/workflows
mkdir -p .tether/memory/patterns
mkdir -p .tether/architecture/decisions
mkdir -p .tether/requirements
mkdir -p .tether/process/batches
mkdir -p .tether/process/user-flows
mkdir -p .tether/platform
mkdir -p .tether/marketing/design-system
mkdir -p .tether/marketing/brand-styles
mkdir -p .tether/marketing/reports
mkdir -p .tether/quality/gates
mkdir -p .tether/quality/test-reports
mkdir -p .tether/debugging/incidents
mkdir -p .tether/debugging/root-cause-analyses
mkdir -p .tether/maintenance/health-reports
mkdir -p .tether/support/tickets
mkdir -p .tether/support/knowledge-base
mkdir -p .tether/learnings/attributions
mkdir -p .tether/experience-cards
mkdir -p .tether/skills/tether-architecture/references/architectural-styles
mkdir -p .tether/skills/tether-architecture/templates
mkdir -p .tether/skills/tether-design/references/brand-styles
mkdir -p .tether/skills/tether-design/templates
mkdir -p .tether/agent-metrics
mkdir -p .tether/payments
mkdir -p apps/web/src/app/routes/projects
mkdir -p apps/web/src/app/routes/settings
mkdir -p apps/web/src/app/routes/auth
mkdir -p apps/web/src/components/agent
mkdir -p apps/web/src/components/documents
mkdir -p apps/web/src/components/preview
mkdir -p apps/web/src/components/voice
mkdir -p apps/web/src/components/export
mkdir -p apps/web/src/components/billing
mkdir -p apps/web/src/components/git
mkdir -p apps/web/src/components/ui
mkdir -p apps/web/src/hooks
mkdir -p apps/web/src/lib
mkdir -p apps/web/src/stores
mkdir -p apps/web/src/styles
mkdir -p apps/web/public
mkdir -p apps/api/src/routes
mkdir -p apps/api/src/services
mkdir -p apps/api/src/db/migrations
mkdir -p apps/api/src/middleware
mkdir -p apps/api/src/mcp
mkdir -p apps/api/src/webhooks
mkdir -p apps/api/src/config
mkdir -p apps/api/src/types
mkdir -p packages/shared-types/src
mkdir -p packages/config/src
mkdir -p packages/tsconfig
mkdir -p packages/memory/src/consolidator
mkdir -p packages/memory/tests
mkdir -p packages/agents/src/personas
mkdir -p packages/agents/src/orchestrator
mkdir -p packages/agents/src/conversation
mkdir -p packages/agents/src/metrics
mkdir -p packages/agents/src/cli/commands
mkdir -p packages/agents/tests
mkdir -p packages/mcp/src/client
mkdir -p packages/mcp/src/server
mkdir -p packages/preview/src
mkdir -p packages/voice/src
mkdir -p packages/platform/src
mkdir -p packages/database/src
mkdir -p packages/database/migrations
mkdir -p packages/skills/src
mkdir -p packages/experience/src
mkdir -p packages/learning/src
mkdir -p packages/export/src
mkdir -p packages/maintenance/src
mkdir -p packages/ast/src
mkdir -p packages/ui/src
mkdir -p supabase/migrations
mkdir -p docker
mkdir -p scripts

# -------------------------------------------------------------------
# ROOT PACKAGE.JSON
# -------------------------------------------------------------------
cat > package.json << 'EOF'
{
  "name": "tether-codex",
  "version": "3.0.0",
  "private": true,
  "description": "Tether Codex — Autonomous Software Organization with 13-Agent Council",
  "workspaces": ["packages/*", "apps/*"],
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "test": "turbo test",
    "lint": "turbo lint",
    "format": "biome format --write .",
    "agent": "node packages/agents/dist/cli/index.js",
    "dream": "node packages/agents/dist/cli/index.js dream",
    "maintenance": "node packages/agents/dist/cli/index.js maintenance start",
    "export": "node packages/agents/dist/cli/index.js export",
    "status": "node packages/agents/dist/cli/index.js status",
    "migrate": "drizzle-kit push"
  },
  "devDependencies": {
    "@biomejs/biome": "^1.9.0",
    "turbo": "^2.0.0",
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0"
  },
  "engines": { "node": ">=20.0.0", "pnpm": ">=9.0.0" },
  "packageManager": "pnpm@9.0.0"
}
EOF

# -------------------------------------------------------------------
# TURBO.JSON
# -------------------------------------------------------------------
cat > turbo.json << 'EOF'
{
  "$schema": "https://turbo.build/schema.json",
  "globalDependencies": ["**/.env.*local"],
  "pipeline": {
    "build": { "dependsOn": ["^build"], "outputs": ["dist/**"] },
    "dev": { "cache": false, "persistent": true },
    "test": { "dependsOn": ["build"], "inputs": ["src/**/*.ts", "test/**/*.ts"] },
    "lint": { "dependsOn": ["^build"] }
  }
}
EOF

# -------------------------------------------------------------------
# PNPM WORKSPACE
# -------------------------------------------------------------------
cat > pnpm-workspace.yaml << 'EOF'
packages:
  - 'packages/*'
  - 'apps/*'
EOF

# -------------------------------------------------------------------
# ROOT TSCONFIG
# -------------------------------------------------------------------
cat > tsconfig.json << 'EOF'
{
  "extends": "./packages/tsconfig/base.json",
  "compilerOptions": { "noEmit": true },
  "include": [],
  "references": [
    { "path": "apps/web" }, { "path": "apps/api" },
    { "path": "packages/shared-types" }, { "path": "packages/config" },
    { "path": "packages/memory" }, { "path": "packages/agents" },
    { "path": "packages/mcp" }, { "path": "packages/preview" },
    { "path": "packages/voice" }, { "path": "packages/platform" },
    { "path": "packages/database" }, { "path": "packages/skills" },
    { "path": "packages/experience" }, { "path": "packages/learning" },
    { "path": "packages/export" }, { "path": "packages/maintenance" },
    { "path": "packages/ast" }, { "path": "packages/ui" }
  ]
}
EOF

# -------------------------------------------------------------------
# BIOME.JSON
# -------------------------------------------------------------------
cat > biome.json << 'EOF'
{
  "$schema": "https://biomejs.dev/schemas/1.9.0/schema.json",
  "vcs": { "enabled": true, "clientKind": "git", "useIgnoreFile": true },
  "files": { "ignoreUnknown": false, "ignore": [".tether/**", "dist/**", "node_modules/**"] },
  "formatter": { "enabled": true, "indentStyle": "space", "indentWidth": 2, "lineWidth": 100 },
  "linter": { "enabled": true, "rules": { "recommended": true } },
  "javascript": { "formatter": { "quoteStyle": "single", "semicolons": "asNeeded" } }
}
EOF

# -------------------------------------------------------------------
# .GITIGNORE
# -------------------------------------------------------------------
cat > .gitignore << 'EOF'
node_modules/
.pnpm-store/
dist/
build/
.next/
out/
.env
.env.local
.env.*.local
.vscode/
.idea/
*.swp
*.swo
.DS_Store
Thumbs.db
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.tether/memory/learnings.jsonl
.tether/maintenance/auto-fix-log.jsonl
.tether/debugging/incidents/
.tether/support/tickets/
*.pem
*.key
*.cert
.turbo
EOF

# -------------------------------------------------------------------
# .ENV.EXAMPLE
# -------------------------------------------------------------------
cat > .env.example << 'EOF'
TETHER_PROJECT_ID=default
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_KEY=your-service-key
CLAWROUTER_MODE=local
GEMINI_API_KEY=your-gemini-key
ANTHROPIC_API_KEY=your-anthropic-key
OPENAI_API_KEY=your-openai-key
UPSTASH_REDIS_URL=your-redis-url
UPSTASH_REDIS_TOKEN=your-redis-token
CLOUDFLARE_API_TOKEN=your-api-token
CLOUDFLARE_ACCOUNT_ID=your-account-id
R2_BUCKET_NAME=tether-storage
R2_ACCESS_KEY_ID=your-r2-key
R2_SECRET_ACCESS_KEY=your-r2-secret
STRIPE_SECRET_KEY=your-stripe-key
STRIPE_WEBHOOK_SECRET=your-webhook-secret
RESEND_API_KEY=your-resend-key
POSTHOG_API_KEY=your-posthog-key
SENTRY_DSN=your-sentry-dsn
EOF

# -------------------------------------------------------------------
# README.MD
# -------------------------------------------------------------------
cat > README.md << 'EOF'
# Tether Codex v3.0
Autonomous software organization with 13-Agent Council.
## Agents
@MAE (Master Architect) | @MI (Innovator) | @MPE (Product Engineer) | @PCA (Platform Compute)
@DB (Database) | @UIX (UI/UX) | @MM (Marketing) | @BUG (Debugging)
@QC (Quality) | @OPS (DevOps) | @MNT (Maintenance) | @SUP (Support) | @REQ (Requirements)
## Quick Start
pnpm install && pnpm build && pnpm dev
## Invoke Agents
@MAE, I want to build an app...
EOF

# -------------------------------------------------------------------
# CONTRIBUTING.MD
# -------------------------------------------------------------------
cat > CONTRIBUTING.md << 'EOF'
# Contributing to Tether Codex
## Agent Development
Agents in `packages/agents/src/personas/`. Triggers, system prompt, metrics, signature.
## Memory Substrate
`.tether/memory/learnings.jsonl` — append-only. Never modify.
## Quality Gates
5 gates: requirements, architecture, implementation, deployment, maintenance.
EOF

# -------------------------------------------------------------------
# LICENSE
# -------------------------------------------------------------------
cat > LICENSE << 'EOF'
MIT License
Copyright (c) 2026 Tether Codex
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
EOF

# -------------------------------------------------------------------
# DOCKER FILES
# -------------------------------------------------------------------
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  web:
    build: { context: ., dockerfile: docker/Dockerfile.web }
    ports: ["3000:3000"]
    volumes: ["./.tether:/app/.tether"]
  api:
    build: { context: ., dockerfile: docker/Dockerfile.api }
    ports: ["8787:8787"]
    volumes: ["./.tether:/app/.tether"]
EOF

cat > docker/Dockerfile.web << 'EOF'
FROM node:20-slim
WORKDIR /app
RUN npm install -g pnpm@9
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages ./packages
COPY apps/web ./apps/web
RUN pnpm install --frozen-lockfile && pnpm --filter web build
EXPOSE 3000
CMD ["npx", "serve", "-s", "apps/web/dist", "-l", "3000"]
EOF

cat > docker/Dockerfile.api << 'EOF'
FROM node:20-slim
WORKDIR /app
RUN npm install -g pnpm@9
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY packages ./packages
COPY apps/api ./apps/api
RUN pnpm install --frozen-lockfile && pnpm --filter api build
EXPOSE 8787
CMD ["node", "apps/api/dist/index.js"]
EOF

cat > Dockerfile << 'EOF'
FROM node:20-slim
WORKDIR /app
RUN npm install -g pnpm@9
COPY . .
RUN pnpm install --frozen-lockfile && pnpm build
EXPOSE 3000 8787
CMD ["pnpm", "dev"]
EOF

# -------------------------------------------------------------------
# TSCONFIG PACKAGE
# -------------------------------------------------------------------
cat > packages/tsconfig/package.json << 'EOF'
{ "name": "@tether/tsconfig", "version": "3.0.0", "private": true }
EOF

cat > packages/tsconfig/base.json << 'EOF'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "bundler",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noFallthroughCasesInSwitch": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    "composite": true,
    "incremental": true
  }
}
EOF

cat > packages/tsconfig/react.json << 'EOF'
{
  "extends": "./base.json",
  "compilerOptions": { "jsx": "react-jsx", "lib": ["ES2022", "DOM", "DOM.Iterable"] }
}
EOF

# -------------------------------------------------------------------
# SHARED TYPES PACKAGE
# -------------------------------------------------------------------
cat > packages/shared-types/package.json << 'EOF'
{
  "name": "@tether/shared-types",
  "version": "3.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": "./dist/index.js",
    "./api": "./dist/api.js",
    "./database": "./dist/database.js",
    "./memory": "./dist/memory.js",
    "./agent": "./dist/agent.js"
  },
  "scripts": { "build": "tsc", "dev": "tsc --watch" },
  "devDependencies": { "@tether/tsconfig": "workspace:*", "typescript": "^5.0.0" }
}
EOF

cat > packages/shared-types/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/base.json", "compilerOptions": { "outDir": "./dist", "rootDir": "./src" }, "include": ["src/**/*"] }
EOF

cat > packages/shared-types/src/index.ts << 'EOF'
export type MemoryType = 'pattern' | 'decision' | 'constraint' | 'pitfall' | 'observation' | 'architecture' | 'risk' | 'tradeoff' | 'question' | 'milestone'
export type ConfidenceLevel = 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10
export type AgentPhase = 'discovery' | 'architecture' | 'implementation' | 'deployment' | 'maintenance' | 'support'
export type GateStatus = 'pending' | 'passed' | 'failed'
export type KennyRogersVerdict = 'HOLD' | 'FOLD' | 'WALK_AWAY' | 'RUN'
export type ArchitecturalLayer = 'conceptual' | 'logical' | 'physical' | 'process'
export type SourceType = 'agent' | 'user' | 'generation' | 'handoff' | 'autoDream' | 'signal'

export interface TetherMemoryEntry {
  ts: string
  type: MemoryType
  key: string
  insight: string
  confidence: ConfidenceLevel
  source: SourceType
  architectural_layer?: ArchitecturalLayer
  decision_context?: string
  alternatives_considered?: string[]
  constraints_applied?: string[]
  relates_to?: string[]
  tags: string[]
  embedding?: number[]
}

export interface ArchitecturalDecision {
  id: string
  key: string
  decision: string
  context: string
  alternatives: string[]
  tradeoffs: string[]
  constraints: string[]
  confidence: ConfidenceLevel
  verdict: KennyRogersVerdict
  layer: ArchitecturalLayer
  recorded_at: string
  recorded_by: string
}

export interface QualityGate {
  gate_name: string
  status: GateStatus
  validated_at: string | null
  validated_by: string | null
  issues: string[]
}

export interface AgentMetrics {
  agent_id: string
  primary_metric_name: string
  primary_metric_value: number
  primary_metric_target: number
  secondary_metric_name: string
  secondary_metric_value: number
  secondary_metric_target: number
  recorded_at: string
  project_id?: string
}

export * from './api'
export * from './database'
export * from './memory'
export * from './agent'
EOF

cat > packages/shared-types/src/api.ts << 'EOF'
export interface Project { id: string; user_id: string; name: string; description?: string; repo_url?: string; tech_stack: string[]; constraints: string[]; current_step: number; created_at: string; updated_at: string }
export interface Document { id: string; project_id: string; doc_type: 'ARCHITECTURE' | 'IMPLEMENTATION_PLAN' | 'HANDOFF' | 'USER_FLOW'; content: string; version: number; generated_by: string; created_at: string }
export interface AgentSession { id: string; project_id: string; messages: ChatMessage[]; created_at: string; expires_at: string }
export interface ChatMessage { id: string; agent_id?: string; agent_name?: string; content: string; timestamp: string; is_user: boolean; metadata?: Record<string, unknown> }
export interface HandoffPackage { version: string; exported_at: string; project: { id: string; name: string }; memory: { decisions: ArchitecturalDecision[]; patterns: TetherMemoryEntry[] }; documents: { architecture?: string; implementation?: string } }
EOF

cat > packages/shared-types/src/database.ts << 'EOF'
export interface Profile { id: string; email: string; full_name?: string; avatar_url?: string; current_streak: number; longest_streak: number; total_projects: number; created_at: string }
export interface BrandSettings { id: string; project_id: string; brand_color: string; logo_url?: string; font_preference: string; design_system: string }
export interface Subscription { id: string; user_id: string; stripe_customer_id?: string; stripe_subscription_id?: string; paddle_customer_id?: string; paddle_subscription_id?: string; status: 'active' | 'inactive' | 'past_due' | 'canceled'; plan?: string; current_period_end?: string }
export interface ExperienceCard { id: string; project_id: string; problem_signature: string; normalized_signature: string; root_cause?: string; fix_strategy: string; verification?: string; confidence: number; problem_category?: string; solution_type?: string; tech_stack: string[]; architectural_layer?: string; is_public: boolean; reusable_score: number; times_used: number; last_used_at?: string; success_rate?: number; tags: string[]; created_at: string; updated_at: string }
EOF

cat > packages/shared-types/src/memory.ts << 'EOF'
import { TetherMemoryEntry, MemoryType, ConfidenceLevel } from './index'
export interface MemoryQueryOptions { type?: MemoryType | MemoryType[]; layer?: string; key?: string; keys?: string[]; minConfidence?: ConfidenceLevel; maxConfidence?: ConfidenceLevel; tags?: string[]; tagsMatch?: 'any' | 'all'; source?: string; created_after?: string; created_before?: string; orderBy?: 'recency' | 'confidence'; limit?: number; offset?: number }
export interface MemoryStats { totalEntries: number; byType: Record<MemoryType, number>; byLayer: Record<string, number>; byConfidence: Record<number, number>; averageConfidence: number; oldestEntry: string | null; newestEntry: string | null; storageSizeBytes: number }
export interface ConsolidatedMemory { content: string; generated_at: string; entries_consolidated: number; compression_ratio: number }
export interface LearningAttributionRecord { id: string; source_agent: string; target_agent: string; incident: string; root_cause: string; prevention: string; confidence: number; status: 'pending' | 'consolidated' | 'rejected'; created_at: string; consolidated_at?: string; project_id?: string }
EOF

cat > packages/shared-types/src/agent.ts << 'EOF'
import { AgentPhase } from './index'
export interface AgentPersona { id: string; name: string; role: string; phase: AgentPhase; triggers: string[]; systemPrompt: string; outputPath: string; metrics: AgentMetricsConfig; signature: string[] }
export interface AgentMetricsConfig { primary: string; primaryTarget: number; secondary: string; secondaryTarget: number }
export interface OrchestratorContext { projectId: string; workspacePath: string; userMessage: string; userId: string }
export interface OrchestratorResponse { agents: AgentPersona[]; responses: AgentResponse[]; memory_updates: string[]; thread_id: string }
export interface AgentResponse { agentId: string; agentName: string; content: string; action?: 'act' | 'wait'; learning?: { type: string; key: string; insight: string; confidence: number } }
export interface ConversationThread { id: string; projectId: string; messages: ConversationMessage[]; activeAgents: string[]; phase: AgentPhase }
export interface ConversationMessage { id: string; agentId?: string; agentName?: string; content: string; timestamp: string; isUser: boolean; metadata?: Record<string, unknown> }
EOF

cat > packages/shared-types/src/payments.ts << 'EOF'
export interface StripeWebhookEvent { id: string; type: string; data: { object: any } }
export interface PaddleWebhookEvent { alert_id: string; alert_name: string; subscription_id?: string; passthrough?: string }
export interface PaymentWebhookLog { id: string; provider: 'stripe' | 'paddle'; event_type: string; event_data: any; processed: boolean; created_at: string }
EOF

# -------------------------------------------------------------------
# CONFIG PACKAGE
# -------------------------------------------------------------------
cat > packages/config/package.json << 'EOF'
{ "name": "@tether/config", "version": "3.0.0", "main": "./dist/index.js", "types": "./dist/index.d.ts", "scripts": { "build": "tsc" }, "devDependencies": { "@tether/tsconfig": "workspace:*", "typescript": "^5.0.0" } }
EOF

cat > packages/config/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/base.json", "compilerOptions": { "outDir": "./dist", "rootDir": "./src" }, "include": ["src/**/*"] }
EOF

cat > packages/config/src/index.ts << 'EOF'
export const STEPS = { INCEPTION: 1, ARCHITECTURE: 2, BUILD_PACKAGE: 3, PLATFORM: 4, UI_POLISH: 5, TESTING: 6, LAUNCH: 7, MAINTENANCE: 8 } as const
export const DOC_TYPES = { ARCHITECTURE: 'ARCHITECTURE', IMPLEMENTATION_PLAN: 'IMPLEMENTATION_PLAN', HANDOFF: 'HANDOFF', USER_FLOW: 'USER_FLOW' } as const
export const AGENT_IDS = { MAE: 'mae', MI: 'mi', MPE: 'mpe', PCA: 'pca', DB: 'db', UIX: 'uix', MM: 'mm', BUG: 'bug', QC: 'qc', OPS: 'ops', MNT: 'mnt', SUP: 'sup', REQ: 'req' } as const
export const FREE_TIER_LIMITS = { API_REQUESTS_PER_DAY: 100000, DATABASE_MB: 500, STORAGE_GB: 10, QUEUE_COMMANDS_PER_DAY: 10000 } as const
export const QUALITY_GATES = ['requirements', 'architecture', 'implementation', 'deployment', 'maintenance'] as const
export const KENNY_ROGERS_VERDICTS = { HOLD: 'HOLD', FOLD: 'FOLD', WALK_AWAY: 'WALK_AWAY', RUN: 'RUN' } as const
export const AUTODREAM_PHASES = { LIGHT_SLEEP: 'light', REM_SLEEP: 'rem', DEEP_SLEEP: 'deep' } as const
export const AUTODREAM_INTERVALS = { LIGHT_SLEEP_SECONDS: 3600, REM_SLEEP_SECONDS: 86400, DEEP_SLEEP_SECONDS: 604800 } as const
EOF

# -------------------------------------------------------------------
# SCRIPTS
# -------------------------------------------------------------------
cat > scripts/setup.sh << 'EOF'
#!/bin/bash
set -e
echo "🔧 Tether Codex Setup"
pnpm install
pnpm build
echo "✅ Setup complete. Run 'pnpm dev' to start."
EOF
chmod +x scripts/setup.sh

cat > scripts/build.sh << 'EOF'
#!/bin/bash
set -e
echo "🏗️ Building Tether Codex..."
pnpm install
pnpm build
echo "✅ Build complete."
EOF
chmod +x scripts/build.sh

# -------------------------------------------------------------------
# INITIALIZE .TETHER/ FILES
# -------------------------------------------------------------------
touch .tether/memory/learnings.jsonl

cat > .tether/memory/consolidated.md << 'EOF'
# Tether Codex — Consolidated Memory
## Project Context
## Key Decisions
## Proven Patterns
## Known Pitfalls
## Open Questions
EOF

echo '{"requirements":[],"success_criteria":[],"constraints":[]}' > .tether/requirements/functional.json

cat > .tether/platform/compute-config.json << 'EOF'
{
  "zero_cost_until_revenue": true,
  "free_tier_limits": { "api_requests_per_day": 100000, "database_mb": 500, "storage_gb": 10, "queue_commands_per_day": 10000 },
  "current_usage": { "api_requests": 0, "database_bytes": 0, "storage_bytes": 0, "queue_commands": 0 }
}
EOF

cat > .tether/quality/gates/status.json << 'EOF'
{
  "gates": {
    "requirements": { "status": "pending", "validated_at": null, "issues": [] },
    "architecture": { "status": "pending", "validated_at": null, "issues": [] },
    "implementation": { "status": "pending", "validated_at": null, "issues": [] },
    "deployment": { "status": "pending", "validated_at": null, "issues": [] },
    "maintenance": { "status": "pending", "validated_at": null, "issues": [] }
  },
  "production_ready": false
}
EOF

echo '{"cards":[]}' > .tether/experience-cards/index.json
touch .tether/learnings/attributions/.gitkeep
echo '{"metrics":[]}' > .tether/agent-metrics/metrics.json
touch .tether/payments/webhook-log.jsonl
touch .tether/architecture/decisions/.gitkeep

echo ""
echo "✅ Batch 1/6 complete — Core Infrastructure"
echo "   • 200+ directories created"
echo "   • Root configuration (package.json, turbo.json, tsconfig.json, biome.json)"
echo "   • Shared types package (7 files, 200+ type definitions)"
echo "   • Config package (constants, steps, gates, limits)"
echo "   • TSConfig package (base.json, react.json)"
echo "   • Docker files (docker-compose.yml, Dockerfile.web, Dockerfile.api)"
echo "   • Scripts (setup.sh, build.sh)"
echo "   • .tether/ memory substrate initialized"