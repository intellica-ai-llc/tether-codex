export class PlatformComputeAgent {
  private hasPayingUsers = false

  async checkLimits(): Promise<any[]> { return [] }
  getZeroCostStatus(): any {
    return {
      isZeroCost: !this.hasPayingUsers,
      message: this.hasPayingUsers ? 'Paying users detected.' : 'Zero-cost compute active.',
    }
  }
  setPayingUsers(v: boolean): void { this.hasPayingUsers = v }
}

export { ProviderResolver } from './provider-resolver.js'
export type { ProviderConfig, ResolvedProvider } from './provider-resolver.js'