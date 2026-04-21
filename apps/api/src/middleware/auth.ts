import { createMiddleware } from 'hono/factory'
import { createClient } from '@supabase/supabase-js'

export const authMiddleware = createMiddleware(async (c, next) => {
  const authHeader = c.req.header('Authorization')
  if (!authHeader) return c.json({ error: 'Unauthorized' }, 401)
  const token = authHeader.replace('Bearer ', '')
  const supabase = createClient(c.env.SUPABASE_URL as string, c.env.SUPABASE_ANON_KEY as string)
  const { data: { user }, error } = await supabase.auth.getUser(token)
  if (error || !user) return c.json({ error: 'Invalid token' }, 401)
  c.set('user', user)
  await next()
})
