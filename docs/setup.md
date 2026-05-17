# Setup Guide

Step-by-step reference for every script in this repo. For the overview and
quick-start, see [README.md](../README.md).

---

## Contents

1. [Fresh install — `setup.sh`](#1-fresh-install--setupsh)
2. [Restore configs — `restore.sh`](#2-restore-configs--restoresh)
3. [Sync changes — `sync.sh`](#3-sync-changes--syncsh)
4. [Add a new config](#4-add-a-new-config)
5. [Troubleshooting](#5-troubleshooting)

---

## 1. Fresh install — `setup.sh`

Runs every setup stage in order. Safe to re-run; every step is idempotent.

```bash
bash scripts/setup.sh
```

### Stages

| Stage       | What it does                                                               |
| ----------- | -------------------------------------------------------------------------- |
| `preflight` | Checks Fedora 43+, non-root user, internet, git, SSH key, GitHub auth      |
| `shell`     | Installs zsh, Oh My Zsh, plugins, JetBrainsMono Nerd Font, Starship        |
| `pkgmgr`    | Installs Homebrew (Linux), configures Flatpak + Flathub                    |
| `packages`  | Installs all packages from `packages.conf` via dnf / brew / flatpak        |
| `editors`   | Installs prettier, micro LSP plugin, Unite GNOME extension, restores dconf |
| `wezterm`   | Adds WezTerm COPR, installs WezTerm, installs terminfo                     |
| `docker`    | Installs Docker CE, sets up WinApps (optional — you can skip)              |
| `restore`   | Creates all config symlinks via `restore.sh`                               |

### Shell restart gate

After the `shell` stage, your default shell is changed to zsh. The script exits
and prints:

```
1. Close this terminal completely
2. Open a new terminal
3. Run: bash scripts/setup.sh --resume
```

This is expected — the new shell must be active before subsequent stages run.

### Flags

```bash
bash scripts/setup.sh --resume   # continue from last completed stage
bash scripts/setup.sh --reset    # clear progress, re-run all stages
```

`--reset` does **not** undo any installations. It only clears
`state/.setup_state`.

### Adding packages

Edit `packages.conf` before running setup, or add packages at any time and
re-run:

```bash
bash scripts/setup.sh --resume   # packages stage installs only what's missing
```

```ini
[dnf]
your-package

[homebrew]
your-brew-package

[flatpak]
com.example.App
```

---

## 2. Restore configs — `restore.sh`

Creates symlinks from the repo into their system locations. Use this on a
machine where the repo is already cloned but configs are not yet linked.

```bash
bash scripts/restore.sh            # create all symlinks
bash scripts/restore.sh --check    # verify symlinks, no changes
bash scripts/restore.sh --unlink   # remove symlinks, restore backups
```

### How symlinks work

Every entry in `CONFIG_MAP` inside `restore.sh` maps a repo path to a system
path:

```bash
["configs/zsh/.zshrc"]="${HOME}/.zshrc"
["configs/nvim"]="${HOME}/.config/nvim"
```

`safe_symlink` handles everything automatically:

- Already correctly linked → skip
- Destination exists but is not a symlink → back it up with a timestamp, then
  link
- Parent directory missing → create it

### Restoring backed-up files

If a file was backed up during linking (e.g. `~/.zshrc.bak.20260517T143000`),
run:

```bash
bash scripts/restore.sh --unlink
```

This removes all managed symlinks and moves the most recent backup back into
place.

---

## 3. Sync changes — `sync.sh`

Commits and pushes all config changes to GitHub.

```bash
bash scripts/sync.sh    # or: sync-dots
```

### What it does

1. Dumps current GNOME extension settings →
   `configs/gnome-extensions/gnome-extensions.txt`
2. Runs `git add -A`
3. Opens your editor for a commit message (`git commit -v` shows the diff
   inline)
4. Pushes to `origin`
5. Prints the full commit graph

### Why no manual copy step is needed

`~/.zshrc` is a symlink pointing to `configs/zsh/.zshrc`. Editing `~/.zshrc`
edits the repo file directly. `git add -A` picks it up immediately.

The only exception is GNOME extension settings, which live in a binary dconf
database — `sync.sh` exports them automatically before staging.

---

## 4. Add a new config

### Step 1 — Move the file into the repo

```bash
mkdir -p ~/repo/obsidian/configs/myapp
mv ~/.config/myapp/myapp.conf ~/repo/obsidian/configs/myapp/myapp.conf
```

### Step 2 — Register it in `restore.sh`

Open `scripts/restore.sh` and add one line to `CONFIG_MAP`:

```bash
declare -A CONFIG_MAP=(
  # ... existing entries ...
  ["configs/myapp/myapp.conf"]="${HOME}/.config/myapp/myapp.conf"
)
```

### Step 3 — Create the symlink and commit

```bash
bash scripts/restore.sh
bash scripts/sync.sh
```

From now on, editing `~/.config/myapp/myapp.conf` edits the repo file directly.

---

## 5. Troubleshooting

### Font not detected after setup

```bash
fc-cache -f
exec zsh
```

Check that the font files exist:

```bash
ls ~/.local/share/fonts/JetBrainsMono/*.ttf | head -3
```

### A stage needs to re-run without resetting everything

Delete only that stage's line from the state file:

```bash
micro ~/repo/obsidian/state/.setup_state
bash scripts/setup.sh --resume
```

### Symlink check reports problems

```bash
bash scripts/restore.sh --check
```

| Status           | Cause                                      | Fix                                        |
| ---------------- | ------------------------------------------ | ------------------------------------------ |
| `MISSING source` | File removed from `configs/`               | `git checkout` the missing file            |
| `BROKEN LINK`    | Target path no longer exists               | Run `restore.sh`                           |
| `UNMANAGED FILE` | Real file exists where a symlink should be | Run `restore.sh` — backs up the file first |
| `NOT LINKED`     | Symlink was never created                  | Run `restore.sh`                           |

### WinApps RDP connection fails

```bash
# Clear stale certificate
rm ~/.config/freerdp/server/127.0.0.1_3389.pem

# Confirm Windows container is running
docker compose --file ~/.config/winapps/compose.yaml ps

# Start if stopped
docker compose --file ~/.config/winapps/compose.yaml start

# Test RDP manually
xfreerdp /u:"MyWindowsUser" /p:"MyWindowsPassword" /v:127.0.0.1 /cert:tofu
```

### dnf transaction fails with "already installed"

The `is_installed_dnf` check uses `rpm -q --whatprovides`, resolving virtual
provides. If a package still causes a conflict, find its actual installed name:

```bash
rpm -q --whatprovides <package-name>
```

Remove or comment it out in `packages.conf` if it is provided under a different
name.
