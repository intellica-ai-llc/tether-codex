export interface ProviderConfig {
  name: string
  apiMode: 'chat_completions' | 'codex_responses' | 'anthropic_messages'
  baseUrl: string
  apiKeyEnv: string
  models: string[]
}

export interface ResolvedProvider { apiMode: string; apiKey: string; baseUrl: string; model: string }

export class ProviderResolver {
  private providers: Map<string, ProviderConfig> = new Map()
  private fallbackChain: string[] = ['openrouter', 'anthropic', 'openai', 'groq', 'together']

  constructor() { this.registerBuiltins() }

  resolve(providerName?: string, model?: string): ResolvedProvider {
    if (providerName) {
      const c = this.providers.get(providerName)
      if (c && process.env[c.apiKeyEnv]) return { apiMode: c.apiMode, apiKey: process.env[c.apiKeyEnv]!, baseUrl: c.baseUrl, model: model || c.models[0] }
    }
    for (const fn of this.fallbackChain) {
      const c = this.providers.get(fn)
      if (c && process.env[c.apiKeyEnv]) return { apiMode: c.apiMode, apiKey: process.env[c.apiKeyEnv]!, baseUrl: c.baseUrl, model: model || c.models[0] }
    }
    throw new Error('No available provider')
  }

  private registerBuiltins(): void {
    const add = (name: string, mode: string, url: string, env: string, models: string[]) =>
      this.providers.set(name, { name, apiMode: mode as any, baseUrl: url, apiKeyEnv: env, models })
    add('anthropic', 'anthropic_messages', 'https://api.anthropic.com', 'ANTHROPIC_API_KEY', ['claude-sonnet-4-20250514'])
    add('openai', 'codex_responses', 'https://api.openai.com/v1', 'OPENAI_API_KEY', ['gpt-5'])
    add('openrouter', 'chat_completions', 'https://openrouter.ai/api/v1', 'OPENROUTER_API_KEY', ['anthropic/claude-sonnet-4'])
    add('groq', 'chat_completions', 'https://api.groq.com/openai/v1', 'GROQ_API_KEY', ['llama-3.3-70b'])
    add('together', 'chat_completions', 'https://api.together.xyz/v1', 'TOGETHER_API_KEY', ['meta-llama/Llama-3.3-70B'])
  }
}
