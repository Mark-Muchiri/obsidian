# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

plugins=(
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-history-substring-search
)
source $ZSH/oh-my-zsh.sh
# install dep using `brew`
# brew install zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search fzf

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='nano'
else
  export EDITOR='micro'
fi

# In your .zshrc/.bashrc
export VISUAL="$EDITOR" # Needed by some applications

##############################################################################################

# daily commands
alias c="clear"
alias x="exit"
alias cpu="sudo btop"
alias /="cd ~"
alias rm="trash"
alias root="sudo -i"

# folder navigation
alias l="lsd -hX"
alias la="lsd -hXa"
alias ls="lsd -hX -1"
alias lt="lsd --tree"

# p10K wizard
alias pk="p10k configure"

# Ghostty config
alias gh="code ~/.config/ghostty/config"

# zshrc commands
alias zshrc="code ~/.zshrc"
alias src="exec zsh"

# bat theme
alias bat="bat --theme=base16"

# dnf commands
alias dnf="sudo dnf5"
alias update="sudo dnf5 update"
alias install="sudo dnf5 install -y"
alias remove="sudo dnf5 remove -y"
alias search="sudo dnf5 search"

#=============================================================================================

# ===== Git Aliases =====
# Core commands
alias gcl='git clone'
alias gco='git checkout'
alias gc='git commit -v' # -v shows diff in editor
alias ga='git add'
alias gps='git push'
alias gpl='git pull --rebase'     # Rebase instead of merge
alias gst='git status -sb'        # Short format + branch info
alias gd='git diff --color-words' # Word-level diff

# Improved logging
alias gl='git log --graph --pretty="%C(bold)%h%Creset - %C(yellow)%d%Creset %s %C(cyan)(%cr) %C(bold blue)<%an>%Creset" --all'

# Safety-enhanced commands
alias gap='git add -p'                  # Interactive add
alias gca='git commit -v --amend'       # Amend last commit
alias grh='git reset --hard'            # Explicit reset
alias gfp='git push --force-with-lease' # Safer force push

# Utility functions
gacp() { # Add, commit, push
  git add -A &&
    git commit -v &&
    git push
}

gss() { # Smart sync (fetch + rebase + push)
  git fetch --all --prune &&
    git rebase &&
    git push
}

gclean() { # Deep clean
  git clean -fd &&
    git reset --hard
}

#=============================================================================================

# ===== fzf configuration =====
# Set default fzf options globally (safer than aliasing fzf)
export FZF_DEFAULT_OPTS='--reverse --height 75% --border'

# ===== File Search Utilities =====
# View shortcuts interactively
shortcuts() {
  bat --theme=base16 --style=numbers ~/.zshrc | fzf --preview-window='right:60%' --preview='echo {}'
}

# Search directories with preview
fdir() {
  local dir
  dir=$(fd --type d --hidden --no-ignore --exclude={.git,.cache} . ~/ 2>/dev/null |
    fzf --preview='tree -C -L 2 {}')

  [[ -n "$dir" ]] && cd "$dir"
}

# Search files with preview
ffile() {
  local file
  file=$(fd --type f --hidden --no-ignore --exclude={.git,.cache} . ~/ 2>/dev/null |
    fzf --preview="bat --style=plain --theme=base16 --color=always {}")

  [[ -n "$file" ]] && echo "$file"
}

# Edit selected file
ed() {
  local file
  file=$(ffile) # Reuse our file search function
  [[ -n "$file" ]] && ${EDITOR:-nano} "$file"
}

# Change to directory of selected file
cdf() {
  local file
  file=$(ffile) # Reuse file search function
  [[ -n "$file" ]] && cd "$(dirname "$file")"
}

##############################################################################################

eval "$(mcfly init zsh)"
# install script
# curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly
export MCFLY_PROMPT="❯"
export MCFLY_DISABLE_MENU=TRUE
export MCFLY_FUZZY=5
export MCFLY_RESULTS=35
export MCFLY_INTERFACE_VIEW=TOP
export MCFLY_RESULTS_SORT=LAST_RUN

##############################################################################################

# pnpm
export PNPM_HOME="/home/mark/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

##############################################################################################

# bun completions
[ -s "/home/mark/.bun/_bun" ] && source "/home/mark/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun end

##############################################################################################

# zoxide
eval "$(zoxide init --cmd cd zsh)"

# zoxide install script
# brew install zoxide
# or
# sudo dnf5 install zoxide

##############################################################################################

# starship
eval "$(starship init zsh)"

# install script
# curl -sS https://starship.rs/install.sh | sh

##############################################################################################

# thefuck
eval $(thefuck --alias)

##############################################################################################

# Homebrew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
export PATH="/usr/local/bin:$PATH"

# Homebrew install script
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# brew execution & PATH setup
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
# export PATH="/usr/local/bin:$PATH"

##############################################################################################

# read man pages using `bat`
export MANPAGER="sh -c 'col -bx | bat -l man -p --theme=\"Solarized (dark)\" --color=always'"
export MANROFFOPT="-c"

# or use less (with dynamic colors form your wallpaper)
# This is better cuz it just uses system recources
# export MANPAGER="less -R --use-color -Dd+r -Du+b"

##############################################################################################

# yazi
function f() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d '' cwd <"$tmp"
  [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
  rm -f -- "$tmp"
}

##############################################################################################

# Saving Gnome-extensions setup
# dconf dump /org/gnome/shell/extensions/ > some-file.txt

# Loading the saved Gnome-extensions setup
# dconf load /org/gnome/shell/extensions/ < some-file.txt

##############################################################################################

# Install Unity gnome extension
# sudo dnf install gnome-browser-connector
# gsettings set org.gnome.shell disable-extension-version-validation true

# Then run this command

# wget https://github.com/hardpixel/unite-shell/releases/download/v82/unite-v82.zip
# gnome-extensions install --force unite-v82.zip
##############################################################################################

# export LIBVA_DRIVER_NAME=iHD
# export LIBVA_DRIVER_NAME=i965
