#!/bin/bash
# BATCH 3/6: TETHER CODEX — AGENT SYSTEM (13 Personas + Orchestrator + Conversation + CLI)
set -e
echo "👥 TETHER CODEX — BATCH 3/6: Agent System"
echo "=========================================="

# -------------------------------------------------------------------
# AGENTS PACKAGE
# -------------------------------------------------------------------
cat > packages/agents/package.json << 'EOF'
{
  "name": "@tether/agents",
  "version": "3.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "bin": { "tether": "./dist/cli/index.js" },
  "scripts": { "build": "tsc", "test": "vitest" },
  "dependencies": { "@tether/shared-types": "workspace:*", "@tether/memory": "workspace:*", "@tether/config": "workspace:*" },
  "devDependencies": { "@tether/tsconfig": "workspace:*", "@types/node": "^20.0.0", "typescript": "^5.0.0", "vitest": "^1.0.0" }
}
EOF

cat > packages/agents/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/base.json", "compilerOptions": { "outDir": "./dist", "rootDir": "./src" }, "include": ["src/**/*"] }
EOF

# -------------------------------------------------------------------
# PERSONA TYPES
# -------------------------------------------------------------------
cat > packages/agents/src/personas/types.ts << 'EOF'
import { AgentPhase } from '@tether/shared-types'

export interface AgentPersona {
  id: string
  name: string
  role: string
  phase: AgentPhase
  triggers: string[]
  systemPrompt: string
  outputPath: string
  metrics: { primary: string; primaryTarget: number; secondary: string; secondaryTarget: number }
  signature: string[]
}
EOF

# -------------------------------------------------------------------
# MAE — MASTER ARCHITECT ESSENCE
# -------------------------------------------------------------------
cat > packages/agents/src/personas/mae.ts << 'EOF'
import { AgentPersona } from './types'
export const MAE: AgentPersona = {
  id: 'mae', name: 'Master Architect Essence', role: 'Architectural Synthesis & Decision Authority', phase: 'architecture',
  triggers: ['architect', 'architecture', 'design', 'tech stack', 'system'],
  systemPrompt: 'You are MAE. 30+ years experience. Kenny Rogers: HOLD/FOLD/WALK AWAY/RUN. Brutal honesty. Free-tier-first.',
  outputPath: '.tether/architecture/', metrics: { primary: 'decision_accuracy', primaryTarget: 90, secondary: 'pattern_reusability', secondaryTarget: 80 },
  signature: ['Takes a slow sip of coffee.', 'My friend.', 'Let me be brutally honest.', 'Now go ship.', '— Your Master Architect 🏗️']
}
EOF

# -------------------------------------------------------------------
# MI — MASTER INNOVATOR
# -------------------------------------------------------------------
cat > packages/agents/src/personas/mi.ts << 'EOF'
import { AgentPersona } from './types'
export const MI: AgentPersona = {
  id: 'mi', name: 'Master Innovator', role: 'Frontier Intelligence & Pattern Discovery', phase: 'architecture',
  triggers: ['pattern', 'innovation', 'research', 'frontier', 'emerging'],
  systemPrompt: 'You are MI. Extract invariants from frontier implementations. No hype. Engineering logic only.',
  outputPath: '.tether/architecture/patterns/', metrics: { primary: 'pattern_prediction_accuracy', primaryTarget: 80, secondary: 'insight_actionability', secondaryTarget: 70 },
  signature: ['Pattern detected.', 'Invariants extracted.', 'Frontier scan complete.']
}
EOF

# -------------------------------------------------------------------
# MPE — MASTER PRODUCT ENGINEER
# -------------------------------------------------------------------
cat > packages/agents/src/personas/mpe.ts << 'EOF'
import { AgentPersona } from './types'
export const MPE: AgentPersona = {
  id: 'mpe', name: 'Master Product Engineer', role: 'Build Package Generation', phase: 'implementation',
  triggers: ['build', 'package', 'scaffold', 'generate', 'implement'],
  systemPrompt: 'You are MPE. Generate complete build packages. Numbered batch scripts.',
  outputPath: '.tether/process/batches/', metrics: { primary: 'build_success_rate', primaryTarget: 95, secondary: 'iteration_speed', secondaryTarget: 90 },
  signature: ['Build package ready.', 'Handing off to PCA and DB.', 'Fixes applied. Redeployed.']
}
EOF

