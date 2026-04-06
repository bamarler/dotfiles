#!/bin/bash
set -euo pipefail

echo "==> Cloning rofi scripts..."

SCRIPTS_DIR="$HOME/scripts"
mkdir -p "$SCRIPTS_DIR"

if [ ! -d "$SCRIPTS_DIR/rofi-bluetooth/.git" ]; then
    git clone https://github.com/nickclyde/rofi-bluetooth.git "$SCRIPTS_DIR/rofi-bluetooth" 2>/dev/null || true
    echo "[OK] rofi-bluetooth cloned"
fi

if [ ! -d "$SCRIPTS_DIR/rofi-wifi-menu/.git" ]; then
    git clone https://github.com/ericmurphyxyz/rofi-wifi-menu.git "$SCRIPTS_DIR/rofi-wifi-menu" 2>/dev/null || true
    echo "[OK] rofi-wifi-menu cloned"
fi

echo "==> Rofi scripts ready"
