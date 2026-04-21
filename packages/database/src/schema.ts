import { pgTable, uuid, text, integer, timestamp, jsonb, boolean, real, index, uniqueIndex } from 'drizzle-orm/pg-core'

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
  projectIdx: index('idx_experience_cards_project_id').on(t.project_id)
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
}, (t) => ({ agentIdx: index('idx_agent_metrics_agent').on(t.agent_id) }))

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
}, (t) => ({ projectIdx: index('idx_maintenance_logs_project').on(t.project_id) }))

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