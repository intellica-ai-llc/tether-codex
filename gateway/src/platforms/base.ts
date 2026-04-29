export interface PlatformAdapter { name: string; start(): Promise<void>; stop(): Promise<void>; sendMessage(chatId: string, content: string): Promise<void>; onMessage(h: (e: MessageEvent) => Promise<void>): void }
export interface MessageEvent { platform: string; chatId: string; userId: string; text: string; timestamp: Date }
