export interface PreviewOptions { projectFiles: Record<string, string>; onReady?: (url: string) => void; onError?: (error: Error) => void }

export class TetherPreview {
  private container: any = null
  private previewUrl: string | null = null

  async start(options: PreviewOptions): Promise<string> {
    try {
      const { WebContainer } = await import('@webcontainer/api')
      this.container = await WebContainer.boot()
      await this.container.mount(options.projectFiles)

      const installProcess = await this.container.spawn('npm', ['install'])
      await installProcess.exit

      this.container.spawn('npm', ['run', 'dev'])
      this.container.on('server-ready', (_port: number, url: string) => {
        this.previewUrl = url
        options.onReady?.(url)
      })

      return 'Preview starting...'
    } catch (error) {
      options.onError?.(error as Error)
      throw error
    }
  }

  async updateFile(path: string, content: string): Promise<void> {
    if (!this.container) throw new Error('Preview not started')
    await this.container.fs.writeFile(path, content)
  }

  async stop(): Promise<void> {
    if (this.container) { await this.container.teardown(); this.container = null }
  }

  getUrl(): string | null { return this.previewUrl }
}