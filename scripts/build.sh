#!/bin/bash
set -e
echo "🏗️ Building Tether Codex..."
pnpm install
pnpm build
echo "✅ Build complete."
