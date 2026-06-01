#!/usr/bin/env zsh
# Quantum Theme CLI
# Invoked via the `qtm` alias installed by install.sh.
# User config is read from and written to ~/.quantumrc.
# The repo default config lives alongside this script as .quantumrc.

QUANTUM_DIR="${0:A:h}"
USER_RC="$HOME/.quantumrc"
DEFAULT_RC="$QUANTUM_DIR/.quantumrc"
VERSION_FILE="$QUANTUM_DIR/.quantumver"

# Logging helpers

_qtm_log()  { printf "  %s\n" "$1" }
_qtm_ok()   { printf "  [ ok ] %s\n" "$1" }
_qtm_err()  { printf "  [ error ] %s\n" "$1" >&2 }
_qtm_warn() { printf "  [ warn ] %s\n" "$1" }
_qtm_info() { printf "  [ .. ] %s\n" "$1" }

# Ensure ~/.quantumrc exists, copy from repo default if not

_qtm_ensure_rc() {
  if [[ ! -f "$USER_RC" ]]; then
    if [[ -f "$DEFAULT_RC" ]]; then
      cp "$DEFAULT_RC" "$USER_RC"
      _qtm_ok "created $USER_RC from defaults"
    else
      _qtm_err "default config not found at $DEFAULT_RC"
      return 1
    fi
  fi
}

# Read the active value of a key from ~/.quantumrc

_qtm_get_value() {
  local key="$1"
  grep -m1 "^${key}=" "$USER_RC" 2>/dev/null | cut -d'=' -f2-
}

# qtm set KEY value

_qtm_cmd_set() {
  local key="$1"
  local val="$2"

  if [[ -z "$key" || -z "$val" ]]; then
    _qtm_err "usage: qtm set <KEY> <value>"
    _qtm_err "example: qtm set COLOR_DIR magenta"
    return 1
  fi

  _qtm_ensure_rc || return 1

  local tmp
  tmp="$(mktemp)"

  if grep -q "^${key}=" "$USER_RC"; then
    sed "s|^${key}=.*|${key}=${val}|" "$USER_RC" > "$tmp" && mv "$tmp" "$USER_RC"
  else
    echo "${key}=${val}" >> "$USER_RC"
    rm -f "$tmp"
  fi

  _qtm_ok "set ${key} = ${val}"
  _qtm_warn "run 'qtm reload' to apply changes"
}

# qtm get KEY

_qtm_cmd_get() {
  local key="$1"

  if [[ -z "$key" ]]; then
    _qtm_err "usage: qtm get <KEY>"
    return 1
  fi

  _qtm_ensure_rc || return 1

  local val
  val="$(_qtm_get_value "$key")"

  if [[ -z "$val" ]]; then
    _qtm_warn "${key} is not set in $USER_RC"
  else
    _qtm_log "${key} = ${val}"
  fi
}

# qtm list

_qtm_cmd_list() {
  _qtm_ensure_rc || return 1

  printf "\n  Quantum Theme  —  %s\n\n" "$USER_RC"

  local groups=(
    "Segments:SEGMENTS"
    "Symbols:PROMPT_SYMBOL GIT_BRANCH_SYMBOL GIT_DETACHED_SYMBOL GIT_DIRTY_SYMBOL GIT_CLEAN_SYMBOL GIT_AHEAD_SYMBOL GIT_BEHIND_SYMBOL"
    "Colors:COLOR_DIR COLOR_BRANCH COLOR_DETACHED COLOR_ARROW COLOR_DIRTY COLOR_CLEAN COLOR_VENV COLOR_USER COLOR_HOST COLOR_TIME COLOR_EXIT_OK COLOR_EXIT_FAIL"
    "Display:DIR_STYLE GIT_SHOW_DIRTY GIT_SHOW_AHEAD_BEHIND SHOW_VENV SHOW_EXIT_CODE SHOW_USER SHOW_HOST SHOW_TIME NEWLINE_BEFORE_PROMPT PROMPT_BOLD"
  )

  for entry in "${groups[@]}"; do
    local section="${entry%%:*}"
    local keys="${entry#*:}"
    printf "  %s\n" "$section"
    for key in ${(z)keys}; do
      local val
      val="$(_qtm_get_value "$key")"
      [[ -z "$val" ]] && val="(not set)"
      printf "    %-28s %s\n" "$key" "$val"
    done
    printf "\n"
  done
}

