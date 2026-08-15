#!/usr/bin/env bash
# rofi-files — سرچ فایل با fd
# Dependencies: fd, xdg-open

if ! command -v fd &>/dev/null; then
    notify-send "rofi-files" "fd not installed\nsudo pacman -S fd"
    exit 1
fi

SEARCH_DIR="${1:-$HOME}"

# سرچ با fd — فایل‌ها و پوشه‌ها
selected=$(fd . "$SEARCH_DIR" \
    --hidden \
    --exclude .git \
    --exclude node_modules \
    --exclude __pycache__ \
    --exclude .cache \
    2>/dev/null \
    | rofi -dmenu \
        -p " Files" \
        -theme "$HOME/.config/rofi/themes/nordic-blur.rasi" \
        -theme-str 'window {width: 700px;}' \
        -i \
        -matching fuzzy \
        -mesg "Fuzzy search in $SEARCH_DIR")

[[ -z "$selected" ]] && exit 0

if [[ -d "$selected" ]]; then
    # پوشه → باز کردن در dolphin
    dolphin "$selected" &
elif [[ -f "$selected" ]]; then
    # فایل → باز کردن با اپ پیش‌فرض
    xdg-open "$selected" &
fi
