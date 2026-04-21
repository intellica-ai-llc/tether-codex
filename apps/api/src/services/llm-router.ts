export async function generateWithRouter(prompt: string, _capability: string): Promise<{ content: string; provider: string }> {
  return { content: `Response for: ${prompt.slice(0, 50)}...`, provider: 'clawrouter' }
}
