# ===== Core Shell Configuration =====
export ZSH="$HOME/.oh-my-zsh"  # Oh My Zsh installation path
zstyle ':omz:update' mode auto # Automatic updates

# Plugins
plugins=(
  sudo
  fast-syntax-highlighting
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)
source $ZSH/oh-my-zsh.sh

# ===== Editor Configuration =====
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano' # Remote editor
else
  export EDITOR='micro' # Local editor
fi
export VISUAL="$EDITOR" # GUI applications

# ===== Path Configuration =====
# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="/usr/local/bin:$PATH"

# ===== Aliases =====
## System Utilities
alias c="clear"
alias x="exit"
alias cpu="sudo btop"
alias /="cd ~"
alias vi="nvim"
alias rm="trash"     # Safer alternative to rm
alias root="sudo -i" # Get root shell

## Navigation
alias l="eza --color='always' --icons='always' --sort='type'"
alias la="eza --color='always' --icons='always' --sort='type' -A -X"
alias ls="eza --color='always' --icons='always' --sort='type' -l"
alias lt="eza --tree --icons='always' --sort='type' --git-ignore -A"

## Configuration Files
alias edzshrc="$EDITOR ~/.zshrc"
alias zshrc="bat ~/.zshrc"
alias src="exec zsh" # Reload zsh config
alias gh="$EDITOR ~/.config/ghostty/config"

## Package Management (DNF)
alias dnf="sudo dnf5"
alias update="sudo dnf5 update -y"
alias install="sudo dnf5 install -y"
alias remove="sudo dnf5 remove -y"
alias search="sudo dnf5 search"

## Bat Enhancements
alias bat="bat --theme=base16"
alias b="bat"

# ===== Git Configuration =====
## Core Commands
alias gcl='git clone'
alias gco='git checkout'
alias gc='git commit -v' # Commit with diff preview
alias ga='git add'
alias gps='git push'
alias gpl='git pull --rebase'     # Rebase instead of merge
alias gst='git status -sb'        # Short status with branch info
alias gd='git diff --color-words' # Word-level diff

## Enhanced Logging
alias gl='git log --graph --pretty="%C(bold)%h%Creset%C(yellow)%d%Creset%n%C(bold blue)(%an)%Creset%C(cyan)(%cr)%n%w(0,0,0)%B" --all'

## Safe Operations
alias gap='git add -p'                  # Interactive staging
alias gca='git commit -v --amend'       # Amend commit
alias grh='git reset --hard'            # Hard reset
alias gfp='git push --force-with-lease' # Safer force push

## Git Functions
alias gsync='git add -A && git commit -v && git push'
alias gsmartsync='git fetch --all --prune && git rebase && git push'
alias gclean='git clean -fd && git reset --hard'


# ===== FZF Configuration =====
## Custom fzf configurations
export FZF_DEFAULT_OPTS='
  --reverse
  --height 85%
  --border=rounded
  --scrollbar=" "
  --preview-window bottom:75%
  '
# Use ~~ as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='~~'

## File Search Utilities
# File search with preview
ffile() { 
  local file
  file=$(fd --type f --hidden --no-ignore --exclude={.git,.cache,node_modules} . ~/ 2>/dev/null |
    fzf -m --preview="bat --style=plain --theme=base16 --color=always {}")
  [[ -n "$file" ]] && echo "$file"
}

# Directory search
fdir() {
  local dir
  dir=$(fd --type d --hidden --no-ignore --exclude={.git,.cache,node_modules} . ~/ 2>/dev/null |
    fzf -m --preview='eza --tree --color='always' --icons='always' --sort='type' --git-ignore --level=3 -A {}')
  [[ -n "$dir" ]] && cd "$dir"
}

# Edit selected file
ed() {
  local file
  file=$(ffile)
  [[ -n "$file" ]] && $EDITOR "$file"
}

# Change to file's directory
cdf() {
  local file
  file=$(ffile)
  [[ -n "$file" ]] && cd "$(dirname "$file")"
}

# ===== Terminal Enhancements =====
## Yazi Terminal File Manager
f() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd "$cwd"
  rm -f "$tmp"
}

## Zoxide (Smarter cd)
eval "$(zoxide init --cmd cd zsh)"

## Starship Prompt
eval "$(starship init zsh)"

## The Fuck (Correct previous command)
eval $(thefuck --alias)

## Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)

# ===== System Tweaks =====
## Manual Page Viewer
export MANPAGER="sh -c 'col -bx | bat -l man -p --theme=\"Solarized (dark)\" --color=always'"
export MANROFFOPT="-c"
# theme=\"Solarized (dark)\"
# theme=\"base16\"
