CREATE TABLE public.payment_webhooks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  provider TEXT NOT NULL CHECK (provider IN ('stripe', 'paddle')),
  event_type TEXT NOT NULL,
  event_data JSONB,
  processed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE public.payment_webhooks ENABLE ROW LEVEL SECURITY;
