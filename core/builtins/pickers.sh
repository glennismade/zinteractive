#!/bin/sh
# Zinteractive — reusable picker primitives

zi_file_pick() {
  if [ "$ZI_HAS_FZF" != "1" ]; then
    echo "[zinteractive] fzf required" >&2; return 1
  fi

  local preview_cmd='cat {}'
  [ "$ZI_HAS_BAT" = "1" ] && preview_cmd='bat --style=numbers,grid --color=always --line-range=:50 {}'

  local source_cmd='find . -type f -not -path "*/.git/*"'
  [ "$ZI_HAS_FD" = "1" ] && source_cmd='fd --type f --hidden --exclude .git'

  local selected
  selected=$(eval "$source_cmd" | fzf \
    --header=$'  enter to select \u2502 esc to cancel\n' \
    --header-first \
    --border=rounded \
    --border-label=" Files " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --pointer="▶" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS_ALT:-default}" \
    --preview="$preview_cmd" \
    --preview-window=right:55%:wrap:border-left \
    --preview-label=" Preview " \
    --preview-label-pos=2)

  [ -z "$selected" ] && return 1
  printf '%s\n' "$selected"
}

zi_branch_pick() {
  if [ "$ZI_HAS_GIT" != "1" ]; then
    echo "[zinteractive] git required" >&2; return 1
  fi
  if [ "$ZI_HAS_FZF" != "1" ]; then
    echo "[zinteractive] fzf required" >&2; return 1
  fi
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo "[zinteractive] Not inside a git repository" >&2; return 1
  }

  local selected
  selected=$(git branch --format='%(refname:short)' | fzf \
    --header=$'  enter to select \u2502 esc to cancel\n' \
    --header-first \
    --border=rounded \
    --border-label=" Branches " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --pointer="▶" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS:-default}" \
    --ansi \
    --preview='git log --oneline --color=always --decorate -20 {}' \
    --preview-window=right:55%:wrap:border-left \
    --preview-label=" Log " \
    --preview-label-pos=2)

  [ -z "$selected" ] && return 1
  printf '%s\n' "$selected"
}

zi_dir_pick() {
  if [ "$ZI_HAS_FZF" != "1" ]; then
    echo "[zinteractive] fzf required" >&2; return 1
  fi

  local source_cmd='find . -type d -not -path "*/.git/*" -maxdepth 4'
  [ "$ZI_HAS_ZOXIDE" = "1" ] && source_cmd='zoxide query -l'

  local selected
  selected=$(eval "$source_cmd" | fzf \
    --header=$'  enter to select \u2502 esc to cancel\n' \
    --header-first \
    --border=rounded \
    --border-label=" Directories " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --pointer="▶" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS_ALT:-default}" \
    --preview='ls -la --color=always {} 2>/dev/null' \
    --preview-window=right:50%:wrap:border-left \
    --preview-label=" Contents " \
    --preview-label-pos=2)

  [ -z "$selected" ] && return 1
  printf '%s\n' "$selected"
}
