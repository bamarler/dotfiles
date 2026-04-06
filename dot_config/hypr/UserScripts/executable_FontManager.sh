#!/usr/bin/env bash
# Font Manager - Rofi-based Nerd Font manager
# Switch between installed fonts, download new ones from nerdfonts.com

FONTS_DIR="$HOME/.local/share/fonts"
CURRENT_FONT_FILE="$HOME/.config/font-manager/current"
NERD_FONTS_BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download"
iDIR="$HOME/.config/swaync/images"

# Ensure config dir exists
mkdir -p "$(dirname "$CURRENT_FONT_FILE")"

# Get current font name
get_current_font() {
    if [[ -f "$CURRENT_FONT_FILE" ]]; then
        cat "$CURRENT_FONT_FILE"
    else
        echo "FantasqueSansMono"
    fi
}

# Save current font
set_current_font() {
    echo "$1" > "$CURRENT_FONT_FILE"
}

# Get the fc-list display name for a font directory
get_font_display_name() {
    local font_dir="$1"
    # Find a Mono variant ttf and extract the family name
    local mono_file
    mono_file=$(find "$FONTS_DIR/$font_dir" -maxdepth 1 -name "*Mono-Regular.ttf" -o -name "*Mono-Regular.otf" 2>/dev/null | head -1)
    if [[ -z "$mono_file" ]]; then
        mono_file=$(find "$FONTS_DIR/$font_dir" -maxdepth 1 -name "*Mono*.ttf" -o -name "*Mono*.otf" 2>/dev/null | head -1)
    fi
    if [[ -n "$mono_file" ]]; then
        fc-query --format='%{family[0]}\n' "$mono_file" 2>/dev/null | head -1
    else
        echo "$font_dir"
    fi
}

# List installed Nerd Font directories
list_installed_fonts() {
    local current
    current=$(get_current_font)
    for dir in "$FONTS_DIR"/*/; do
        [[ -d "$dir" ]] || continue
        local dirname
        dirname=$(basename "$dir")
        # Check if it has Nerd Font ttf files
        if ls "$dir"/*Nerd*.ttf &>/dev/null || ls "$dir"/*Nerd*.otf &>/dev/null; then
            if [[ "$dirname" == "$current" ]]; then
                echo "✓ $dirname"
            else
                echo "  $dirname"
            fi
        fi
    done
}

# Apply font to all configs
apply_font() {
    local font_dir="$1"
    local font_name
    font_name=$(get_font_display_name "$font_dir")

    if [[ -z "$font_name" ]]; then
        notify-send -i "$iDIR/error.png" "Font Manager" "Could not determine font name for $font_dir"
        return 1
    fi

    # Update kitty
    if [[ -f "$HOME/.config/kitty/kitty.conf" ]]; then
        sed -i "s/^font_family .*/font_family ${font_name} Bold/" "$HOME/.config/kitty/kitty.conf"
    fi

    # Update hyprlock (only lines with Nerd Font references, not Victor Mono decorative ones)
    if [[ -f "$HOME/.config/hypr/hyprlock.conf" ]]; then
        sed -i "s/font_family = .*Nerd Font.*/font_family = ${font_name} Bold/g" "$HOME/.config/hypr/hyprlock.conf"
    fi

    # Update VS Code
    local vscode_settings="$HOME/.config/Code/User/settings.json"
    if [[ -f "$vscode_settings" ]]; then
        # Use python/jq for safe JSON editing
        if command -v jq &>/dev/null; then
            local tmp
            tmp=$(mktemp)
            jq --arg font "'${font_name}', 'Droid Sans Mono', 'monospace'" \
                '.["editor.fontFamily"] = $font' "$vscode_settings" > "$tmp" && mv "$tmp" "$vscode_settings"
        fi
    fi

    # Save current font
    set_current_font "$font_dir"

    # Reload kitty
    if pgrep -x kitty &>/dev/null; then
        kill -SIGUSR1 "$(pgrep -x kitty)" 2>/dev/null
    fi

    # Refresh font cache
    fc-cache -f &>/dev/null

    notify-send "Font Manager" "Switched to $font_name"
}

