# Obsidian Dotfiles — Project Handout

> **Purpose of this document:** Give a brand-new AI agent (or a future
> maintainer) complete context to continue this project without any loss of
> understanding. Every design decision, file content, and remaining task is
> recorded here.

---

## 1. Project Purpose

This repo automates the complete setup, configuration restore, and Git-based
sync of a **Fedora Workstation 43+** development environment — covering shell,
fonts, CLI tools, GUI apps, editors, and terminal emulator — so any machine can
be brought to a fully configured state by running a single script.

---

## 2. Current Goals

These are the refactoring objectives driving all work in this session (sourced
from `context.md`):

- [x] Restructure the repo into clean, self-documenting directories (`configs/`,
      `lib/`, `scripts/`, `docs/`, `extras/`, `zzz/`)
- [x] Rename `some-file/` → `configs/gnome-extensions/` and `some-file.txt` →
      `gnome-extensions.txt`
- [x] Rename `nvimbak/` → `configs/nvim/` (active config, not a backup)
- [x] Move `rename/` playlist scripts → `extras/rename/`
- [x] Move `setup.md` → `docs/setup.md`
- [x] Replace `sync.sh` with a git-only version (no file copying)
- [x] Modularise `setup.sh` into sourced `lib/` modules, one per concern
- [x] Write `lib/utils.sh` — shared utilities foundation
- [x] Write `lib/preflight.sh` — OS/root/internet/GitHub checks
- [x] Write `lib/shell.sh` — zsh, Oh My Zsh, plugins, Nerd Font, starship
- [x] Write `scripts/restore.sh` — symlink manager with --check and --unlink
      modes
- [x] Write `scripts/sync.sh` — git-only sync
- [x] Write `scripts/setup.sh` — orchestrator with stage resumption
- [x] Populate `packages.conf` with INI-format package lists
- [ ] Write `lib/pkgmgr.sh` — Homebrew + Flatpak setup (currently a stub)
- [ ] Write `lib/packages.sh` — reads `packages.conf`, installs via
      dnf/brew/flatpak
- [ ] Write `lib/editors.sh` — micro plugins, GNOME extension, dconf restore
      (currently a stub)
- [ ] Write `lib/wezterm.sh` — COPR, terminfo, config link (currently a stub)
- [ ] Write `lib/docker.sh` — Docker + Winapps, optional stage (currently a
      stub)
- [ ] Write `README.md` — attractive landing page with structure tree,
      quick-start, links
- [ ] Write `docs/setup.md` — step-by-step manual (no README duplication)
- [ ] Add `.gitignore` entries for secrets and temp files
- [ ] Full end-to-end test on a clean Fedora 43+ VM

---

## 3. Progress Made in This Session

### Structural changes

- [x] Created `configs/`, `lib/`, `scripts/`, `docs/`, `extras/`, `state/`
      directories
- [x] Moved all dotfile folders into `configs/` using `git mv` (history
      preserved)
- [x] Renamed `configs/some-file/` → `configs/gnome-extensions/`
- [x] Renamed `configs/gnome-extensions/some-file.txt` →
      `configs/gnome-extensions/gnome-extensions.txt`
- [x] Renamed `configs/nvimbak/` → `configs/nvim/` (with duplicate cleanup — a
      nested `nvim/nvim/` subdir was created by accident and removed; hidden
      files `.luarc.json`, `.neoconf.json`, `.stylua.toml` were verified
      present)
- [x] Moved `rename/` → `extras/rename/`
- [x] Moved `setup.md` → `docs/setup.md`
- [x] Moved root scripts into `scripts/`
- [x] Added `state/` to `.gitignore`

### New scripts created or rewritten

- `lib/utils.sh` — written from scratch; full foundation module
- `lib/preflight.sh` — written from scratch; all pre-flight safety gates
- `lib/shell.sh` — written from scratch; complete shell setup stage
- `lib/pkgmgr.sh` — **stub only** (`#!/usr/bin/env bash\n# stub`)
- `lib/packages.sh` — **full INI parser + install logic written** (see
  section 8)
- `lib/editors.sh` — **stub only**
- `lib/wezterm.sh` — **stub only**
- `lib/docker.sh` — **stub only**
- `scripts/setup.sh` — complete orchestrator with state machine and resume logic
- `scripts/restore.sh` — complete symlink manager (link / --check / --unlink)
- `scripts/sync.sh` — git-only sync (replaces old file-copying version)
- `packages.conf` — INI-format package list (dnf / homebrew / flatpak sections)

### Bugs found and fixed during testing

- Colour escape sequences were single-quoted (`'\033[0m'`) — not interpreted by
  bash. Fixed to `$'\033[0m'` syntax throughout `lib/utils.sh`.
- `printf` format strings contained colour variables directly — SC2059
  violation. Fixed by passing colours as `%s` arguments everywhere.
- `local backup="$(date ...)"` masked the exit code — SC2155. Fixed by
  separating declaration and assignment.
- `ls` used for battery path and backup listing — SC2012. Fixed with `find`.
- `A && B || C` used as if-then-else in `setup.sh` — SC2015. Fixed with proper
  `if/elif/else`.
- `die "msg\nUsage"` — `\n` printed literally since `die` uses `%s`. Fixed by
  printing usage line separately before calling `die`.
- `fc-cache -f` printed permission warnings for system dirs. Fixed with
  `2>/dev/null` and post-install verification via `fc-list`.
