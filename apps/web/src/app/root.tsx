import React from 'react'
import { BrowserRouter, Routes, Route } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

const queryClient = new QueryClient()

export function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<div className="p-8"><h1 className="text-4xl font-bold">Tether Codex</h1><p className="mt-4">Autonomous Software Organization</p></div>} />
        </Routes>
      </BrowserRouter>
    </QueryClientProvider>
  )
}
