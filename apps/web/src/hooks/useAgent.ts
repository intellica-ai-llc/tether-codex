import { useState } from 'react'

export function useAgent() {
  const [loading, setLoading] = useState(false)
  const send = async (msg: string) => { setLoading(true); const res = await fetch('/api/agent', { method: 'POST', body: JSON.stringify({ message: msg }) }); setLoading(false); return res.json() }
  return { send, loading }
}
