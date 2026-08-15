#!/usr/bin/env bash
# rofi-ssh — SSH با kitty kitten

HOSTS=$(cat ~/.ssh/config 2>/dev/null | grep "^Host " | awk '{print $2}' | grep -v '\*')
KNOWN=$(cat ~/.ssh/known_hosts 2>/dev/null | awk '{print $1}' | cut -d',' -f1 | sort -u)

ALL=$(printf '%s\n%s\n' "$HOSTS" "$KNOWN" | sort -u | grep -v '^$')

selected=$(echo "$ALL" | rofi -dmenu \
    -p " SSH" \
    -theme "$HOME/.config/rofi/themes/nordic-solid.rasi" \
    -theme-str 'window {width: 500px;}' \
    -mesg "Select host or type IP")

[[ -z "$selected" ]] && exit 0

kitty +kitten ssh "$selected"
