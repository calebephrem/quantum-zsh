#!/usr/bin/env bash
# Quantum Theme Installer
# Clones the theme into oh-my-zsh custom themes, sets up ~/.quantumrc,
# and installs the qtm CLI alias into ~/.zshrc.
# Safe to re-run; existing files are not overwritten without prompting.

set -euo pipefail

REPO_URL="https://github.com/calebephrem/quantum-zsh"
THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/quantum"
USER_RC="$HOME/.quantumrc"
ZSHRC="$HOME/.zshrc"

# Logging

log()  { printf "  %s\n" "$1"; }
ok()   { printf "  [ ok ] %s\n" "$1"; }
info() { printf "  [ .. ] %s\n" "$1"; }
warn() { printf "  [ warn ] %s\n" "$1"; }
err()  { printf "  [ error ] %s\n" "$1" >&2; }
fail() { err "$1"; exit 1; }

# ASCII art header

print_header() {
  printf "\n"
  printf "   ___  _  _  ___  _  _  ____  _  _  __  __\n"
  printf "  / _ \| || |/ _ \| \| ||_  _|| || ||  \/  |\n"
  printf " | (_) | || | (_) | .  | _|| |_|| || || |\/| |\n"
  printf "  \__\_|\\__/ \___/|_|\_||_____|\____|_|  |_|\n"
  printf "\n"
  printf "   ____  _  _  ____  __  __  ____\n"
  printf "  |_  _|| || || ===||  \/  ||  __|\n"
  printf "   _|| |_|| || |___ | |\/| || |___\n"
  printf "  |_____|\____||____||_|  |_||_____|\n"
  printf "\n"
}

# Dependency checks

check_deps() {
  info "checking dependencies"

  command -v git &>/dev/null || fail "git is not installed"
  command -v zsh &>/dev/null || fail "zsh is not installed"

  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    fail "oh-my-zsh not found. Install it first: https://ohmyz.sh"
  fi

  ok "dependencies satisfied"
}

# Clone or update the repo

install_theme() {
  if [[ -d "$THEME_DIR/.git" ]]; then
    warn "theme already installed at $THEME_DIR"
    printf "  reinstall (pull latest)? [y/N] "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      info "pulling latest changes"
      git -C "$THEME_DIR" pull --ff-only -q
      ok "theme updated"
    else
      log "skipping"
    fi
  else
    info "cloning quantum theme"
    mkdir -p "$(dirname "$THEME_DIR")"
    git clone --depth=1 -q "$REPO_URL" "$THEME_DIR"
    ok "cloned to $THEME_DIR"
  fi
}

# Copy default .quantumrc to ~ if not already there

install_rc() {
  local default_rc="$THEME_DIR/.quantumrc"

  if [[ ! -f "$default_rc" ]]; then
    warn "default .quantumrc not found in repo, skipping"
    return
  fi

  if [[ -f "$USER_RC" ]]; then
    warn "~/.quantumrc already exists, leaving it untouched"
  else
    info "creating ~/.quantumrc"
    cp "$default_rc" "$USER_RC"
    ok "created $USER_RC"
  fi
}

# Make cli.sh executable

prepare_cli() {
  local cli="$THEME_DIR/cli.sh"

  if [[ ! -f "$cli" ]]; then
    warn "cli.sh not found in $THEME_DIR, skipping"
    return
  fi

  chmod +x "$cli"
  ok "cli.sh is executable"
}

# Append qtm alias to ~/.zshrc if not already there

install_alias() {
  local cli="$THEME_DIR/cli.sh"
  local alias_line="alias qtm=\"source $cli\""

  if grep -qF "alias qtm=" "$ZSHRC" 2>/dev/null; then
    warn "qtm alias already present in $ZSHRC, skipping"
  else
    info "adding qtm alias to $ZSHRC"
    printf "\n# Quantum Theme CLI\n%s\n" "$alias_line" >> "$ZSHRC"
    ok "qtm alias added"
  fi
}

# Set ZSH_THEME in ~/.zshrc

configure_zshrc_theme() {
  if grep -q 'ZSH_THEME="quantum/quantum"' "$ZSHRC" 2>/dev/null; then
    warn "ZSH_THEME already set to quantum/quantum in $ZSHRC"
  else
    info "setting ZSH_THEME to quantum/quantum"
    if grep -q 'ZSH_THEME=' "$ZSHRC" 2>/dev/null; then
      local tmp
      tmp="$(mktemp)"
      sed 's|^ZSH_THEME=.*|ZSH_THEME="quantum/quantum"|' "$ZSHRC" > "$tmp" && mv "$tmp" "$ZSHRC"
    else
      printf '\nZSH_THEME="quantum/quantum"\n' >> "$ZSHRC"
    fi
    ok "ZSH_THEME set to quantum/quantum"
  fi
}

# Post-install instructions

print_done() {
  printf "\n"
  ok "installation complete"
  printf "\n"
  log "next steps:"
  log "  1. restart your shell:  exec zsh"
  log "  2. edit your config:    \$EDITOR ~/.quantumrc"
  log "  3. use the CLI:         qtm help"
  printf "\n"
}

# Main

print_header
check_deps
install_theme
install_rc
prepare_cli
install_alias
configure_zshrc_theme
print_done