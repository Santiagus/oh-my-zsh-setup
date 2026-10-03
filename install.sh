#!/usr/bin/env bash
# ==============================================================================
# Oh My Zsh Setup & Custom santiagus Theme Installer
# Supports: Linux (Ubuntu/Debian, Fedora/RHEL, Arch, Alpine) & macOS
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color formatting
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  BOLD="\033[1m"
  GREEN="\033[0;32m"
  CYAN="\033[0;36m"
  YELLOW="\033[0;33m"
  RED="\033[0;31m"
  RESET="\033[0m"
else
  BOLD=""
  GREEN=""
  CYAN=""
  YELLOW=""
  RED=""
  RESET=""
fi

log_info() {
  printf "${CYAN}[INFO]${RESET} %s\n" "$*"
}

log_success() {
  printf "${GREEN}[SUCCESS]${RESET} %s\n" "$*"
}

log_warn() {
  printf "${YELLOW}[WARN]${RESET} %s\n" "$*"
}

log_error() {
  printf "${RED}[ERROR]${RESET} %s\n" "$*" >&2
}

# ------------------------------------------------------------------------------
# 1. Dependency Checks & Auto-Installation
# ------------------------------------------------------------------------------
ensure_dependencies() {
  log_info "Checking prerequisites..."

  local missing_deps=()
  for cmd in zsh git curl; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      missing_deps+=("$cmd")
    fi
  done

  # If curl is missing, check if wget is available
  if [[ " ${missing_deps[*]:-} " =~ " curl " ]] && command -v wget >/dev/null 2>&1; then
    missing_deps=("${missing_deps[@]/curl/}")
  fi

  if [ ${#missing_deps[@]} -gt 0 ]; then
    log_warn "Missing dependencies: ${missing_deps[*]}"
    log_info "Attempting to install missing dependencies..."

    local installed=false
    if command -v apt-get >/dev/null 2>&1; then
      if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        apt-get update && apt-get install -y "${missing_deps[@]}"
      elif command -v sudo >/dev/null 2>&1; then
        sudo apt-get update && sudo apt-get install -y "${missing_deps[@]}"
      fi
      installed=true
    elif command -v dnf >/dev/null 2>&1; then
      if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        dnf install -y "${missing_deps[@]}"
      elif command -v sudo >/dev/null 2>&1; then
        sudo dnf install -y "${missing_deps[@]}"
      fi
      installed=true
    elif command -v pacman >/dev/null 2>&1; then
      if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        pacman -Sy --noconfirm "${missing_deps[@]}"
      elif command -v sudo >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm "${missing_deps[@]}"
      fi
      installed=true
    elif command -v apk >/dev/null 2>&1; then
      if [ "${EUID:-$(id -u)}" -eq 0 ]; then
        apk add "${missing_deps[@]}"
      elif command -v sudo >/dev/null 2>&1; then
        sudo apk add "${missing_deps[@]}"
      fi
      installed=true
    elif command -v brew >/dev/null 2>&1; then
      brew install "${missing_deps[@]}"
      installed=true
    fi

    # Verify again
    for cmd in "${missing_deps[@]}"; do
      if [ -n "$cmd" ] && ! command -v "$cmd" >/dev/null 2>&1; then
        log_error "Could not automatically install '$cmd'. Please install it manually."
        exit 1
      fi
    done
  fi

  log_success "All prerequisites are satisfied."
}

# ------------------------------------------------------------------------------
# 2. Backup Existing Config with Timestamp
# ------------------------------------------------------------------------------
backup_existing_config() {
  local zshrc="$HOME/.zshrc"
  if [ -f "$zshrc" ] || [ -L "$zshrc" ]; then
    local timestamp
    timestamp="$(date +%Y%m%d_%H%M%S)"
    local backup_file="${zshrc}.bak.${timestamp}"
    log_info "Backing up existing ~/.zshrc to ${backup_file}..."
    cp "$zshrc" "$backup_file"
    log_success "Backup saved: ${backup_file}"
  else
    log_info "No existing ~/.zshrc detected. Skipping backup."
  fi
}

# ------------------------------------------------------------------------------
# 3. Install Oh My Zsh (Official Unattended Installer)
# ------------------------------------------------------------------------------
install_oh_my_zsh() {
  local omz_dir="${ZSH:-$HOME/.oh-my-zsh}"

  if [ -d "$omz_dir" ]; then
    log_info "Oh My Zsh is already installed at ${omz_dir}."
  else
    log_info "Installing Oh My Zsh via official unattended installer..."
    local omz_install_url="https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh"

    if command -v curl >/dev/null 2>&1; then
      RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL "$omz_install_url")" "" --unattended --keep-zshrc
    elif command -v wget >/dev/null 2>&1; then
      RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(wget -O- "$omz_install_url")" "" --unattended --keep-zshrc
    else
      log_error "Neither curl nor wget is available to download Oh My Zsh."
      exit 1
    fi
    log_success "Oh My Zsh installed successfully."
  fi

  # Ensure ~/.zshrc exists
  if [ ! -f "$HOME/.zshrc" ]; then
    if [ -f "$omz_dir/templates/zshrc.zsh-template" ]; then
      log_info "Creating default ~/.zshrc from template..."
      cp "$omz_dir/templates/zshrc.zsh-template" "$HOME/.zshrc"
    else
      touch "$HOME/.zshrc"
    fi
  fi
}

# ------------------------------------------------------------------------------
# 4. Deploy Custom santiagus Theme
# ------------------------------------------------------------------------------
deploy_theme() {
  local custom_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  local target_dir="${custom_dir}/themes"
  local source_theme="${SCRIPT_DIR}/themes/santiagus.zsh-theme"
  local target_theme="${target_dir}/santiagus.zsh-theme"

  if [ ! -f "$source_theme" ]; then
    log_error "Custom theme not found at ${source_theme}!"
    exit 1
  fi

  log_info "Deploying custom santiagus theme to ${target_theme}..."
  mkdir -p "$target_dir"
  cp "$source_theme" "$target_theme"
  log_success "Theme deployed to Oh My Zsh custom themes directory."
}

# ------------------------------------------------------------------------------
# 5. Configure ZSH_THEME in ~/.zshrc
# ------------------------------------------------------------------------------
configure_theme() {
  local zshrc="$HOME/.zshrc"
  log_info "Configuring ZSH_THEME=\"santiagus\" in ${zshrc}..."

  local tmp_file
  tmp_file="$(mktemp "${zshrc}.tmp.XXXXXX")"

  awk '
  BEGIN {
      theme_inserted = 0
      already_santiagus = 0
  }
  # If already set to santiagus (uncommented), keep it as is
  /^[[:space:]]*ZSH_THEME=["'\''"]santiagus["'\''"]/ {
      already_santiagus = 1
      print $0
      next
  }
  # Comment any active (uncommented) ZSH_THEME line and set santiagus
  /^[[:space:]]*ZSH_THEME=/ {
      if (!already_santiagus && !theme_inserted) {
          print "ZSH_THEME=\"santiagus\""
          theme_inserted = 1
      }
      print "# " $0
      next
  }
  # Keep all other lines intact
  {
      print $0
  }
  END {
      # If no ZSH_THEME declaration was present, add it at the end
      if (!already_santiagus && !theme_inserted) {
          print "ZSH_THEME=\"santiagus\""
      }
  }
  ' "$zshrc" > "$tmp_file"

  mv "$tmp_file" "$zshrc"
  log_success "Theme configured: ZSH_THEME=\"santiagus\""
}

# ------------------------------------------------------------------------------
# 6. Set Zsh as Default Shell
# ------------------------------------------------------------------------------
set_default_shell() {
  local current_shell
  current_shell="$(basename "${SHELL:-}")"

  if [ "$current_shell" = "zsh" ]; then
    log_info "Default shell is already zsh (${SHELL})."
    return 0
  fi

  local zsh_bin
  zsh_bin="$(command -v zsh || true)"
  if [ -z "$zsh_bin" ]; then
    log_warn "zsh binary not found; unable to set as default shell."
    return 0
  fi

  log_info "Configuring default shell to ${zsh_bin}..."

  # Check /etc/shells
  if [ -f /etc/shells ] && ! grep -qxF "$zsh_bin" /etc/shells; then
    log_info "Adding ${zsh_bin} to /etc/shells..."
    if [ "${EUID:-$(id -u)}" -eq 0 ]; then
      echo "$zsh_bin" >> /etc/shells
    elif command -v sudo >/dev/null 2>&1; then
      echo "$zsh_bin" | sudo tee -a /etc/shells >/dev/null || true
    fi
  fi

  local switched=false
  if chsh -s "$zsh_bin" "$USER" 2>/dev/null; then
    switched=true
  elif chsh -s "$zsh_bin" 2>/dev/null; then
    switched=true
  elif command -v sudo >/dev/null 2>&1 && sudo chsh -s "$zsh_bin" "$USER" 2>/dev/null; then
    switched=true
  fi

  if [ "$switched" = true ]; then
    log_success "Default shell successfully changed to ${zsh_bin}."
  else
    log_warn "Automatic shell change requires user password or root permissions."
    log_warn "Please run this command manually to set zsh as default:"
    printf "    chsh -s %s\n" "$zsh_bin"
  fi
}

# ------------------------------------------------------------------------------
# Main Execution
# ------------------------------------------------------------------------------
main() {
  printf "${BOLD}${GREEN}====================================================${RESET}\n"
  printf "${BOLD}${GREEN}        Oh My Zsh & santiagus Theme Setup           ${RESET}\n"
  printf "${BOLD}${GREEN}====================================================${RESET}\n\n"

  ensure_dependencies
  backup_existing_config
  install_oh_my_zsh
  deploy_theme
  configure_theme
  set_default_shell

  printf "\n${BOLD}${GREEN}====================================================${RESET}\n"
  printf "${BOLD}${GREEN}               Installation Complete!               ${RESET}\n"
  printf "${BOLD}${GREEN}====================================================${RESET}\n\n"
  log_success "Your custom Zsh environment is ready."
  printf "To start using it immediately, run:\n"
  printf "    ${BOLD}exec zsh${RESET}\n\n"
}

main "$@"
