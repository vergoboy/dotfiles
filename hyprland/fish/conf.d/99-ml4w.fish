# -----------------------------------------------------
# ML4W aliases (added by ML4W install script)
# Does not override existing user aliases in config.fish
# -----------------------------------------------------

alias nf='fastfetch'
alias pf='fastfetch'
alias ff='fastfetch'
alias shutdown='~/.config/ml4w/scripts/ml4w-power -p'
alias v='$EDITOR'
alias vim='$EDITOR'
alias wifi='nmtui'
alias arch-cleanup='~/.config/ml4w/scripts/arch/cleanup.sh'
alias apps='~/.config/ml4w/bin/ml4w-apps'
alias screenshot='~/.config/ml4w/bin/ml4w-screenshot'
alias updates='~/.config/ml4w/scripts/ml4w-install-system-updates'
alias filemanager='~/.config/ml4w/settings/filemanager'
alias autostart='~/.config/ml4w/scripts/ml4w-autostart'
alias lock='hyprlock'
alias clock='tty-clock'
alias system='~/.config/ml4w/settings/systemmonitor'
alias quick='~/.config/ml4w/bin/ml4w-quicklinks'
alias wallpaper='~/.config/ml4w/bin/ml4w-wallpaper'
alias settings='ml4w-dotfiles-settings com.ml4w.dotfiles'

# -----------------------------------------------------
# ML4W Apps
# -----------------------------------------------------
alias ml4w='qs ipc call welcome toggle'
alias ml4w-settings='qs -p ~/.local/share/ml4w-dotfiles-settings/quickshell ipc call settings toggle'
alias ml4w-calendar='qs ipc call calendar toggle'
alias ml4w-hyprland='flatpak run com.ml4w.hyprlandsettings'
alias ml4w-sidebar='qs ipc call sidebar toggle'
