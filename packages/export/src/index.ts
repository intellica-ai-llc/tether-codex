import * as fs from 'fs/promises'
import * as path from 'path'
import archiver from 'archiver'
import { createWriteStream } from 'fs'

export interface ExportOptions { format: 'zip' | 'vercel' | 'netlify'; includeMemory?: boolean; includeDocs?: boolean }

export class TetherExporter {
  private projectPath: string
  constructor(projectPath: string = '.') { this.projectPath = projectPath }

  async export(options: ExportOptions): Promise<string> {
    switch (options.format) {
      case 'zip': return this.exportZip(options)
      case 'vercel': return this.exportVercel()
      case 'netlify': return this.exportNetlify()
      default: throw new Error(`Unknown format: ${options.format}`)
    }
  }

  private async exportZip(options: ExportOptions): Promise<string> {
    const outputPath = path.join(this.projectPath, 'tether-export.zip')
    const output = createWriteStream(outputPath)
    const archive = archiver('zip', { zlib: { level: 9 } })
    archive.pipe(output)
    archive.directory('src/', 'src')
    archive.directory('apps/', 'apps')
    archive.directory('packages/', 'packages')
    archive.file('package.json', { name: 'package.json' })
    archive.file('README.md', { name: 'README.md' })
    if (options.includeMemory) archive.directory('.tether/memory/', '.tether/memory')
    await archive.finalize()
    return outputPath
  }

  private async exportVercel(): Promise<string> {
    const vercelConfig = { framework: 'vite', buildCommand: 'pnpm build', outputDirectory: 'dist', installCommand: 'pnpm install' }
    await fs.writeFile('vercel.json', JSON.stringify(vercelConfig, null, 2))
    return 'vercel.json created. Run `vercel deploy` to deploy.'
  }

  private async exportNetlify(): Promise<string> {
    await fs.writeFile('netlify.toml', '[build]\n  command = "pnpm build"\n  publish = "dist"')
    return 'netlify.toml created. Connect repository to Netlify to deploy.'
  }
}
