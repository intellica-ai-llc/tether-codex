import { PlatformAdapter, MessageEvent } from './base.js'
import readline from 'readline'
export class CLIAdapter implements PlatformAdapter {
  name = 'cli'; private handler: ((e: MessageEvent) => Promise<void>) | null = null; private rl: readline.Interface | null = null
  async start(): Promise<void> {
    this.rl = readline.createInterface({ input: process.stdin, output: process.stdout })
    console.log('🏛️ Tether Codex v3 Gateway — CLI')
    this.rl.on('line', async (line) => { if (line === '/exit') { await this.stop(); process.exit(0) }; if (this.handler) await this.handler({ platform: 'cli', chatId: 'cli', userId: 'cli', text: line, timestamp: new Date() }) })
  }
  async stop(): Promise<void> { this.rl?.close() }
  async sendMessage(_: string, content: string): Promise<void> { console.log(`\n${content}\n`) }
  onMessage(h: (e: MessageEvent) => Promise<void>): void { this.handler = h }
}
