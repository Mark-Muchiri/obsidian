# Core utilities
```zsh
sudo dnf group install development-tools
sudo dnf5 install procps-ng curl file
sudo dnf5 install bat fd-find tree trash-cli btop node
sudo npm install --global prettier
```

## zsh plugins
```zsh
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions;
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting;
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting;
```

## HOMEBREW INSTALL INSTRUCTIONS
## website link for proper instructions
🖙  https://docs.brew.sh/Homebrew-on-Linux
# 1. install script 🖟 
🖙  ```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
# 2. add to path 🖟 
```zsh
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zshrc
```
# 3. test brew
# installing your first package will also install a recent version of glibc and gcc
```zsh
brew install hello
```
# Once you're done
# Install (gcc & glibc) 1st, then 🖟 
```zsh
brew install micro eza wget zoxide thefuck starship yazi fastfetch nerdfetch 
brew install --cask font-jetbrains-mono-nerd-font
alias --save ls eza
```

## Unite extension
```zsh
sudo dnf5 install gnome-browser-connector xprop
sudo gsettings set org.gnome.shell disable-extension-version-validation true
wget https://github.com/hardpixel/unite-shell/releases/download/v82/unite-v82.zip
gnome-extensions install --force unite-v82.zip
```

## Gnome Extension Backup/Restore
```zsh
dump /org/gnome/shell/extensions/ > ~/repo/obsidian/some-file/some-file.txt
dconf load /org/gnome/shell/extensions/ < ~/repo/obsidian/some-file/some-file.txt
```

## Install Wezterm
```zsh
dnf copr enable wezfurlong/wezterm-nightly
dnf install wezterm
```

## loading the backup files
```zsh
cp ~/repo/obsidian/micro/settings.json ~/.config/micro/settings.json
sudo cp ~/repo/obsidian/nano/nanorc /etc/nanorc
dconf load /org/gnome/shell/extensions/ < ~/repo/obsidian/some-file/some-file.txt
cp ~/repo/obsidian/starship/starship.toml ~/.config/starship.toml
cp ~/repo/obsidian/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
cp ~/repo/obsidian/yazi/yazi.toml ~/.config/yazi/yazi.toml
cp ~/repo/obsidian/zsh/.zshrc ~/.zshrc
```