# qtm reload

_qtm_cmd_reload() {
  _qtm_info "reloading shell"
  exec zsh -l
}

# qtm reset

_qtm_cmd_reset() {
  if [[ ! -f "$USER_RC" ]]; then
    _qtm_warn "no user config found at $USER_RC, nothing to reset"
    return 0
  fi

  printf "  reset ~/.quantumrc to defaults? this cannot be undone. [y/N] "
  read -r answer

  if [[ "$answer" =~ ^[Yy]$ ]]; then
    if [[ -f "$DEFAULT_RC" ]]; then
      cp "$DEFAULT_RC" "$USER_RC"
      _qtm_ok "config reset to defaults"
      _qtm_warn "run 'qtm reload' to apply"
    else
      _qtm_err "default config not found at $DEFAULT_RC"
      return 1
    fi
  else
    _qtm_log "reset cancelled"
  fi
}

# qtm update

_qtm_cmd_update() {
  if [[ ! -d "$QUANTUM_DIR/.git" ]]; then
    _qtm_err "theme directory is not a git repo: $QUANTUM_DIR"
    return 1
  fi

  _qtm_info "pulling latest changes"
  git -C "$QUANTUM_DIR" pull --ff-only -q
  _qtm_ok "theme updated"
  _qtm_warn "run 'qtm reload' to apply changes"
}

# qtm version / qtm -v

_qtm_cmd_version() {
  if [[ ! -f "$VERSION_FILE" ]]; then
    _qtm_err "version file not found at $VERSION_FILE"
    return 1
  fi

  local version
  version="$(cat "$VERSION_FILE")"
  _qtm_log "quantum theme $version"
}

# qtm help

_qtm_cmd_help() {
  printf "\n"
  printf "  Quantum Theme CLI\n"
  printf "\n"
  printf "  Usage: qtm <command> [args]\n"
  printf "\n"
  printf "  Commands:\n"
  printf "\n"
  printf "    set <KEY> <value>    set a config value in ~/.quantumrc\n"
  printf "    get <KEY>            print the current value of a key\n"
  printf "    list                 show all config values\n"
  printf "    reload               restart the shell to apply changes\n"
  printf "    reset                reset ~/.quantumrc to repo defaults\n"
  printf "    update               pull latest changes from github\n"
  printf "    -v, version          show the current theme version\n"
  printf "    help                 show this help text\n"
  printf "\n"
  printf "  Examples:\n"
  printf "\n"
  printf "    qtm set PROMPT_SYMBOL ->\n"
  printf "    qtm set COLOR_DIR magenta\n"
  printf "    qtm set SEGMENTS \"(dir git_status venv)\"\n"
  printf "    qtm set DIR_STYLE short\n"
  printf "    qtm set GIT_SHOW_DIRTY false\n"
  printf "    qtm get COLOR_ARROW\n"
  printf "    qtm list\n"
  printf "    qtm update\n"
  printf "    qtm -v\n"
  printf "\n"
  printf "  Config: ~/.quantumrc\n"
  printf "\n"
}

# Entry point

case "$1" in
  set)             shift; _qtm_cmd_set "$@" ;;
  get)             shift; _qtm_cmd_get "$@" ;;
  list)            _qtm_cmd_list ;;
  reload)          _qtm_cmd_reload ;;
  reset)           _qtm_cmd_reset ;;
  update)          _qtm_cmd_update ;;
  -v|version)      _qtm_cmd_version ;;
  help)            _qtm_cmd_help ;;
  "")              _qtm_cmd_help ;;
  *)
    _qtm_err "unknown command: $1"
    _qtm_cmd_help
    return 1
    ;;
esac