#!/usr/bin/env bash
# setup-rofi.sh — نصب و راه‌اندازی کامل Rofi
# اجرا: bash setup-rofi.sh

set -e

ROFI_DIR="$HOME/.config/rofi"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing dependencies..."
sudo pacman -S --needed --noconfirm \
    rofi \
    fd \
    playerctl \
    gnu-units \
    python3 \
    papirus-icon-theme

# Wayland clipboard
if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    yay -S --needed --noconfirm cliphist wl-clipboard
else
    yay -S --needed --noconfirm rofi-greenclip xclip
    systemctl --user enable --now greenclip.service
fi

echo "==> Creating config directories..."
mkdir -p "$ROFI_DIR"/{themes,scripts}

echo "==> Copying configs..."
cp "$SCRIPT_DIR/config/config.rasi"           "$ROFI_DIR/config.rasi"
cp "$SCRIPT_DIR/themes/nordic-blur.rasi"      "$ROFI_DIR/themes/nordic-blur.rasi"
cp "$SCRIPT_DIR/scripts/"*.sh                 "$ROFI_DIR/scripts/"
chmod +x "$ROFI_DIR/scripts/"*.sh

echo "==> Done!"
echo ""
echo "Keybindings to set in KDE System Settings → Shortcuts → Custom Shortcuts:"
echo ""
echo "  Super + Space     →  rofi -show drun"
echo "  Super + Tab       →  rofi -show window"
echo "  Super + F         →  $ROFI_DIR/scripts/rofi-files.sh"
echo "  Super + V         →  $ROFI_DIR/scripts/rofi-clipboard.sh"
echo "  Super + M         →  $ROFI_DIR/scripts/rofi-music.sh"
echo "  Super + C         →  $ROFI_DIR/scripts/rofi-calc.sh"
echo "  Super + S         →  rofi -show ssh"
