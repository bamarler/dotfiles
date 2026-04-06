#!/usr/bin/env bash
# Wallpaper Manager

wallDIR="$HOME/Pictures/wallpapers"
rofi_theme="$HOME/.config/rofi/config-wallpaper.rasi"
SCRIPTSDIR="$HOME/.config/hypr/scripts"

# Icon sizing (same as WallpaperSelect)
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')
scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .scale')
monitor_height=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .height')
icon_size=$(echo "scale=1; ($monitor_height * 3) / ($scale_factor * 150)" | bc)
adjusted_icon_size=$(echo "$icon_size" | awk '{if ($1 < 15) $1 = 20; if ($1 > 25) $1 = 25; print $1}')
rofi_override="element-icon{size:${adjusted_icon_size}%;}"

convert_to_webp() {
    local file="$1"
    local output="${file%.*}.webp"
    cwebp -q 90 "$file" -o "$output" && rm "$file"
    echo "$output"
}

add_wallpapers() {
    local files=$(zenity --file-selection --multiple --title="Select Wallpapers" --file-filter="Images | *.jpg *.jpeg *.png *.webp")
    [[ -z "$files" ]] && return
    
    IFS='|' read -ra FILE_ARRAY <<< "$files"
    
    for file in "${FILE_ARRAY[@]}"; do
        [[ -f "$file" ]] || continue
        local basename=$(basename "$file")
        local dest="$wallDIR/$basename"
        
        cp "$file" "$dest"
        
        if [[ ! "$dest" =~ \.webp$ ]]; then
            convert_to_webp "$dest"
        fi
    done
    
    notify-send "Wallpapers" "Added and converted to WebP"
}

display_wallpapers() {
    mapfile -d '' PICS < <(find -L "$wallDIR" -type f \( -name "*.webp" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) -print0)
    
    {
        printf "➕ Add Wallpapers\x00icon\x1f%s\n" "/usr/share/icons/Papirus/48x48/actions/list-add.svg"
        
        for pic in "${PICS[@]}"; do
            printf "%s\x00icon\x1f%s\n" "$(basename "$pic")" "$pic"
        done
    } | rofi -dmenu -config "$rofi_theme" -theme-str "$rofi_override"
}

action_menu() {
    local file="$1"
    local fullpath="$wallDIR/$file"
    
    local choice=$(echo -e "Set Wallpaper\nSet Lock Screen\nRename\nDelete\nCancel" | \
        rofi -dmenu -p "📷 $file" -mesg "Selected: $(basename "$file")")
    
    case "$choice" in
        "Set Wallpaper")
            swww img -o "$focused_monitor" "$fullpath" --transition-type "grow"
            ;;
        "Set Lock Screen")
            sed -i "20s|.*|    path = $fullpath|" ~/.config/hypr/hyprlock.conf
            notify-send "Lock Screen" "Set to $file"
            ;;
        "Rename")
            local new_name=$(rofi -dmenu -p "New name")
            [[ -n "$new_name" ]] && mv "$fullpath" "$wallDIR/$new_name"
            ;;
        "Delete")
            rm "$fullpath"
            notify-send "Deleted" "$file"
            ;;
    esac
}

# Main loop
while true; do
    choice=$(display_wallpapers)
    [[ -z "$choice" ]] && exit 0

    if [[ "$choice" == "➕ Add Wallpapers" ]]; then
        add_wallpapers
    else
        action_menu "$choice"
    fi
done
