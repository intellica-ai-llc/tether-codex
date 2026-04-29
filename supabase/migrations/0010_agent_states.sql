CREATE TABLE IF NOT EXISTS agent_states (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  agent_id TEXT NOT NULL,
  session_id TEXT,
  short_term JSONB DEFAULT '{}',
  working JSONB DEFAULT '{}',
  long_term JSONB DEFAULT '{}',
  metrics JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  last_active TIMESTAMPTZ DEFAULT NOW(),
  last_saved_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_agent_states_agent ON agent_states(agent_id, last_active DESC);
ALTER TABLE agent_states ENABLE ROW LEVEL SECURITY;
