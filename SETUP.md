# Post-Bootstrap Setup

After running `chezmoi init --apply`, these manual steps complete the setup.

## 1. NVIDIA Driver (if applicable)

```bash
# Linux Mint / Ubuntu
sudo ubuntu-drivers install
sudo reboot
```

Verify: `nvidia-smi` should show your GPU. The chezmoi template auto-enables Wayland NVIDIA env vars if you answered `hasNvidia = true` during init.

## 2. 1Password (optional)

If you use 1Password for SSH agent and git commit signing:

1. Install [1Password](https://1password.com/downloads/linux/) and the CLI (`op`)
2. Enable SSH agent in 1Password settings
3. The chezmoi template auto-configures:
   - `SSH_AUTH_SOCK` pointing to `~/.1password/agent.sock`
   - Git commit signing via `op-ssh-sign`
   - SSH `IdentityAgent` in `~/.ssh/config`
4. Test: `ssh -T git@github.com`

If you don't use 1Password, generate SSH keys manually:

```bash
ssh-keygen -t ed25519 -C "your@email.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

## 3. Howdy — Facial Recognition (optional)

If you have an IR camera and answered `useHowdy = true`:

**Linux Mint / Ubuntu:**
```bash
sudo add-apt-repository ppa:slimbook/slimbook
sudo apt update && sudo apt install howdy
```

**Arch:**
```bash
yay -S howdy
```

Then enroll your face:
```bash
sudo howdy add
```

Test: `sudo howdy test` — you should see your face detected.

Howdy works with `sudo`, login screen, and `polkit` prompts.

## 4. GPG Keys

If you have existing GPG keys:

```bash
gpg --import private-key.asc
gpg --import public-key.asc
gpg --edit-key <KEY_ID> trust  # set to ultimate
```

## 5. Tailscale

```bash
sudo tailscale up
```

Authenticate in the browser when prompted.

## 6. Flatpak Apps

The bootstrap script installs Spotify and WhatsApp. For additional apps:

```bash
flatpak install flathub <app-id>
```

Browse: https://flathub.org/

## 7. Timeshift Backup

Set up automatic system snapshots:

```bash
sudo timeshift --create --comments "Post-setup baseline"
```

Configure schedule in Timeshift GUI (daily recommended).

## 8. WiFi / VPN

WiFi credentials are stored by NetworkManager and not tracked in dotfiles. Connect manually after install.

For Northeastern VPN:
```bash
sudo -E gpclient connect --browser default vpn.northeastern.edu
```

## 9. LUKS / Disk Encryption

Disk encryption must be configured during OS installation. It cannot be added after the fact without data loss. If you need encryption, enable it during the install wizard.

## 10. Secure Boot / MOK Keys

If using Secure Boot with NVIDIA:

```bash
sudo mokutil --import /var/lib/shim-signed/mok/MOK.der
```

Reboot and enroll the key in the MOK manager.

## Verification

After completing setup, run:

```bash
dots check    # verify all tools installed
dots doctor   # chezmoi health check
dots status   # confirm no drift between source and home
```
