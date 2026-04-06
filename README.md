# dotfiles

Fully reproducible Linux desktop environment using [chezmoi](https://www.chezmoi.io/). One command to set up a complete Hyprland + Wayland workstation from scratch.

## Quick Start

**New machine (fresh install):**

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply bamarler
```

You'll be prompted for machine-specific settings (hostname, GPU, monitor config, etc.) during init.

**Already have chezmoi:**

```bash
chezmoi init --apply bamarler
```

After applying, restart your shell and run `dots check` to verify everything installed correctly.

## What's Included

| Category | Configs |
|---|---|
| **Shell** | zsh, oh-my-zsh, powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting |
| **Desktop** | Hyprland, Waybar, Rofi, SwayNC, wlogout, hyprlock, hypridle |
| **Terminal** | Kitty (with theme collection) |
| **Editor** | Helix (config only, runtime auto-downloads), VS Code (settings + extensions) |
| **Dev Tools** | mise (runtimes), lazygit, delta (git pager), bat, eza, fd, ripgrep, zoxide |
| **Git** | gitconfig (templated), git-delta, 1Password SSH signing (optional) |
| **Fonts** | FantasqueSansM Nerd Font Mono (default), Font Manager for downloading more |
| **Wallpapers** | 35 webp images + WallpaperManager script + auto-cycle timer |
| **Scripts** | Screenshot, screen recording, rofi-bluetooth, rofi-wifi-menu, and more |
| **Theming** | wallust (pywal successor), qt5ct, qt6ct, gtk-3.0 |

## Init Prompts

On first run, chezmoi will ask:

| Prompt | Purpose |
|---|---|
| **Hostname** | Sets machine hostname |
| **Git name / email** | Your git identity |
| **NVIDIA GPU?** | Enables Wayland NVIDIA env vars |
| **Monitor config** | Primary monitor line for Hyprland (e.g. `eDP-1, preferred, auto, 1.67`) |
| **1Password?** | Enables SSH agent socket, git commit signing, SSH IdentityAgent |
| **Signing key** | Your 1Password SSH public key (only if 1Password = yes) |
| **Howdy?** | Facial recognition login via IR camera |

Friends without 1Password: answer `no` — you'll get a fully working setup with standard SSH keys and no commit signing.

## Daily Usage

```bash
# Edit a config in place (e.g. ~/.config/kitty/kitty.conf)
# Then sync it back to the chezmoi source:
dots sync

# See what chezmoi would change:
dots diff

# Apply source to home:
dots apply

# Pull latest from remote + apply:
dots update

# Check all dependencies:
dots check

# Install everything (or specific targets):
dots install
dots install brew
dots install apt
dots install mise
```

Run `dots` or `dots help` for all available commands.

## Install Targets

| Command | What it installs |
|---|---|
| `dots install omz` | oh-my-zsh + plugins + powerlevel10k |
| `dots install brew` | Homebrew packages from `Brewfile` |
| `dots install apt` | System packages from `apt.txt` / `pacman.txt` |
| `dots install mise` | Language runtimes (Node, Python, Go, etc.) |
| `dots install cargo` | Rust tools: wallust, hyprsession |
| `dots install uv` | Python tools: pyright, ruff, codegraphcontext, mcp-codebase-index |
| `dots install flatpak` | Spotify, WhatsApp |
| `dots install vscode` | 40+ VS Code extensions |
| `dots install fonts` | FantasqueSansM Nerd Font (default) |

## Font Manager

Press **Super+F** to open the rofi-based font manager. It can:

- View installed Nerd Fonts
- Download new fonts from [nerdfonts.com](https://www.nerdfonts.com/font-downloads)
- Switch the active font (updates Kitty, hyprlock, and VS Code automatically)
- Preview fonts in a temporary Kitty window
- Remove unused fonts

Current font is stored in `~/.config/font-manager/current`.

## Wallpaper Manager

Press **Super+M** to open the wallpaper manager, or:

- **Super+W** — select wallpaper
- **Super+Shift+W** — wallpaper effects
- **Ctrl+Alt+W** — random wallpaper

Wallpapers auto-cycle via a systemd user timer.

## For Friends / Forks

1. Fork this repo
2. Run `chezmoi init --apply <your-github-username>`
3. Answer the prompts (1Password = no, Howdy = no if you don't have them)
4. Add your wallpapers to `~/Pictures/wallpapers/` and run `dots sync`
5. Customize `UserConfigs/` and `UserScripts/` — they won't be overwritten by upstream

## Project Structure

```
~/.local/share/chezmoi/          # chezmoi source (this repo)
├── dot_zshrc.tmpl               # shell config (templated)
├── private_dot_gitconfig.tmpl   # git config (templated)
├── private_dot_ssh/             # SSH config (templated)
├── dot_config/
│   ├── hypr/                    # Hyprland (JaKooLit framework)
│   │   ├── configs/             # Default configs
│   │   ├── UserConfigs/         # User overrides (safe to edit)
│   │   ├── scripts/             # JaKooLit scripts
│   │   └── UserScripts/         # Custom scripts (FontManager, etc.)
│   ├── kitty/                   # Terminal + themes
│   ├── waybar/                  # Status bar
│   ├── rofi/                    # App launcher
│   ├── swaync/                  # Notification center
│   ├── wlogout/                 # Logout menu
│   ├── mise/                    # Runtime manager
│   ├── helix/                   # Editor (no runtime/)
│   └── ...
├── packages/                    # Package lists
│   ├── Brewfile                 # Homebrew
│   ├── apt.txt                  # Debian/Ubuntu
│   ├── pacman.txt               # Arch (stub)
│   ├── flatpak.txt              # Flatpak apps
│   └── vscode-extensions.txt    # VS Code
├── run_once_before_00-*.sh      # Bootstrap: oh-my-zsh
├── run_onchange_10-*.sh.tmpl    # Bootstrap: brew (hash-triggered)
├── run_onchange_11-*.sh.tmpl    # Bootstrap: apt (hash-triggered)
├── run_onchange_20-*.sh.tmpl    # Bootstrap: mise (hash-triggered)
├── run_once_3x-*.sh             # Bootstrap: cargo, uv, flatpak, vscode, etc.
└── .chezmoi.toml.tmpl           # Init prompts
```

## Not Tracked

These are machine-specific or sensitive and must be set up manually:

- `~/.ssh/id_*`, `~/.ssh/known_hosts` — SSH keys
- `~/.gnupg/` — GPG keys
- `~/.1password/` — 1Password agent
- `~/.config/helix/runtime/` — auto-downloads on first run (2.1GB)
- `~/.zsh_history`, `~/.zcompdump*` — shell state
- `~/.claude/` — Claude Code sessions

See [SETUP.md](SETUP.md) for post-bootstrap manual steps.
See [KEYBINDS.md](KEYBINDS.md) for the complete keybind reference.
