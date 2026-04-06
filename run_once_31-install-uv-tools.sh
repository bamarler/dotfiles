#!/bin/bash
set -euo pipefail

echo "==> Installing uv tools..."

if command -v uv &>/dev/null; then
    uv tool install codegraphcontext 2>/dev/null || true
    uv tool install mcp-codebase-index 2>/dev/null || true
    uv tool install pyright 2>/dev/null || true
    uv tool install ruff 2>/dev/null || true
    echo "[OK] uv tools installed"
else
    echo "[SKIP] uv not found, install it first (brew install uv)"
fi
