#!/bin/bash
set -euo pipefail

echo "==> Installing Cargo tools..."

if command -v cargo &>/dev/null; then
    cargo install hyprsession wallust 2>/dev/null || true
    echo "[OK] Cargo tools installed"
else
    echo "[SKIP] cargo not found, install Rust first"
fi
