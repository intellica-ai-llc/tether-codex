export const RLS_POLICIES = {
  profiles: `ALTER TABLE profiles ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own profiles" ON profiles USING (auth.uid() = id);`,
  projects: `ALTER TABLE projects ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own projects" ON projects USING (auth.uid() = user_id);`,
  documents: `ALTER TABLE documents ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own documents" ON documents USING (EXISTS (SELECT 1 FROM projects WHERE projects.id = documents.project_id AND projects.user_id = auth.uid()));`,
  experience_cards: `ALTER TABLE experience_cards ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own cards" ON experience_cards USING (EXISTS (SELECT 1 FROM projects WHERE projects.id = experience_cards.project_id AND projects.user_id = auth.uid())); CREATE POLICY "Anyone can view public cards" ON experience_cards FOR SELECT USING (is_public = true);`,
  subscriptions: `ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY; CREATE POLICY "Users can CRUD own subscriptions" ON subscriptions USING (auth.uid() = user_id);`
}
