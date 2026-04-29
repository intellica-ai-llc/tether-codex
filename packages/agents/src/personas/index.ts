export { MAE } from './mae.js'
export { MI } from './mi.js'
export { PCA } from './pca.js'
export { DB } from './db.js'
export { MM } from './mm.js'
export { BUG } from './bug.js'
export { QC } from './qc.js'
export { MNT } from './mnt.js'
export type { AgentPersona } from './types.js'

import { MAE, MI, PCA, DB, MM, BUG, QC, MNT } from './index.js'
import type { AgentPersona } from './types.js'

export const ALL_PERSONAS = [MAE, MI, PCA, DB, MM, BUG, QC, MNT]

export const PERSONA_BY_ID: Record<string, AgentPersona> =
  Object.fromEntries(ALL_PERSONAS.map(p => [p.id, p]))