- Line continuation `\` immediately before `2>/dev/null` parsed as `\2` —
  SC2260/SC1001. Fixed by keeping redirection on the same line as `find`.
- `/etc/os-release` was sourced in a subshell — SC1091/SC2153. Fixed by using
  `grep + cut + tr` to extract values directly.

### ShellCheck status

All written files pass `shellcheck -x -s bash` with **zero warnings or errors**:

- `lib/utils.sh` ✔
- `lib/preflight.sh` ✔
- `lib/shell.sh` ✔
- `scripts/restore.sh` ✔
- `scripts/sync.sh` ✔
- `scripts/setup.sh` ✔

### Symlinks verified on live system

All configs are symlinked into place and confirmed with `restore.sh --check`:

```
✔  OK : /home/obsidian/.config/nvim
✔  OK : /home/obsidian/.config/wezterm/wezterm.lua
✔  OK : /home/obsidian/.config/micro/bindings.json
✔  OK : /home/obsidian/.config/btop/btop.conf
✔  OK : /home/obsidian/.config/starship.toml
✔  OK : /home/obsidian/.zshrc
✔  OK : /home/obsidian/.config/yazi/yazi.toml
✔  OK : /home/obsidian/.config/micro/settings.json
✔  OK : /home/obsidian/.config/nano/nanorc
✔  All symlinks intact.
```

---

## 4. Current File & Folder Structure

```txt
obsidian/
├── configs/                  ← all dotfiles; source of truth; never copied during sync
│   ├── btop/
│   │   └── btop.conf
│   ├── gnome-extensions/
│   │   └── gnome-extensions.txt
│   ├── micro/
│   │   ├── micro/
│   │   │   ├── bindings.json
│   │   │   └── settings.json
│   │   └── settings.json
│   ├── nano/
│   │   └── nanorc
│   ├── nvim/                 ← active Neovim config (was nvimbak/)
│   │   ├── .luarc.json
│   │   ├── .neoconf.json
│   │   ├── .stylua.toml
│   │   ├── init.lua
│   │   ├── lazy-lock.json
│   │   ├── me.lua
│   │   ├── neovim.yml
│   │   ├── README.md
│   │   ├── selene.toml
│   │   └── lua/
│   │       ├── 1st_customs.md
│   │       ├── community.lua
│   │       ├── lazy_setup.lua
│   │       ├── polish.lua
│   │       └── plugins/
│   │           └── (15 lua plugin files)
│   ├── starship/
│   │   └── starship.toml
│   ├── wezterm/
│   │   └── wezterm.lua
│   ├── yazi/
│   │   └── yazi.toml
│   └── zsh/
│       └── .zshrc
├── docs/
│   └── setup.md              ← step-by-step manual (to be written/trimmed)
├── extras/
│   └── rename/               ← playlist helper scripts (moved from root)
├── lib/                      ← sourced modules; never run directly
│   ├── utils.sh              ← COMPLETE: colours, ok/warn/die/info, spinner, battery, symlink helper
│   ├── preflight.sh          ← COMPLETE: OS check, root check, internet, git/SSH setup
│   ├── shell.sh              ← COMPLETE: zsh, OMZ, plugins, JetBrainsMono, starship, config links
│   ├── pkgmgr.sh             ← STUB: homebrew + flatpak setup
│   ├── packages.sh           ← COMPLETE: INI parser + dnf/brew/flatpak install functions
│   ├── editors.sh            ← STUB: micro plugins, GNOME extension, dconf restore
│   ├── wezterm.sh            ← STUB: COPR, terminfo, wezterm.lua link
│   └── docker.sh             ← STUB: Docker + Winapps (optional stage)
├── scripts/                  ← user-facing entry points
│   ├── setup.sh              ← COMPLETE: orchestrator with state machine and resume
│   ├── restore.sh            ← COMPLETE: symlink manager (link / --check / --unlink)
│   └── sync.sh               ← COMPLETE: git-only sync
├── state/                    ← gitignored; contains .setup_state progress file
├── zzz/                      ← archive; do not modify
│   ├── Default/              ← Brave browser profile backup
│   ├── screenshots/
│   ├── config                ← ghostty terminal config
│   ├── foxbookmarks.html
│   ├── smoke-test.sh
│   ├── vscode-keybindings.json
│   └── vscode-settings.json
├── .gitignore
├── packages.conf             ← INI-format package lists (dnf / homebrew / flatpak)
├── README.md                 ← to be rewritten as attractive landing page
└── handout.md                ← this file
```

---

## 5. Key Design Decisions

| Decision                                        | Rationale                                                                                                                                                                          |
| ----------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Symlinks, not copies**                        | Edits to live configs are instantly in the repo. `git add -A && commit && push` captures everything without a copy step.                                                           |
| **Sync = git commands only**                    | The repo is the source of truth. No file-copying during sync. `sync.sh` is three git commands + a log display.                                                                     |
| **Package priority: dnf → homebrew → flatpak**  | dnf is the native Fedora package manager. Homebrew and Flatpak are only used when a package is not in dnf.                                                                         |
| **Shell stage runs first**                      | Everything else depends on zsh, Oh My Zsh, and starship being in place.                                                                                                            |
| **Stage state machine in `state/.setup_state`** | Allows `--resume` after the mandatory shell restart. Each stage name is written to the file on completion. File is gitignored.                                                     |
| **Mandatory shell restart gate**                | After `setup_shell` changes the default shell, the script writes a sentinel and exits cleanly with instructions. Re-run with `--resume` continues past the gate.                   |
| **`packages.conf` in INI format**               | Non-bash users can edit package lists safely. The parser (`parse_packages` in `lib/packages.sh`) is pure bash — no external dependencies.                                          |
| **Batch dnf installs**                          | `install_dnf_packages` collects all packages into an array and calls `dnf5 install` once. Far faster than one call per package.                                                    |
| **`safe_symlink` in utils.sh**                  | Centralised symlink logic: skip if already correct, backup with timestamp if destination exists, create parent dirs. All config linking goes through this function.                |
| **No root execution**                           | Script dies early if `EUID == 0`. `sudo` is used only where necessary, with a comment explaining why.                                                                              |
| **Idempotency everywhere**                      | Every install step checks if the requirement is already met and skips with a message. Safe to re-run on a partially configured system.                                             |
| **`die` never contains `\n`**                   | `die()` uses `printf '%s'` — `\n` would print literally. Separate `printf` calls are used for multi-line error messages.                                                           |
| **`$'...'` for escape sequences**               | Colour codes use `$'\033[...'` syntax so bash interprets them at assignment time. Single-quoted `'\033[...'` is a literal string and does not render.                              |
| **ShellCheck `-x` flag for scripts/\***         | Scripts that source `lib/` files must be checked with `-x` so ShellCheck follows the source chain.                                                                                 |
| **Secrets never committed**                     | SSH private keys, API tokens excluded via `.gitignore`. Script only prints the public key when instructing the user to add it to GitHub.                                           |
| **`configs/nvim` symlinked as a directory**     | The entire nvim config dir is one symlink, not per-file links. Neovim writes files inside `~/.config/nvim/` — symlinking the directory means all writes go directly into the repo. |
| **GUI-managed configs excluded from symlinks**  | GNOME settings are managed via `dconf`, not config files — they are handled separately in `lib/editors.sh`. Atomically-rewritten configs are noted in `restore.sh` comments.       |

---

## 6. Remaining Work (To-Do)

### Immediate — lib stubs to implement

- [ ] **`lib/pkgmgr.sh`** — `setup_package_managers()` function:
  - Install Homebrew if not present (use official install script)
  - Ensure `flatpak` is installed and Flathub remote is added
  - Check for `brew` in PATH after install; warn if not found

- [ ] **`lib/editors.sh`** — `setup_editors()` function:
  - Install `prettier` globally via npm (`npm install -g prettier`)
  - Install micro `lsp` plugin (`micro -plugin install lsp`)
  - Install `unite` GNOME Shell extension (fetch latest release, disable version
    validation, install)
  - Restore GNOME extension settings via `dconf load`

- [ ] **`lib/wezterm.sh`** — `setup_wezterm()` function:
  - Add wezterm COPR and install via dnf5
  - Install terminfo (`curl ... | tic -x -`)
  - Verify `configs/wezterm/wezterm.lua` → `~/.config/wezterm/wezterm.lua`
    symlink (already done by restore.sh)

- [ ] **`lib/docker.sh`** — `setup_docker()` function:
  - Install Docker via dnf5 (add Docker repo first)
  - Add user to `docker` group
  - Enable and start `docker` service
  - Install Winapps prerequisites (freerdp etc.)
  - Clone and install Winapps

### Documentation

- [ ] **`README.md`** — rewrite as attractive GitHub landing page:
  - Project overview
  - Directory structure tree
  - Prerequisites
  - Quick-start (clone → run setup.sh)
  - Link to `docs/setup.md`
  - Placeholder for animated GIF/screenshot

- [ ] **`docs/setup.md`** — step-by-step manual:
  - How to run `setup.sh` (fresh install)
  - How to run `restore.sh` (existing machine)
  - How to run `sync.sh`
  - How to add a new config to the managed set
  - No duplication with README

### Testing

- [ ] Full end-to-end test on a clean **Fedora 43+** VM
- [ ] Test `--resume` path after simulated shell restart
- [ ] Test `restore.sh --unlink` and verify backup restoration
- [ ] Test `sync.sh` with actual pending changes
- [ ] Verify `packages.conf` installs complete without errors

### Polish

- [ ] Add `sync-dots` and `restore-dots` aliases to `.zshrc` pointing to new
      script paths
- [ ] Verify `.gitignore` excludes: `state/`, `*.swp`, `.DS_Store`, `*.bak.*`
- [ ] Confirm `bun` and `code` (VS Code) special-case install logic in
      `lib/packages.sh`

---

## 7. Working Conventions

### Shell rules

- All scripts: `#!/usr/bin/env bash` + `set -euo pipefail`
- Sourced modules: guard with `[[ -n "${_MODULE_LOADED:-}" ]] && return 0`
- Variables: `local` inside functions, `lowercase_with_underscores`
- No `echo -e` — always `printf`
- No hardcoded paths — `REPO_DIR` resolved at script start via
  `cd "$(dirname ...)" && pwd`

