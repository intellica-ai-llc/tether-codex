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
