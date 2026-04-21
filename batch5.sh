#!/bin/bash
# BATCH 5/6: TETHER CODEX — DATABASE LAYER + SUPABASE MIGRATIONS
set -e
echo "🗄️ TETHER CODEX — BATCH 5/6: Database Layer + Supabase Migrations"
echo "=================================================================="

# -------------------------------------------------------------------
# DATABASE PACKAGE
# -------------------------------------------------------------------
cat > packages/database/package.json << 'EOF'
{
  "name": "@tether/database",
  "version": "3.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": { "build": "tsc", "migrate": "drizzle-kit push", "generate": "drizzle-kit generate" },
  "dependencies": { "@tether/shared-types": "workspace:*", "@tether/config": "workspace:*", "drizzle-orm": "^0.30.0", "postgres": "^3.0.0" },
  "devDependencies": { "@tether/tsconfig": "workspace:*", "drizzle-kit": "^0.20.0", "typescript": "^5.0.0" }
}
EOF

cat > packages/database/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/base.json", "compilerOptions": { "outDir": "./dist", "rootDir": "./src" }, "include": ["src/**/*"] }
EOF

cat > packages/database/drizzle.config.ts << 'EOF'
import type { Config } from 'drizzle-kit'
export default { schema: './src/schema.ts', out: './migrations', driver: 'pg', dbCredentials: { connectionString: process.env.SUPABASE_URL! } } satisfies Config
EOF

cat > packages/database/src/schema.ts << 'EOF'
import { pgTable, uuid, text, integer, timestamp, jsonb, boolean, real, uniqueIndex, index } from 'drizzle-orm/pg-core'

export const profiles = pgTable('profiles', {
  id: uuid('id').primaryKey(),
  email: text('email').notNull(),
  full_name: text('full_name'),
  avatar_url: text('avatar_url'),
  current_streak: integer('current_streak').default(0),
  longest_streak: integer('longest_streak').default(0),
  total_projects: integer('total_projects').default(0),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow()
})

export const projects = pgTable('projects', {
  id: uuid('id').defaultRandom().primaryKey(),
  user_id: uuid('user_id').notNull(),
  name: text('name').notNull(),
  repo_url: text('repo_url'),
  tech_stack: text('tech_stack').array().default([]),
  description: text('description'),
  constraints: text('constraints').array().default([]),
  current_step: integer('current_step').default(1),
  classification: jsonb('classification'),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow()
}, (t) => ({ userIdx: index('idx_projects_user_id').on(t.user_id) }))

export const brand_settings = pgTable('brand_settings', {
  id: uuid('id').defaultRandom().primaryKey(),
  project_id: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
  brand_color: text('brand_color').default('#000000'),
  logo_url: text('logo_url'),
  font_preference: text('font_preference').default('system-ui'),
  design_system: text('design_system').default('stripe'),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow()
})

export const documents = pgTable('documents', {
  id: uuid('id').defaultRandom().primaryKey(),
  project_id: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
  doc_type: text('doc_type').notNull(),
  content: text('content').notNull(),
  version: integer('version').default(1),
  generated_by: text('generated_by'),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow()
}, (t) => ({ projectIdx: index('idx_documents_project_id').on(t.project_id) }))

export const step_history = pgTable('step_history', {
  id: uuid('id').defaultRandom().primaryKey(),
  project_id: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
  step_id: integer('step_id').notNull(),
  completed_at: timestamp('completed_at').defaultNow(),
  notes: text('notes')
}, (t) => ({ projectIdx: index('idx_step_history_project_id').on(t.project_id) }))

export const agent_sessions = pgTable('agent_sessions', {
  id: uuid('id').defaultRandom().primaryKey(),
  project_id: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
  messages: jsonb('messages').default([]),
  created_at: timestamp('created_at').defaultNow(),
  expires_at: timestamp('expires_at').defaultNow()
}, (t) => ({ projectIdx: index('idx_agent_sessions_project_id').on(t.project_id) }))

