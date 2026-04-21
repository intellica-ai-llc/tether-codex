#!/bin/bash
# BATCH 2/6: TETHER CODEX — MEMORY SUBSTRATE + AUTODREAM + EXPERIENCE + LEARNING
set -e
echo "🧠 TETHER CODEX — BATCH 2/6: Memory Substrate + autoDream + Experience + Learning"
echo "=================================================================================="

# -------------------------------------------------------------------
# MEMORY PACKAGE
# -------------------------------------------------------------------
cat > packages/memory/package.json << 'EOF'
{
  "name": "@tether/memory",
  "version": "3.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": { "build": "tsc", "test": "vitest" },
  "dependencies": { "@tether/shared-types": "workspace:*", "@tether/config": "workspace:*" },
  "devDependencies": { "@tether/tsconfig": "workspace:*", "@types/node": "^20.0.0", "typescript": "^5.0.0", "vitest": "^1.0.0" }
}
EOF

cat > packages/memory/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/base.json", "compilerOptions": { "outDir": "./dist", "rootDir": "./src" }, "include": ["src/**/*"], "references": [{ "path": "../shared-types" }, { "path": "../config" }] }
EOF

cat > packages/memory/src/schema.ts << 'EOF'
import { TetherMemoryEntry, MemoryType, ConfidenceLevel } from '@tether/shared-types'

export interface MemoryQueryOptions {
  type?: MemoryType | MemoryType[]
  minConfidence?: ConfidenceLevel
  key?: string
  tags?: string[]
  limit?: number
  orderBy?: 'recency' | 'confidence'
}

export function validateMemoryEntry(entry: Partial<TetherMemoryEntry>): string[] {
  const errors: string[] = []
  if (!entry.ts) errors.push('ts required')
  if (!entry.type) errors.push('type required')
  if (!entry.key) errors.push('key required')
  if (!entry.insight) errors.push('insight required')
  if (!entry.confidence) errors.push('confidence required')
  return errors
}

export function createDecision(key: string, insight: string, context: string, confidence: ConfidenceLevel): TetherMemoryEntry {
  return {
    ts: new Date().toISOString(),
    type: 'decision',
    key,
    insight,
    confidence,
    source: 'mae',
    tags: ['decision']
  }
}

export function createPattern(key: string, insight: string, confidence: ConfidenceLevel): TetherMemoryEntry {
  return {
    ts: new Date().toISOString(),
    type: 'pattern',
    key,
    insight,
    confidence,
    source: 'agent',
    tags: ['pattern']
  }
}

export function createPitfall(key: string, insight: string): TetherMemoryEntry {
  return {
    ts: new Date().toISOString(),
    type: 'pitfall',
    key,
    insight,
    confidence: 8,
    source: 'bug',
    tags: ['pitfall', 'warning']
  }
}
EOF

cat > packages/memory/src/storage.ts << 'EOF'
import * as fs from 'fs/promises'
import * as path from 'path'
import { TetherMemoryEntry } from '@tether/shared-types'
import { MemoryQueryOptions } from './schema'

export class TetherMemoryStorage {
  private memoryDir: string
  private learningsFile: string
  private consolidatedFile: string

  constructor(projectId: string, basePath: string = '.tether') {
    this.memoryDir = path.join(basePath, 'memory', projectId)
    this.learningsFile = path.join(this.memoryDir, 'learnings.jsonl')
    this.consolidatedFile = path.join(this.memoryDir, 'consolidated.md')
  }

  async initialize(): Promise<void> {
    await fs.mkdir(this.memoryDir, { recursive: true })
    try { await fs.access(this.learningsFile) } catch { await fs.writeFile(this.learningsFile, '') }
  }

  async append(entry: Omit<TetherMemoryEntry, 'ts'> & { ts?: string }): Promise<TetherMemoryEntry> {
    const fullEntry: TetherMemoryEntry = { ts: new Date().toISOString(), ...entry }
    const line = JSON.stringify(fullEntry) + '\n'
    await fs.appendFile(this.learningsFile, line, 'utf-8')
    return fullEntry
  }