# Download a new Nerd Font
download_font() {
    local font_name="$1"

    if [[ -z "$font_name" ]]; then
        font_name=$(rofi -dmenu -p "🔤 Font name" \
            -mesg "Enter the exact Nerd Font name (e.g. FiraCode, CascadiaCode, JetBrainsMono, Lilex)\nSee all fonts at: nerdfonts.com/font-downloads")
    fi

    [[ -z "$font_name" ]] && return

    local zip_url="${NERD_FONTS_BASE_URL}/${font_name}.zip"
    local tmp_zip="/tmp/${font_name}.zip"
    local tmp_dir="/tmp/${font_name}-extract"
    local dest_dir="$FONTS_DIR/$font_name"

    notify-send "Font Manager" "Downloading ${font_name}..."

    # Download
    if ! curl -sL --fail "$zip_url" -o "$tmp_zip" 2>/dev/null; then
        notify-send -i "$iDIR/error.png" "Font Manager" "Failed to download ${font_name}\nCheck the name at nerdfonts.com/font-downloads"
        rm -f "$tmp_zip"
        return 1
    fi

    # Extract
    rm -rf "$tmp_dir"
    mkdir -p "$tmp_dir"
    unzip -o "$tmp_zip" -d "$tmp_dir" > /dev/null 2>&1

    # Install only Mono variant to save space
    mkdir -p "$dest_dir"
    local found=0
    for f in "$tmp_dir"/*NerdFontMono*.ttf "$tmp_dir"/*NerdFontMono*.otf; do
        [[ -f "$f" ]] && cp "$f" "$dest_dir/" && found=1
    done

    # If no Mono variant found, copy all
    if [[ "$found" -eq 0 ]]; then
        cp "$tmp_dir"/*.ttf "$dest_dir/" 2>/dev/null
        cp "$tmp_dir"/*.otf "$dest_dir/" 2>/dev/null
    fi

    # Copy license if present
    cp "$tmp_dir"/LICENSE* "$tmp_dir"/OFL* "$dest_dir/" 2>/dev/null

    # Cleanup
    rm -rf "$tmp_zip" "$tmp_dir"

    fc-cache -f &>/dev/null

    notify-send "Font Manager" "${font_name} installed!\nSelect it from the font menu to activate."
}

# Remove a font
remove_font() {
    local font_dir="$1"
    local current
    current=$(get_current_font)

    if [[ "$font_dir" == "$current" ]]; then
        notify-send -i "$iDIR/error.png" "Font Manager" "Cannot remove the active font. Switch to another font first."
        return 1
    fi

    local confirm
    confirm=$(echo -e "Yes, delete\nCancel" | rofi -dmenu -p "🗑️ Remove $font_dir?")
    if [[ "$confirm" == "Yes, delete" ]]; then
        rm -rf "$FONTS_DIR/$font_dir"
        fc-cache -f &>/dev/null
        notify-send "Font Manager" "Removed $font_dir"
    fi
}

# Main menu
main_menu() {
    local current
    current=$(get_current_font)

    {
        echo "⬇️  Download New Font"
        echo "━━━━━━━━━━━━━━━━━━━━"
        list_installed_fonts
    } | rofi -dmenu -p "🔤 Font Manager" \
        -mesg "Current: $(get_font_display_name "$current")"
}

# Action menu for a selected font
action_menu() {
    local font_dir="$1"
    # Strip leading marker
    font_dir=$(echo "$font_dir" | sed 's/^[✓ ]* //')

    local font_name
    font_name=$(get_font_display_name "$font_dir")

    local choice
    choice=$(printf "Apply Font\nPreview (kitty)\nRemove\nCancel" | \
        rofi -dmenu -p "🔤 $font_dir" -mesg "Font: $font_name")

    case "$choice" in
        "Apply Font")
            apply_font "$font_dir"
            ;;
        "Preview (kitty)")
            # Open a temporary kitty window with the font for preview
            kitty --override "font_family=${font_name}" \
                  --override "font_size=16" \
                  --title "Font Preview: $font_name" \
                  -e bash -c "echo ''; echo '  Font: $font_name'; echo ''; echo '  ABCDEFGHIJKLMNOPQRSTUVWXYZ'; echo '  abcdefghijklmnopqrstuvwxyz'; echo '  0123456789'; echo '  !@#\$%^&*()_+-=[]{}|;:,.<>?'; echo '  -> => != >= <= === !== ~='; echo '  λ α β γ δ ε ζ η θ   '; echo ''; read -p '  Press Enter to close...'" &
            ;;
        "Remove")
            remove_font "$font_dir"
            ;;
    esac
}

# Kill existing rofi
if pidof rofi &>/dev/null; then
    pkill rofi
fi

# Main loop
while true; do
    choice=$(main_menu)
    [[ -z "$choice" ]] && exit 0

    case "$choice" in
        "⬇️  Download New Font")
            download_font
            ;;
        "━━━━━━━━━━━━━━━━━━━━")
            # Separator, ignore
            ;;
        *)
            action_menu "$choice"
            ;;
    esac
done