# -------------------------------------------------------------------
# PCA — PLATFORM COMPUTE AGENT
# -------------------------------------------------------------------
cat > packages/agents/src/personas/pca.ts << 'EOF'
import { AgentPersona } from './types'
export const PCA: AgentPersona = {
  id: 'pca', name: 'Platform Compute Agent', role: 'Zero-Cost Compute Orchestration', phase: 'deployment',
  triggers: ['platform', 'compute', 'deploy', 'cloudflare', 'hosting'],
  systemPrompt: 'You are PCA. Zero-cost until revenue. Cloudflare ecosystem.',
  outputPath: '.tether/platform/', metrics: { primary: 'zero_cost_compliance', primaryTarget: 100, secondary: 'scaling_prediction', secondaryTarget: 90 },
  signature: ['Zero-cost compute guaranteed.', 'Free tier limit approaching.', 'Auto-scaling enabled.']
}
EOF

# -------------------------------------------------------------------
# DB — DATABASE EXPERT
# -------------------------------------------------------------------
cat > packages/agents/src/personas/db.ts << 'EOF'
import { AgentPersona } from './types'
export const DB: AgentPersona = {
  id: 'db', name: 'Database Expert', role: 'Schema Design & Data Layer', phase: 'implementation',
  triggers: ['database', 'schema', 'migration', 'postgres', 'supabase'],
  systemPrompt: 'You are DB. Supabase PostgreSQL, RLS, Drizzle ORM.',
  outputPath: '.tether/platform/', metrics: { primary: 'query_performance_p95', primaryTarget: 100, secondary: 'migration_success_rate', secondaryTarget: 99 },
  signature: ['Schema deployed.', 'RLS active.', 'Migration ready.']
}
EOF

# -------------------------------------------------------------------
# UIX — UI/UX ENGINEER
# -------------------------------------------------------------------
cat > packages/agents/src/personas/uix.ts << 'EOF'
import { AgentPersona } from './types'
export const UIX: AgentPersona = {
  id: 'uix', name: 'UI/UX Engineer', role: 'Visual Design & Components', phase: 'implementation',
  triggers: ['design', 'ui', 'ux', 'component', 'tailwind', 'style'],
  systemPrompt: 'You are UIX. Tailwind, React, design systems (Stripe, Vercel, Linear).',
  outputPath: '.tether/marketing/design-system/', metrics: { primary: 'user_engagement', primaryTarget: 60, secondary: 'polish_cycle_reduction', secondaryTarget: 50 },
  signature: ['Three design directions.', 'Using Stripe design system.', 'Brand customization applied.']
}
EOF

# -------------------------------------------------------------------
# MM — MASTER MARKETER
# -------------------------------------------------------------------
cat > packages/agents/src/personas/mm.ts << 'EOF'
import { AgentPersona } from './types'
export const MM: AgentPersona = {
  id: 'mm', name: 'Master Marketer', role: 'Positioning & UX Direction', phase: 'discovery',
  triggers: ['marketing', 'positioning', 'brand', 'audience', 'conversion'],
  systemPrompt: 'You are MM. Positioning, messaging, conversion optimization.',
  outputPath: '.tether/marketing/', metrics: { primary: 'conversion_rate', primaryTarget: 5, secondary: 'user_retention', secondaryTarget: 60 },
  signature: ['Positioning for', 'Report sent to MPE.', 'Ready for user testing.']
}
EOF

# -------------------------------------------------------------------
# BUG — DEBUGGING AGENT
# -------------------------------------------------------------------
cat > packages/agents/src/personas/bug.ts << 'EOF'
import { AgentPersona } from './types'
export const BUG: AgentPersona = {
  id: 'bug', name: 'Debugging Agent', role: 'Root Cause Analysis', phase: 'implementation',
  triggers: ['bug', 'error', 'debug', 'fix', 'broken'],
  systemPrompt: 'You are BUG. Root cause analysis. Session replay. Permanent fixes.',
  outputPath: '.tether/debugging/', metrics: { primary: 'time_to_resolution_hours', primaryTarget: 4, secondary: 'recurrence_rate', secondaryTarget: 5 },
  signature: ['Error detected.', 'Root cause identified.', 'Fixed. Deployed.', 'Regression test added.']
}
EOF

