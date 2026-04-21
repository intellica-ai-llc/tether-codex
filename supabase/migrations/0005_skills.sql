CREATE TABLE public.skills (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  version TEXT NOT NULL,
  description TEXT,
  author TEXT,
  license TEXT DEFAULT 'MIT',
  tags TEXT[] DEFAULT '{}',
  triggers TEXT[] DEFAULT '{}',
  downloads INTEGER DEFAULT 0,
  rating REAL,
  verified BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.project_skills (
  project_id UUID REFERENCES public.projects(id) ON DELETE CASCADE,
  skill_id UUID REFERENCES public.skills(id) ON DELETE CASCADE,
  installed_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (project_id, skill_id)
);

ALTER TABLE public.skills ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.project_skills ENABLE ROW LEVEL SECURITY;
