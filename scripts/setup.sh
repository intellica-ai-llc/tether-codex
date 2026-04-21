#!/bin/bash
set -e
echo "🔧 Tether Codex Setup"
pnpm install
pnpm build
echo "✅ Setup complete. Run 'pnpm dev' to start."
