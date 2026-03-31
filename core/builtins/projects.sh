#!/bin/sh
# Zinteractive — project picker (git repos with branch/tmux status)

zi_projects() {
  [ "$ZI_HAS_FZF" != "1" ] && echo "[zinteractive] fzf required" && return 1
  [ "$ZI_HAS_GIT" != "1" ] && echo "[zinteractive] git required" && return 1

  local project_dirs="${ZI_PROJECT_DIRS:-$HOME/Documents/GIT}"

  # Build tmux session lookup (path -> session name)
  local tmux_lookup=""
  if command -v tmux >/dev/null 2>&1; then
    tmux_lookup=$(tmux list-sessions -F '#{pane_current_path}|#{session_name}' 2>/dev/null)
  fi

  # Scan for git repos and build display lines
  local entries=""
  local IFS_SAVE="$IFS"
  IFS=':'
  for scan_dir in $project_dirs; do
    IFS="$IFS_SAVE"
    [ -d "$scan_dir" ] || continue
    local parent_label
    parent_label=$(basename "$scan_dir")

    for repo_dir in "$scan_dir"/*/; do
      [ -d "$repo_dir/.git" ] || continue
      local repo_path="${repo_dir%/}"
      local repo_name
      repo_name=$(basename "$repo_path")
      local branch
      branch=$(git -C "$repo_path" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "???")
      local commit_ts
      commit_ts=$(git -C "$repo_path" log -1 --format=%ct 2>/dev/null || echo "0")

      # Check for tmux session at this path
      local tmux_tag=""
      if [ -n "$tmux_lookup" ]; then
        local session_match
        session_match=$(echo "$tmux_lookup" | grep "^${repo_path}|" | head -1 | cut -d'|' -f2)
        [ -n "$session_match" ] && tmux_tag="[tmux: ${session_match}]"
      fi

      entries="${entries}${commit_ts}|${parent_label}|${repo_name}|${branch}|${tmux_tag}|${repo_path}
"
    done
  done
  IFS="$IFS_SAVE"

  if [ -z "$entries" ]; then
    echo "[zinteractive] No git repos found in $project_dirs"
    return 1
  fi

  # Sort by commit timestamp (descending), format for display
  # Embed path as tab-separated last field (hidden from display via --with-nth)
  local display
  display=$(printf '%s' "$entries" | sort -t'|' -k1 -nr | while IFS='|' read -r ts parent name branch tmux_session path; do
    [ -z "$name" ] && continue
    printf '[%-10s] %-24s %-20s %s\t%s\n' "$parent" "$name" "$branch" "$tmux_session" "$path"
  done)

  local selected
  selected=$(echo "$display" | fzf \
    --delimiter='\t' \
    --with-nth=1 \
    --header=$'  enter=cd \u2502 ctrl-t=cd+tmux \u2502 esc=cancel\n' \
    --header-first \
    --border=rounded \
    --border-label=" Projects " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --pointer="▶" \
    --marker="●" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS:-default}" \
    --preview='git -C {2} log --oneline --color=always --decorate -15' \
    --preview-window=right:50%:wrap:border-left \
    --preview-label=" Recent Commits " \
    --preview-label-pos=2 \
    --expect=ctrl-t)

  [ -z "$selected" ] && return 0

  local key
  key=$(echo "$selected" | head -1)
  local line
  line=$(echo "$selected" | tail -n +2)
  [ -z "$line" ] && return 0

  # Extract path from hidden tab-separated field
  local target_path
  target_path=$(printf '%s' "$line" | cut -f2)
  local project_name
  project_name=$(basename "$target_path")

  [ -z "$target_path" ] || [ ! -d "$target_path" ] && echo "[zinteractive] Could not find project path" && return 1

  case "$key" in
    ctrl-t)
      cd "$target_path" || return 1
      echo "[zinteractive] cd $target_path"
      if command -v tmux >/dev/null 2>&1; then
        local sess_name="$project_name"
        if tmux has-session -t "$sess_name" 2>/dev/null; then
          if [ -n "$TMUX" ]; then
            tmux switch-client -t "$sess_name"
          else
            tmux attach -t "$sess_name"
          fi
        else
          if [ -n "$TMUX" ]; then
            tmux new-session -d -s "$sess_name" -c "$target_path" && tmux switch-client -t "$sess_name"
          else
            tmux new-session -s "$sess_name" -c "$target_path"
          fi
        fi
      fi
      ;;
    *)
      cd "$target_path" || return 1
      echo "[zinteractive] cd $target_path"
      ;;
  esac
}
