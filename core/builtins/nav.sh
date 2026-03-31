#!/bin/sh
# Zinteractive — built-in navigation functions

zi_go() {
  if [ "$ZI_HAS_ZOXIDE" != "1" ]; then
    echo "[zinteractive] zoxide not found — zi_go requires zoxide"
    return 1
  fi
  if [ "$ZI_HAS_FZF" != "1" ]; then
    echo "[zinteractive] fzf required for zi_go"
    return 1
  fi
  local dir
  dir=$(zoxide query -l | \
    fzf --prompt="Go to> " \
        --header="Select a directory" \
        --preview='ls -la --color=always {}' \
        --preview-window=right:50%)
  if [ -z "$dir" ]; then
    echo "[zinteractive] Aborted: no directory selected"
    return 1
  fi
  cd "$dir" || return 1
}

zi_mkcd() {
  local dir="$1"
  if [ -z "$dir" ]; then
    printf "Directory name: "
    read -r dir
  fi
  if [ -z "$dir" ]; then
    echo "[zinteractive] Aborted: no directory specified"
    return 1
  fi
  mkdir -p "$dir" && cd "$dir" || return 1
}

zi_ports() {
  echo "Listening ports:"
  lsof -iTCP -sTCP:LISTEN -n -P 2>/dev/null | \
    awk 'NR==1 || /LISTEN/ {printf "%-10s %-8s %-8s %s\n", $1, $2, $3, $9}' | \
    column -t
}

zi_kill_port() {
  local port="$1"
  if [ -z "$port" ]; then
    printf "Port number: "
    read -r port
  fi
  if [ -z "$port" ]; then
    echo "[zinteractive] Aborted: no port specified"
    return 1
  fi
  local pids
  pids=$(lsof -ti :"$port" 2>/dev/null)
  if [ -z "$pids" ]; then
    echo "[zinteractive] No process found on port $port"
    return 1
  fi
  echo "Process(es) on port $port:"
  echo "$pids" | while read -r pid; do
    local name
    name=$(ps -p "$pid" -o comm= 2>/dev/null || echo "unknown")
    printf "  PID %-8s %s\n" "$pid" "$name"
  done
  printf "Kill these process(es)? [y/N] "
  read -r answer
  case "$answer" in
    [yY]|[yY][eE][sS])
      echo "$pids" | xargs kill -9
      echo "[zinteractive] Killed process(es) on port $port"
      ;;
    *)
      echo "[zinteractive] Aborted"
      ;;
  esac
}
