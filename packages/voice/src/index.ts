export interface VoiceConfig { useWhisperFallback: boolean; whisperApiKey?: string }

export class TetherVoice {
  private recognition: any = null
  private isListening = false
  private config: VoiceConfig

  constructor(config: VoiceConfig = { useWhisperFallback: true }) { this.config = config }

  async startListening(onTranscript: (text: string) => void): Promise<void> {
    if (typeof window !== 'undefined' && 'webkitSpeechRecognition' in window) {
      const SpeechRecognition = (window as any).webkitSpeechRecognition
      this.recognition = new SpeechRecognition()
      this.recognition.continuous = true
      this.recognition.interimResults = false
      this.recognition.onresult = (event: any) => {
        const transcript = Array.from(event.results).map((r: any) => r[0].transcript).join('')
        onTranscript(transcript)
      }
      this.recognition.start()
      this.isListening = true
    } else if (this.config.useWhisperFallback) {
      console.log('Whisper fallback would record audio and send to API')
      onTranscript('[Voice input would appear here]')
    } else {
      throw new Error('Voice input not supported')
    }
  }

  stopListening(): void { if (this.recognition) { this.recognition.stop(); this.isListening = false } }
  isActive(): boolean { return this.isListening }
}
