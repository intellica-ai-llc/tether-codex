import React, { useState } from 'react'

export function AgentConsole() {
  const [message, setMessage] = useState('')
  const [responses, setResponses] = useState<string[]>([])

  const sendMessage = async () => {
    if (!message.trim()) return
    setResponses([...responses, `You: ${message}`])
    try {
      const res = await fetch('/api/agent', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify({ message }) })
      const data = await res.json()
      setResponses(prev => [...prev, ...data.responses.map((r: any) => `[${r.agentName}] ${r.content}`)])
    } catch (e) {
      setResponses(prev => [...prev, 'Error connecting to agent'])
    }
    setMessage('')
  }

  return (
    <div className="border rounded-lg p-4">
      <div className="h-96 overflow-y-auto mb-4 space-y-2">
        {responses.map((r, i) => <div key={i} className="p-2 bg-gray-100 rounded">{r}</div>)}
      </div>
      <div className="flex gap-2">
        <input className="flex-1 border rounded px-3 py-2" value={message} onChange={e => setMessage(e.target.value)} onKeyDown={e => e.key === 'Enter' && sendMessage()} placeholder="@MAE, I want to build..." />
        <button className="px-4 py-2 bg-blue-600 text-white rounded" onClick={sendMessage}>Send</button>
      </div>
    </div>
  )
}