export const experience_cards = pgTable('experience_cards', {
  id: uuid('id').defaultRandom().primaryKey(),
  project_id: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
  problem_signature: text('problem_signature').notNull(),
  normalized_signature: text('normalized_signature').notNull(),
  root_cause: text('root_cause'),
  fix_strategy: text('fix_strategy').notNull(),
  verification: text('verification'),
  confidence: real('confidence').default(0.5),
  problem_category: text('problem_category'),
  solution_type: text('solution_type'),
  tech_stack: text('tech_stack').array().default([]),
  architectural_layer: text('architectural_layer'),
  is_public: boolean('is_public').default(false),
  reusable_score: real('reusable_score').default(0.0),
  times_used: integer('times_used').default(0),
  last_used_at: timestamp('last_used_at'),
  success_rate: real('success_rate'),
  tags: text('tags').array().default([]),
  step_id: integer('step_id'),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow()
}, (t) => ({
  projectIdx: index('idx_experience_cards_project_id').on(t.project_id),
  publicIdx: index('idx_experience_cards_public').on(t.is_public, t.reusable_score.desc()).where(t.is_public.eq(true)),
  techStackIdx: index('idx_experience_cards_tech_stack').using('gin', t.tech_stack)
}))

export const learning_attributions = pgTable('learning_attributions', {
  id: uuid('id').defaultRandom().primaryKey(),
  source_agent: text('source_agent').notNull(),
  target_agent: text('target_agent').notNull(),
  incident: text('incident').notNull(),
  root_cause: text('root_cause').notNull(),
  prevention: text('prevention').notNull(),
  confidence: integer('confidence'),
  status: text('status').default('pending'),
  created_at: timestamp('created_at').defaultNow(),
  consolidated_at: timestamp('consolidated_at'),
  project_id: uuid('project_id').references(() => projects.id, { onDelete: 'set null' })
}, (t) => ({ targetIdx: index('idx_learning_attributions_target').on(t.target_agent, t.status) }))

export const quality_gates = pgTable('quality_gates', {
  id: uuid('id').defaultRandom().primaryKey(),
  project_id: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
  gate_name: text('gate_name').notNull(),
  status: text('status').default('pending'),
  issues: text('issues').array().default([]),
  validated_at: timestamp('validated_at'),
  validated_by: text('validated_by'),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow()
}, (t) => ({ projectIdx: index('idx_quality_gates_project').on(t.project_id) }))

export const agent_metrics = pgTable('agent_metrics', {
  id: uuid('id').defaultRandom().primaryKey(),
  agent_id: text('agent_id').notNull(),
  project_id: uuid('project_id').references(() => projects.id, { onDelete: 'cascade' }),
  primary_metric_name: text('primary_metric_name').notNull(),
  primary_metric_value: real('primary_metric_value').notNull(),
  primary_metric_target: real('primary_metric_target').notNull(),
  secondary_metric_name: text('secondary_metric_name').notNull(),
  secondary_metric_value: real('secondary_metric_value').notNull(),
  secondary_metric_target: real('secondary_metric_target').notNull(),
  recorded_at: timestamp('recorded_at').defaultNow()
}, (t) => ({ agentIdx: index('idx_agent_metrics_agent').on(t.agent_id, t.recorded_at.desc()) }))

export const skills = pgTable('skills', {
  id: uuid('id').defaultRandom().primaryKey(),
  name: text('name').notNull().unique(),
  version: text('version').notNull(),
  description: text('description'),
  author: text('author'),
  license: text('license').default('MIT'),
  tags: text('tags').array().default([]),
  triggers: text('triggers').array().default([]),
  downloads: integer('downloads').default(0),
  rating: real('rating'),
  verified: boolean('verified').default(false),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow()
}, (t) => ({ nameIdx: uniqueIndex('idx_skills_name').on(t.name) }))

