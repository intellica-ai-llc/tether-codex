export { MAE } from './mae.js'
export { MI } from './mi.js'
export { MPE } from './mpe.js'
export { PCA } from './pca.js'
export { DB } from './db.js'
export { UIX } from './uix.js'
export { MM } from './mm.js'
export { BUG } from './bug.js'
export { QC } from './qc.js'
export { OPS } from './ops.js'
export { MNT } from './mnt.js'
export { SUP } from './sup.js'
export { REQ } from './req.js'
export type { AgentPersona } from './types.js'

import { MAE, MI, MPE, PCA, DB, UIX, MM, BUG, QC, OPS, MNT, SUP, REQ } from './index.js'
import type { AgentPersona } from './types.js'
export const ALL_PERSONAS = [MAE, MI, MPE, PCA, DB, UIX, MM, BUG, QC, OPS, MNT, SUP, REQ]
export const PERSONA_BY_ID: Record<string, AgentPersona> = Object.fromEntries(ALL_PERSONAS.map(p => [p.id, p]))