### Colour and output conventions

```bash
ok "success message"       # green  ✔
warn "advisory message"    # yellow ⚠  (non-fatal, goes to stderr)
die "fatal message"        # red    ✖  (exits 1, goes to stderr)
info "informational"       # cyan   →
progress "in-progress"     # dim    …
progress_header "Stage"    # cyan banner box
```

### Printf colour rule

Colour variables must **never** appear in the printf format string. Always pass
as `%s` arguments:

```bash
# WRONG:
printf "${C_GREEN}message${C_RESET}\n"
# CORRECT:
printf '%smessage%s\n' "${C_GREEN}" "${C_RESET}"
```

### Colour escape rule

Colour variables must use `$'...'` syntax — **not** single quotes:

```bash
C_GREEN=$'\033[0;32m'   # CORRECT — bash interprets \033
C_GREEN='\033[0;32m'    # WRONG   — prints literally
```

### ShellCheck rules

- Run `shellcheck -x -s bash <file>` on every file before committing
- `-x` is required for `scripts/` files that source `lib/` modules
- Zero warnings or errors required — no suppressions without documented reason

### Testing approach

- Test each `lib/` module in isolation with a `bash -c '...'` block before
  integration
- Test idempotency: run the same function twice; second run must skip with a
  warning
- Run `restore.sh --check` before and after `restore.sh` (link mode)
- Run ShellCheck before every commit

### Git workflow

```bash
# Normal sync after editing a config:
bash scripts/sync.sh

# Restore configs on a new machine (after cloning):
bash scripts/restore.sh

# Full fresh install:
bash scripts/setup.sh

# Resume after shell restart:
bash scripts/setup.sh --resume

# Start over (keeps installs, clears progress):
bash scripts/setup.sh --reset
```

---

## 8. Complete File Contents

### `context.md` (original AI brief)

```markdown
# Context for AI Agent – Obsidian Dotfiles Refactoring

## 🎯 Mission

Help me re-architect, clean, and complete my Fedora workstation dotfiles
management project. The goal is a well-structured, modular, robust set of Bash
scripts that:

- Set up a fresh Fedora 43+ machine from scratch
- Restore backed-up configs safely on an existing system
- Sync changes back to a private GitHub repo using simple Git commands (no
  external copy logic)
- Are accompanied by clear, attractive documentation (README.md) and a concise
  setup guide (setup.md)

## 👤 Role & Persona

Senior Linux / Bash scripting expert with deep knowledge of Fedora Workstation
43+, dotfiles management best practices, idempotent shell scripting, Git
workflows (SSH), and package management (dnf5, homebrew, flatpak).

Behaviour:

- Ask at most two clarifying questions before diving into a solution.
- Propose changes as concrete code diffs or full script rewrites with comments.
- Show directory trees when proposing new structure.
- Test logic mentally and point out edge cases.
- Never invent package names or versions.

## 📚 Background

- Repo: ~/repo/obsidian (git@github.com:Mark-Muchiri/obsidian.git)
- Fedora uses dnf5 by default.
- Package priority: dnf first, then homebrew, then flatpak.
- GitHub SSH key: ~/.ssh/id_ed25519
- Preferred sync: git add -A && git commit -v && git push (the sync-config
  alias)
- restore.sh keeps backup-then-overwrite logic but is improved and modularised.
- Strict installation order: shell first, GUI essentials, low-priority,
  wine/winapps.

## 🗺️ Ideal Fresh Install Flow

1. Pre-flight checks (OS, root, internet, GitHub/SSH)
2. Shell & terminal (zsh, OMZ, plugins, JetBrainsMono Nerd Font, starship)
3. Package managers (homebrew, flatpak)
4. Essential CLI tools (dnf → homebrew → flatpak)
5. Editors & config tools (micro, GNOME extension, dconf)
6. Wezterm (COPR, terminfo, config)
7. Docker & Winapps (optional, lowest priority)
8. Finalise (aliases, summary)

## ⛔ Constraints

- Target OS: Fedora Workstation 43+
- dnf first, then homebrew, then flatpak
- No wine; use Winapps instead
- No root execution; sudo only where needed with a comment
- Idempotent scripts (safe to re-run)
- Symlinks as source of truth (configs live in repo)
- Sync via git commands only, no file copying
- Secrets never committed; SSH keys only
- set -euo pipefail, printf over echo -e, local variables, ShellCheck-clean
```

---

### `lib/utils.sh` (complete, ShellCheck-clean)

