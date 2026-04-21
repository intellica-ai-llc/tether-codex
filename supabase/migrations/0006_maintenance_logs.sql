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
