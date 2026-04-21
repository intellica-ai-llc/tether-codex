import { Hono } from 'hono'
import Stripe from 'stripe'

type Env = {
  STRIPE_SECRET_KEY: string
  STRIPE_WEBHOOK_SECRET: string
}

const billing = new Hono<{ Bindings: Env }>()

billing.post('/create-checkout', async c => {
  const { priceId, successUrl, cancelUrl } = await c.req.json()
  const stripe = new Stripe(c.env.STRIPE_SECRET_KEY, { httpClient: Stripe.createFetchHttpClient() })
  const session = await stripe.checkout.sessions.create({ line_items: [{ price: priceId, quantity: 1 }], mode: 'subscription', success_url: successUrl, cancel_url: cancelUrl })
  return c.json({ url: session.url })
})

billing.post('/webhook', async c => {
  const body = await c.req.text()
  const signature = c.req.header('stripe-signature')
  const stripe = new Stripe(c.env.STRIPE_SECRET_KEY)
  try {
    const event = await stripe.webhooks.constructEventAsync(body, signature!, c.env.STRIPE_WEBHOOK_SECRET)
    console.log('Stripe webhook:', event.type)
  } catch (err) { return c.json({ error: 'Invalid signature' }, 400) }
  return c.json({ received: true })
})

export default billing