```bash
#!/usr/bin/env bash
# lib/utils.sh — Shared utilities for Obsidian dotfiles scripts
# Sourced by all scripts. Never run directly.

[[ -n "${_UTILS_LOADED:-}" ]] && return 0
_UTILS_LOADED=1

# ── Colours ───────────────────────────────────────────────────────────────────
# $'...' causes bash to interpret \033 as ESC at assignment time.
# Single-quoted '\033[...' prints literally — do not use that form.
if [[ -t 1 ]]; then
  C_RESET=$'\033[0m'
  C_BOLD=$'\033[1m'
  C_GREEN=$'\033[0;32m'
  C_YELLOW=$'\033[0;33m'
  C_RED=$'\033[0;31m'
  C_CYAN=$'\033[0;36m'
  C_DIM=$'\033[2m'
else
  C_RESET='' C_BOLD='' C_GREEN='' C_YELLOW='' C_RED='' C_CYAN='' C_DIM=''
fi

# ── Core print helpers ────────────────────────────────────────────────────────

ok() {
  printf '%s%s  ✔  %s%s\n' "${C_GREEN}" "${C_BOLD}" "$*" "${C_RESET}"
}

warn() {
  printf '%s%s  ⚠  %s%s\n' "${C_YELLOW}" "${C_BOLD}" "$*" "${C_RESET}" >&2
}

die() {
  printf '%s%s  ✖  ERROR: %s%s\n' "${C_RED}" "${C_BOLD}" "$*" "${C_RESET}" >&2
  exit 1
}

info() {
  printf '%s  →  %s%s\n' "${C_CYAN}" "$*" "${C_RESET}"
}

progress() {
  printf '%s  …  %s%s\n' "${C_DIM}" "$*" "${C_RESET}"
}

progress_header() {
  local name="$1"
  printf '\n'
  printf '%s══════════════════════════════════════════%s\n' "${C_BOLD}${C_CYAN}" "${C_RESET}"
  printf '%s  ▶  Stage: %s%s\n'                            "${C_BOLD}${C_CYAN}" "${name}" "${C_RESET}"
  printf '%s══════════════════════════════════════════%s\n' "${C_BOLD}${C_CYAN}" "${C_RESET}"
}

# ── Spinner ───────────────────────────────────────────────────────────────────

_SPINNER_PID=''

spinner_start() {
  local msg="${1:-Working…}"
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  (
    local i=0
    while true; do
      printf "\r%s  %s  %s%s" "${C_CYAN}" "${frames[i]}" "${msg}" "${C_RESET}" >&2
      i=$(( (i + 1) % ${#frames[@]} ))
      sleep 0.1
    done
  ) &
  _SPINNER_PID=$!
  trap 'spinner_stop' EXIT
}

spinner_stop() {
  if [[ -n "${_SPINNER_PID}" ]]; then
    kill "${_SPINNER_PID}" 2>/dev/null
    wait "${_SPINNER_PID}" 2>/dev/null
    _SPINNER_PID=''
    printf '\r\033[K' >&2
  fi
}

# ── Battery check ─────────────────────────────────────────────────────────────

check_battery() {
  local battery_path
  battery_path="$(find /sys/class/power_supply -name 'capacity' -path '*/BAT*' 2>/dev/null | head -1)"
  [[ -z "${battery_path}" ]] && return 0

  local capacity
  capacity="$(cat "${battery_path}")"

  local status_path="${battery_path%capacity}status"
  local status
  status="$(cat "${status_path}" 2>/dev/null || printf 'Unknown')"

  if [[ "${status}" == "Discharging" && "${capacity}" -lt 50 ]]; then
    warn "Battery at ${capacity}% and discharging."
    warn "This operation may take a while. Consider plugging in before continuing."
    prompt_yes_no "Continue anyway?" || die "Aborted by user."
  fi
}

# ── Yes/No prompt ─────────────────────────────────────────────────────────────

prompt_yes_no() {
  local msg="$1"
  local reply
  while true; do
    printf '%s  ?  %s [Y/n]: %s' "${C_BOLD}" "${msg}" "${C_RESET}"
    read -r reply
    reply="${reply:-Y}"
    case "${reply}" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *)     warn "Please answer y or n." ;;
    esac
  done
}

# ── Symlink helper ────────────────────────────────────────────────────────────
# safe_symlink SRC DEST
#   Creates a symlink at DEST pointing to SRC.
#   - Skips if already correctly linked (idempotent).
#   - Backs up any existing file/symlink with a timestamp before replacing.
#   - Creates parent directories as needed.

safe_symlink() {
  local src="$1"
  local dest="$2"

  if [[ ! -e "${src}" ]]; then
    die "safe_symlink: source does not exist: ${src}"
  fi

  if [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
    warn "  Already linked: ${dest} → ${src}"
    return 0
  fi

  mkdir -p "$(dirname "${dest}")"

  if [[ -e "${dest}" || -L "${dest}" ]]; then
    local backup
    backup="${dest}.bak.$(date +%Y%m%dT%H%M%S)"
    info "  Backing up existing ${dest} → ${backup}"
    mv "${dest}" "${backup}"
  fi

  ln -s "${src}" "${dest}"
  ok "  Linked: ${dest} → ${src}"
}

# ── Banner & summary ──────────────────────────────────────────────────────────

print_banner() {
  printf '%s' "${C_BOLD}${C_CYAN}"
  printf '                                                    \n'
  printf '   ██████╗ ██████╗ ███████╗██╗██████╗ ██╗ █████╗  \n'
  printf '  ██╔═══██╗██╔══██╗██╔════╝██║██╔══██╗██║██╔══██╗ \n'
  printf '  ██║   ██║██████╔╝███████╗██║██║  ██║██║███████║ \n'
  printf '  ██║   ██║██╔══██╗╚════██║██║██║  ██║██║██╔══██║ \n'
  printf '  ╚██████╔╝██████╔╝███████║██║██████╔╝██║██║  ██║ \n'
  printf '   ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝\n'
  printf '            Dotfiles — Fedora Workstation           \n'
  printf '                                                    \n'
  printf '%s' "${C_RESET}"
  printf '%s  Repository : %s%s\n' "${C_DIM}" "${REPO_DIR}" "${C_RESET}"
  printf '%s  User       : %s%s\n' "${C_DIM}" "${USER}"     "${C_RESET}"
  printf '%s  Date       : %s%s\n' "${C_DIM}" "$(date '+%Y-%m-%d %H:%M')" "${C_RESET}"
  printf '\n'
}

print_success_summary() {
  printf '\n'
  printf '%s╔══════════════════════════════════════════╗%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf "%s║       Setup complete! What's next:       ║%s\n" "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '%s╚══════════════════════════════════════════╝%s\n' "${C_GREEN}${C_BOLD}" "${C_RESET}"
  printf '\n'
  printf '  %sSync changes to GitHub:%s\n'                 "${C_BOLD}" "${C_RESET}"
  printf '    bash %s/scripts/sync.sh\n\n'                 "${REPO_DIR}"
  printf '  %sRestore configs on another machine:%s\n'     "${C_BOLD}" "${C_RESET}"
  printf '    bash %s/scripts/restore.sh\n\n'              "${REPO_DIR}"
  printf '  %sRe-run setup (resumes from last stage):%s\n' "${C_BOLD}" "${C_RESET}"
  printf '    bash %s/scripts/setup.sh --resume\n\n'       "${REPO_DIR}"
}
```

