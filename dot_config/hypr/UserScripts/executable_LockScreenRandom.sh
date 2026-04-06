#!/usr/bin/env bash
wallDIR="$HOME/Pictures/wallpapers"
hyprlock_conf="$HOME/.config/hypr/hyprlock.conf"

PICS=($(find -L ${wallDIR} -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -iname "*.webp" -o -iname "*.gif" \)))
RANDOM_PIC=${PICS[ $RANDOM % ${#PICS[@]} ]}

sed -i "20s|.*|    path = $RANDOM_PIC|" "$hyprlock_conf"
