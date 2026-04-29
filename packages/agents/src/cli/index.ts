#!/usr/bin/env node
import { AgentOrchestrator } from '../orchestrator/index.js'
import { ALL_PERSONAS } from '../personas/index.js'
import {
  TetherMemoryStorage,
  AutoDreamConsolidator,
  TetherHandoffPackager,
} from '@tether/memory'

const cmd = process.argv[2]
const args = process.argv.slice(3)
const msg = args.join(' ')

async function main() {
  const projectId = process.env.TETHER_PROJECT_ID || 'default'
  const orch = new AgentOrchestrator(projectId)
  const mem = new TetherMemoryStorage(projectId)
  await mem.initialize()

  if (cmd === 'chat' || !cmd) {
    const r = await orch.processMessage(msg, {
      projectId,
      workspacePath: process.cwd(),
      userMessage: msg,
      userId: 'cli-user',
      sessionId: `cli-${Date.now()}`,
    })
    r.responses.forEach(r =>
      console.log(`[${r.agentName}] ${r.content}`)
    )
  } else if (cmd === 'agents') {
    ALL_PERSONAS.forEach(a =>
      console.log(`@${a.id} — ${a.name} (${a.role})`)
    )
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
    console.log(
      JSON.stringify(
        {
          activeAgents: ALL_PERSONAS.length,
          memoryEntries: (await mem.query({})).length,
        },
        null,
        2
      )
    )
  } else {
    console.log('Commands: chat, agents, memory, dream, export, status')
  }
}
main()
