# oh-my-zsh-setup

[![Shell](https://img.shields.io/badge/shell-zsh-blue.svg)](https://www.zsh.org/)
[![Oh My Zsh](https://img.shields.io/badge/framework-Oh%20My%20Zsh-orange.svg)](https://ohmyz.sh/)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS-lightgrey.svg)]()
[![License](https://img.shields.io/badge/license-MIT-green.svg)]()

A complete, self-contained setup repository to automatically bootstrap, install, and configure Oh My Zsh and the custom **santiagus** theme on any fresh Linux or macOS machine with a single command.

---

## ⚡ Quick Start

Clone this repository and run the installer:

```bash
git clone https://github.com/Santiagus/oh-my-zsh-setup.git
cd oh-my-zsh-setup
./install.sh
```

Once the script completes, reload your shell:

```bash
exec zsh
```

---

## ✨ Features & What the Installer Does

Running `./install.sh` automatically performs the following steps in sequence:

1. **Prerequisite Check & Auto-Installation**
   - Verifies that `zsh`, `git`, and `curl` (or `wget`) are installed.
   - On fresh Linux distributions (`apt`, `dnf`, `pacman`, `apk`) or macOS (`brew`), attempts automatic package installation if missing dependencies are detected.

2. **Timestamped Config Backup**
   - If an existing `~/.zshrc` file is detected, it is safely backed up with a timestamp suffix:
     ```
     ~/.zshrc.bak.YYYYMMDD_HHMMSS
     ```
   - Your original configuration is preserved and never overwritten without a backup.

3. **Unattended Oh My Zsh Installation**
   - Checks if `~/.oh-my-zsh` already exists.
   - If not installed, downloads and runs the official Oh My Zsh installer in **unattended mode** (`--unattended --keep-zshrc`), preventing terminal prompts or subshell interruptions during setup.

4. **Custom Theme Deployment (`santiagus`)**
   - Copies `themes/santiagus.zsh-theme` to:
     ```
     ~/.oh-my-zsh/custom/themes/santiagus.zsh-theme
     ```
   - Using the `custom/` directory ensures upstream Oh My Zsh updates will never overwrite or erase your theme.

5. **Safe In-Place `~/.zshrc` Configuration**
   - Locates existing `ZSH_THEME` declarations in `~/.zshrc`.
   - Comments out the active theme (e.g. `# ZSH_THEME="robbyrussell"`).
   - Injects `ZSH_THEME="santiagus"` directly in place.
   - Completely preserves all other contents, comments, plugins, aliases, and environment variables.
   - Idempotent: safe to run multiple times without duplicating entries.

6. **Default Shell Configuration**
   - Checks if your current shell is already `zsh`.
   - If not, verifies `/etc/shells` and invokes `chsh -s $(which zsh)` to set `zsh` as your login shell.

---

## 🎨 About the `santiagus` Theme

The **santiagus** theme is a heavily enhanced custom prompt (originally evolved from the classic Soliah theme), offering a high-density, clean two-line prompt loaded with developer context:

```text
(venv) [19:54] (user@hostname) ~/projects/my-repo (12m|a1b2c3d|main*|↑1) $
```

### Prompt Breakdown
- **Virtualenv Support**: Displays active Python `(venv)` environment name in bold green.
- **Timestamp**: `[HH:MM]` system time in bold blue.
- **User & Host**: `(user@host)` in bold yellow.
- **Current Path**: 2-level directory path (`%2~`) in bold cyan.
- **Git Segment**:
  - **Time Elapsed Since Commit**: Shows time since last commit, dynamically color-coded:
    - 🟢 Green: `< 10 minutes`
    - 🟡 Yellow: `10 - 30 minutes`
    - 🔴 Red: `> 30 minutes`
  - **Commit Hash**: Short commit hash (or `HEAD`).
  - **Branch Name & Dirty State**: Active branch name in magenta, with a red `*` when uncommitted changes exist.
  - **Detached HEAD Detection**: Displays `detached-head` in magenta if checked out detached.
  - **Upstream Sync**: Shows sync status with upstream:
    - `↑X`: Commits ahead of upstream
    - `↓Y`: Commits behind upstream
    - `↑X↓Y`: Diverged from upstream
    - `✓`: In sync with upstream
  - **RVM Gemset**: Displays active Ruby RVM gemset if active.

---

## 📂 Repository Structure

```text
oh-my-zsh-setup/
├── install.sh               # Main self-contained setup script (executable)
├── themes/
│   └── santiagus.zsh-theme  # Custom Oh My Zsh theme
├── .gitignore               # Git ignore rules for backups & temporary files
└── README.md                # Documentation & usage instructions
```

---

## 🔄 Rollback / Restoring Configuration

If you ever wish to revert your `~/.zshrc` to a state prior to running the installer, restore from the timestamped backup:

```bash
# List available backups
ls -la ~/.zshrc.bak.*

# Restore a specific backup
cp ~/.zshrc.bak.YYYYMMDD_HHMMSS ~/.zshrc
source ~/.zshrc
```

---

## 🛠️ Requirements & Compatibility

- **Operating Systems**:
  - Linux (Ubuntu, Debian, Fedora, CentOS, RHEL, Arch Linux, Alpine, etc.)
  - macOS (Intel & Apple Silicon)
- **Dependencies**: `zsh`, `git`, and either `curl` or `wget` (auto-installed on supported package managers).

---

## 📄 License

This repository is licensed under the [MIT License](LICENSE) (or choose your preferred license).