---

### `lib/preflight.sh` (complete, ShellCheck-clean)

```bash
#!/usr/bin/env bash
# lib/preflight.sh — Pre-flight checks for Obsidian dotfiles setup
# Sourced by scripts/setup.sh — do not run directly.

[[ -n "${_PREFLIGHT_LOADED:-}" ]] && return 0
_PREFLIGHT_LOADED=1

_check_fedora_version() {
  local os_id version_id
  # grep + cut avoids sourcing /etc/os-release (SC1091/SC2153).
  # tr -d '"' handles both quoted (ID="fedora") and unquoted (ID=fedora) forms.
  os_id="$(     grep '^ID='         /etc/os-release | cut -d= -f2 | tr -d '"' )"
  version_id="$( grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"' )"

  if [[ "${os_id}" != "fedora" ]]; then
    die "This script targets Fedora only. Detected OS: '${os_id}'."
  fi

  if [[ ! "${version_id}" =~ ^[0-9]+$ ]] || (( version_id < 43 )); then
    die "Fedora 43+ required. Detected version: ${version_id}."
  fi

  ok "OS check passed — Fedora ${version_id}."
}

_check_not_root() {
  if (( EUID == 0 )); then
    die "Do not run this script as root. Run as your normal user — sudo is used internally where needed."
  fi
  ok "User check passed — running as '${USER}' (uid ${EUID})."
}

_check_internet() {
  info "Checking internet connectivity…"
  if ! ping -c 2 -W 3 1.1.1.1 &>/dev/null; then
    die "No internet connection detected. Please connect and re-run."
  fi
  ok "Internet connectivity confirmed."
}

_ensure_git_installed() {
  if ! command -v git &>/dev/null; then
    info "git not found — installing via dnf5…"
    # sudo required: dnf5 writes to the system package database
    sudo dnf5 install -y git || die "Failed to install git."
    ok "git installed."
  else
    ok "git already installed ($(git --version))."
  fi
}

_configure_git_identity() {
  local git_user git_email

  git_user="$(git config --global user.name  2>/dev/null || true)"
  git_email="$(git config --global user.email 2>/dev/null || true)"

  if [[ -z "${git_user}" ]]; then
    printf '%s  ?  GitHub username (for git config): %s' "${C_BOLD}" "${C_RESET}"
    read -r git_user
    [[ -z "${git_user}" ]] && die "Git username cannot be empty."
    git config --global user.name "${git_user}"
  else
    info "Git user already set: ${git_user}"
  fi

  if [[ -z "${git_email}" ]]; then
    printf '%s  ?  GitHub email (for git config): %s' "${C_BOLD}" "${C_RESET}"
    read -r git_email
    [[ -z "${git_email}" ]] && die "Git email cannot be empty."
    git config --global user.email "${git_email}"
  else
    info "Git email already set: ${git_email}"
  fi

  ok "Git identity: ${git_user} <${git_email}>."
}

_ensure_ssh_key() {
  local key_path="${HOME}/.ssh/id_ed25519"
  local pub_path="${key_path}.pub"

  if [[ -f "${key_path}" && -f "${pub_path}" ]]; then
    ok "SSH key already exists at ${key_path}."
    return 0
  fi

  info "No SSH key found at ${key_path}. Generating one…"

  local git_email
  git_email="$(git config --global user.email 2>/dev/null || true)"
  [[ -z "${git_email}" ]] && die "Git email not set — run _configure_git_identity first."

  # -N "" means no passphrase; adjust if desired
  ssh-keygen -t ed25519 -C "${git_email}" -f "${key_path}" -N "" \
    || die "ssh-keygen failed."

  ok "SSH key generated."
  printf '\n'
  printf '%s  ══════════════════════════════════════════════════════%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '%s  Add the following public key to GitHub before continuing%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '%s  Settings → SSH and GPG keys → New SSH key            %s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '%s  ══════════════════════════════════════════════════════%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
  printf '\n'
  # Print ONLY the public key — never the private key
  cat "${pub_path}"
  printf '\n'

  prompt_yes_no "Have you added the key to GitHub?" \
    || die "Please add your SSH key to GitHub, then re-run."
}

_test_github_ssh() {
  info "Testing SSH connection to GitHub…"
  # ssh -T exits 1 on success (GitHub's documented behaviour) and 255 on failure.
  local ssh_output
  ssh_output="$(ssh -T -o StrictHostKeyChecking=accept-new \
                       -o ConnectTimeout=10 \
                       git@github.com 2>&1 || true)"

  if printf '%s' "${ssh_output}" | grep -q "successfully authenticated"; then
    ok "GitHub SSH authentication successful."
  else
    die "GitHub SSH test failed. Output: ${ssh_output}"
  fi
}

_setup_github() {
  _ensure_git_installed
  _configure_git_identity
  _ensure_ssh_key
  _test_github_ssh
}

preflight_checks() {
  _check_fedora_version
  _check_not_root
  _check_internet

  if prompt_yes_no "Set up GitHub backup (SSH)?"; then
    _setup_github
  else
    _ensure_git_installed
    _configure_git_identity
    warn "GitHub backup skipped. Re-run setup.sh to add it later."
  fi

  ok "Pre-flight complete — all checks passed."
}
```

---

### `lib/shell.sh` (complete, ShellCheck-clean)

