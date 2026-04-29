CREATE TABLE IF NOT EXISTS skill_versions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  skill_name TEXT NOT NULL REFERENCES skills(name) ON DELETE CASCADE,
  from_version TEXT NOT NULL,
  to_version TEXT NOT NULL,
  breaking_change BOOLEAN DEFAULT false,
  migration_script TEXT,
  release_notes TEXT,
  upgraded_at TIMESTAMPTZ DEFAULT NOW()
);
CREATE INDEX IF NOT EXISTS idx_skill_versions_name ON skill_versions(skill_name);
ALTER TABLE skill_versions ENABLE ROW LEVEL SECURITY;
