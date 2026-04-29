CREATE TABLE IF NOT EXISTS cron_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  schedule TEXT NOT NULL,
  prompt TEXT NOT NULL,
  skills TEXT[] DEFAULT '{}',
  delivery_platform TEXT,
  delivery_destination TEXT,
  enabled BOOLEAN DEFAULT true,
  config JSONB DEFAULT '{}',
  last_run TIMESTAMPTZ,
  next_run TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE TABLE IF NOT EXISTS cron_executions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id UUID NOT NULL REFERENCES cron_jobs(id) ON DELETE CASCADE,
  status TEXT NOT NULL CHECK (status IN ('success','failed','timeout')),
  attempt INTEGER DEFAULT 1,
  response TEXT,
  error TEXT,
  duration_ms INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_cron_jobs_enabled ON cron_jobs(enabled, next_run);
ALTER TABLE cron_jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE cron_executions ENABLE ROW LEVEL SECURITY;