  async query(options: MemoryQueryOptions = {}): Promise<TetherMemoryEntry[]> {
    const entries = await this.readAll()
    let filtered = entries

    if (options.type) {
      const types = Array.isArray(options.type) ? options.type : [options.type]
      filtered = filtered.filter(e => types.includes(e.type))
    }
    if (options.minConfidence) filtered = filtered.filter(e => e.confidence >= options.minConfidence)
    if (options.key) filtered = filtered.filter(e => e.key === options.key)
    if (options.tags) filtered = filtered.filter(e => options.tags!.some(t => e.tags.includes(t)))

    filtered.sort((a, b) => options.orderBy === 'confidence' ? b.confidence - a.confidence : b.ts.localeCompare(a.ts))
    return filtered.slice(0, options.limit || 50)
  }

  async getDecisions(limit: number = 50): Promise<TetherMemoryEntry[]> {
    return this.query({ type: 'decision', orderBy: 'recency', limit })
  }

  async getPatterns(minConfidence: 7): Promise<TetherMemoryEntry[]> {
    return this.query({ type: 'pattern', minConfidence, orderBy: 'confidence' })
  }

  async getPitfalls(limit: number = 30): Promise<TetherMemoryEntry[]> {
    return this.query({ type: 'pitfall', orderBy: 'recency', limit })
  }

  async searchByText(query: string, limit: number = 20): Promise<TetherMemoryEntry[]> {
    const entries = await this.readAll()
    const q = query.toLowerCase()
    const scored = entries.map(e => {
      let score = 0
      if (e.key.toLowerCase().includes(q)) score += 10
      if (e.insight.toLowerCase().includes(q)) score += 5
      if (e.tags.some(t => t.toLowerCase().includes(q))) score += 3
      return { entry: e, score }
    })
    return scored.filter(s => s.score > 0).sort((a, b) => b.score - a.score).slice(0, limit).map(s => s.entry)
  }

  async getConsolidated(): Promise<string | null> {
    try { return await fs.readFile(this.consolidatedFile, 'utf-8') } catch { return null }
  }

  async saveConsolidated(content: string): Promise<void> {
    await fs.writeFile(this.consolidatedFile, content, 'utf-8')
  }

  private async readAll(): Promise<TetherMemoryEntry[]> {
    try {
      const content = await fs.readFile(this.learningsFile, 'utf-8')
      return content.split('\n').filter(l => l.trim()).map(l => JSON.parse(l)).reverse()
    } catch { return [] }
  }
}
EOF

cat > packages/memory/src/consolidator.ts << 'EOF'
import { TetherMemoryStorage } from './storage'
import { TetherMemoryEntry } from '@tether/shared-types'
import { AUTODREAM_INTERVALS, AUTODREAM_PHASES } from '@tether/config'

export interface ConsolidationResult {
  phase: string
  patternsExtracted: number
  entriesProcessed: number
  causalLinks?: number
}

export class AutoDreamConsolidator {
  private storage: TetherMemoryStorage
  private lastLight: Date = new Date(0)
  private lastREM: Date = new Date(0)
  private lastDeep: Date = new Date(0)

  constructor(storage: TetherMemoryStorage) {
    this.storage = storage
  }

  async tick(): Promise<ConsolidationResult | null> {
    const now = new Date()

    if (now.getTime() - this.lastDeep.getTime() >= AUTODREAM_INTERVALS.DEEP_SLEEP_SECONDS * 1000) {
      const result = await this.deepSleep()
      this.lastDeep = now
      return result
    }
    if (now.getTime() - this.lastREM.getTime() >= AUTODREAM_INTERVALS.REM_SLEEP_SECONDS * 1000) {
      const result = await this.remSleep()
      this.lastREM = now
      return result
    }
    if (now.getTime() - this.lastLight.getTime() >= AUTODREAM_INTERVALS.LIGHT_SLEEP_SECONDS * 1000) {
      const result = await this.lightSleep()
      this.lastLight = now
      return result
    }
    return null
  }

