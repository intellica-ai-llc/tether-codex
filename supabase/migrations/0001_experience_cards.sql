CREATE TABLE public.experience_cards (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  problem_signature TEXT NOT NULL,
  normalized_signature TEXT NOT NULL,
  root_cause TEXT,
  fix_strategy TEXT NOT NULL,
  verification TEXT,
  confidence REAL DEFAULT 0.5,
  problem_category TEXT,
  solution_type TEXT,
  tech_stack TEXT[] DEFAULT '{}',
  architectural_layer TEXT,
  is_public BOOLEAN DEFAULT false,
  reusable_score REAL DEFAULT 0.0,
  times_used INTEGER DEFAULT 0,
  last_used_at TIMESTAMPTZ,
  success_rate REAL,
  tags TEXT[] DEFAULT '{}',
  step_id INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_experience_cards_project_id ON public.experience_cards(project_id);
CREATE INDEX idx_experience_cards_public ON public.experience_cards(is_public, reusable_score DESC) WHERE is_public = true;
CREATE INDEX idx_experience_cards_tech_stack ON public.experience_cards USING gin(tech_stack);

ALTER TABLE public.experience_cards ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can CRUD own cards" ON public.experience_cards USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = experience_cards.project_id AND projects.user_id = auth.uid()));
CREATE POLICY "Anyone can view public cards" ON public.experience_cards FOR SELECT USING (is_public = true);
