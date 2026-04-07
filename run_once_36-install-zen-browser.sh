#!/bin/bash
set -euo pipefail

echo "==> Installing Zen Browser..."

INSTALL_DIR="$HOME/.tarball-installations/zen"
BIN="$HOME/.local/bin/zen"
DESKTOP="$HOME/.local/share/applications/zen.desktop"

if [ -d "$INSTALL_DIR" ] && [ -x "$INSTALL_DIR/zen" ]; then
    echo "[OK] Zen Browser already installed"
    exit 0
fi

mkdir -p "$INSTALL_DIR" "$HOME/.local/bin" "$HOME/.local/share/applications"

# Download latest release
TMP=$(mktemp -d)
echo "Downloading Zen Browser..."
curl -fsSL "https://github.com/nicoth-in/zen-browser-bin/releases/latest/download/zen-browser.tar.xz" -o "$TMP/zen.tar.xz" 2>/dev/null || \
curl -fsSL "https://github.com/nicoth-in/zen-browser-bin/releases/latest/download/zen.linux-x86_64.tar.xz" -o "$TMP/zen.tar.xz" 2>/dev/null || \
curl -fsSL "$(curl -fsSL https://api.github.com/repos/zen-browser/desktop/releases/latest | grep -o 'https://[^"]*linux-x86_64.tar.xz' | head -1)" -o "$TMP/zen.tar.xz"

echo "Extracting..."
tar -xf "$TMP/zen.tar.xz" -C "$INSTALL_DIR" --strip-components=1
rm -rf "$TMP"

# Create wrapper script
cat > "$BIN" << 'WRAPPER'
#!/bin/bash
exec "$HOME/.tarball-installations/zen/zen" "$@"
WRAPPER
chmod +x "$BIN"

# Create desktop entry
cat > "$DESKTOP" << DESKTOP
[Desktop Entry]
Name=Zen Browser
Comment=Experience tranquillity while browsing the web without people tracking you!
Keywords=web;browser;internet
Exec=$HOME/.tarball-installations/zen/zen %u
Icon=$HOME/.tarball-installations/zen/browser/chrome/icons/default/default128.png
Terminal=false
StartupNotify=true
StartupWMClass=zen
NoDisplay=false
Type=Application
MimeType=text/html;text/xml;application/xhtml+xml;application/vnd.mozilla.xul+xml;text/mml;x-scheme-handler/http;x-scheme-handler/https;
Categories=Network;WebBrowser;
Actions=new-window;new-private-window;profile-manager-window;
[Desktop Action new-window]
Name=Open a New Window
Exec=$HOME/.tarball-installations/zen/zen --new-window %u
[Desktop Action new-private-window]
Name=Open a New Private Window
Exec=$HOME/.tarball-installations/zen/zen --private-window %u
[Desktop Action profile-manager-window]
Name=Open the Profile Manager
Exec=$HOME/.tarball-installations/zen/zen --ProfileManager
DESKTOP

echo "[OK] Zen Browser installed"
