# Copyright (c) 2025 Caleb Ephrem
# Licensed under the MIT License
# Quantum Theme for ZSH

if [[ -f "$HOME/.quantumrc" ]]; then
  source "$HOME/.quantumrc"
elif [[ -f "${0:A:h}/.quantumrc" ]]; then
  source "${0:A:h}/.quantumrc"
fi

SEGMENTS=(${SEGMENTS:-dir git_status})
PROMPT_SYMBOL="${PROMPT_SYMBOL:-»}"
GIT_BRANCH_SYMBOL="${GIT_BRANCH_SYMBOL:- }"
GIT_DETACHED_SYMBOL="${GIT_DETACHED_SYMBOL:-@}"
GIT_DIRTY_SYMBOL="${GIT_DIRTY_SYMBOL:-✗}"
GIT_CLEAN_SYMBOL="${GIT_CLEAN_SYMBOL:-}"
GIT_AHEAD_SYMBOL="${GIT_AHEAD_SYMBOL:-↑}"
GIT_BEHIND_SYMBOL="${GIT_BEHIND_SYMBOL:-↓}"

COLOR_DIR="${COLOR_DIR:-cyan}"
COLOR_BRANCH="${COLOR_BRANCH:-yellow}"
COLOR_DETACHED="${COLOR_DETACHED:-red}"
COLOR_ARROW="${COLOR_ARROW:-green}"
COLOR_DIRTY="${COLOR_DIRTY:-red}"
COLOR_CLEAN="${COLOR_CLEAN:-green}"
COLOR_VENV="${COLOR_VENV:-blue}"
COLOR_USER="${COLOR_USER:-magenta}"
COLOR_HOST="${COLOR_HOST:-white}"
COLOR_TIME="${COLOR_TIME:-white}"
COLOR_EXIT_OK="${COLOR_EXIT_OK:-green}"
COLOR_EXIT_FAIL="${COLOR_EXIT_FAIL:-red}"

DIR_STYLE="${DIR_STYLE:-name}"
GIT_SHOW_DIRTY="${GIT_SHOW_DIRTY:-true}"
GIT_SHOW_AHEAD_BEHIND="${GIT_SHOW_AHEAD_BEHIND:-false}"
SHOW_VENV="${SHOW_VENV:-true}"
SHOW_EXIT_CODE="${SHOW_EXIT_CODE:-false}"
SHOW_USER="${SHOW_USER:-false}"
SHOW_HOST="${SHOW_HOST:-false}"
SHOW_TIME="${SHOW_TIME:-false}"
NEWLINE_BEFORE_PROMPT="${NEWLINE_BEFORE_PROMPT:-false}"
PROMPT_BOLD="${PROMPT_BOLD:-false}"

export LS_COLORS="di=01;34:fi=01;33:*.zip=01;32:*.tar=01;32:*.gz=01;32:*.xz=01;32:*.bz2=01;32:*.7z=01;32:*.rar=01;32:*.exe=01;35:*.msi=01;35:*.dat=01;35:*.run=01;35:*.out=01;35:*.bin=01;35:*.elf=01;35:*.sh=01;35"

# Map color name to ANSI code
_qtm_ansi() {
  local color="$1"
  local bold="${2:-1}"
  case "$color" in
    black)   printf "\e[${bold};30m" ;;
    red)     printf "\e[${bold};31m" ;;
    green)   printf "\e[${bold};32m" ;;
    yellow)  printf "\e[${bold};33m" ;;
    blue)    printf "\e[${bold};34m" ;;
    magenta) printf "\e[${bold};35m" ;;
    cyan)    printf "\e[${bold};36m" ;;
    white)   printf "\e[${bold};37m" ;;
    *)       printf "\e[${bold};37m" ;;
  esac
}

_qtm_reset() { printf "\e[0m"; }

function _qtm_seg_dir() {
  local c="$(_qtm_ansi $COLOR_DIR)"
  local r="$(_qtm_reset)"
  case "$DIR_STYLE" in
    full)
      printf "%s%s%s" "$c" "$PWD" "$r"
      ;;
    short)
      printf "%s%s%s" "$c" "${${PWD/#$HOME/~}}" "$r"
      ;;
    name|*)
      if [[ "$PWD" == "$HOME" ]]; then
        printf "%s~%s" "$c" "$r"
      elif [[ "$PWD" == "/" ]]; then
        printf "%s/%s" "$c" "$r"
      else
        printf "%s%s%s" "$c" "${PWD##*/}" "$r"
      fi
      ;;
  esac
}

