import { FREE_TIER_LIMITS } from '@tether/config'

export interface FreeTierLimits { apiRequestsPerDay: number; databaseMB: number; storageGB: number; queueCommandsPerDay: number }
export interface CurrentUsage { apiRequests: number; databaseBytes: number; storageBytes: number; queueCommands: number }

export class PlatformComputeAgent {
  private limits: FreeTierLimits
  private usage: CurrentUsage
  private hasPayingUsers = false

  constructor(limits?: Partial<FreeTierLimits>) {
    this.limits = { apiRequestsPerDay: FREE_TIER_LIMITS.API_REQUESTS_PER_DAY, databaseMB: FREE_TIER_LIMITS.DATABASE_MB, storageGB: FREE_TIER_LIMITS.STORAGE_GB, queueCommandsPerDay: FREE_TIER_LIMITS.QUEUE_COMMANDS_PER_DAY, ...limits }
    this.usage = { apiRequests: 0, databaseBytes: 0, storageBytes: 0, queueCommands: 0 }
  }

  async checkLimits(): Promise<LimitStatus[]> {
    const statuses: LimitStatus[] = []
    const apiPct = (this.usage.apiRequests / this.limits.apiRequestsPerDay) * 100
    if (apiPct >= 80) statuses.push({ resource: 'api_requests', percentUsed: apiPct, status: apiPct >= 100 ? 'exceeded' : 'warning' })
    const dbPct = (this.usage.databaseBytes / (this.limits.databaseMB * 1024 * 1024)) * 100
    if (dbPct >= 80) statuses.push({ resource: 'database', percentUsed: dbPct, status: dbPct >= 100 ? 'exceeded' : 'warning' })
    const storagePct = (this.usage.storageBytes / (this.limits.storageGB * 1024 * 1024 * 1024)) * 100
    if (storagePct >= 80) statuses.push({ resource: 'storage', percentUsed: storagePct, status: storagePct >= 100 ? 'exceeded' : 'warning' })
    return statuses
  }

  getZeroCostStatus(): ZeroCostStatus {
    return { isZeroCost: !this.hasPayingUsers, freeTierLimits: this.limits, currentUsage: this.usage, message: this.hasPayingUsers ? 'Paying users detected. Compute costs covered.' : 'Zero-cost compute active. You pay $0 until your users pay you.' }
  }

  setPayingUsers(hasPaying: boolean): void { this.hasPayingUsers = hasPaying }
  updateUsage(usage: Partial<CurrentUsage>): void { this.usage = { ...this.usage, ...usage } }
}

interface LimitStatus { resource: string; percentUsed: number; status: 'warning' | 'exceeded' }
interface ZeroCostStatus { isZeroCost: boolean; freeTierLimits: FreeTierLimits; currentUsage: CurrentUsage; message: string }