  private async lightSleep(): Promise<ConsolidationResult> {
    const entries = await this.storage.query({ orderBy: 'recency', limit: 100 })
    const patterns = this.extractPatterns(entries)

    for (const pattern of patterns) {
      if (pattern.confidence >= 5) {
        await this.storage.append({
          type: 'pattern',
          key: pattern.key,
          insight: pattern.insight,
          confidence: pattern.confidence,
          source: 'autoDream',
          tags: ['consolidated', 'light-sleep']
        })
      }
    }
    return { phase: AUTODREAM_PHASES.LIGHT_SLEEP, patternsExtracted: patterns.length, entriesProcessed: entries.length }
  }

  private async remSleep(): Promise<ConsolidationResult> {
    const entries = await this.storage.query({ orderBy: 'recency', limit: 500 })
    const links = this.discoverCausalLinks(entries)

    for (const link of links) {
      await this.storage.append({
        type: 'observation',
        key: `causal-${link.source}-${link.target}`,
        insight: `${link.source} led to ${link.target}`,
        confidence: link.confidence,
        source: 'autoDream',
        tags: ['causal-link', 'rem-sleep']
      })
    }
    return { phase: AUTODREAM_PHASES.REM_SLEEP, patternsExtracted: 0, entriesProcessed: entries.length, causalLinks: links.length }
  }

  private async deepSleep(): Promise<ConsolidationResult> {
    const entries = await this.storage.query({ orderBy: 'recency', limit: 1000 })
    const consolidated = this.extractPatterns(entries)

    await this.storage.append({
      type: 'observation',
      key: 'deep-sleep-consolidation',
      insight: `Consolidated ${entries.length} entries into memory`,
      confidence: 10,
      source: 'autoDream',
      tags: ['consolidation', 'deep-sleep']
    })

    return { phase: AUTODREAM_PHASES.DEEP_SLEEP, patternsExtracted: consolidated.length, entriesProcessed: entries.length }
  }

  private extractPatterns(entries: TetherMemoryEntry[]): { key: string; insight: string; confidence: number }[] {
    const byKey: Record<string, TetherMemoryEntry[]> = {}
    for (const e of entries) {
      if (!byKey[e.key]) byKey[e.key] = []
      byKey[e.key].push(e)
    }
    return Object.entries(byKey)
      .filter(([_, es]) => es.length >= 3)
      .map(([key, es]) => ({
        key,
        insight: es[0].insight,
        confidence: Math.min(10, Math.floor(es.reduce((s, e) => s + e.confidence, 0) / es.length))
      }))
  }

  private discoverCausalLinks(entries: TetherMemoryEntry[]): { source: string; target: string; confidence: number }[] {
    return []
  }
}
EOF

cat > packages/memory/src/query-engine.ts << 'EOF'
import { TetherMemoryStorage } from './storage'

export class TetherMemoryQueryEngine {
  constructor(private storage: TetherMemoryStorage) {}

  async getContextForCapability(capability: 'architecture' | 'implementation' | 'debugging' | 'planning'): Promise<string> {
    const sections: string[] = []

    switch (capability) {
      case 'architecture':
        const consolidated = await this.storage.getConsolidated()
        if (consolidated) sections.push(consolidated.slice(0, 2000))
        const decisions = await this.storage.getDecisions(10)
        if (decisions.length) sections.push('## Key Decisions\n' + decisions.map(d => `- ${d.key}: ${d.insight}`).join('\n'))
        break
      case 'implementation':
        const patterns = await this.storage.getPatterns(7)
        if (patterns.length) sections.push('## Proven Patterns\n' + patterns.map(p => `- ${p.key}: ${p.insight}`).join('\n'))
        const pitfalls = await this.storage.getPitfalls(10)
        if (pitfalls.length) sections.push('## Pitfalls to Avoid\n' + pitfalls.map(p => `- ${p.key}: ${p.insight}`).join('\n'))
        break
      case 'debugging':
        const recentPitfalls = await this.storage.getPitfalls(20)
        if (recentPitfalls.length) sections.push('## Known Pitfalls\n' + recentPitfalls.map(p => `- ${p.key}: ${p.insight}`).join('\n'))
        break
      case 'planning':
        const openQuestions = await this.storage.query({ type: 'question', limit: 20 })
        if (openQuestions.length) sections.push('## Open Questions\n' + openQuestions.map(q => `- ${q.key}: ${q.insight}`).join('\n'))
        break
    }

    return sections.join('\n\n')
  }
}
EOF

