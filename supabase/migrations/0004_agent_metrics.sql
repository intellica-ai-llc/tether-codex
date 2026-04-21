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
