#!/bin/bash

notify-send "Getting WiFi networks..."

# Get list of networks, remove duplicates
networks=$(nmcli -f SSID device wifi list | tail -n +2 | awk '{$1=$1};1' | sort -u)

# Show in rofi
chosen=$(echo "$networks" | rofi -dmenu -i -p "WiFi" -theme-str 'window {width: 30%;}')

if [ -z "$chosen" ]; then
    exit 0
fi

# Check if already saved
if nmcli connection show | grep -q "$chosen"; then
    nmcli connection up "$chosen"
else
    # Ask for password
    password=$(rofi -dmenu -password -p "Password for $chosen")
    nmcli device wifi connect "$chosen" password "$password"
fi