# -------------------------------------------------------------------
# QC — QUALITY CONTROL AGENT
# -------------------------------------------------------------------
cat > packages/agents/src/personas/qc.ts << 'EOF'
import { AgentPersona } from './types'
export const QC: AgentPersona = {
  id: 'qc', name: 'Quality Control Agent', role: '5 Quality Gates', phase: 'all' as any,
  triggers: ['quality', 'gate', 'review', 'production ready'],
  systemPrompt: 'You are QC. 5 gates: requirements, architecture, implementation, deployment, maintenance.',
  outputPath: '.tether/quality/', metrics: { primary: 'production_incident_rate', primaryTarget: 1, secondary: 'gate_false_positive', secondaryTarget: 5 },
  signature: ['✅ Gate passed.', '⚠️ Gate incomplete.', 'All gates passed. Production ready.']
}
EOF

# -------------------------------------------------------------------
# OPS — DEVOPS ENGINEER
# -------------------------------------------------------------------
cat > packages/agents/src/personas/ops.ts << 'EOF'
import { AgentPersona } from './types'
export const OPS: AgentPersona = {
  id: 'ops', name: 'DevOps Engineer', role: 'Deployment & CI/CD', phase: 'deployment',
  triggers: ['deploy', 'ci/cd', 'pipeline', 'launch'],
  systemPrompt: 'You are OPS. Cloudflare, GitHub Actions, blue-green deployments.',
  outputPath: '.tether/platform/', metrics: { primary: 'deployment_success_rate', primaryTarget: 99, secondary: 'mttr_minutes', secondaryTarget: 30 },
  signature: ['Deploying to staging.', 'Blue/Green deploy initiated.', 'Deployed to production.']
}
EOF

# -------------------------------------------------------------------
# MNT — MAINTENANCE MASTER
# -------------------------------------------------------------------
cat > packages/agents/src/personas/mnt.ts << 'EOF'
import { AgentPersona } from './types'
export const MNT: AgentPersona = {
  id: 'mnt', name: 'Maintenance Master', role: '24/7 Monitoring & Auto-Fixes', phase: 'maintenance',
  triggers: ['maintenance', 'monitor', 'health', 'patch', 'update'],
  systemPrompt: 'You are MNT. 24/7 monitoring, deprecation scanning, auto-fixes.',
  outputPath: '.tether/maintenance/', metrics: { primary: 'mtbi_days', primaryTarget: 30, secondary: 'auto_fix_success_rate', secondaryTarget: 90 },
  signature: ['Monitoring enabled.', 'Security patch applied.', '24/7 monitoring active.']
}
EOF

# -------------------------------------------------------------------
# SUP — SUPPORT AGENT
# -------------------------------------------------------------------
cat > packages/agents/src/personas/sup.ts << 'EOF'
import { AgentPersona } from './types'
export const SUP: AgentPersona = {
  id: 'sup', name: 'Support Agent', role: 'User Support & Triage', phase: 'support',
  triggers: ['support', 'help', 'issue', 'question'],
  systemPrompt: 'You are SUP. First-line support, knowledge base, triage.',
  outputPath: '.tether/support/', metrics: { primary: 'time_to_first_response_hours', primaryTarget: 1, secondary: 'knowledge_base_deflection', secondaryTarget: 40 },
  signature: ['Knowledge base initialized.', 'Ticket received.', 'Escalating to BUG.']
}
EOF

# -------------------------------------------------------------------
# REQ — REQUIREMENTS ENGINEER
# -------------------------------------------------------------------
cat > packages/agents/src/personas/req.ts << 'EOF'
import { AgentPersona } from './types'
export const REQ: AgentPersona = {
  id: 'req', name: 'Requirements Engineer', role: 'Requirements Capture', phase: 'discovery',
  triggers: ['requirements', 'scope', 'define', 'spec'],
  systemPrompt: 'You are REQ. Capture, validate, prioritize requirements.',
  outputPath: '.tether/requirements/', metrics: { primary: 'requirements_stability', primaryTarget: 90, secondary: 'scope_adherence', secondaryTarget: 90 },
  signature: ['Capturing requirements.', 'Clarifying question:', 'Requirements documented.']
}
EOF

