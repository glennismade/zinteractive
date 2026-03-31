#!/bin/sh
# Zinteractive — dependency checking

_zi_check_dep() {
  command -v "$1" >/dev/null 2>&1
}

_zi_check_deps() {
  ZI_HAS_FZF=0
  ZI_HAS_BAT=0
  ZI_HAS_GLOW=0
  ZI_HAS_ZOXIDE=0
  ZI_HAS_FD=0
  ZI_HAS_GIT=0
  ZI_HAS_EZA=0

  if _zi_check_dep fzf; then
    ZI_HAS_FZF=1
  else
    echo "[zinteractive] fzf is required but not found. Palette disabled."
    echo "[zinteractive] Install: https://github.com/junegunn/fzf"
  fi

  _zi_check_dep bat && ZI_HAS_BAT=1
  _zi_check_dep glow && ZI_HAS_GLOW=1
  _zi_check_dep zoxide && ZI_HAS_ZOXIDE=1
  _zi_check_dep git && ZI_HAS_GIT=1
  _zi_check_dep eza && ZI_HAS_EZA=1

  if _zi_check_dep fd; then
    ZI_HAS_FD=1
  elif _zi_check_dep fdfind; then
    ZI_HAS_FD=1
    alias fd=fdfind
  fi

  if [ "${ZI_QUIET:-0}" != "1" ]; then
    [ "$ZI_HAS_BAT" = "0" ] && echo "[zinteractive] bat not found — using cat for previews"
    [ "$ZI_HAS_ZOXIDE" = "0" ] && echo "[zinteractive] zoxide not found — directory navigation disabled"
  fi
}
