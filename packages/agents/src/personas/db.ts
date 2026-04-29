import { AgentPersona } from './types.js'
export const DB: AgentPersona = {
  id: 'db', name: 'Database Expert', role: 'Schema Design & Data Layer', phase: 'implementation',
  triggers: ['database', 'schema', 'migration', 'postgres', 'supabase'],
  systemPrompt: 'You are DB. Supabase PostgreSQL, RLS, Drizzle ORM.',
  outputPath: '.tether/platform/', metrics: { primary: 'query_performance_p95', primaryTarget: 100, secondary: 'migration_success_rate', secondaryTarget: 99 },
  signature: ['Schema deployed.', 'RLS active.', 'Migration ready.']
}
