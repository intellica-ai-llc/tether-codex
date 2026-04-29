CREATE TABLE public.learnings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  ts TEXT NOT NULL,
  type TEXT NOT NULL,
  key TEXT NOT NULL,
  insight TEXT NOT NULL,
  confidence INTEGER CHECK (confidence BETWEEN 1 AND 10),
  source TEXT NOT NULL,
  architectural_layer TEXT,
  decision_context TEXT,
  alternatives_considered TEXT[],
  constraints_applied TEXT[],
  relates_to TEXT[],
  tags TEXT[] DEFAULT '{}',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_learnings_project_id ON public.learnings(project_id);
CREATE INDEX idx_learnings_type ON public.learnings(type);
CREATE INDEX idx_learnings_key ON public.learnings(key);
CREATE INDEX idx_learnings_confidence ON public.learnings(confidence);
ALTER TABLE public.learnings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own learnings" ON public.learnings 
  USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = learnings.project_id AND projects.user_id = auth.uid()));