cat > packages/memory/src/handoff.ts << 'EOF'
import { TetherMemoryStorage } from './storage'
import { HandoffPackage } from '@tether/shared-types'

export class TetherHandoffPackager {
  constructor(private storage: TetherMemoryStorage) {}

  async export(projectId: string, projectName: string): Promise<HandoffPackage> {
    const decisions = await this.storage.getDecisions(100)
    const patterns = await this.storage.getPatterns(5)

    return {
      version: '1.0.0',
      exported_at: new Date().toISOString(),
      project: { id: projectId, name: projectName },
      memory: { decisions, patterns },
      documents: {}
    }
  }

  async import(pkg: HandoffPackage): Promise<number> {
    let count = 0
    for (const decision of pkg.memory.decisions) {
      await this.storage.append({
        type: 'decision',
        key: decision.key,
        insight: decision.decision,
        confidence: decision.confidence,
        source: 'handoff',
        tags: ['imported', decision.layer]
      })
      count++
    }
    for (const pattern of pkg.memory.patterns) {
      await this.storage.append({
        type: 'pattern',
        key: pattern.key,
        insight: pattern.insight,
        confidence: pattern.confidence,
        source: 'handoff',
        tags: ['imported']
      })
      count++
    }
    return count
  }
}
EOF

cat > packages/memory/src/index.ts << 'EOF'
export { TetherMemoryStorage } from './storage'
export { AutoDreamConsolidator } from './consolidator'
export { TetherMemoryQueryEngine } from './query-engine'
export { TetherHandoffPackager } from './handoff'
export { validateMemoryEntry, createDecision, createPattern, createPitfall } from './schema'
export { MemoryQueryOptions } from './schema'
EOF

# -------------------------------------------------------------------
# EXPERIENCE PACKAGE
# -------------------------------------------------------------------
cat > packages/experience/package.json << 'EOF'
{
  "name": "@tether/experience",
  "version": "3.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": { "build": "tsc" },
  "dependencies": { "@tether/shared-types": "workspace:*", "@tether/memory": "workspace:*" },
  "devDependencies": { "@tether/tsconfig": "workspace:*", "@types/node": "^20.0.0", "typescript": "^5.0.0" }
}
EOF

cat > packages/experience/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/base.json", "compilerOptions": { "outDir": "./dist", "rootDir": "./src" }, "include": ["src/**/*"] }
EOF

cat > packages/experience/src/index.ts << 'EOF'
import * as fs from 'fs/promises'
import * as path from 'path'
import { ExperienceCard } from '@tether/shared-types'

export class ExperienceCardSystem {
  private cardsPath: string
  private indexPath: string

  constructor(basePath: string = '.tether') {
    this.cardsPath = path.join(basePath, 'experience-cards')
    this.indexPath = path.join(this.cardsPath, 'index.json')
  }

  async create(card: Omit<ExperienceCard, 'id' | 'created_at' | 'updated_at' | 'times_used' | 'last_used_at' | 'success_rate' | 'normalized_signature'>): Promise<ExperienceCard> {
    const normalized = this.normalizeSignature(card.problem_signature)
    const full: ExperienceCard = {
      id: `card_${Date.now()}`,
      ...card,
      normalized_signature: normalized,
      times_used: 0,
      last_used_at: null,
      success_rate: null,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString()
    }

    const cardPath = path.join(this.cardsPath, `${full.id}.json`)
    await fs.writeFile(cardPath, JSON.stringify(full, null, 2))
    await this.updateIndex(full)
    return full
  }

  async findSimilar(problemSignature: string, techStack: string[], limit: number = 5): Promise<ExperienceCard[]> {
    const normalized = this.normalizeSignature(problemSignature)
    const index = await this.loadIndex()
    const candidates: ExperienceCard[] = []

    for (const cardId of index.public_cards || []) {
      const card = await this.load(cardId)
      if (card && this.hasTechStackOverlap(card.tech_stack, techStack)) {
        const similarity = this.calculateSimilarity(normalized, card.normalized_signature)
        if (similarity > 0.7) {
          candidates.push({ ...card, reusable_score: similarity })
        }
      }
    }
    return candidates.sort((a, b) => (b.reusable_score || 0) - (a.reusable_score || 0)).slice(0, limit)
  }