# -------------------------------------------------------------------
# PERSONAS INDEX
# -------------------------------------------------------------------
cat > packages/agents/src/personas/index.ts << 'EOF'
export { MAE } from './mae'
export { MI } from './mi'
export { MPE } from './mpe'
export { PCA } from './pca'
export { DB } from './db'
export { UIX } from './uix'
export { MM } from './mm'
export { BUG } from './bug'
export { QC } from './qc'
export { OPS } from './ops'
export { MNT } from './mnt'
export { SUP } from './sup'
export { REQ } from './req'
export { AgentPersona } from './types'

import { MAE, MI, MPE, PCA, DB, UIX, MM, BUG, QC, OPS, MNT, SUP, REQ } from './index'
export const ALL_PERSONAS = [MAE, MI, MPE, PCA, DB, UIX, MM, BUG, QC, OPS, MNT, SUP, REQ]
export const PERSONA_BY_ID: Record<string, AgentPersona> = Object.fromEntries(ALL_PERSONAS.map(p => [p.id, p]))
EOF

# -------------------------------------------------------------------
# ORCHESTRATOR
# -------------------------------------------------------------------
cat > packages/agents/src/orchestrator/index.ts << 'EOF'
import { AgentPersona, ALL_PERSONAS, PERSONA_BY_ID } from '../personas'
import { TetherMemoryStorage } from '@tether/memory'

export interface OrchestratorContext { projectId: string; workspacePath: string; userMessage: string }
export interface AgentResponse { agentId: string; agentName: string; content: string; action?: 'act' | 'wait' }

export class AgentOrchestrator {
  private memory: TetherMemoryStorage
  constructor(projectId: string) { this.memory = new TetherMemoryStorage(projectId) }

  async processMessage(message: string, context: OrchestratorContext): Promise<{ agents: AgentPersona[]; responses: AgentResponse[] }> {
    await this.memory.initialize()
    const agents = this.classifyIntent(message)
    const responses = await Promise.all(agents.map(a => this.invokeAgent(a, message)))
    return { agents, responses }
  }

  private classifyIntent(message: string): AgentPersona[] {
    const lower = message.toLowerCase()
    const matched = ALL_PERSONAS.filter(a => a.triggers.some(t => lower.includes(t)))
    if (matched.length === 0) return [PERSONA_BY_ID['mae'], PERSONA_BY_ID['mi'], PERSONA_BY_ID['req']]
    const mentions = lower.match(/@(\w+)/g)?.map(m => m.slice(1)) || []
    const mentioned = mentions.map(id => PERSONA_BY_ID[id]).filter(Boolean)
    return mentioned.length > 0 ? mentioned : matched
  }

  private async invokeAgent(agent: AgentPersona, message: string): Promise<AgentResponse> {
    return { agentId: agent.id, agentName: agent.name, content: `[${agent.name}] ${agent.signature[0]}`, action: 'wait' }
  }
}
EOF

# -------------------------------------------------------------------
# CONVERSATION
# -------------------------------------------------------------------
cat > packages/agents/src/conversation/parser.ts << 'EOF'
export function parseMessage(message: string): { mentions: string[]; content: string; isQuestion: boolean } {
  const mentions = Array.from(message.matchAll(/@(\w+)/g)).map(m => m[1].toLowerCase())
  return { mentions, content: message.replace(/@(\w+)/g, '').trim(), isQuestion: message.trim().endsWith('?') }
}
export function formatAgentResponse(agentId: string, agentName: string, content: string): string { return `**${agentName}**\n${content}` }
EOF

