# macOS Setup — Get Running Fast After First Login

This is the macOS counterpart to [SETUP.md](SETUP.md) (which is Linux/Hyprland).
Follow it top to bottom on a brand-new Mac. Goal: minimal manual work — most of the
setup is automated by chezmoi; what's left are the things macOS *forces* to be manual
(permission clicks, app logins, a couple of in-app settings).

---

## 1. Bootstrap (one time, ~15–30 min mostly unattended)

Run these in **Terminal.app** (Spotlight → "Terminal"):

```bash
# 1. Xcode Command Line Tools (git, compilers) — click through the GUI prompt
xcode-select --install

# 2. Homebrew — needs your password once; installs to /opt/homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"

# 3. chezmoi — then pull + apply this repo in one shot
brew install chezmoi
chezmoi init --apply bamarler
```

> **Why install Homebrew first** instead of the pure `get.chezmoi.io` one-liner: the Homebrew
> installer needs an interactive password prompt, which doesn't work when chezmoi runs it
> non-interactively during `apply`. Doing brew by hand first is the reliable fast path — and
> once brew exists, chezmoi's brew step just runs `brew bundle` (no reinstall).

### What the init prompts ask (macOS only asks these)

| Prompt | Answer |
|---|---|
| **Hostname** | e.g. your Mac's name |
| **Git name / email** | your identity |
| **Use 1Password?** | `yes` if you'll use 1Password for SSH agent + git signing |
| **Signing key** | your 1Password SSH public key (only if 1Password = yes) |

The Linux-only prompts (NVIDIA, Hyprland monitor, Howdy) are **skipped on macOS** — you
won't see them.

### What runs automatically during `apply`

- Installs **all Homebrew formulae + casks** from `packages/Brewfile.tmpl` (AeroSpace,
  Karabiner, Orion, Ghostty, Raycast, 1Password, Slack, Spotify, WhatsApp, Tailscale,
  OrbStack, VS Code, Claude Code, the FantasqueSansM Nerd Font, …)
- Installs mise runtimes, uv tools, VS Code extensions
- Places every tracked config: **AeroSpace, Karabiner, Ghostty, zsh, git, Helix, VS Code, btop, lazygit, …**

When it finishes, **restart your shell** (`exec zsh`) so oh-my-zsh / powerlevel10k / the
`dots` function load.

---

## 2. Grant permissions (the unavoidable human clicks)

macOS requires these to be granted by hand. Do them in **System Settings → Privacy & Security**.
Launch each app once so it appears in the list (add with `+` → `/Applications/…` if not).

| App | Permission(s) | Why |
|---|---|---|
| **AeroSpace** | Accessibility | Tiling / moving windows + `cmd` keybindings |
| **Karabiner-Elements** | Input Monitoring **+** enable its **Driver Extension** (Login Items & Extensions → Driver Extensions → Karabiner-VirtualHIDDevice) | Caps Lock → Cmd remap. **Do this early** — your AeroSpace `cmd` bindings depend on it |
| **Raycast** | Accessibility | Window/command features |
| **Shottr** | Screen Recording **+** Accessibility | Screenshots / annotations |

> Karabiner walks you through most of its own permission grants on first launch — follow its
> prompts. Nothing else works right until Karabiner's driver is enabled and Input Monitoring
> is on.

---

## 3. Sign in / authenticate

- **1Password** — sign in, turn on **Developer → Use the SSH agent**, enable Touch ID unlock.
  (If you answered 1Password = yes, git commit signing + SSH both flow through this.)
- **Tailscale** — open the app (or `tailscale up`) and authenticate in the browser.
- **Slack, Spotify, WhatsApp** — sign in.
- **GitHub** — via 1Password SSH agent, or `gh auth login` if not using 1Password.

Verify SSH: `ssh -T git@github.com`

---

## 4. Manual app settings to reproduce (the "I'll forget these" list)

These live inside apps, not in files, so chezmoi can't track them. **Recreate each by hand,
and add new ones here as you set them so future-you has the list.**

### Orion (browser)
Settings → Keyboard Shortcuts (or the app's shortcut editor):

| Shortcut | Action |
|---|---|
| **Cmd + G** | Show/hide sidebar |

*(Add any other Orion shortcuts/settings you customize here.)*

### Raycast
- Set the launcher hotkey (and, if using **Cmd + Space**, first disable Spotlight's hotkey:
  System Settings → Keyboard → Keyboard Shortcuts → Spotlight → uncheck "Show Spotlight search").
- Raycast settings aren't file-tracked — use Raycast's own **Export/Import** (Settings →
  Advanced → Export) to move your config, and drop the `.rayconfig` somewhere safe.

### macOS System Settings (optional dev defaults)
Not tracked. Common ones to re-apply — run in a terminal, then log out/in:

```bash
# Fast key repeat, no press-and-hold accent popup (better for Vim/Helix)
defaults write -g ApplePressAndHoldEnabled -bool false
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15
```

*(Add trackpad, Dock, Finder, etc. tweaks here as you make them.)*

---

## 5. Verify

```bash
dots status    # no drift between chezmoi source and home
aerospace reload-config   # config loads clean (ignore the config-version warning)
```

- Tiling works, `cmd + enter` opens a new Ghostty window, `cmd + b` opens a new Orion window,
  hovering a window focuses it.
- Ghostty shows FantasqueSansM Nerd Font.

---

## 6. Daily usage (same as Linux)

```bash
dots sync      # re-add changed files from home → chezmoi source, show status
dots diff      # preview what apply would change
dots apply     # apply source → home
dots update    # git pull + apply
```

Then `git -C ~/.local/share/chezmoi commit` + `push` to save changes. See the main
[README.md](README.md) for the full `dots` command list.
