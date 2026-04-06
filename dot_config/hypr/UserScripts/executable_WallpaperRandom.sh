#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Script for Random Wallpaper ( CTRL ALT W)

wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

mapfile -d '' PICS < <(find -L "${wallDIR}" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" -o -name "*.gif" \) -print0)
RANDOMPICS="${PICS[$RANDOM % ${#PICS[@]}]}"

# Transition config
FPS=30
TYPE=$([ $((RANDOM % 2)) -eq 0 ] && echo "grow" || echo "outer")
DURATION=3
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION --transition-bezier $BEZIER --transition-pos $(echo $RANDOM),$(echo $RANDOM)"

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

swww query >/dev/null 2>&1 || { systemd-run --user swww-daemon; sleep 2; }
swww img -o "$focused_monitor" "$RANDOMPICS" $SWWW_PARAMS
