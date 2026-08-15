#!/bin/bash
# ══════════════════════════════════════════════════
#  اسکریپت نصب و راه‌اندازی btop + GPU support
# ══════════════════════════════════════════════════

set -e

echo "🚀 راه‌اندازی btop با پشتیبانی GPU..."

# ────────────────────────────────
# نصب btop
# ────────────────────────────────
install_btop() {
    if command -v btop &>/dev/null; then
        echo "✅ btop قبلاً نصب شده: $(btop --version)"
        return
    fi

    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y btop
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm btop
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y btop
    elif command -v brew &>/dev/null; then
        brew install btop
    else
        echo "⚠️  پکیج منیجر شناخته نشد. btop رو دستی نصب کن:"
        echo "   https://github.com/aristocratos/btop/releases"
        exit 1
    fi
    echo "✅ btop نصب شد."
}

# ────────────────────────────────
# نصب ابزارهای GPU
# ────────────────────────────────
install_gpu_tools() {
    echo ""
    echo "🎮 بررسی GPU..."

    # NVIDIA
    if lspci 2>/dev/null | grep -qi nvidia; then
        echo "  → کارت NVIDIA شناسایی شد"
        if ! command -v nvidia-smi &>/dev/null; then
            echo "  ⚠️  nvidia-smi نصب نیست. درایور NVIDIA لازمه:"
            echo "     Ubuntu:  sudo apt install nvidia-driver-535"
            echo "     Arch:    sudo pacman -S nvidia"
        else
            echo "  ✅ nvidia-smi موجوده: $(nvidia-smi --query-gpu=name --format=csv,noheader 2>/dev/null | head -1)"
        fi
    fi

    # AMD
    if lspci 2>/dev/null | grep -qi "amd\|radeon\|advanced micro"; then
        echo "  → کارت AMD شناسایی شد"
        if lsmod | grep -q amdgpu; then
            echo "  ✅ درایور amdgpu لود شده"
        else
            echo "  ⚠️  درایور amdgpu لود نشده"
        fi
    fi

    # Intel Arc
    if lspci 2>/dev/null | grep -qi "intel.*arc\|intel.*xe"; then
        echo "  → کارت Intel Arc شناسایی شد"
        if lsmod | grep -q i915; then
            echo "  ✅ درایور i915 لود شده"
        fi
    fi
}

# ────────────────────────────────
# نصب Nerd Font (برای آیکون‌ها)
# ────────────────────────────────
install_nerd_font() {
    echo ""
    echo "🔤 نصب Nerd Font (JetBrainsMono)..."

    FONT_DIR="$HOME/.local/share/fonts"
    mkdir -p "$FONT_DIR"

    if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd"; then
        echo "  ✅ JetBrainsMono Nerd Font قبلاً نصبه"
        return
    fi

    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    TMP_DIR=$(mktemp -d)

    echo "  دانلود فونت..."
    if curl -fLo "$TMP_DIR/font.zip" "$FONT_URL" 2>/dev/null; then
        unzip -q "$TMP_DIR/font.zip" -d "$FONT_DIR/" 2>/dev/null
        fc-cache -f "$FONT_DIR" 2>/dev/null
        echo "  ✅ JetBrainsMono Nerd Font نصب شد"
    else
        echo "  ⚠️  دانلود فونت ناموفق. دستی نصب کن:"
        echo "     https://www.nerdfonts.com/font-downloads"
    fi
    rm -rf "$TMP_DIR"
}

# ────────────────────────────────
# کپی کانفیگ
# ────────────────────────────────
install_config() {
    echo ""
    echo "⚙️  نصب کانفیگ..."

    CONFIG_DIR="$HOME/.config/btop"
    mkdir -p "$CONFIG_DIR"

    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    if [ -f "$SCRIPT_DIR/btop.conf" ]; then
        if [ -f "$CONFIG_DIR/btop.conf" ]; then
            cp "$CONFIG_DIR/btop.conf" "$CONFIG_DIR/btop.conf.backup.$(date +%Y%m%d)"
            echo "  📦 بک‌آپ کانفیگ قبلی ساخته شد"
        fi
        cp "$SCRIPT_DIR/btop.conf" "$CONFIG_DIR/btop.conf"
        echo "  ✅ کانفیگ نصب شد → $CONFIG_DIR/btop.conf"
    else
        echo "  ⚠️  فایل btop.conf پیدا نشد. کنار این اسکریپت بذارش."
    fi
}

# ────────────────────────────────
# نصب تم dracula
# ────────────────────────────────
install_dracula_theme() {
    echo ""
    echo "🎨 نصب تم Dracula..."

    THEME_DIR="$HOME/.config/btop/themes"
    mkdir -p "$THEME_DIR"

    if [ ! -f "$THEME_DIR/dracula.theme" ]; then
        cat > "$THEME_DIR/dracula.theme" << 'THEME'
# Dracula theme for btop
theme[main_bg]="#282a36"
theme[main_fg]="#f8f8f2"
theme[title]="#f8f8f2"
theme[hi_fg]="#ff79c6"
theme[selected_bg]="#44475a"
theme[selected_fg]="#f8f8f2"
theme[inactive_fg]="#6272a4"
theme[graph_text]="#f8f8f2"
theme[meter_bg]="#44475a"
theme[proc_misc]="#f1fa8c"
theme[cpu_box]="#6272a4"
theme[mem_box]="#6272a4"
theme[net_box]="#6272a4"
theme[proc_box]="#6272a4"
theme[div_line]="#44475a"
theme[temp_start]="#50fa7b"
theme[temp_mid]="#f1fa8c"
theme[temp_end]="#ff5555"
theme[cpu_start]="#50fa7b"
theme[cpu_mid]="#f1fa8c"
theme[cpu_end]="#ff5555"
theme[free_start]="#50fa7b"
theme[free_mid]="#f1fa8c"
theme[free_end]="#ff5555"
theme[cached_start]="#8be9fd"
theme[cached_mid]="#8be9fd"
theme[cached_end]="#8be9fd"
theme[available_start]="#50fa7b"
theme[available_mid]="#f1fa8c"
theme[available_end]="#ff5555"
theme[used_start]="#50fa7b"
theme[used_mid]="#f1fa8c"
theme[used_end]="#ff5555"
theme[download_start]="#50fa7b"
theme[download_mid]="#f1fa8c"
theme[download_end]="#ff5555"
theme[upload_start]="#8be9fd"
theme[upload_mid]="#8be9fd"
theme[upload_end]="#ff79c6"
theme[process_start]="#50fa7b"
theme[process_mid]="#f1fa8c"
theme[process_end]="#ff5555"
THEME
        echo "  ✅ تم Dracula نصب شد"
    else
        echo "  ✅ تم Dracula از قبل موجوده"
    fi
}

# ────────────────────────────────
# اجرای همه مراحل
# ────────────────────────────────
main() {
    echo "══════════════════════════════════"
    echo "  نصب و راه‌اندازی btop"
    echo "══════════════════════════════════"

    install_btop
    install_gpu_tools
    install_nerd_font
    install_dracula_theme
    install_config

    echo ""
    echo "══════════════════════════════════"
    echo "✅ همه چیز آماده‌ست!"
    echo ""
    echo "برای اجرا: btop"
    echo ""
    echo "کلیدهای مفید:"
    echo "  m     → تغییر چیدمان"
    echo "  f     → فیلتر پروسس"
    echo "  k     → kill پروسس"
    echo "  +/-   → تنظیم سرعت آپدیت"
    echo "  esc   → خروج از منو"
    echo "  q     → خروج"
    echo "══════════════════════════════════"
}

main "$@"
