CREATE TABLE public.quality_gates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  gate_name TEXT NOT NULL CHECK (gate_name IN ('requirements', 'architecture', 'implementation', 'deployment', 'maintenance')),
  status TEXT DEFAULT 'pending',
  issues TEXT[] DEFAULT '{}',
  validated_at TIMESTAMPTZ,
  validated_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_quality_gates_project ON public.quality_gates(project_id);
ALTER TABLE public.quality_gates ENABLE ROW LEVEL SECURITY;
