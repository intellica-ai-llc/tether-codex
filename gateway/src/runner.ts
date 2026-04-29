import { AgentOrchestrator, AgentResponse } from '@tether/agents'
import { PlatformAdapter, MessageEvent } from './platforms/base.js'
import { CLIAdapter } from './platforms/cli.js'

class GatewayRunner {
  private adapters: PlatformAdapter[] = []
  private orch = new AgentOrchestrator()

  async start(): Promise<void> {
    const cli = new CLIAdapter()
    this.adapters.push(cli)
    cli.onMessage(this.handle.bind(this))
    await cli.start()
  }

  private async handle(event: MessageEvent): Promise<void> {
    const r = await this.orch.processMessage(event.text, {
      projectId: 'default',
      workspacePath: process.cwd(),
      userMessage: event.text,
      userId: event.userId,
      sessionId: `gw-${Date.now()}`
    })
    const content = r.responses.map((r: AgentResponse) => `[${r.agentName}]\n${r.content}`).join('\n\n')
    await this.adapters[0]?.sendMessage(event.chatId, content)
  }
}

new GatewayRunner().start().catch(console.error)