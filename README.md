# dotfiles

Config for **vergoboy** — KDE Plasma (Wayland) + fish + nvim + rofi + fastfetch + more.

## Contents

Managed as a git repo directly inside `~/.config` with a **whitelist** `.gitignore`:
only the directories/files listed there are tracked, everything else is ignored.

Highlights:

| Area | Path |
|------|------|
| Shell | `fish/`, `starship.toml` |
| Editor | `nvim/`, `opencode/` |
| KDE / Plasma | `kdeglobals`, `kwinrc`, `kwinoutputconfig.json`, `kglobalshortcutsrc`, `plasma-org.kde.plasma.desktop-appletsrc`, `plasmashellrc`, `kdedefaults/`, `plasma-workspace/`, `Kvantum/`, `klassy/`, `kde-material-you-colors/`, `latte/` |
| Theme / QT / GTK | `gtk-3.0/`, `gtk-4.0/`, `gtkrc`, `QtProject.conf`, `Trolltech.conf`, `xsettingsd/` |
| Wayland | `waywallen/`, `wekde/`, `kwinoutputconfig.json` |
| Tools | `rofi/`, `fastfetch/`, `btop/`, `cava/`, `kitty/`, `nvim/`, `systemd/` |
| Systemd user units | `systemd/user/` |

## Secrets

Anything that could leak credentials is **excluded** (see `.gitignore`):
browsers, chat apps, VPN configs, `fish_variables`-level tokens, etc.
The `DASHSCOPE_API_KEY` in `fish/config.fish` was redacted before publishing.

## Usage

Clone elsewhere and symlink the directories you want into `~/.config/`:

```sh
git clone https://github.com/vergoboy/dotfiles.git ~/.config  # or a dotfiles dir
```

> Be careful — this repo is a whitelist, so pulling it over your existing
> `~/.config` will only touch the tracked files.
