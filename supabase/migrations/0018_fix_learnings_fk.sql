ALTER TABLE public.learnings ALTER COLUMN project_id DROP NOT NULL; ALTER TABLE public.learnings DROP CONSTRAINT IF EXISTS learnings_project_id_fkey;
