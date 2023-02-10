# Installation and setup
---
## 1st actions

<br>

- Install
- Set up dnf for speed optimizations
- Download required apps and extensions
- Set up theme

## Installing Fedora

<br>

### `For installation process`
<br>
<iframe width="560" height="315" src="https://www.youtube.com/embed/VaIgbTOvAd0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>

[12:16]([https://youtu.be/VaIgbTOvAd0?t=736](https://youtu.be/VaIgbTOvAd0?t=736))
How to auto set the custom partitions

### `For Dnf setup`
<br>
<iframe width="560" height="315" src="https://www.youtube.com/embed/RrRpXs2pkzg" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" allowfullscreen></iframe>
<br>

[0:30](https://youtu.be/RrRpXs2pkzg?t=30)
DNF configuration
[4:30](https://youtu.be/RrRpXs2pkzg?t=270)
Enable RPM fusion
[6:38](https://youtu.be/RrRpXs2pkzg?t=398)
Adding flatpaks
<br>
terminal code for dnf
```bash
sudo nano /etc/dnf/dnf.conf
```

nano code
```bash
# added for speed
fastestmirror=True 
max_parallel_downloads=2 
defaultyes=True 
keepcache=True
```

Then `update the system`

enable RPM fusion terminal code
```bash
sudo dnf install https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
sudo dnf groupupdate core
```

### `For Zsh and OhMyZsh setup`

Install zsh
```bash
sudo dnf install zsh
```
Enter zsh
```bash
zsh
```
Download and install OhMyZsh
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
This might set zsh as the default shell. If not, follow this while in zsh:
```bash
chsh -s $(which zsh)
```

1. Zsh-syntax-highlighting
clone :
```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```
Activate the plugin in `~/.zshrc`:
```bash
plugins=( [plugins...] zsh-syntax-highlighting)
```
2. zsh-autosuggestions
clone :
```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
```
Add plugin
```bash
plugins=( 
    # other plugins...
    zsh-autosuggestions
)
```

3. Powerlevel10K
clone :
```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```
font :
![[Screenshot from 2023-02-08 08-01-30 1.png]]
![[Screenshot from 2023-02-08 08-04-07.png]]
[powerlevel10k github repo](https://github.com/romkatv/powerlevel10k#fonts)

set ohmyzsh theme in ~/.zshrc :
```bash
ZSH_THEME="powerlevel10k/powerlevel10k"
```
configuration wizard :
``` bash
p10k configure
```

4. McFly
Install brew :
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```
Try bin/zsh if it doesn't work. Use :
```bash
which zsh
```
to see the file directory.

Install McFly :
- Install tap :
```bash
brew tap cantino/mcfly
```
- install `mcfly` :
```bash
brew install cantino/mcfly/mcfly
```
- Add at the end of your `~/.zshrc` :
```bash
eval "$(mcfly init zsh)"
```
- Restart shell.
- Customization :
```bash
export MCFLY_FUZZY=5 
export MCFLY_RESULTS=35 
export MCFLY_INTERFACE_VIEW=TOP 
export MCFLY_RESULTS_SORT=LAST_RUN
```

### `Aliases`

```bash
alias dnf="sudo dnf"
alias c="clear"
alias rm="trash"
alias psh="nano ~/.zshrc"
alias pr="exec zsh"
alias f=". ranger"
alias pk="p10k configure"
alias code="code ."
alias subl="subl ."
alias cpu="sudo bpytop"
alias gtk3="cd .config/gtk-3.0 && sudo nano gtk.css"
alias gtk4="cd .config/gtk-4.0 && sudo nano gtk.css"
alias log="git log --graph --pretty='%C(bold) %s' --decorate --all"
alias commit="git add . && git commit"
alias add="git add ."
alias sync="git add . && git commit && git push  && log"
alias start="npm start"
alias diff="git diff"
alias push="git push"
alias l="ls -1"
alias la="ls -a -1"
#alias ls="ls -1"
alias list="npm list"
alias vi="nvim"
alias X="exit"
alias dnfu="sudo dnf update"
alias dnfi="sudo dnf install"
alias dnfr="sudo dnf remove"
alias dnfs="sudo dnf search"
alias mern="cd /home/mark/Documents/coding/mongotest/mern-tutorial"
alias sellme="cd /home/mark/Documents/coding/PROJECT/mac/sellme"
alias sellmern="cd /home/mark/Documents/database/sellmern"
```

[Apps to download](obsidian://open?vault=Notes%20and%20Tasks&file=Linux%20setup%2FApps%20to%20download)
And set up git-credentials

##### `Linked notes`
[[OhMyZsh]]
[[Tweaks and Extnsions]]
[[Apps to download]]
