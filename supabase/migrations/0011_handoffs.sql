CREATE TABLE IF NOT EXISTS handoffs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_agent TEXT NOT NULL,
  to_agent TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('delegation','escalation','consultation','handoff')),
  task JSONB NOT NULL,
  urgency TEXT DEFAULT 'normal',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending','accepted','completed','failed','expired')),
  result JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  accepted_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);
CREATE INDEX IF NOT EXISTS idx_handoffs_from ON handoffs(from_agent, status);
CREATE INDEX IF NOT EXISTS idx_handoffs_to ON handoffs(to_agent, status);
ALTER TABLE handoffs ENABLE ROW LEVEL SECURITY;
