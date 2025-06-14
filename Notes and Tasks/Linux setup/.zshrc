# Enable Powerlevel10k instant prompt. Should stay .close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.

#if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
#fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# p10k install script
# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
 zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency  1

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
sudo
zsh-autosuggestions
zsh-syntax-highlighting
zsh-history-substring-search
)
source $ZSH/oh-my-zsh.sh
# install script using `brew`
# brew install zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search fzf

# Homebrew install script
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
 if [[ -n $SSH_CONNECTION ]]; then
   export EDITOR='nano'
# else
#   export EDITOR='nano'
 fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#

##############################################################################################

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# daily commands
alias c="clear"
alias x="exit"
alias cpu="sudo btop"
alias /="cd ~"
alias rm="trash"
alias root="sudo -i"

# folder navigation
alias f=". ranger"
alias l="lsd -hX"
alias la="lsd -hXa"
alias ls="lsd -hX -1"
alias lt="lsd --tree"

# p10K wizard
alias pk="p10k configure"

# Ghostty config
alias gh="nano ~/.config/ghostty/config"

# zshrc commands
alias zshrc="nano ~/.zshrc"
alias src="exec zsh"

# bat theme
alias bat="bat --theme=base16"

# fzf controls
alias shortcuts="bat --theme=base16 ~/.zshrc | fzf --reverse --height 75%"
alias fzf="fzf --reverse --height 75%"
alias folder="cd ~ && cd \$(find ~/ -type d -print | fzf --reverse --height 75% --preview='tree -C {}')"
alias files="find ~/ -type f -print | fzf --reverse --height 75% --preview='bat --theme=base16 --color=always {}'"

# dnf commands
alias dnf="sudo dnf5"
alias update="sudo dnf5 update"
alias install="sudo dnf5 install -y"
alias remove="sudo dnf5 remove -y"
alias search="sudo dnf5 search"

# Git command alias
alias clone="git clone"
alias log="git log --graph --pretty='%C(bold) %s' --decorate --all"
alias commit="git add . && git commit"
alias add="git add ."
alias sync="git add . && git commit && git push"
alias diff="git diff"
alias push="git push"

##############################################################################################

eval "$(mcfly init zsh)"
# install script
# curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sudo sh -s -- --git cantino/mcfly
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

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

eval $(thefuck --alias)
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh
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

##############################################################################################