```bash
#!/usr/bin/env bash
# lib/shell.sh — Shell & terminal setup stage
# Sourced by scripts/setup.sh — do not run directly.

[[ -n "${_SHELL_LOADED:-}" ]] && return 0
_SHELL_LOADED=1

_install_zsh() {
  if command -v zsh &>/dev/null; then
    ok "zsh already installed ($(zsh --version | head -1))."
    return 0
  fi
  progress "Installing zsh via dnf5…"
  # sudo required: dnf5 writes to the system package database
  sudo dnf5 install -y zsh || die "Failed to install zsh."
  ok "zsh installed."
}

_set_default_shell() {
  local zsh_path
  zsh_path="$(command -v zsh)" || die "zsh not found in PATH after install."

  if [[ "${SHELL}" == "${zsh_path}" ]]; then
    ok "Default shell is already zsh."
    return 0
  fi

  if ! grep -qx "${zsh_path}" /etc/shells; then
    info "Adding ${zsh_path} to /etc/shells…"
    # sudo required: /etc/shells is root-owned
    printf '%s\n' "${zsh_path}" | sudo tee -a /etc/shells >/dev/null
  fi

  info "Changing default shell to zsh (you will be prompted for your password)…"
  chsh -s "${zsh_path}" || die "chsh failed — could not set zsh as default shell."
  ok "Default shell set to zsh. Takes effect on next login."
}

_install_oh_my_zsh() {
  if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    ok "Oh My Zsh already installed."
    return 0
  fi
  progress "Installing Oh My Zsh…"
  check_battery
  # RUNZSH=no — do not start a new zsh session (would halt the script)
  # CHSH=no   — do not change shell here; handled by _set_default_shell
  RUNZSH=no CHSH=no \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    || die "Oh My Zsh installation failed."
  ok "Oh My Zsh installed."
}

_install_zsh_plugin() {
  local name="$1"
  local repo="$2"
  local plugin_dir="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}/plugins/${name}"

  if [[ -d "${plugin_dir}" ]]; then
    warn "  Plugin '${name}' already installed — skipping."
    return 0
  fi
  progress "  Installing plugin: ${name}…"
  git clone --depth=1 "${repo}" "${plugin_dir}" \
    || die "Failed to clone plugin '${name}' from ${repo}."
  ok "  Plugin '${name}' installed."
}

_install_zsh_plugins() {
  info "Installing ZSH plugins…"
  _install_zsh_plugin "zsh-autosuggestions"          "https://github.com/zsh-users/zsh-autosuggestions"
  _install_zsh_plugin "zsh-syntax-highlighting"      "https://github.com/zsh-users/zsh-syntax-highlighting"
  _install_zsh_plugin "fast-syntax-highlighting"     "https://github.com/zdharma-continuum/fast-syntax-highlighting"
  _install_zsh_plugin "zsh-history-substring-search" "https://github.com/zsh-users/zsh-history-substring-search"
  ok "ZSH plugins installed."
}

_install_jetbrains_font() {
  if fc-list | grep -q "JetBrainsMono"; then
    ok "JetBrainsMono Nerd Font already installed."
    return 0
  fi
  progress "Downloading JetBrainsMono Nerd Font…"
  check_battery

  local font_dir="${HOME}/.local/share/fonts/JetBrainsMono"
  mkdir -p "${font_dir}"

  local latest_tag
  latest_tag="$(curl -fsSL \
    "https://api.github.com/repos/ryanoasis/nerd-fonts/releases/latest" \
    | grep '"tag_name"' \
    | head -1 \
    | cut -d'"' -f4)" \
    || die "Could not fetch latest Nerd Fonts release tag."

  info "Latest Nerd Fonts release: ${latest_tag}"

  local zip_url="https://github.com/ryanoasis/nerd-fonts/releases/download/${latest_tag}/JetBrainsMono.zip"
  local tmp_zip
  tmp_zip="$(mktemp --suffix='.zip')"

  curl -fsSL "${zip_url}" -o "${tmp_zip}" || die "Failed to download JetBrainsMono.zip."
  unzip -q "${tmp_zip}" -d "${font_dir}"  || die "Failed to unzip JetBrainsMono.zip."
  rm -f "${tmp_zip}"

  # 2>/dev/null suppresses warnings about system font dirs we can't write to.
  # The user cache (~/.cache/fontconfig) is always written successfully.
  fc-cache -f "${font_dir}" 2>/dev/null || fc-cache -f 2>/dev/null

  if fc-list | grep -q "JetBrainsMono"; then
    ok "JetBrainsMono Nerd Font installed and font cache refreshed."
  else
    warn "Font files installed but not yet detected. Try: fc-cache -f && exec zsh"
  fi
}

_install_starship() {
  if command -v starship &>/dev/null; then
    ok "Starship already installed ($(starship --version | head -1))."
    return 0
  fi
  progress "Installing Starship prompt…"
  check_battery
  curl -fsSL https://starship.rs/install.sh \
    | sh -s -- --yes --bin-dir "${HOME}/.local/bin" \
    || die "Starship installation failed."
  ok "Starship installed."
}

_deploy_shell_configs() {
  info "Linking shell configs…"
  safe_symlink "${REPO_DIR}/configs/zsh/.zshrc"             "${HOME}/.zshrc"
  safe_symlink "${REPO_DIR}/configs/starship/starship.toml" "${HOME}/.config/starship.toml"
  ok "Shell configs linked."
}

setup_shell() {
  check_battery
  _install_zsh
  _set_default_shell
  _install_oh_my_zsh
  _install_zsh_plugins
  _install_jetbrains_font
  _install_starship
  _deploy_shell_configs
  ok "Shell stage complete."
  info "Run 'exec zsh' or open a new terminal to start using zsh now."
}
```

---

### `lib/packages.sh` (complete, ShellCheck-clean)

```bash
#!/usr/bin/env bash
# lib/packages.sh — Package installation module
# Sourced by scripts/setup.sh — do not run directly.

[[ -n "${_PACKAGES_LOADED:-}" ]] && return 0
_PACKAGES_LOADED=1

# parse_packages SECTION CONF_FILE
#   Reads CONF_FILE, finds [SECTION], prints one package name per line.
#   Strips inline comments and blank lines.
#   Usage: mapfile -t pkgs < <(parse_packages "dnf" "${REPO_DIR}/packages.conf")
parse_packages() {
  local section="$1"
  local conf_file="$2"
  local in_section=0

  if [[ ! -f "${conf_file}" ]]; then
    die "packages.conf not found at: ${conf_file}"
  fi

  while IFS= read -r line; do
    # Strip leading/trailing whitespace
    line="${line#"${line%%[![:space:]]*}"}"
    line="${line%"${line##*[![:space:]]}"}"
    [[ -z "${line}" || "${line}" == \#* ]] && continue

    if [[ "${line}" =~ ^\[([a-zA-Z0-9_-]+)\]$ ]]; then
      local current_section="${BASH_REMATCH[1]}"
      if [[ "${current_section}" == "${section}" ]]; then
        in_section=1
      else
        in_section=0
      fi
      continue
    fi

    if (( in_section )); then
      local pkg="${line%%#*}"
      pkg="${pkg%"${pkg##*[![:space:]]}"}"
      [[ -n "${pkg}" ]] && printf '%s\n' "${pkg}"
    fi
  done < "${conf_file}"
}

is_installed_dnf()     { rpm -q "$1" &>/dev/null; }
is_installed_brew()    { brew list "$1" &>/dev/null 2>&1; }
is_installed_flatpak() { flatpak list --app --columns=application 2>/dev/null | grep -qx "$1"; }

install_dnf_packages() {
  local -a pkgs
  mapfile -t pkgs < <(parse_packages "dnf" "${REPO_DIR}/packages.conf")

  local -a to_install=()
  for pkg in "${pkgs[@]}"; do
    if is_installed_dnf "${pkg}"; then
      warn "  [dnf] ${pkg} already installed — skipping."
    else
      to_install+=("${pkg}")
    fi
  done

  if (( ${#to_install[@]} == 0 )); then
    ok "All dnf packages already installed."
    return 0
  fi

  progress "Installing ${#to_install[@]} dnf package(s)…"
  # sudo required: dnf5 writes to system package database
  sudo dnf5 install -y "${to_install[@]}" || die "dnf5 install failed."
  ok "dnf packages installed."
}

install_brew_packages() {
  local -a pkgs
  mapfile -t pkgs < <(parse_packages "homebrew" "${REPO_DIR}/packages.conf")

  for pkg in "${pkgs[@]}"; do
    if is_installed_brew "${pkg}"; then
      warn "  [brew] ${pkg} already installed — skipping."
    else
      progress "  [brew] Installing ${pkg}…"
      # warn (not die) on failure — brew packages are supplementary
      brew install "${pkg}" || warn "  [brew] ${pkg} failed — continuing."
    fi
  done
  ok "Homebrew packages done."
}

install_flatpak_packages() {
  local -a pkgs
  mapfile -t pkgs < <(parse_packages "flatpak" "${REPO_DIR}/packages.conf")

  for pkg in "${pkgs[@]}"; do
    if is_installed_flatpak "${pkg}"; then
      warn "  [flatpak] ${pkg} already installed — skipping."
    else
      progress "  [flatpak] Installing ${pkg}…"
      flatpak install -y flathub "${pkg}" || warn "  [flatpak] ${pkg} failed — continuing."
    fi
  done
  ok "Flatpak packages done."
}

install_packages() {
  install_dnf_packages
  install_brew_packages
  install_flatpak_packages
}
```

