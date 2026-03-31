#!/bin/sh
# Zinteractive — tmux session manager

_zi_tmux_check() {
  if ! command -v tmux >/dev/null 2>&1; then
    echo "[zinteractive] tmux not found"
    echo "[zinteractive] Install: brew install tmux"
    return 1
  fi
}

# fzf-based input prompt (works from ZLE widgets unlike read)
_zi_tmux_input() {
  local label="$1"
  local header="$2"
  printf '' | fzf \
    --print-query \
    --header="$header" \
    --header-first \
    --border=rounded \
    --border-label=" $label " \
    --border-label-pos=2 \
    --margin=8,20 \
    --padding=1,2 \
    --pointer="▶" \
    --prompt="  " \
    --separator="─" \
    --info=hidden \
    --color="${ZI_FZF_COLORS_ALT:-default}" \
    --no-preview | head -1
}

# fzf-based yes/no confirm (works from ZLE widgets unlike read)
_zi_tmux_confirm() {
  local message="$1"
  local choice
  choice=$(printf 'Yes\nNo' | fzf \
    --header="$message" \
    --header-first \
    --border=rounded \
    --border-label=" Confirm " \
    --border-label-pos=2 \
    --margin=8,20 \
    --padding=1,2 \
    --pointer="▶" \
    --prompt="  " \
    --separator="─" \
    --info=hidden \
    --color="${ZI_FZF_COLORS_ALT:-default}" \
    --no-preview \
    --no-sort)
  [ "$choice" = "Yes" ]
}

zi_tmux() {
  _zi_tmux_check || return 1
  [ "$ZI_HAS_FZF" != "1" ] && echo "[zinteractive] fzf required" && return 1

  local sessions
  sessions=$(tmux list-sessions -F '#{session_name}|#{?session_attached,attached,detached}|#{session_windows}|#{pane_current_path}' 2>/dev/null)

  if [ -z "$sessions" ]; then
    _zi_tmux_new
    return
  fi

  local list
  list=$(echo "$sessions" | while IFS='|' read -r sess_name sess_state windows path; do
    local win_label="windows"
    [ "$windows" = "1" ] && win_label="window"
    printf '%-20s [%-8s]  %s %s   %s\n' "$sess_name" "$sess_state" "$windows" "$win_label" "$path"
  done)

  local selected
  selected=$(echo "$list" | fzf \
    --header=$'  enter=attach \u2502 ctrl-n=new \u2502 ctrl-x=kill \u2502 esc=cancel\n' \
    --header-first \
    --border=rounded \
    --border-label=" Tmux Sessions " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --pointer="▶" \
    --marker="●" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS:-default}" \
    --preview='tmux list-windows -t $(echo {} | awk "{print \$1}") 2>/dev/null || echo "No windows"' \
    --preview-window=right:50%:wrap:border-left \
    --preview-label=" Windows " \
    --preview-label-pos=2 \
    --expect=ctrl-n,ctrl-x)

  [ -z "$selected" ] && return 0

  local key
  key=$(echo "$selected" | head -1)
  local session_name
  session_name=$(echo "$selected" | tail -n +2 | awk '{print $1}')

  case "$key" in
    ctrl-n)
      _zi_tmux_new
      ;;
    ctrl-x)
      [ -z "$session_name" ] && return 0
      if _zi_tmux_confirm "Kill session '$session_name'?"; then
        tmux kill-session -t "$session_name"
        echo "[zinteractive] Killed session: $session_name"
      else
        echo "[zinteractive] Aborted"
      fi
      ;;
    *)
      [ -z "$session_name" ] && return 0
      if [ -n "$TMUX" ]; then
        tmux switch-client -t "$session_name"
      else
        tmux attach -t "$session_name"
      fi
      ;;
  esac
}

_zi_tmux_new() {
  local name
  name=$(_zi_tmux_input "New Session" "Type a session name and press enter")
  [ -z "$name" ] && echo "[zinteractive] Aborted" && return 1
  if [ -n "$TMUX" ]; then
    tmux new-session -d -s "$name" && tmux switch-client -t "$name"
  else
    tmux new-session -s "$name"
  fi
}
