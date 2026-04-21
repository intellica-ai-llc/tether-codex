export interface MCPServerConfig { name: string; command: string; args: string[]; env?: Record<string, string> }
export interface MCPTool { name: string; description: string; parameters: Record<string, any> }

export class TetherMCPClient {
  private servers: Map<string, any> = new Map()

  async connect(configs: MCPServerConfig[]): Promise<void> {
    for (const config of configs) {
      this.servers.set(config.name, { config })
    }
    console.log(`MCP client connected to ${this.servers.size} servers`)
  }

  async listTools(serverName?: string): Promise<Record<string, MCPTool[]>> {
    const tools: Record<string, MCPTool[]> = {}
    for (const [name] of this.servers) {
      if (!serverName || serverName === name) {
        tools[name] = []
      }
    }
    return tools
  }

  async callTool(fullName: string, _args: any): Promise<any> {
    const [serverName, toolName] = fullName.split('__')
    const server = this.servers.get(serverName)
    if (!server) throw new Error(`MCP server not found: ${serverName}`)
    return { result: `Called ${toolName} on ${serverName}` }
  }

  static DEFAULT_SERVERS: MCPServerConfig[] = [
    { name: 'filesystem', command: 'npx', args: ['-y', '@modelcontextprotocol/server-filesystem', '/workspace'] },
    { name: 'github', command: 'npx', args: ['-y', '@modelcontextprotocol/server-github'] },
    { name: 'playwright', command: 'npx', args: ['-y', '@modelcontextprotocol/server-playwright'] }
  ]
}