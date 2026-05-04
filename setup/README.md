# 🧰 Obsidian Dotfiles — Fedora Setup Guide

> **Repo:** `https://github.com/Mark-Muchiri/obsidian.git`  
> **Purpose:** Replicate and maintain your personal Fedora Linux environment from this dotfiles backup.

---

## 📁 What's In This Repo

```
obsidian/
├── micro/
│   └── micro/
│       └── settings.json         # Micro editor config (themes, tab size, etc.)
├── nano/
│   └── nanorc                    # Nano editor config (syntax highlighting, etc.)
├── nvimbak/                      # ⚠️ Neovim backup only — not actively used
│   ├── lua/
│   ├── nvim/
│   │   └── init.lua
│   ├── lazy-lock.json
│   ├── me.lua
│   ├── neovim.yml
│   ├── README.md
│   └── selene.toml
├── setup.sh                      # ← Full automated installer (run this on a fresh machine)
├── sync.sh                       # ← Push local config changes to GitHub
├── restore.sh                    # ← Pull latest configs from GitHub and apply them
├── some-file/
│   └── some-file.txt             # GNOME extensions dconf backup (binary-safe dump)
├── starship/
│   └── starship.toml             # Starship prompt config
├── wezterm/
│   └── wezterm.lua               # Wezterm terminal emulator config
├── yazi/
│   └── yazi.toml                 # Yazi file manager config
├── zsh/
│   └── .zshrc                    # Main ZSH shell config (plugins, aliases, PATH, etc.)
└── zzz/                          # Miscellaneous / browser backups
    ├── Default/                  # Brave browser profile backup
    ├── screenshots/
    ├── config
    ├── foxbookmarks.html          # Firefox bookmarks export
    ├── smoke-test.sh
    ├── vscode-keybindings.json
    └── vscode-settings.json
```

> **`nvimbak/`** is a frozen snapshot of a previous Neovim config. Not actively synced — keep for reference only.

---

## 🚀 Fresh Fedora Setup — Automated

The entire setup is automated. On a fresh Fedora machine, all you need is:

```zsh
# 1. Clone the repo
mkdir -p ~/repo
git clone https://github.com/Mark-Muchiri/obsidian.git ~/repo/obsidian

# 2. Run the installer
bash ~/repo/obsidian/setup.sh
```

The script will ask for your **Git name** and **email** at the start, then handle everything from there — including generating your SSH key, walking you through adding it to GitHub, and cloning the repo over SSH from that point on.

---

## 🔄 Maintaining & Syncing Changes

After the initial setup, two aliases are available in your shell:

### `sync-dots` — Push your changes to GitHub

Run this any time you've edited a config file and want to save it:

```zsh
sync-dots
```

What it does:
- Copies all live config files into the repo
- Dumps the current GNOME extensions state via `dconf`
- Shows a `git diff --stat` of what changed
- Lets you confirm or customise the commit message
- Pushes to GitHub

### `restore-dots` — Pull latest configs from GitHub

Run this on any machine that's already set up, to pull changes made elsewhere:

```zsh
restore-dots
```

What it does:
- Pulls the latest from GitHub
- **Backs up your current live configs** to `~/.config/dotfiles-backup/<timestamp>` before overwriting
- Applies all configs from the repo to the system
- Restores GNOME extensions via `dconf`

You can also run the scripts directly:

```zsh
bash ~/repo/obsidian/sync.sh
bash ~/repo/obsidian/restore.sh
```

---

## 🔑 SSH Key Setup (Git authentication)

The setup script handles this automatically. For reference, here's what it does:

```zsh
# Generate key
ssh-keygen -t ed25519 -C "your@email.com" -f ~/.ssh/id_ed25519

# Add to agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Show public key — copy this to https://github.com/settings/keys
cat ~/.ssh/id_ed25519.pub

# Test connection
ssh -T git@github.com

# Configure git
git config --global user.name  "Your Name"
git config --global user.email "your@email.com"
git config --global core.sshCommand "ssh -i ~/.ssh/id_ed25519"
git config --global init.defaultBranch main
```

---

## ⚠️ Things That May Be Missing or Need Manual Setup

### Not automated by `setup.sh`

