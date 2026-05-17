<div align="center">

```
   ██████╗ ██████╗ ███████╗██╗██████╗ ██╗ █████╗  ███╗   ██╗
  ██╔═══██╗██╔══██╗██╔════╝██║██╔══██╗██║██╔══██╗ ████╗  ██║
  ██║   ██║██████╔╝███████╗██║██║  ██║██║███████║ ██╔██╗ ██║
  ██║   ██║██╔══██╗╚════██║██║██║  ██║██║██╔══██║ ██║╚██╗██║
  ╚██████╔╝██████╔╝███████║██║██████╔╝██║██║  ██║ ██║ ╚████║
   ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝
```

**Dotfiles — Fedora Workstation**

One script. Fresh Fedora 43+ install → fully configured development environment.

[Quick Start](#quick-start) · [Structure](#structure) ·
[Daily Usage](#daily-usage) · [Setup Guide](docs/setup.md)

![Fedora](https://img.shields.io/badge/Fedora-43%2B-51A2DA?logo=fedora&logoColor=white)
![Shell](https://img.shields.io/badge/shell-bash%20%2F%20zsh-89E051?logo=gnubash&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)

</div>

---

## About this project

This is a personal dotfiles management system built for a **Fedora Workstation
43+** development environment. The goal is to make setting up a new machine — or
recovering a broken one — a single command rather than hours of manual work.

The approach is built on three ideas:

**Symlinks as the source of truth.** Every config file (`~/.zshrc`,
`~/.config/nvim`, etc.) is a symlink pointing into this repo. Editing a config
in your editor is the same as editing it in the repo. There is no copy step, no
sync-back step, and no risk of the repo and the live system diverging.

**Git as the sync mechanism.** Running `sync.sh` exports GNOME settings, stages
everything with `git add -A`, and pushes. Because configs are symlinked,
`git diff` always shows exactly what changed — no diffing between two copies of
a file.

**Staged, resumable automation.** `setup.sh` runs through a sequence of named
stages (shell, packages, editors, WezTerm, Docker/WinApps, restore). Each stage
is marked complete in a local state file. If setup is interrupted —
intentionally, for a shell restart, or due to an error — re-running with
`--resume` picks up exactly where it left off without repeating work.

This project is specific to one person's machine and tooling choices. It is
published publicly in case the structure or approach is useful to others as a
reference.

---

## What's included

- **Shell** — zsh + Oh My Zsh, autosuggestions, syntax highlighting, history
  search
- **Prompt** — Starship with custom config
- **Font** — JetBrainsMono Nerd Font (user-scoped, no root required)
- **Terminal** — WezTerm via COPR with terminfo
- **Editors** — Neovim (full config), micro (with LSP plugin), nano
- **CLI tools** — eza, bat, fd, zoxide, thefuck, btop, yazi, fastfetch, bun
- **GUI apps** — VS Code, EasyEffects, GNOME Extension Manager, Flatseal, Smile
- **Desktop** — Unite shell extension, GNOME extension settings restored via
  dconf
- **Package managers** — dnf (primary), Homebrew, Flatpak/Flathub
- **Windows apps** — Docker-based WinApps (FreeRDP, winapps-org/winapps)
- **Sync** — git-only, no file copying; symlinks make every config edit instant

---

## Structure

```
obsidian/
├── configs/          ← dotfiles; source of truth; never copied during sync
│   ├── btop/
│   ├── gnome-extensions/
│   ├── micro/
│   ├── nano/
│   ├── nvim/         ← full Neovim config (symlinked as a directory)
│   ├── starship/
│   ├── wezterm/
│   ├── yazi/
│   └── zsh/
├── docs/
│   └── setup.md      ← step-by-step manual
├── extras/
│   └── rename/       ← playlist helper scripts
├── lib/              ← sourced modules; never run directly
│   ├── utils.sh      ← colours, logging, spinner, safe_symlink
│   ├── preflight.sh  ← OS, root, internet, git/SSH checks
│   ├── shell.sh      ← zsh, Oh My Zsh, plugins, font, starship
│   ├── pkgmgr.sh     ← Homebrew + Flatpak/Flathub setup
│   ├── packages.sh   ← dnf / brew / flatpak installs
│   ├── editors.sh    ← prettier, micro LSP, Unite extension, dconf
│   ├── wezterm.sh    ← COPR, terminfo, config symlink
│   └── docker.sh     ← Docker CE + WinApps (optional)
├── scripts/          ← user-facing entry points
│   ├── setup.sh      ← orchestrator with stage resumption
│   ├── restore.sh    ← symlink manager (link / --check / --unlink)
│   └── sync.sh       ← git-only sync (dconf dump included)
├── state/            ← gitignored; setup progress file
├── zzz/              ← archive; do not modify
├── packages.conf     ← INI package list (dnf / homebrew / flatpak)
└── README.md
```

---

## Prerequisites

- Fedora Workstation 43+
- A regular user account (not root)
- Internet connection
- A GitHub account with an SSH key (setup.sh will generate one if needed)

---

## Quick Start

### Fresh machine

```bash
# 1. Clone the repo
git clone git@github.com:Mark-Muchiri/obsidian.git ~/repo/obsidian

# 2. Run setup
cd ~/repo/obsidian
bash scripts/setup.sh
```

Setup will walk you through every stage. If it asks you to restart your shell,
do so and run:

```bash
bash scripts/setup.sh --resume
```

### Existing machine (restore configs only)

```bash
git clone git@github.com:Mark-Muchiri/obsidian.git ~/repo/obsidian
bash ~/repo/obsidian/scripts/restore.sh
```

---

## Daily Usage

### Sync changes to GitHub

```bash
bash scripts/sync.sh        # or: sync-dots
```

Automatically dumps GNOME extension settings, stages all changes, opens your
editor for a commit message, and pushes.

### Verify all symlinks are intact

```bash
bash scripts/restore.sh --check
```

### Add a new config file

1. Move the file into the appropriate `configs/` subdirectory
2. Add one line to the `CONFIG_MAP` in `scripts/restore.sh`
3. Run `bash scripts/restore.sh` to create the symlink
4. Run `bash scripts/sync.sh` to commit

See [docs/setup.md](docs/setup.md) for the full walkthrough.

---

## Setup flags

| Command                            | Effect                                                  |
| ---------------------------------- | ------------------------------------------------------- |
| `bash scripts/setup.sh`            | Fresh install, runs all stages                          |
| `bash scripts/setup.sh --resume`   | Skip completed stages, continue from last               |
| `bash scripts/setup.sh --reset`    | Clear state, re-run all stages (does not undo installs) |
| `bash scripts/restore.sh`          | Create all config symlinks                              |
| `bash scripts/restore.sh --check`  | Verify all symlinks, no changes made                    |
| `bash scripts/restore.sh --unlink` | Remove symlinks, restore backups                        |
| `bash scripts/sync.sh`             | Dump dconf + commit + push                              |

---

## How sync works

All configs in `configs/` are **symlinked** into their system locations — not
copied. Editing `~/.zshrc` edits `configs/zsh/.zshrc` directly. `sync.sh` runs
`git add -A`, so every config change is captured automatically. No manual copy
step is ever needed.

---

## ShellCheck

All scripts and lib modules are ShellCheck-clean (`shellcheck -x -s bash`). Run
before every commit:

```bash
for f in lib/*.sh scripts/*.sh; do shellcheck -x -s bash "$f"; done
```

---

## For contributors and maintainers

If you are working on this project — fixing a bug, adding a new config, or
extending the automation — read [`handout.md`](handout.md) before making
changes.

`handout.md` is a complete technical reference that documents every design
decision, the full contents of every script, the rationale behind each
implementation choice, every bug found and fixed during development, and the
current known gaps. It is written to give a technical reader (or an AI
assistant) full context to continue the project without any prior knowledge of
its history.
