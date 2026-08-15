#!/usr/bin/env bash
# rofi-clipboard — از Klipper داخل KDE استفاده می‌کنه

selected=$(qdbus6 org.kde.klipper /klipper \
    org.kde.klipper.klipper.getClipboardHistoryMenu \
    | rofi -dmenu \
        -p " Clipboard" \
        -theme "$HOME/.config/rofi/themes/nordic-blur.rasi" \
        -theme-str 'window {width: 600px;}')

[[ -z "$selected" ]] && exit 0

qdbus6 org.kde.klipper /klipper \
    org.kde.klipper.klipper.setClipboardContents "$selected"