| Item | Why | How to install |
|---|---|---|
| **ghostty** | Not in Fedora repos yet | https://ghostty.org/download |
| **pnpm** | Separate installer | `curl -fsSL https://get.pnpm.io/install.sh \| sh -` |
| **bun** | Separate installer | `curl -fsSL https://bun.sh/install \| bash` |
| **Wine** | Optional / large | See Wine section below |
| **Brave profile** | Risk of corrupting running browser | Close Brave first, then `cp -r ~/repo/obsidian/zzz/Default ~/.config/BraveSoftware/Brave-Browser/Default` |
| **VS Code settings** | Not actively synced | Copy manually: `cp ~/repo/obsidian/zzz/vscode-settings.json ~/.config/Code/User/settings.json` |
| **Firefox bookmarks** | Binary import | Firefox → Bookmarks → Manage → Import from `zzz/foxbookmarks.html` |
| **Oh My ZSH** | Handled in setup.sh | Automated |

### Found in `.zshrc` but not in the original setup

| Item | Used for | Notes |
|---|---|---|
| **`fzf`** | `ffile`, `fdir`, `ed`, `cdf` functions | Installed via `dnf5` in `setup.sh` |
| **`nvim`** | Default local editor, `v` alias | Installed via `dnf5` in `setup.sh` |
| **`ghostty`** | `gh` alias points to its config | Not in Fedora repos — manual install |
| **`pnpm`** | In PATH config block | Manual install required |
| **`bun`** | In PATH config block | Manual install required |

---

## 🗺️ Key Config Locations (Quick Reference)

| Config | Repo Path | System Path | Sync? |
|---|---|---|---|
| ZSH | `zsh/.zshrc` | `~/.zshrc` | ✅ Auto |
| Starship | `starship/starship.toml` | `~/.config/starship.toml` | ✅ Auto |
| Wezterm | `wezterm/wezterm.lua` | `~/.config/wezterm/wezterm.lua` | ✅ Auto |
| Yazi | `yazi/yazi.toml` | `~/.config/yazi/yazi.toml` | ✅ Auto |
| Micro | `micro/micro/settings.json` | `~/.config/micro/settings.json` | ✅ Auto |
| Nano | `nano/nanorc` | `/etc/nanorc` (needs sudo) | ✅ Auto |
| GNOME Extensions | `some-file/some-file.txt` | via `dconf` | ✅ Auto |
| Brave profile | `zzz/Default/` | `~/.config/BraveSoftware/Brave-Browser/Default/` | ❌ Manual |
| VS Code settings | `zzz/vscode-settings.json` | `~/.config/Code/User/settings.json` | ❌ Manual |
| VS Code keys | `zzz/vscode-keybindings.json` | `~/.config/Code/User/keybindings.json` | ❌ Manual |
| ghostty | *(not in repo yet)* | `~/.config/ghostty/config` | ❌ Manual |

---

## 🧠 Major Things to Know

- **`some-file/some-file.txt` is a dconf dump** — never edit it manually. Always regenerate with `dconf dump` and restore with `dconf load`. The `sync-dots` and `restore-dots` scripts handle this automatically.
- **Nano is system-wide** (`/etc/nanorc`) — `sudo` is required to overwrite it. Both scripts handle this.
- **Wezterm terminfo** must be installed separately for `config.term = "wezterm"` to function correctly over SSH and in multiplexers. `setup.sh` does this.
- **Homebrew on Linux** lives at `/home/linuxbrew/.linuxbrew`. The `.zshrc` already has the `eval` line — just needs Homebrew installed first before that line works.
- **SSH agent** — the sync and restore scripts automatically load your `~/.ssh/id_ed25519` key so pushes/pulls always work without prompting.
- **`restore-dots` always backs up** your current configs to `~/.config/dotfiles-backup/<timestamp>` before overwriting. If a restore breaks something, you can always roll back from there.
- **`nvimbak/`** — snapshot only. If returning to Neovim, use it as a reference. There's no automated restore path for it.
- **The Unite extension** removes title bars and merges them into the GNOME top bar. If v82 is outdated: https://github.com/hardpixel/unite-shell/releases

---

## 🍷 Wine (Optional)

> Full guide: https://gitlab.winehq.org/wine/wine/-/wikis/Fedora

```zsh
sudo dnf5 config-manager addrepo \
  --from-repofile=https://dl.winehq.org/wine-builds/fedora/42/winehq.repo
sudo dnf install winehq-stable -y
```

---

## 🛠️ Useful One-Liners

```zsh
# Copy directory contents (preserving permissions)
cp -a /source/. /destination/

# Sync with progress (large directories)
rsync -avh --progress /source/ /destination/

# Reload ZSH after config changes
exec zsh

# Check what your SSH key is
cat ~/.ssh/id_ed25519.pub

# Re-test GitHub SSH connection
ssh -T git@github.com
```

---

*Last updated: 2026 · Maintained by Mark Muchiri*
