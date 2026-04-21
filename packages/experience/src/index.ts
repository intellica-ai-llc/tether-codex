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
      last_used_at: undefined,
      success_rate: undefined,
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
    
    const currentRate = card.success_rate ?? 0.5
    if (card.times_used === 1) {
      card.success_rate = success ? 1.0 : 0.0
    } else {
      card.success_rate = (currentRate * (card.times_used - 1) + (success ? 1 : 0)) / card.times_used
    }
    
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