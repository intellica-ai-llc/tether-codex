export const STEPS = { INCEPTION: 1, ARCHITECTURE: 2, BUILD_PACKAGE: 3, PLATFORM: 4, UI_POLISH: 5, TESTING: 6, LAUNCH: 7, MAINTENANCE: 8 } as const
export const DOC_TYPES = { ARCHITECTURE: 'ARCHITECTURE', IMPLEMENTATION_PLAN: 'IMPLEMENTATION_PLAN', HANDOFF: 'HANDOFF', USER_FLOW: 'USER_FLOW' } as const
export const AGENT_IDS = { MAE: 'mae', MI: 'mi', MPE: 'mpe', PCA: 'pca', DB: 'db', UIX: 'uix', MM: 'mm', BUG: 'bug', QC: 'qc', OPS: 'ops', MNT: 'mnt', SUP: 'sup', REQ: 'req' } as const
export const FREE_TIER_LIMITS = { API_REQUESTS_PER_DAY: 100000, DATABASE_MB: 500, STORAGE_GB: 10, QUEUE_COMMANDS_PER_DAY: 10000 } as const
export const QUALITY_GATES = ['requirements', 'architecture', 'implementation', 'deployment', 'maintenance'] as const
export const KENNY_ROGERS_VERDICTS = { HOLD: 'HOLD', FOLD: 'FOLD', WALK_AWAY: 'WALK_AWAY', RUN: 'RUN' } as const
export const AUTODREAM_PHASES = { LIGHT_SLEEP: 'light', REM_SLEEP: 'rem', DEEP_SLEEP: 'deep' } as const
export const AUTODREAM_INTERVALS = { LIGHT_SLEEP_SECONDS: 3600, REM_SLEEP_SECONDS: 86400, DEEP_SLEEP_SECONDS: 604800 } as const