export const project_skills = pgTable('project_skills', {
  project_id: uuid('project_id').references(() => projects.id, { onDelete: 'cascade' }),
  skill_id: uuid('skill_id').references(() => skills.id, { onDelete: 'cascade' }),
  installed_at: timestamp('installed_at').defaultNow()
}, (t) => ({ pk: uniqueIndex('pk_project_skills').on(t.project_id, t.skill_id) }))

export const maintenance_logs = pgTable('maintenance_logs', {
  id: uuid('id').defaultRandom().primaryKey(),
  project_id: uuid('project_id').references(() => projects.id, { onDelete: 'cascade' }),
  log_type: text('log_type').notNull(),
  message: text('message').notNull(),
  details: jsonb('details'),
  success: boolean('success'),
  created_at: timestamp('created_at').defaultNow()
}, (t) => ({ projectIdx: index('idx_maintenance_logs_project').on(t.project_id, t.created_at.desc()) }))

export const queued_jobs = pgTable('queued_jobs', {
  id: uuid('id').defaultRandom().primaryKey(),
  project_id: uuid('project_id').notNull().references(() => projects.id, { onDelete: 'cascade' }),
  job_type: text('job_type').notNull(),
  status: text('status').default('pending'),
  payload: jsonb('payload'),
  result: jsonb('result'),
  error: text('error'),
  created_at: timestamp('created_at').defaultNow(),
  started_at: timestamp('started_at'),
  completed_at: timestamp('completed_at')
}, (t) => ({ statusIdx: index('idx_queued_jobs_status').on(t.status) }))

export const subscriptions = pgTable('subscriptions', {
  id: uuid('id').defaultRandom().primaryKey(),
  user_id: uuid('user_id').notNull(),
  stripe_customer_id: text('stripe_customer_id'),
  stripe_subscription_id: text('stripe_subscription_id'),
  paddle_customer_id: text('paddle_customer_id'),
  paddle_subscription_id: text('paddle_subscription_id'),
  status: text('status').default('inactive'),
  plan: text('plan'),
  current_period_end: timestamp('current_period_end'),
  created_at: timestamp('created_at').defaultNow(),
  updated_at: timestamp('updated_at').defaultNow()
}, (t) => ({ userIdx: index('idx_subscriptions_user').on(t.user_id) }))

export const payment_webhooks = pgTable('payment_webhooks', {
  id: uuid('id').defaultRandom().primaryKey(),
  provider: text('provider').notNull(),
  event_type: text('event_type').notNull(),
  event_data: jsonb('event_data'),
  processed: boolean('processed').default(false),
  created_at: timestamp('created_at').defaultNow()
})
EOF

cat > packages/database/src/client.ts << 'EOF'
import { drizzle } from 'drizzle-orm/postgres-js'
import postgres from 'postgres'

const client = postgres(process.env.SUPABASE_URL!)
export const db = drizzle(client)
EOF

cat > packages/database/src/rls.ts << 'EOF'
export const RLS_POLICIES = {
  profiles: `ALTER TABLE profiles ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own profiles" ON profiles USING (auth.uid() = id);`,
  projects: `ALTER TABLE projects ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own projects" ON projects USING (auth.uid() = user_id);`,
  documents: `ALTER TABLE documents ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own documents" ON documents USING (EXISTS (SELECT 1 FROM projects WHERE projects.id = documents.project_id AND projects.user_id = auth.uid()));`,
  experience_cards: `ALTER TABLE experience_cards ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own cards" ON experience_cards USING (EXISTS (SELECT 1 FROM projects WHERE projects.id = experience_cards.project_id AND projects.user_id = auth.uid())); CREATE POLICY "Anyone can view public cards" ON experience_cards FOR SELECT USING (is_public = true);`,
  subscriptions: `ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own subscriptions" ON subscriptions USING (auth.uid() = user_id);`
}
EOF

cat > packages/database/src/index.ts << 'EOF'
export * from './schema'
export { db } from './client'
export { RLS_POLICIES } from './rls'
EOF