  async recordUsage(cardId: string, success: boolean): Promise<void> {
    const card = await this.load(cardId)
    if (!card) return

    card.times_used++
    card.last_used_at = new Date().toISOString()
    card.success_rate = card.success_rate === null ? (success ? 1.0 : 0.0) : (card.success_rate * (card.times_used - 1) + (success ? 1 : 0)) / card.times_used
    card.updated_at = new Date().toISOString()

    const cardPath = path.join(this.cardsPath, `${cardId}.json`)
    await fs.writeFile(cardPath, JSON.stringify(card, null, 2))
    await this.updateIndex(card)
  }

  async makePublic(cardId: string): Promise<void> {
    const card = await this.load(cardId)
    if (!card) return
    card.is_public = true
    card.updated_at = new Date().toISOString()
    const cardPath = path.join(this.cardsPath, `${cardId}.json`)
    await fs.writeFile(cardPath, JSON.stringify(card, null, 2))
    await this.updateIndex(card)
  }

  private async load(cardId: string): Promise<ExperienceCard | null> {
    try {
      const cardPath = path.join(this.cardsPath, `${cardId}.json`)
      return JSON.parse(await fs.readFile(cardPath, 'utf-8'))
    } catch { return null }
  }

  private async loadIndex(): Promise<any> {
    try { return JSON.parse(await fs.readFile(this.indexPath, 'utf-8')) } catch { return { cards: [], public_cards: [] } }
  }

  private async updateIndex(card: ExperienceCard): Promise<void> {
    const index = await this.loadIndex()
    if (!index.cards.includes(card.id)) index.cards.push(card.id)
    if (card.is_public && !index.public_cards.includes(card.id)) index.public_cards.push(card.id)
    await fs.writeFile(this.indexPath, JSON.stringify(index, null, 2))
  }

  private normalizeSignature(signature: string): string {
    return signature.toLowerCase().replace(/[^a-z0-9\s]/g, ' ').replace(/\s+/g, ' ').trim()
  }

  private calculateSimilarity(a: string, b: string): number {
    const wordsA = new Set(a.split(' '))
    const wordsB = new Set(b.split(' '))
    const intersection = new Set([...wordsA].filter(x => wordsB.has(x)))
    const union = new Set([...wordsA, ...wordsB])
    return intersection.size / union.size
  }

  private hasTechStackOverlap(stack1: string[], stack2: string[]): boolean {
    return stack1.some(t => stack2.includes(t))
  }
}
EOF

# -------------------------------------------------------------------
# LEARNING PACKAGE (LARs)
# -------------------------------------------------------------------
cat > packages/learning/package.json << 'EOF'
{
  "name": "@tether/learning",
  "version": "3.0.0",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": { "build": "tsc" },
  "dependencies": { "@tether/shared-types": "workspace:*", "@tether/memory": "workspace:*" },
  "devDependencies": { "@tether/tsconfig": "workspace:*", "@types/node": "^20.0.0", "typescript": "^5.0.0" }
}
EOF

cat > packages/learning/tsconfig.json << 'EOF'
{ "extends": "@tether/tsconfig/base.json", "compilerOptions": { "outDir": "./dist", "rootDir": "./src" }, "include": ["src/**/*"] }
EOF

cat > packages/learning/src/index.ts << 'EOF'
import * as fs from 'fs/promises'
import * as path from 'path'
import { TetherMemoryStorage } from '@tether/memory'
import { LearningAttributionRecord } from '@tether/shared-types'

export class LearningAttributionSystem {
  private attributionsPath: string
  private storage: TetherMemoryStorage

  constructor(projectId: string, basePath: string = '.tether') {
    this.attributionsPath = path.join(basePath, 'learnings', 'attributions')
    this.storage = new TetherMemoryStorage(projectId)
  }

