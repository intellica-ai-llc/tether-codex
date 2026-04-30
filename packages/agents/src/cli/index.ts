#!/usr/bin/env node
import { AgentOrchestrator } from '../orchestrator/index.js'
import { ALL_PERSONAS } from '../personas/index.js'
import {
  TetherMemoryStorage,
  SupabaseMemoryStorage,
  AutoDreamConsolidator,
  TetherHandoffPackager,
} from '@tether/memory'

function getStorage(projectId: string): TetherMemoryStorage | SupabaseMemoryStorage {
  if (process.env.SUPABASE_URL && process.env.SUPABASE_ANON_KEY) {
    return new SupabaseMemoryStorage(projectId, process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY)
  }
  return new TetherMemoryStorage(projectId)
}

const cmd = process.argv[2]
const args = process.argv.slice(3)
const msg = args.join(' ')

async function main() {
  const projectId = process.env.TETHER_PROJECT_ID || 'default'
  const storage = getStorage(projectId)
  if (storage instanceof TetherMemoryStorage) await storage.initialize()
  const orch = new AgentOrchestrator(projectId, storage)

  if (cmd === 'chat' || !cmd) {
    const r = await orch.processMessage(msg, {
      projectId, workspacePath: process.cwd(), userMessage: msg,
      userId: 'cli-user', sessionId: `cli-${Date.now()}`
    })
    r.responses.forEach((r: any) => console.log(`[${r.agentName}] ${r.content}`))
  } else if (cmd === 'agents') {
    ALL_PERSONAS.forEach(a => console.log(`@${a.id} — ${a.name} (${a.role})`))
  } else if (cmd === 'memory') {
    console.log(JSON.stringify(await storage.query({ limit: 20 }), null, 2))
  } else if (cmd === 'dream') {
    const c = new AutoDreamConsolidator(storage as TetherMemoryStorage)
    console.log(`autoDream: ${(await c.tick())?.phase || 'no consolidation needed'}`)
  } else if (cmd === 'export') {
    const pkg = new TetherHandoffPackager(storage as TetherMemoryStorage)
    console.log(JSON.stringify(await pkg.export(projectId, 'tether-project'), null, 2))
  } else if (cmd === 'status') {
    console.log(JSON.stringify({
      activeAgents: ALL_PERSONAS.length,
      memoryEntries: (await storage.query({})).length
    }, null, 2))
  } else {
    console.log('Commands: chat, agents, memory, dream, export, status')
  }
}
main()