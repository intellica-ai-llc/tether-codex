export interface StripeWebhookEvent { id: string; type: string; data: { object: any } }
export interface PaddleWebhookEvent { alert_id: string; alert_name: string; subscription_id?: string; passthrough?: string }
export interface PaymentWebhookLog { id: string; provider: 'stripe' | 'paddle'; event_type: string; event_data: any; processed: boolean; created_at: string }