function _qtm_seg_git_status() {
  git rev-parse --is-inside-work-tree &>/dev/null || return

  local ca="$(_qtm_ansi $COLOR_ARROW)"
  local cb="$(_qtm_ansi $COLOR_BRANCH)"
  local cd="$(_qtm_ansi $COLOR_DETACHED)"
  local cdirty="$(_qtm_ansi $COLOR_DIRTY)"
  local cclean="$(_qtm_ansi $COLOR_CLEAN)"
  local r="$(_qtm_reset)"
  local ref
  ref=$(git symbolic-ref --quiet HEAD 2>/dev/null)

  local dirty_str=""
  if [[ "$GIT_SHOW_DIRTY" == "true" ]]; then
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
      dirty_str=" ${cdirty}${GIT_DIRTY_SYMBOL}${r}"
    elif [[ -n "$GIT_CLEAN_SYMBOL" ]]; then
      dirty_str=" ${cclean}${GIT_CLEAN_SYMBOL}${r}"
    fi
  fi

  local ahead_behind_str=""
  if [[ "$GIT_SHOW_AHEAD_BEHIND" == "true" ]]; then
    local upstream
    upstream=$(git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
    if [[ -n "$upstream" ]]; then
      local ahead behind
      ahead=$(git rev-list --count @{u}..HEAD 2>/dev/null)
      behind=$(git rev-list --count HEAD..@{u} 2>/dev/null)
      [[ "$ahead" -gt 0 ]] && ahead_behind_str+=" ${cclean}${GIT_AHEAD_SYMBOL}${ahead}${r}"
      [[ "$behind" -gt 0 ]] && ahead_behind_str+=" ${cdirty}${GIT_BEHIND_SYMBOL}${behind}${r}"
    fi
  fi

  if [[ -n "$ref" ]]; then
    local branch="${ref##refs/heads/}"
    printf " %s%s%s %s%s%s%s%s%s" "$ca" "$PROMPT_SYMBOL" "$r" "$cb" "$GIT_BRANCH_SYMBOL" "$branch" "$r" "$dirty_str" "$ahead_behind_str"
  else
    local commit
    commit=$(git rev-parse --short HEAD 2>/dev/null)
    printf " %s%s%s %s%s%s%s%s" "$ca" "$PROMPT_SYMBOL" "$r" "$cd" "$commit" "$r" "$dirty_str" "$ahead_behind_str"
  fi
}

function _qtm_seg_venv() {
  [[ -z "$VIRTUAL_ENV" ]] && return
  local c="$(_qtm_ansi $COLOR_VENV)"
  local r="$(_qtm_reset)"
  printf "%s(%s)%s " "$c" "${VIRTUAL_ENV##*/}" "$r"
}

function _qtm_seg_user() {
  local c="$(_qtm_ansi $COLOR_USER)"
  local r="$(_qtm_reset)"
  printf "%s%s%s" "$c" "$USER" "$r"
}

function _qtm_seg_host() {
  local c="$(_qtm_ansi $COLOR_HOST)"
  local r="$(_qtm_reset)"
  printf "%s%s%s" "$c" "$HOST" "$r"
}

function _qtm_seg_time() {
  local c="$(_qtm_ansi $COLOR_TIME)"
  local r="$(_qtm_reset)"
  printf "%s%s%s" "$c" "$(date +%H:%M:%S)" "$r"
}

function _qtm_seg_exit_code() {
  local code="$_qtm_last_exit"
  if [[ "$code" -eq 0 ]]; then
    printf "%s%s%s " "$(_qtm_ansi $COLOR_EXIT_OK)" "$code" "$(_qtm_reset)"
  else
    printf "%s%s%s " "$(_qtm_ansi $COLOR_EXIT_FAIL)" "$code" "$(_qtm_reset)"
  fi
}

function _qtm_build_prompt() {
  _qtm_last_exit=$?

  local out=""
  local ca="$(_qtm_ansi $COLOR_ARROW)"
  local r="$(_qtm_reset)"

  for seg in "${SEGMENTS[@]}"; do
    typeset -f "_qtm_seg_${seg}" &>/dev/null || continue
    out+="$(_qtm_seg_${seg})"
  done

  [[ "$NEWLINE_BEFORE_PROMPT" == "true" ]] && out=$'\n'"${out}"

  PROMPT="${out} ${ca}${PROMPT_SYMBOL}${r} "
}

precmd_functions+=(_qtm_build_prompt)