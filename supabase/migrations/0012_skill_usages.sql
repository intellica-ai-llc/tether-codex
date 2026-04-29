CREATE TABLE IF NOT EXISTS skill_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_id UUID NOT NULL REFERENCES skills(id) ON DELETE CASCADE,
  project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
  agent TEXT NOT NULL,
  outcome TEXT NOT NULL CHECK (outcome IN ('success','partial_success','failure')),
  user_feedback TEXT CHECK (user_feedback IN ('approved','requested_changes','rejected')),
  duration_ms INTEGER,
  tool_calls_count INTEGER DEFAULT 0,
  had_errors BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_skill_usages_skill ON skill_usages(skill_id);
ALTER TABLE skill_usages ENABLE ROW LEVEL SECURITY;
