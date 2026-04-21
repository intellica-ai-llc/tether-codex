import type { Config } from 'drizzle-kit'
export default { schema: './src/schema.ts', out: './migrations', driver: 'pg', dbCredentials: { connectionString: process.env.SUPABASE_URL! } } satisfies Config
