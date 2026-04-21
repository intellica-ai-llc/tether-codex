#!/bin/bash
set -e
echo "🚀 Deploying Tether Codex..."
pnpm build
pnpm --filter api deploy
echo "✅ Deploy complete."
