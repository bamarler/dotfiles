#!/usr/bin/env bash
# Lock screen wallpaper selector

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .scale')
monitor_height=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .height')
icon_size=$(echo "scale=1; ($monitor_height * 3) / ($scale_factor * 150)" | bc)
adjusted_icon_size=$(echo "$icon_size" | awk '{if ($1 < 15) $1 = 20; if ($1 > 25) $1 = 25; print $1}')
rofi_override="element-icon{size:${adjusted_icon_size}%;}"

wallDIR="$HOME/Pictures/wallpapers"
hyprlock_conf="$HOME/.config/hypr/hyprlock.conf"
rofi_theme="$HOME/.config/rofi/config-wallpaper.rasi"

# Get images only (no videos for lock screen)
mapfile -d '' PICS < <(find -L "${wallDIR}" -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) -print0)

# Rofi menu
menu() {
  for pic in "${PICS[@]}"; do
    printf "%s\x00icon\x1f%s\n" "$(basename "$pic")" "$pic"
  done
}

choice=$(menu | rofi -dmenu -config "$rofi_theme" -theme-str "$rofi_override")
[[ -z "$choice" ]] && exit 0

selected=$(find "$wallDIR" -name "$choice" -print -quit)
[[ -z "$selected" ]] && exit 1

# Update hyprlock.conf path line
sed -i "20s|.*|    path = $selected|" "$hyprlock_conf"

notify-send "Lock Screen" "Wallpaper updated to $choice"
