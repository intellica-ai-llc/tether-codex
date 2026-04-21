CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  total_projects INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.projects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  repo_url TEXT,
  tech_stack TEXT[] DEFAULT '{}',
  description TEXT,
  constraints TEXT[] DEFAULT '{}',
  current_step INTEGER DEFAULT 1,
  classification JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.brand_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  brand_color TEXT DEFAULT '#000000',
  logo_url TEXT,
  font_preference TEXT DEFAULT 'system-ui',
  design_system TEXT DEFAULT 'stripe',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  doc_type TEXT NOT NULL,
  content TEXT NOT NULL,
  version INTEGER DEFAULT 1,
  generated_by TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.step_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  step_id INTEGER NOT NULL,
  completed_at TIMESTAMPTZ DEFAULT NOW(),
  notes TEXT
);

CREATE TABLE public.agent_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  messages JSONB DEFAULT '[]',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ DEFAULT (NOW() + INTERVAL '24 hours')
);

CREATE TABLE public.queued_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id UUID NOT NULL REFERENCES public.projects(id) ON DELETE CASCADE,
  job_type TEXT NOT NULL,
  status TEXT DEFAULT 'pending',
  payload JSONB,
  result JSONB,
  error TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

CREATE INDEX idx_projects_user_id ON public.projects(user_id);
CREATE INDEX idx_documents_project_id ON public.documents(project_id);
CREATE INDEX idx_step_history_project_id ON public.step_history(project_id);
CREATE INDEX idx_agent_sessions_project_id ON public.agent_sessions(project_id);
CREATE INDEX idx_queued_jobs_status ON public.queued_jobs(status);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.brand_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.step_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.agent_sessions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own profiles" ON public.profiles USING (auth.uid() = id);
CREATE POLICY "Users can CRUD own projects" ON public.projects USING (auth.uid() = user_id);
CREATE POLICY "Users can CRUD own brand_settings" ON public.brand_settings USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = brand_settings.project_id AND projects.user_id = auth.uid()));
CREATE POLICY "Users can CRUD own documents" ON public.documents USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = documents.project_id AND projects.user_id = auth.uid()));
CREATE POLICY "Users can CRUD own step_history" ON public.step_history USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = step_history.project_id AND projects.user_id = auth.uid()));
CREATE POLICY "Users can CRUD own agent_sessions" ON public.agent_sessions USING (EXISTS (SELECT 1 FROM public.projects WHERE projects.id = agent_sessions.project_id AND projects.user_id = auth.uid()));