cat > packages/agents/src/conversation/thread.ts << 'EOF'
export interface ConversationMessage { id: string; agentId?: string; agentName?: string; content: string; timestamp: string; isUser: boolean }
export interface ConversationThread { id: string; projectId: string; messages: ConversationMessage[]; activeAgents: string[] }
export function createThread(projectId: string): ConversationThread { return { id: `thread_${Date.now()}`, projectId, messages: [], activeAgents: [] } }
export function addUserMessage(t: ConversationThread, content: string): ConversationThread { return { ...t, messages: [...t.messages, { id: `msg_${Date.now()}`, content, timestamp: new Date().toISOString(), isUser: true }] } }
export function addAgentMessage(t: ConversationThread, agentId: string, agentName: string, content: string): ConversationThread { return { ...t, messages: [...t.messages, { id: `msg_${Date.now()}`, agentId, agentName, content, timestamp: new Date().toISOString(), isUser: false }] } }
EOF

cat > packages/agents/src/conversation/handoff.ts << 'EOF'
import { PERSONA_BY_ID } from '../personas'; import { ConversationThread, addAgentMessage } from './thread'
export function detectHandoff(message: string): string | null { const m = message.match(/hand(?:ing)? off to @(\w+)/i); return m ? m[1].toLowerCase() : null }
export function executeHandoff(t: ConversationThread, targetId: string): ConversationThread { const target = PERSONA_BY_ID[targetId]; return target ? addAgentMessage(t, target.id, target.name, `Handoff received.`) : t }
EOF

cat > packages/agents/src/conversation/index.ts << 'EOF'
export { parseMessage, formatAgentResponse } from './parser'
export { createThread, addUserMessage, addAgentMessage, ConversationThread } from './thread'
export { detectHandoff, executeHandoff } from './handoff'
EOF

# -------------------------------------------------------------------
# AGENT CLI
# -------------------------------------------------------------------
cat > packages/agents/src/cli/index.ts << 'EOF'
#!/usr/bin/env node
import { AgentOrchestrator } from '../orchestrator'
import { ALL_PERSONAS } from '../personas'
import { TetherMemoryStorage, AutoDreamConsolidator, TetherHandoffPackager } from '@tether/memory'

const cmd = process.argv[2]
const args = process.argv.slice(3)
const msg = args.join(' ')

async function main() {
  const projectId = process.env.TETHER_PROJECT_ID || 'default'
  const orch = new AgentOrchestrator(projectId)
  const mem = new TetherMemoryStorage(projectId)
  await mem.initialize()

  if (cmd === 'chat' || !cmd) {
    const r = await orch.processMessage(msg, { projectId, workspacePath: process.cwd(), userMessage: msg })
    r.responses.forEach(r => console.log(`[${r.agentName}] ${r.content}`))
  } else if (cmd === 'agents') {
    ALL_PERSONAS.forEach(a => console.log(`@${a.id} — ${a.name} (${a.role})`))
  } else if (cmd === 'memory') {
    const entries = await mem.query({ limit: 20 })
    console.log(JSON.stringify(entries, null, 2))
  } else if (cmd === 'dream') {
    const c = new AutoDreamConsolidator(mem)
    const r = await c.tick()
    console.log(`autoDream: ${r?.phase || 'no consolidation needed'}`)
  } else if (cmd === 'export') {
    const pkg = new TetherHandoffPackager(mem)
    const handoff = await pkg.export(projectId, 'tether-project')
    console.log(JSON.stringify(handoff, null, 2))
  } else if (cmd === 'status') {
    console.log(JSON.stringify({ activeAgents: ALL_PERSONAS.length, memoryEntries: (await mem.query({})).length }, null, 2))
  } else {
    console.log('Commands: chat, agents, memory, dream, export, status')
  }
}
main()
EOF

# -------------------------------------------------------------------
# AGENTS INDEX
# -------------------------------------------------------------------
cat > packages/agents/src/index.ts << 'EOF'
export { AgentOrchestrator } from './orchestrator'
export { ALL_PERSONAS, PERSONA_BY_ID, AgentPersona } from './personas'
export { createThread, ConversationThread, parseMessage, formatAgentResponse } from './conversation'
EOF

echo ""
echo "✅ Batch 3/6 complete — Agent System"
echo "   • 13 agent personas (MAE, MI, MPE, PCA, DB, UIX, MM, BUG, QC, OPS, MNT, SUP, REQ)"
echo "   • AgentOrchestrator (intent classification, invocation)"
echo "   • Conversation (parser, thread, handoff)"
echo "   • Agent CLI (chat, agents, memory, dream, export, status)"