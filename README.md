# Core utilities

```zsh
sudo dnf group install development-tools -y
```

```zsh
dnf copr enable atim/starship
dnf install starship
```

#### GCM (Git Credential Manager)

Link: https://github.com/git-ecosystem/git-credential-manager/releases/

```zsh
sudo tar -xvf ~/Downloads/*.tar.gz -C /usr/local/bin
git-credential-manager configure
```

```zsh
sudo dnf5 install procps-ng curl file bat fd-find tree trash-cli btop node dconf-editor gnome-tweaks
sudo npm install --global prettier
flatpak install flathub com.mattjakeman.ExtensionManager -y
flatpak install it.mijorus.smile -y
```

## zsh plugins

```zsh
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions;
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting;
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting;
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search;
```

### HOMEBREW INSTALL INSTRUCTIONS

> website link for proper instructions 🖙 https://docs.brew.sh/Homebrew-on-Linux

1. install script 🖟

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. add to path 🖟

```zsh
test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zshrc
```

3. test brew

installing your first package will also install a recent version of glibc and
gcc

```zsh
brew install hello gcc
```

> Once you're done Install (gcc & glibc) 1st, then 🖟

```zsh
brew install micro eza wget zoxide thefuck yazi fastfetch nerdfetch
```

```zsh
brew install --cask font-jetbrains-mono-nerd-font
```

```zsh
brew install --cask font-victor-mono-nerd-font
```

### Micro Prettier installation

should work automatically on save

```zsh
sudo npm install --global prettier
micro --plugin install prettier
micro -plugin install lsp
```

### Unite extension install

```zsh
sudo dnf5 install gnome-browser-connector xprop
sudo gsettings set org.gnome.shell disable-extension-version-validation true
wget https://github.com/hardpixel/unite-shell/releases/download/v82/unite-v82.zip
gnome-extensions install --force unite-v82.zip
```

### Gnome Extensions Backup/Restore

```zsh
dconf dump /org/gnome/shell/extensions/ > ~/repo/obsidian/some-file/some-file.txt
dconf load /org/gnome/shell/extensions/ < ~/repo/obsidian/some-file/some-file.txt
```

### Install Wezterm

```zsh
dnf copr enable wezfurlong/wezterm-nightly
dnf install wezterm
```

for this function to work `config.term = "wezterm"`, you need this 🖟.

> Ref: wezterm.lua

```zsh
tempfile=$(mktemp) \
  && curl -o $tempfile https://raw.githubusercontent.com/wezterm/wezterm/main/termwiz/data/wezterm.terminfo \
  && tic -x -o ~/.terminfo $tempfile \
  && rm $tempfile
```

### loading the backup files

```zsh
cp ~/repo/obsidian/micro/settings.json ~/.config/micro/settings.json
sudo cp ~/repo/obsidian/nano/nanorc /etc/nanorc
dconf load /org/gnome/shell/extensions/ < ~/repo/obsidian/some-file/some-file.txt
cp ~/repo/obsidian/starship/starship.toml ~/.config/starship.toml
cp ~/repo/obsidian/wezterm/wezterm.lua ~/.config/wezterm/wezterm.lua
cp ~/repo/obsidian/yazi/yazi.toml ~/.config/yazi/yazi.toml
cp ~/repo/obsidian/zsh/.zshrc ~/.zshrc
```

### Install Wine

Link: https://gitlab.winehq.org/wine/wine/-/wikis/Fedora

```zsh
dnf5 config-manager addrepo --from-repofile=https://dl.winehq.org/wine-builds/fedora/42/winehq.repo
```

```zsh
dnf install winehq-stable
```

### Brave backup

```zsh
cp -r ~/repo/obsidian/zzz/Default ~/.config/BraveSoftware/Brave-Browser/Default
```

#### Extra stuff

Copy folder content

```zsh
cp -a /source/. /destination/
```

Initial full copy

```zsh
rsync -avh --progress /source/ /destination/
```