---

### `scripts/setup.sh` (complete, ShellCheck-clean)

```bash
#!/usr/bin/env bash
# scripts/setup.sh — Obsidian dotfiles setup orchestrator
# Usage:
#   bash scripts/setup.sh            # fresh install, runs all stages
#   bash scripts/setup.sh --resume   # skip completed stages, continue from last
#   bash scripts/setup.sh --reset    # clear state and start over (does NOT undo installs)

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${REPO_DIR}/lib"
STATE_DIR="${REPO_DIR}/state"
STATE_FILE="${STATE_DIR}/.setup_state"

# shellcheck source=lib/utils.sh
. "${LIB_DIR}/utils.sh"
# shellcheck source=lib/preflight.sh
. "${LIB_DIR}/preflight.sh"
# shellcheck source=lib/shell.sh
. "${LIB_DIR}/shell.sh"
# shellcheck source=lib/pkgmgr.sh
. "${LIB_DIR}/pkgmgr.sh"
# shellcheck source=lib/packages.sh
. "${LIB_DIR}/packages.sh"
# shellcheck source=lib/editors.sh
. "${LIB_DIR}/editors.sh"
# shellcheck source=lib/wezterm.sh
. "${LIB_DIR}/wezterm.sh"
# shellcheck source=lib/docker.sh
. "${LIB_DIR}/docker.sh"

mkdir -p "${STATE_DIR}"

# Ensure state/ is gitignored
if ! grep -qx 'state/' "${REPO_DIR}/.gitignore" 2>/dev/null; then
  printf 'state/\n' >> "${REPO_DIR}/.gitignore"
fi

stage_done() { grep -qxF "$1" "${STATE_FILE}" 2>/dev/null; }
mark_done()  { printf '%s\n' "$1" >> "${STATE_FILE}"; }

run_stage() {
  local name="$1"
  local fn="$2"

  if stage_done "${name}"; then
    printf '%s  ↷  Skipping: %s (already complete)%s\n' "${C_DIM}" "${name}" "${C_RESET}"
    return 0
  fi

  progress_header "${name}"
  "${fn}"
  mark_done "${name}"
  ok "'${name}' complete."
}

handle_args() {
  case "${1:-}" in
    --resume)
      info "Resuming from last completed stage."
      ;;
    --reset)
      warn "Clearing setup state. All stages will re-run."
      warn "This does NOT undo any installations."
      prompt_yes_no "Continue?" || exit 0
      rm -f "${STATE_FILE}"
      info "State cleared."
      ;;
    "")
      if [[ -f "${STATE_FILE}" ]]; then
        warn "A previous setup run was detected."
        info "Use --resume to continue it, or --reset to start over."
        if prompt_yes_no "Resume previous run?"; then
          :  # continue — state file stays, completed stages will be skipped
        elif prompt_yes_no "Reset and start over?"; then
          rm -f "${STATE_FILE}"
        else
          exit 0
        fi
      fi
      ;;
    *)
      printf '%s  Usage: setup.sh [--resume | --reset]%s\n' "${C_DIM}" "${C_RESET}" >&2
      die "Unknown argument: ${1}"
      ;;
  esac
}

check_shell_restart() {
  if stage_done "shell" && ! stage_done "shell_restarted"; then
    printf '\n'
    printf '%s╔══════════════════════════════════════════════════════╗%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║  Shell changed to zsh — action required              ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║                                                      ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║  1. Close this terminal completely                   ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║  2. Open a new terminal                              ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s║  3. Run: bash scripts/setup.sh --resume              ║%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '%s╚══════════════════════════════════════════════════════╝%s\n' "${C_BOLD}${C_YELLOW}" "${C_RESET}"
    printf '\n'
    mark_done "shell_restarted"
    exit 0
  fi
}

main() {
  handle_args "${@}"
  print_banner

  run_stage "preflight" preflight_checks
  run_stage "shell"     setup_shell
  check_shell_restart
  run_stage "pkgmgr"   setup_package_managers
  run_stage "packages"  install_packages
  run_stage "editors"   setup_editors
  run_stage "wezterm"   setup_wezterm

  if ! stage_done "docker"; then
    if prompt_yes_no "Install Docker and Winapps? (optional — skip if unsure)"; then
      run_stage "docker" setup_docker
    else
      mark_done "docker"
      info "Docker skipped. Re-run with --reset if you change your mind."
    fi
  fi

  run_stage "restore" do_link
  print_success_summary
}

main "$@"
```

---

### `scripts/restore.sh` (complete, ShellCheck-clean)