  async record(record: Omit<LearningAttributionRecord, 'id' | 'created_at' | 'status'>): Promise<LearningAttributionRecord> {
    const full: LearningAttributionRecord = {
      id: `lar_${Date.now()}`,
      ...record,
      status: 'pending',
      created_at: new Date().toISOString()
    }
    const filePath = path.join(this.attributionsPath, `${full.id}.json`)
    await fs.writeFile(filePath, JSON.stringify(full, null, 2))
    return full
  }

  async getPending(target_agent?: string): Promise<LearningAttributionRecord[]> {
    const files = await fs.readdir(this.attributionsPath).catch(() => [])
    const records: LearningAttributionRecord[] = []
    for (const file of files.filter(f => f.endsWith('.json'))) {
      const record = JSON.parse(await fs.readFile(path.join(this.attributionsPath, file), 'utf-8'))
      if (record.status === 'pending' && (!target_agent || record.target_agent === target_agent)) {
        records.push(record)
      }
    }
    return records
  }

  async consolidate(id: string): Promise<void> {
    const filePath = path.join(this.attributionsPath, `${id}.json`)
    const record: LearningAttributionRecord = JSON.parse(await fs.readFile(filePath, 'utf-8'))
    record.status = 'consolidated'
    record.consolidated_at = new Date().toISOString()
    await fs.writeFile(filePath, JSON.stringify(record, null, 2))

    await this.storage.append({
      type: 'pattern',
      key: `lar-${record.source_agent}-to-${record.target_agent}`,
      insight: record.prevention,
      confidence: record.confidence,
      source: 'lar',
      tags: ['lar', record.source_agent, record.target_agent]
    })
  }

  async reject(id: string, reason: string): Promise<void> {
    const filePath = path.join(this.attributionsPath, `${id}.json`)
    const record = JSON.parse(await fs.readFile(filePath, 'utf-8'))
    record.status = 'rejected'
    await fs.writeFile(filePath, JSON.stringify({ ...record, rejection_reason: reason }, null, 2))
  }
}
EOF

# -------------------------------------------------------------------
# BUILT-IN SKILLS
# -------------------------------------------------------------------
cat > .tether/skills/tether-architecture/SKILL.md << 'EOF'
---
name: tether-architecture
version: 3.0.0
description: Expert architectural design with Kenny Rogers framework
triggers: [architect, architecture, design system, tech stack, system design]
allowed_tools: [Read, Write, mcp__tether__memory_query]
---
# Tether Architecture Skill

## Kenny Rogers Framework
- HOLD: Good architecture, wait for better position
- FOLD: Bad approach, cut losses
- WALK AWAY: Could work but effort > value
- RUN: Vendor lock-in or unsustainable dependencies

## Free-Tier-First
Always recommend architectures that run on free tiers until revenue justifies scaling.

## Routing Table
| Task | Reference | Template |
|------|-----------|----------|
| New architecture | architecture-excellence.md | architecture_canvas.jsx |
| Tech stack | stack-comparison.md | decision_matrix.jsx |
EOF

cat > .tether/skills/tether-design/SKILL.md << 'EOF'
---
name: tether-design
version: 3.0.0
description: Professional UI/UX design with 68+ brand styles
triggers: [design, ui, ux, style, component, tailwind, branding]
allowed_tools: [Read, Write, mcp__playwright__browser_snapshot]
---
# Tether Design Skill

## Brand Styles
- stripe: Clean, professional, purple gradient
- vercel: Dark, minimalist, geometric
- linear: Modern, productive, purple accent
- github: Developer-focused, monochrome

## Routing Table
| Task | Reference | Template |
|------|-----------|----------|
| New design | design-excellence.md | design_canvas.jsx |
| Brand clone | brand-styles/ | browser_window.jsx |
EOF

echo ""
echo "✅ Batch 2/6 complete — Memory Substrate + autoDream + Experience + Learning"
echo "   • @tether/memory package (storage, consolidator, query-engine, handoff)"
echo "   • AutoDreamConsolidator (Light/REM/Deep sleep phases)"
echo "   • @tether/experience package (Experience Cards)"
echo "   • @tether/learning package (Learning Attribution Records)"
echo "   • Built-in skills (tether-architecture, tether-design)"