import { TetherMemoryStorage } from '@tether/memory'

export interface MCPToolDefinition { name: string; description: string; parameters: Record<string, any> }

export class TetherMCPServer {
  private storage: TetherMemoryStorage

  constructor(projectId: string) {
    this.storage = new TetherMemoryStorage(projectId)
  }

  getTools(): MCPToolDefinition[] {
    return [
      { name: 'query_architecture', description: 'Query architectural memory', parameters: { query: { type: 'string' }, type: { type: 'string', enum: ['decision', 'pattern', 'all'] } } },
      { name: 'get_decisions', description: 'Get all architectural decisions', parameters: {} },
      { name: 'get_patterns', description: 'Get proven patterns', parameters: {} },
      { name: 'get_constraints', description: 'Get non-negotiable constraints', parameters: {} },
      { name: 'export_handoff', description: 'Export handoff package', parameters: {} }
    ]
  }

  async handleToolCall(toolName: string, args: any): Promise<any> {
    await this.storage.initialize()
    switch (toolName) {
      case 'query_architecture': return this.storage.searchByText(args.query)
      case 'get_decisions': return this.storage.getDecisions()
      case 'get_patterns': return this.storage.getPatterns(7)
      case 'get_constraints': return this.storage.query({ type: 'constraint' })
      case 'export_handoff': return { version: '1.0', decisions: await this.storage.getDecisions(), patterns: await this.storage.getPatterns(7) }
      default: throw new Error(`Unknown tool: ${toolName}`)
    }
  }
}
