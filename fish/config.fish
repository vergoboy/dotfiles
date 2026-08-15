################################################################################
#  🐟  Fish Shell Config — handy for Linux / Git / Python / Docker / SSH
#  Path: ~/.config/fish/config.fish
################################################################################

# ──────────────────────────────────────────────────────────────────────────────
#  Environment and PATH
# ──────────────────────────────────────────────────────────────────────────────
set -gx EDITOR nvim            # or vim / nano
set -gx VISUAL $EDITOR
set -gx PAGER less
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8

# Add common paths to PATH
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/go/bin

# ──────────────────────────────────────────────────────────────────────────────
#  Nice informative prompt  (no external plugin needed)
# ──────────────────────────────────────────────────────────────────────────────
function fish_prompt
    set -l last_status $status
    set -l cyan    (set_color cyan)
    set -l yellow  (set_color yellow)
    set -l green   (set_color green)
    set -l red     (set_color red)
    set -l blue    (set_color brblue)
    set -l magenta (set_color magenta)
    set -l reset   (set_color normal)

    # ── user@host
    set -l host (command cat /proc/sys/kernel/hostname)
    set -l user_host "$cyan$USER$reset$magenta@$reset$cyan$host$reset"

    # ── current directory (abbreviated)
    set -l dir "$yellow"(prompt_pwd)"$reset"

    # ── Git status
    set -l git_info ""
    if command -sq git; and git rev-parse --is-inside-work-tree &>/dev/null
        set -l branch (git symbolic-ref --short HEAD 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
        set -l dirty ""
        if not git diff --quiet 2>/dev/null; or not git diff --cached --quiet 2>/dev/null
            set dirty "$red*$reset"
        end
        # number of commits ahead/behind remote
        set -l ahead  (git rev-list --count @{u}..HEAD 2>/dev/null; or echo 0)
        set -l behind (git rev-list --count HEAD..@{u} 2>/dev/null; or echo 0)
        set -l sync ""
        test "$ahead"  -gt 0; and set sync "$sync$green↑$ahead$reset"
        test "$behind" -gt 0; and set sync "$sync$red↓$behind$reset"
        set git_info " $blue($branch$dirty$sync)$reset"
    end

    # ── Python virtualenv
    set -l venv_info ""
if set -q VIRTUAL_ENV
    set venv_info " "(set_color magenta)"["(basename $VIRTUAL_ENV)"]"(set_color normal)
end

    # ── end symbol: green ✓ / red ✗
    set -l symbol
    if test $last_status -eq 0
        set symbol "$green❯$reset"
    else
        set symbol "$red❯$reset"
    end

    echo -n "$user_host:$dir$git_info$venv_info $symbol "
end

# Terminal tab title
function fish_title
    echo (prompt_pwd) " — fish"
end

# ──────────────────────────────────────────────────────────────────────────────
#  Git aliases
# ──────────────────────────────────────────────────────────────────────────────
alias g='git'
alias gs='git status -sb'
alias ga='git add'
alias gaa='git add -A'
alias gc='git commit -m'
alias gca='git commit --amend --no-edit'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull --rebase'
alias gl='git log --oneline --graph --decorate -20'
alias gla='git log --oneline --graph --decorate --all'
alias gd='git diff'
alias gds='git diff --staged'
alias gst='git stash'
alias gstp='git stash pop'
alias grb='git rebase'
alias gri='git rebase -i'
alias gcp='git cherry-pick'
alias gclean='git clean -fd'
alias gundo='git reset --soft HEAD~1'

# ──────────────────────────────────────────────────────────────────────────────
#  Docker / K8s aliases
# ──────────────────────────────────────────────────────────────────────────────
alias d='docker'
alias dc='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Image}}"'
alias dimg='docker images'
alias dprune='docker system prune -af --volumes'
alias dexec='docker exec -it'
alias dlogs='docker logs -f --tail=100'

alias k='kubectl'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kgs='kubectl get services'
alias kgn='kubectl get nodes'
alias kdp='kubectl describe pod'
alias kl='kubectl logs -f --tail=100'
alias kx='kubectl exec -it'
alias kns='kubectl config set-context --current --namespace'
alias kctx='kubectl config use-context'
alias kgctx='kubectl config get-contexts'

# ──────────────────────────────────────────────────────────────────────────────
#  Python / Node.js aliases
# ──────────────────────────────────────────────────────────────────────────────
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv'
alias activate='source .venv/bin/activate.fish'
alias pipi='pip install'
alias pipu='pip install --upgrade'
alias pipf='pip freeze > requirements.txt'
alias pipr='pip install -r requirements.txt'

alias ni='npm install'
alias nid='npm install -D'
alias nr='npm run'
alias nrs='npm run start'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nlg='npm list -g --depth=0'

alias yi='yarn install'
alias ya='yarn add'
alias yad='yarn add -D'
alias yr='yarn run'

# ──────────────────────────────────────────────────────────────────────────────
#  SSH / server aliases
# ──────────────────────────────────────────────────────────────────────────────
alias sshc='cat ~/.ssh/config'                     # show ssh config
alias sshkey='cat ~/.ssh/id_ed25519.pub'           # show public key
alias sshgen='ssh-keygen -t ed25519 -C'            # create new key
alias scpup='scp -r'                               # upload
alias ports='ss -tulnp'                            # open ports
alias myip='curl -s ifconfig.me'                   # public IP
alias localip='ip -4 addr show | grep -oP "(?<=inet\s)\d+(\.\d+){3}" | grep -v 127'

# ──────────────────────────────────────────────────────────────────────────────
#  Filesystem / general aliases
# ──────────────────────────────────────────────────────────────────────────────
alias ls='ls --color=auto -F'
alias ll='ls -lah --color=auto'
alias la='ls -lAh --color=auto'
alias lt='ls -lth --color=auto | head -20'         # newest files
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkd='mkdir -p'
alias rmf='rm -rf'
alias cp='cp -iv'
alias mv='mv -iv'
alias df='df -h'
alias du='du -sh'
alias dus='du -sh * | sort -h'                     # folder sizes sorted
alias grep='grep --color=auto'
alias rg='rg --smart-case'
alias cat='bat --style=plain 2>/dev/null'  # if bat is installed
alias top='htop 2>/dev/null; or top'
alias vi='$EDITOR'
alias battry='upower -i /org/freedesktop/UPower/devices/battery_BAT0'
alias cl='clear'
alias pw='poweroff'
alias treesize='ncdu'
alias pq='proxychains -q'
alias yay='paru'
alias scrcpy='scrcpy --window-title=dont-be-nosy'

# ──────────────────────────────────────────────────────────────────────────────
#  Useful functions
# ──────────────────────────────────────────────────────────────────────────────

# mkcd — create directory and enter it
function mkcd
    mkdir -p $argv[1]; and cd $argv[1]
end

# extract — extract various archives
function extract
    if test -f $argv[1]
        switch $argv[1]
            case '*.tar.bz2';  tar xjf $argv[1]
            case '*.tar.gz';   tar xzf $argv[1]
            case '*.tar.xz';   tar xJf $argv[1]
            case '*.tar';      tar xf  $argv[1]
            case '*.bz2';      bunzip2 $argv[1]
            case '*.gz';       gunzip  $argv[1]
            case '*.zip';      unzip   $argv[1]
            case '*.rar';      unrar x $argv[1]
            case '*.7z';       7z x    $argv[1]
            case '*';          echo "I don't know how to extract: $argv[1]"
        end
    else
        echo "File not found: $argv[1]"
    end
end

# fcd — search folder with fzf and cd into it
function fcd
    set -l search_dir .
    test (count $argv) -gt 0; and set search_dir $argv[1]
    set -l dir (find $search_dir -type d 2>/dev/null | fzf +m)
    test -n "$dir"; and cd "$dir"
end

# flog — search git log with fzf
function flog
    git log --oneline --color=always | fzf --ansi --preview 'git show {1}' | awk '{print $1}' | xargs git show
end

# fssh — pick host from ~/.ssh/config with fzf
function fssh
    set -l host (grep -E "^Host " ~/.ssh/config 2>/dev/null | awk '{print $2}' | fzf)
    test -n "$host"; and ssh $host
end

# pj — jump quickly to projects (adjust the path)
function pj
    set -l PROJECTS_DIR ~/projects
    set -l dir (ls $PROJECTS_DIR 2>/dev/null | fzf)
    test -n "$dir"; and cd "$PROJECTS_DIR/$dir"
end

# serve — simple HTTP server on current folder
function serve
    set -l port 8080
    test (count $argv) -gt 0; and set port $argv[1]
    echo "🌍 Serving on http://localhost:$port"
    python3 -m http.server $port
end

# dsh — quickly enter a Docker container shell
function dsh
    set -l container (docker ps --format "{{.Names}}" | fzf)
    test -n "$container"; and docker exec -it $container sh
end

# ksh — quickly enter a Kubernetes pod shell
function ksh
    set -l pod (kubectl get pods --no-headers | awk '{print $1}' | fzf)
    test -n "$pod"; and kubectl exec -it $pod -- sh
end

# backup — quick backup of a file/folder
function backup
    cp -r $argv[1] "$argv[1].bak.(date +%Y%m%d_%H%M%S)"
    echo "✅ Backup created"
end

# upd — update the system (Arch Linux)
function upd
    echo "📦 Updating the system..."
    sudo pacman -Syu
    if command -sq yay
        yay -Sua --noconfirm
    else if command -sq paru
        paru -Sua --noconfirm
    end
end

# weather
function weather
    set -l city ""
    test (count $argv) -gt 0; and set city $argv[1]
    curl -s "wttr.in/$city?lang=en&format=3"
end

# ──────────────────────────────────────────────────────────────────────────────
#  Better autocomplete
# ──────────────────────────────────────────────────────────────────────────────

# search history with arrows (fish default but we make sure)
bind \e\[A history-search-backward
bind \e\[B history-search-forward

# if fzf is installed, enable Ctrl+R history completion
if command -sq fzf
    fzf --fish | source
end

# if zoxide is installed (smart cd replacement)
if command -sq zoxide
    zoxide init fish | source
    alias cd='z'
end

# ──────────────────────────────────────────────────────────────────────────────
#  Tool variables
# ──────────────────────────────────────────────────────────────────────────────

# Python — pyenv
if command -sq pyenv
    pyenv init - | source
end

# Node — nvm / fnm
if command -sq fnm
    fnm env --use-on-cd | source
end

# ──────────────────────────────────────────────────────────────────────────────
#  Welcome message (optional — remove if you don't want it)
# ──────────────────────────────────────────────────────────────────────────────
if status is-interactive
    echo "🐟 fish "(fish --version | string match -r '\d+\.\d+\.\d+') "| "(date +"%A %d %B")
end
set -Ux LANG en_US.UTF-8
set -Ux LC_ALL en_US.UTF-8
pyenv init - | source
alias easyeffects="QSG_RHI_BACKEND=opengl command easyeffects"
alias easyeffects="QSG_RHI_BACKEND=opengl command easyeffects"
set fnm_path "$HOME/.local/share/fnm"
if test -d $fnm_path
    set PATH $fnm_path $PATH
    fnm env --use-on-cd | source
end
set -x MODELS_DIR /run/media/vergoboy/3C746F2B746EE75C/models
set -x LLAMA_DIR ~/Documents/git/llama.cpp
# redacted: DASHSCOPE_API_KEY was removed before publishing to GitHub (re-add locally)


# Added by Antigravity CLI installer
set -gx PATH "/home/vergoboy/.local/bin" $PATH
