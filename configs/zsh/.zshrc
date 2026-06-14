# ===== Path Configuration =====
# Homebrew (must come first — other tools depend on it)
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="/usr/local/bin:${HOME}/.local/bin:$PATH"

# PNPM
export PNPM_HOME="$HOME/.local/share/pnpm"
[[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ===== Plugin Management (Antidote) =====
source /home/linuxbrew/.linuxbrew/opt/antidote/share/antidote/antidote.zsh
antidote load

# ===== Editor Configuration =====
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='micro' # Remote editor
else
  export EDITOR='nvim'  # Local editor
fi
export VISUAL="$EDITOR"

# ===== Terminal Enhancements =====
eval "$(starship init zsh)"          # Starship prompt
eval "$(zoxide init --cmd cd zsh)"   # Smarter cd
source <(fzf --zsh)                  # FZF key bindings and completions

# ===== Shell Options =====
setopt CORRECT

# ===== History =====
HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

setopt HIST_IGNORE_DUPS      # Don't save consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS  # Remove older duplicate entries from history
setopt HIST_IGNORE_SPACE     # Don't save commands prefixed with a space
setopt HIST_SAVE_NO_DUPS     # Don't write duplicates to the history file
setopt HIST_REDUCE_BLANKS    # Strip superfluous whitespace
setopt EXTENDED_HISTORY      # Save timestamp and duration with each entry
setopt INC_APPEND_HISTORY    # Write to HISTFILE immediately, not on shell exit
setopt SHARE_HISTORY         # Share history across all active sessions

# ===== FZF Configuration =====
export FZF_DEFAULT_OPTS='
  --reverse
  --height 85%
  --border=rounded
  --scrollbar=" "
  --preview-window bottom:75%
  '
export FZF_COMPLETION_TRIGGER='~~'

# ===== Aliases =====
## System Utilities
alias c="clear"
alias x="exit"
alias cpu="sudo btop"
alias /="cd ~"
alias v="nvim"
alias m="micro"
alias rm="trash"     # Safer alternative to rm
alias root="sudo -i" # Get root shell
alias fastfetch="fastfetch -c examples/6.jsonc"
alias ..="cd .."

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

## Bat
alias bat="bat --theme=base16"
alias b="bat"

# ===== Git =====
## Core Commands
alias gcl='git clone'
alias gco='git checkout'
alias gc='git commit -v'          # Commit with diff preview
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

## Workflows
alias gsync='git add -A && git commit -v && git push'
alias gsmartsync='git fetch --all --prune && git rebase && git push'
alias gclean='git clean -fd && git reset --hard'
alias sync-config="cd ~/repo/obsidian/ && gsync && gl && cd ~"

# ===== Functions =====
## FZF Utilities
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

## Yazi Terminal File Manager
f() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && cd "$cwd"
  rm -f "$tmp"
}

# ===== System Tweaks =====
## Manual Page Viewer
export MANPAGER="sh -c 'col -bx | bat -l man -p --theme=\"Solarized (dark)\" --color=always'"
export MANROFFOPT="-c"

## Environment
export TERM=xterm-256color
export LIBVA_DRIVER_NAME=i965

# ── Obsidian dotfiles ─────────────────────────────────────────────────────────
# Resolve the repo root dynamically from the .zshrc symlink target so these
# aliases work regardless of username or clone location.
_obsidian_dir="$(cd "$(dirname "$(readlink -f "${HOME}/.zshrc")")/../.." && pwd)"

alias sync-dots='bash "${_obsidian_dir}/scripts/sync.sh"'
alias restore-dots='bash "${_obsidian_dir}/scripts/restore.sh"'