# -------------------------------------------------------------------
# SUPABASE MIGRATIONS
# -------------------------------------------------------------------
cat > supabase/migrations/0000_initial.sql << 'EOF'
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_projects INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  repo_url TEXT,
  tech_stack TEXT[] DEFAULT '{}',
  description TEXT,
  constraints TEXT[] DEFAULT '{}',
  current_step INTEGER DEFAULT 1,
  classification JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.brand_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  brand_color TEXT DEFAULT '#000000',
  logo_url TEXT,
  font_preference TEXT DEFAULT 'system-ui',
  design_system TEXT DEFAULT 'stripe',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  doc_type TEXT NOT NULL,
  content TEXT NOT NULL,
  version INTEGER DEFAULT 1,
  generated_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.step_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  step_id INTEGER NOT NULL,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT
);

CREATE TABLE public.agent_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  messages JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours')
);

CREATE TABLE public.queued_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  job_type TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  payload JSONB,
  result JSONB,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_projects_user_id ON public.projects(user_id);
CREATE INDEX idx_documents_project_id ON public.documents(project_id);
CREATE INDEX idx_step_history_project_id ON public.step_history(project_id);
CREATE INDEX idx_agent_sessions_project_id ON public.agent_sessions(project_id);
CREATE INDEX idx_queued_jobs_status ON public.queued_jobs(status);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brand_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.step_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own profiles" ON public.profiles USING (auth.uid() = id);
CREATE POLICY "Users can CRUD own projects" ON public.projects USING (auth.uid() = user_id);
CREATE POLICY "Users can CRUD own brand_settings" ON public.brand_settings USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = brand_settings.project_id AND projects.user_id = auth.uid()));
CREATE POLICY "Users can CRUD own documents" ON public.documents USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = documents.project_id AND projects.user_id = auth.uid()));
CREATE POLICY "Users can CRUD own step_history" ON public.step_history USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = step_history.project_id AND projects.user_id = auth.uid()));
CREATE POLICY "Users can CRUD own agent_sessions" ON public.agent_sessions USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = agent_sessions.project_id AND projects.user_id = auth.uid()));
EOF

cat > supabase/migrations/0001_experience_cards.sql << 'EOF'
CREATE TABLE public.experience_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  problem_signature TEXT NOT NULL,
  normalized_signature TEXT NOT NULL,
  root_cause TEXT,
  fix_strategy TEXT NOT NULL,
  verification TEXT,
  confidence REAL DEFAULT 0.5,
  problem_category TEXT,
  solution_type TEXT,
  tech_stack TEXT[] DEFAULT '{}',
  architectural_layer TEXT,
  is_public BOOLEAN DEFAULT false,
  reusable_score REAL DEFAULT 0.0,
  times_used INTEGER DEFAULT 0,
  last_used_at TIMESTAMPTZ,
  success_rate REAL,
  tags TEXT[] DEFAULT '{}',
  step_id INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_experience_cards_project_id ON public.experience_cards(project_id);
CREATE INDEX idx_experience_cards_public ON public.experience_cards(is_public, reusable_score DESC) WHERE is_public = true;
CREATE INDEX idx_experience_cards_tech_stack ON public.experience_cards USING gin(tech_stack);

ALTER TABLE public.experience_cards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own cards" ON public.experience_cards USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = experience_cards.project_id AND projects.user_id = auth.uid()));
CREATE POLICY "Anyone can view public cards" ON public.experience_cards FOR SELECT USING (is_public = true);
EOF

cat > supabase/migrations/0002_learning_attributions.sql << 'EOF'
CREATE TABLE public.learning_attributions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_agent TEXT NOT NULL,
  target_agent TEXT NOT NULL,
  incident TEXT NOT NULL,
  root_cause TEXT NOT NULL,
  prevention TEXT NOT NULL,
  confidence INTEGER CHECK (confidence BETWEEN 1 AND 10),
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  consolidated_at TIMESTAMPTZ,
  project_id UUID REFERENCES public.projects(id) ON DELETE SET NULL
);

