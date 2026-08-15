#!/usr/bin/env bash
# rofi-quickmenu.sh — Super+X
# کلیدهای میانبر مستقیم

THEME="$HOME/.config/rofi/themes/nordic-blur.rasi"
THEME_STR='window {width: 420px;} listview {lines: 15;}'

# ── Power submenu ──
power_menu() {
    rofi -dmenu \
        -p "󰐥  Power" \
        -theme "$THEME" \
        -theme-str "$THEME_STR" \
        -no-custom \
        -kb-custom-1 "u" \
        -kb-custom-2 "r" \
        -kb-custom-3 "l" \
        -kb-custom-4 "p" \
        -kb-custom-5 "k" \
        << 'EOF'
[u]   Shutdown
[r]   Reboot
[l]   Logout
[p]   Suspend
[k]   Lock Screen
EOF

    case "$?" in
        10) systemctl poweroff ;;
        11) systemctl reboot ;;
        12) loginctl terminate-user "$USER" ;;
        13) systemctl suspend ;;
        14) loginctl lock-session ;;
        0)
            # اگه با Enter انتخاب کرد
            case "$REPLY" in
                *Shutdown*) systemctl poweroff ;;
                *Reboot*)   systemctl reboot ;;
                *Logout*)   loginctl terminate-user "$USER" ;;
                *Suspend*)  systemctl suspend ;;
                *Lock*)     loginctl lock-session ;;
            esac
            ;;
    esac
}

# ── Main menu ──
REPLY=$(rofi -dmenu \
    -p "󰣖  Quick" \
    -theme "$THEME" \
    -theme-str "$THEME_STR" \
    -no-custom \
    -kb-custom-1  "z" \
    -kb-custom-2  "o" \
    -kb-custom-3  "c" \
    -kb-custom-4  "b" \
    -kb-custom-5  "f" \
    -kb-custom-6  "e" \
    -kb-custom-7  "y" \
    -kb-custom-8  "s" \
    -kb-custom-9  "g" \
    -kb-custom-10 "u" \
    << 'EOF'
[z]   Zen Browser
[o]   OBS Studio
[c]   VSCodium (Wayland)
[b]   btop
[f]   FileZilla
[e]   Element
[y]   Yazi
[s]   System Settings
[g]   Steam
──────────────────────
[u]   Power...
EOF
)

EXIT=$?

# kb-custom-* از exit code 10 شروع میشه
case "$EXIT" in
    10) zen-browser & ;;
    11) obs & ;;
    12) codium --ozone-platform=wayland & ;;
    13) kitty --title btop -e btop & ;;
    14) filezilla & ;;
    15) element-desktop & ;;
    16) kitty --title yazi -e yazi & ;;
    17) systemsettings & ;;
    18) steam & ;;
    19) power_menu ;;
    0)
        # انتخاب با Enter
        case "$REPLY" in
            *Zen*)      zen-browser & ;;
            *OBS*)      obs & ;;
            *VSCodium*) codium --ozone-platform=wayland & ;;
            *btop*)     kitty --title btop -e btop & ;;
            *FileZilla*)filezilla & ;;
            *Element*)  element-desktop & ;;
            *Yazi*)     kitty --title yazi -e yazi & ;;
            *Settings*) systemsettings & ;;
            *Steam*)    steam & ;;
            *Power*)    power_menu ;;
        esac
        ;;
esac