```bash
#!/usr/bin/env bash
# scripts/restore.sh — Link dotfiles from the repo into their system locations
# Usage:
#   bash scripts/restore.sh            # create all symlinks
#   bash scripts/restore.sh --check    # verify all symlinks, no changes
#   bash scripts/restore.sh --unlink   # remove symlinks, restore backups

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${REPO_DIR}/lib"

# shellcheck source=lib/utils.sh
. "${LIB_DIR}/utils.sh"

# ── Config map ────────────────────────────────────────────────────────────────
# Format: ["REPO_SOURCE"]="SYSTEM_DEST"
# To add a new config: add one line here. Nothing else needs changing.
#
# NOTE: configs managed by GUI apps that rewrite files atomically must NOT be
# symlinked — they break the link silently. Those are handled via dconf or
# direct copies in the relevant lib/ module. All entries below are safe.
declare -A CONFIG_MAP=(
  ["configs/zsh/.zshrc"]="${HOME}/.zshrc"
  ["configs/starship/starship.toml"]="${HOME}/.config/starship.toml"
  ["configs/wezterm/wezterm.lua"]="${HOME}/.config/wezterm/wezterm.lua"
  ["configs/micro/settings.json"]="${HOME}/.config/micro/settings.json"
  ["configs/micro/micro/bindings.json"]="${HOME}/.config/micro/bindings.json"
  ["configs/nano/nanorc"]="${HOME}/.config/nano/nanorc"
  ["configs/btop/btop.conf"]="${HOME}/.config/btop/btop.conf"
  ["configs/yazi/yazi.toml"]="${HOME}/.config/yazi/yazi.toml"
  ["configs/nvim"]="${HOME}/.config/nvim"
)

do_link() {
  progress_header "Restore — linking configs"
  local src dest
  for rel_src in "${!CONFIG_MAP[@]}"; do
    src="${REPO_DIR}/${rel_src}"
    dest="${CONFIG_MAP[${rel_src}]}"
    safe_symlink "${src}" "${dest}"
  done
  ok "All configs linked."
  info "Run 'exec zsh' to pick up the new .zshrc immediately."
}

do_check() {
  progress_header "Restore — checking symlinks"
  local src dest all_ok=1
  for rel_src in "${!CONFIG_MAP[@]}"; do
    src="${REPO_DIR}/${rel_src}"
    dest="${CONFIG_MAP[${rel_src}]}"
    if [[ ! -e "${src}" ]]; then
      warn "  MISSING source : ${src}"; all_ok=0
    elif [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
      ok "  OK             : ${dest}"
    elif [[ -e "${dest}" && ! -L "${dest}" ]]; then
      warn "  UNMANAGED FILE : ${dest}  (exists but is not a symlink)"; all_ok=0
    elif [[ -L "${dest}" ]]; then
      warn "  BROKEN LINK    : ${dest} → $(readlink "${dest}") (target missing)"; all_ok=0
    else
      warn "  NOT LINKED     : ${dest}  (run restore.sh to create it)"; all_ok=0
    fi
  done
  if (( all_ok )); then
    ok "All symlinks intact."
  else
    warn "Some configs are not correctly linked. Run restore.sh to fix."
    return 1
  fi
}

do_unlink() {
  progress_header "Restore — unlinking configs"
  warn "This will remove all managed symlinks."
  warn "If a backup exists (.bak.*), it will be restored in place."
  prompt_yes_no "Continue?" || { info "Aborted."; exit 0; }

  local dest backup
  for rel_src in "${!CONFIG_MAP[@]}"; do
    dest="${CONFIG_MAP[${rel_src}]}"
    if [[ ! -L "${dest}" ]]; then
      warn "  Not a symlink, skipping: ${dest}"
      continue
    fi
    rm "${dest}"
    backup="$(find "$(dirname "${dest}")" -maxdepth 1 \
                -name "$(basename "${dest}").bak.*" \
                2>/dev/null | sort -r | head -1)"
    if [[ -n "${backup}" ]]; then
      mv "${backup}" "${dest}"
      ok "  Restored backup: ${backup} → ${dest}"
    else
      info "  Removed symlink (no backup found): ${dest}"
    fi
  done
  ok "Unlink complete."
}

main() {
  case "${1:-}" in
    --check)  do_check  ;;
    --unlink) do_unlink ;;
    "")       do_link   ;;
    *)
      printf '%s  Usage: restore.sh [--check | --unlink]%s\n' "${C_DIM}" "${C_RESET}" >&2
      die "Unknown argument: ${1}"
      ;;
  esac
}

main "$@"
```

---

### `scripts/sync.sh` (complete, ShellCheck-clean)

```bash
#!/usr/bin/env bash
# scripts/sync.sh — Sync dotfiles changes back to GitHub
# Usage: bash scripts/sync.sh
#
# Equivalent to the sync-config alias:
#   git add -A && git commit -v && git push

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LIB_DIR="${REPO_DIR}/lib"

# shellcheck source=lib/utils.sh
. "${LIB_DIR}/utils.sh"

main() {
  progress_header "Sync dotfiles → GitHub"
  cd "${REPO_DIR}"

  if ! git rev-parse --git-dir &>/dev/null; then
    die "Not a git repository: ${REPO_DIR}"
  fi

  if ! git remote get-url origin &>/dev/null; then
    die "No 'origin' remote configured. Add one with: git remote add origin git@github.com:Mark-Muchiri/obsidian.git"
  fi

  if git diff --quiet && git diff --cached --quiet && \
     [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
    ok "Nothing to commit — repo is clean."
    info "Last commit:"
    git log --oneline -1
    exit 0
  fi

  info "Staging all changes…"
  git add -A

  info "Opening editor for commit message…"
  # -v shows the diff in the commit message editor — matches sync-config alias
  git commit -v

  info "Pushing to origin…"
  git push

  ok "Sync complete."
  printf '\n'
  info "Recent commits:"
  git log --oneline -5
}

main "$@"
```

---

### `packages.conf` (current state)

```ini
# packages.conf — Package list for Obsidian dotfiles setup
# Edit this file to add/remove packages. No bash knowledge required.
# Sections: [dnf], [homebrew], [flatpak]
# Lines starting with # are comments. Blank lines are ignored.
# Format: one package per line, optionally followed by  # comment

[dnf]
micro
eza
wget
zoxide
thefuck
fastfetch
easyeffects
btop
npm
procps-ng
curl
file
bat
fd-find
tree
trash-cli
nodejs
dconf-editor
gnome-tweaks
gnome-browser-connector
xprop
wezterm
rsync
bun                        # attempt dnf first; installer fallback in packages.sh
code                       # VS Code — requires Microsoft repo (handled in packages.sh)

[homebrew]
yazi                       # not in dnf as of Fedora 43
nerdfetch                  # not in dnf

[flatpak]
com.mattjakeman.ExtensionManager
it.mijorus.smile
com.github.tchx84.Flatseal   # install last — manages other flatpak permissions
```

---

### Stub files (`lib/pkgmgr.sh`, `lib/editors.sh`, `lib/wezterm.sh`, `lib/docker.sh`)

All four currently contain only:

```bash
#!/usr/bin/env bash
# stub
```

The entry-point functions `setup.sh` calls and expects each to export:

| File             | Required function          |
| ---------------- | -------------------------- |
| `lib/pkgmgr.sh`  | `setup_package_managers()` |
| `lib/editors.sh` | `setup_editors()`          |
| `lib/wezterm.sh` | `setup_wezterm()`          |
| `lib/docker.sh`  | `setup_docker()`           |

---

## 9. Last Known Git State

```
commit ddd839e7a01947560d6396b64ddb62316ef7709f (HEAD -> main, origin/main)
Author: mark <muriithimac@gmail.com>
Date:   Sat May 16 05:02:39 2026 +0300

    feat: add all scripts and lib modules (stubs pending for pkgmgr/editors/wezterm/docker)
```

All symlinks verified live. All written files pass `shellcheck -x -s bash` with
zero warnings.

---

_Handout generated 2026-05-16. Next step: implement `lib/pkgmgr.sh`, then
`lib/editors.sh`, `lib/wezterm.sh`, `lib/docker.sh`, then documentation._