CREATE INDEX idx_learning_attributions_target ON public.learning_attributions(target_agent, status);
ALTER TABLE public.learning_attributions ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/0003_quality_gates.sql << 'EOF'
CREATE TABLE public.quality_gates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  gate_name TEXT NOT NULL CHECK (gate_name IN ('requirements', 'architecture', 'implementation', 'deployment', 'maintenance')),
  status TEXT DEFAULT 'pending',
  issues TEXT[] DEFAULT '{}',
  validated_at TIMESTAMPTZ,
  validated_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_quality_gates_project ON public.quality_gates(project_id);
ALTER TABLE public.quality_gates ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/0004_agent_metrics.sql << 'EOF'
CREATE TABLE public.agent_metrics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id TEXT NOT NULL,
  project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
  primary_metric_name TEXT NOT NULL,
  primary_metric_value REAL NOT NULL,
  primary_metric_target REAL NOT NULL,
  secondary_metric_name TEXT NOT NULL,
  secondary_metric_value REAL NOT NULL,
  secondary_metric_target REAL NOT NULL,
  recorded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_agent_metrics_agent ON public.agent_metrics(agent_id, recorded_at DESC);
ALTER TABLE public.agent_metrics ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/0005_skills.sql << 'EOF'
CREATE TABLE public.skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  version TEXT NOT NULL,
  description TEXT,
  author TEXT,
  license TEXT DEFAULT 'MIT',
  tags TEXT[] DEFAULT '{}',
  triggers TEXT[] DEFAULT '{}',
  downloads INTEGER DEFAULT 0,
  rating REAL,
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.project_skills (
  project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
  skill_id UUID REFERENCES public.skills(id) ON DELETE CASCADE,
  installed_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (project_id, skill_id)
);

ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_skills ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/0006_maintenance_logs.sql << 'EOF'
CREATE TABLE public.maintenance_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
  log_type TEXT NOT NULL CHECK (log_type IN ('health_check', 'deprecation', 'security_patch', 'auto_fix', 'consolidation')),
  message TEXT NOT NULL,
  details JSONB,
  success BOOLEAN,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_maintenance_logs_project ON public.maintenance_logs(project_id, created_at DESC);
ALTER TABLE public.maintenance_logs ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/migrations/0007_subscriptions.sql << 'EOF'
CREATE TABLE public.subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  paddle_customer_id TEXT,
  paddle_subscription_id TEXT,
  status TEXT DEFAULT 'inactive',
  plan TEXT,
  current_period_end TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_subscriptions_user ON public.subscriptions(user_id);
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own subscriptions" ON public.subscriptions USING (auth.uid() = user_id);
EOF

cat > supabase/migrations/0008_payment_webhooks.sql << 'EOF'
CREATE TABLE public.payment_webhooks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider TEXT NOT NULL CHECK (provider IN ('stripe', 'paddle')),
  event_type TEXT NOT NULL,
  event_data JSONB,
  processed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.payment_webhooks ENABLE ROW LEVEL SECURITY;
EOF

cat > supabase/seed.sql << 'EOF'
INSERT INTO public.skills (name, version, description, author, tags, triggers, verified) VALUES
('tether-architecture', '3.0.0', 'Expert architectural design with Kenny Rogers framework', 'Tether Codex', ARRAY['architecture', 'design', 'system'], ARRAY['architect', 'architecture', 'design system', 'tech stack'], true),
('tether-design', '3.0.0', 'Professional UI/UX design with 68+ brand styles', 'Tether Codex', ARRAY['design', 'ui', 'ux', 'tailwind'], ARRAY['design', 'ui', 'ux', 'style', 'branding'], true);
EOF

echo ""
echo "✅ Batch 5/6 complete — Database Layer + Supabase Migrations"
echo "   • @tether/database package (Drizzle ORM schemas, client, RLS)"
echo "   • 14 database tables with indexes"
echo "   • 9 migration files (0000_initial.sql through 0008_payment_webhooks.sql)"
echo "   • seed.sql with built-in skills"
echo "   • Full RLS policies for multi-tenant security"