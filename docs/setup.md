# 🚀 Setup Guide

> [!NOTE]
> **Step-by-step reference for every script in this repo.**
> For the overview and quick-start, please see the main [README.md](../README.md).

<div align="center">
  <!-- To add your animation, replace the src link with a path to your own .gif or .svg terminal recording! -->
  <img src="../media/setup-banner.webp" alt="Terminal Setup Animation" width="600" style="border-radius: 8px;"/>
  <br/>
  <sup><em>Running the automated setup script.</em></sup>
</div>

---

## 📑 Contents

1. [🚀 Fresh install — `setup.sh`](#1--fresh-install--setupsh)
2. [🔗 Restore configs — `restore.sh`](#2--restore-configs--restoresh)
3. [🔄 Sync changes — `sync.sh`](#3--sync-changes--syncsh)
4. [➕ Add a new config](#4--add-a-new-config)
5. [🛠️ Troubleshooting](#5--troubleshooting)

---

## 1. 🚀 Fresh install — `setup.sh`

Runs every setup stage in order. It is completely safe to re-run; every step is designed to be idempotent.

```bash
bash scripts/setup.sh
```

### 🗂️ Stages

| Stage           | What it does                                                               |
| :-------------- | :------------------------------------------------------------------------- |
| **`preflight`** | Checks Fedora 43+, non-root user, internet, git, SSH key, GitHub auth      |
| **`shell`**     | Installs zsh, Oh My Zsh, plugins, JetBrainsMono Nerd Font, Starship        |
| **`pkgmgr`**    | Installs Homebrew (Linux), configures Flatpak + Flathub                    |
| **`packages`**  | Installs all packages from `packages.conf` via dnf / brew / flatpak        |
| **`editors`**   | Installs prettier, micro LSP plugin, Unite GNOME extension, restores dconf |
| **`wezterm`**   | Adds WezTerm COPR, installs WezTerm, installs terminfo                     |
| **`docker`**    | Installs Docker CE, sets up WinApps (optional — you can skip)              |
| **`restore`**   | Creates all config symlinks via `restore.sh`                               |

> [!WARNING]
>
> ### 🛑 Shell restart gate
>
> After the `shell` stage, your default shell is changed to `zsh`. The script will purposefully exit and print:
>
> 1. Close this terminal completely
> 2. Open a new terminal
> 3. Run: `bash scripts/setup.sh --resume`
>
> **This is expected** — the new shell must be actively running before the subsequent stages can continue.

### ⚙️ Flags

```bash
bash scripts/setup.sh --resume    # continue from last completed stage
bash scripts/setup.sh --reset     # clear progress, re-run all stages
```

> [!IMPORTANT]
> `--reset` does **not** undo any installations. It only clears the tracker at `state/.setup_state` so the scripts run from the beginning.

### 📦 Adding packages

Edit `packages.conf` before running setup, or add packages to it at any time and simply re-run the setup:

```bash
bash scripts/setup.sh --resume    # packages stage installs only what's missing
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

## 2. 🔗 Restore configs — `restore.sh`

Creates symlinks from the repo into their required system locations. Use this on a new machine where the repo is already cloned but configs are not yet linked.

```bash
bash scripts/restore.sh            # create all symlinks
bash scripts/restore.sh --check    # verify symlinks, no changes made
bash scripts/restore.sh --unlink   # remove symlinks, restore backups
```

<details>
<summary><b>🧠 How symlinks work (Click to expand)</b></summary>
<br>
Every entry in <code>CONFIG_MAP</code> inside <code>restore.sh</code> maps a repo path to a system path:

```bash
["configs/zsh/.zshrc"]="${HOME}/.zshrc"
["configs/nvim"]="${HOME}/.config/nvim"
```

`safe_symlink` handles everything automatically:

- Already correctly linked → **skip**
- Destination exists but is not a symlink → **back it up with a timestamp, then link**
- Parent directory missing → **create it automatically**
</details>

> [!TIP]
> **Restoring backed-up files**
> If a file was backed up during linking (e.g., `~/.zshrc.bak.20260517T143000`), run:
>
> ```bash
> bash scripts/restore.sh --unlink
>
> ```

````
> This immediately removes all managed symlinks and moves the most recent backup back into its original place.

---

## 3. 🔄 Sync changes — `sync.sh`

Quickly commits and pushes all config changes to GitHub.

```bash
bash scripts/sync.sh    # or: sync-dots
````

### What it does:

1. Dumps current GNOME extension settings to `configs/gnome-extensions/gnome-extensions.txt`
2. Runs `git add -A`
3. Opens your editor for a commit message (`git commit -v` shows the diff inline)
4. Pushes to `origin`
5. Prints the full commit graph

<details>
<summary><b>💡 Why no manual copy step is needed</b></summary>
<br>
Because <code>~/.zshrc</code> is a symlink pointing to <code>configs/zsh/.zshrc</code>, editing <code>~/.zshrc</code> edits the repo file directly. <code>git add -A</code> picks it up immediately.

_The only exception is GNOME extension settings, which live in a binary dconf database. `sync.sh` handles exporting them automatically before staging._

</details>

---

## 4. ➕ Add a new config

Want to start tracking a new configuration file? Follow these three steps:

**Step 1 — Move the file into the repo**

```bash
mkdir -p ~/repo/obsidian/configs/myapp
mv ~/.config/myapp/myapp.conf ~/repo/obsidian/configs/myapp/myapp.conf
```

**Step 2 — Register it in `restore.sh`**
Open `scripts/restore.sh` and add one line to the `CONFIG_MAP`:

```bash
declare -A CONFIG_MAP=(
  # ... existing entries ...
  ["configs/myapp/myapp.conf"]="${HOME}/.config/myapp/myapp.conf"
)
```

**Step 3 — Create the symlink and commit**

```bash
bash scripts/restore.sh
bash scripts/sync.sh
```

_From now on, editing `~/.config/myapp/myapp.conf` edits the repo file directly!_

---

## 5. 🛠️ Troubleshooting

_Click on an issue below to view its solution._

<details>
<summary><b>🔠 Font not detected after setup</b></summary>
<br>

First, refresh your font cache and restart zsh:

```bash
fc-cache -f
exec zsh
```

If it still fails, check that the font files actually exist:

```bash
ls ~/.local/share/fonts/JetBrainsMono/*.ttf | head -3
```

</details>

<details>
<summary><b>⏪ A stage needs to re-run without resetting everything</b></summary>
<br>

You can trick the script by deleting only that stage's specific line from the state file:

```bash
micro ~/repo/obsidian/state/.setup_state
bash scripts/setup.sh --resume
```

</details>

<details>
<summary><b>🔗 Symlink check reports problems</b></summary>
<br>

Run the check command:

```bash
bash scripts/restore.sh --check
```

| Status              | Cause                                      | Fix                                          |
| :------------------ | :----------------------------------------- | :------------------------------------------- |
| 🔴 `MISSING source` | File removed from `configs/`               | `git checkout` the missing file              |
| 🔴 `BROKEN LINK`    | Target path no longer exists               | Run `restore.sh`                             |
| 🟡 `UNMANAGED FILE` | Real file exists where a symlink should be | Run `restore.sh` _(backs up the file first)_ |
| ⚪ `NOT LINKED`     | Symlink was never created                  | Run `restore.sh`                             |

</details>

<details>
<summary><b>🖥️ WinApps RDP connection fails</b></summary>
<br>

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

</details>

<details>
<summary><b>📦 dnf transaction fails with "already installed"</b></summary>
<br>

The `is_installed_dnf` check uses `rpm -q --whatprovides`, resolving virtual provides. If a package still causes a conflict, find its actual installed name:

```bash
rpm -q --whatprovides <package-name>
```

Once you find the exact name, remove or comment it out in `packages.conf` if it is provided under a different name.

</details>
