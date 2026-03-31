#!/bin/sh
# Zinteractive — navi .cheat file parser

_zi_cheat_dirs() {
  local dirs=""
  if [ -d "$HOME/.config/zinteractive/cheats" ]; then
    dirs="$HOME/.config/zinteractive/cheats"
  fi
  if [ -d "$ZI_HOME/cheats" ]; then
    dirs="${dirs:+$dirs }$ZI_HOME/cheats"
  fi
  if [ -d "$HOME/.local/share/navi/cheats" ]; then
    dirs="${dirs:+$dirs }$HOME/.local/share/navi/cheats"
  fi
  if [ -n "$ZI_CHEAT_DIRS" ]; then
    dirs="${dirs:+$dirs }$ZI_CHEAT_DIRS"
  fi
  echo "$dirs"
}

_zi_cheat_items() {
  local c="$ZI_COLOR_CAT"
  local n="$ZI_COLOR_CMD"
  local d="$ZI_COLOR_DESC"
  local r="$ZI_RESET"
  local tag="[Cheat]"

  local dirs
  dirs=$(_zi_cheat_dirs)
  [ -z "$dirs" ] && return

  local desc cmd short_cmd

  # Use find piped to a while loop that reads file paths,
  # then process each file in an inner loop
  echo "$dirs" | tr ' ' '\n' | while read -r dir; do
    [ -d "$dir" ] || continue
    find "$dir" -name "*.cheat" -type f 2>/dev/null
  done | while read -r file; do
    desc=""
    cmd=""
    while IFS= read -r line; do
      case "$line" in
        "% "*|"%"*)
          ;;
        "# "*)
          desc="${line#\# }"
          ;;
        "$ "*)
          ;;
        "")
          desc=""
          cmd=""
          ;;
        *)
          if [ -n "$desc" ]; then
            cmd="$line"
            short_cmd=$(printf '%.22s' "$cmd")
            printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "$short_cmd" "$desc"
            desc=""
            cmd=""
          fi
          ;;
      esac
    done < "$file"
  done
}

_zi_cheat_run() {
  local selected_cmd="$1"

  # Check for placeholders
  if echo "$selected_cmd" | grep -q '<[^>]*>'; then
    local resolved="$selected_cmd"
    local dirs
    dirs=$(_zi_cheat_dirs)

    # Extract all placeholders
    local placeholders
    placeholders=$(echo "$selected_cmd" | grep -o '<[^>]*>' | sort -u)

    for ph in $placeholders; do
      local var_name
      var_name=$(echo "$ph" | sed 's/^<//;s/>$//')

      # Search for $ variable definition in cheat files
      local var_cmd=""
      for dir in $dirs; do
        [ -n "$var_cmd" ] && break
        var_cmd=$(find "$dir" -name "*.cheat" -type f 2>/dev/null -exec grep -h "^\$ ${var_name}:" {} \; | head -1 | sed "s/^\$ ${var_name}: *//")
      done

      local value=""
      if [ -n "$var_cmd" ] && [ "${ZI_HAS_FZF:-0}" = "1" ]; then
        value=$(eval "$var_cmd" 2>/dev/null | fzf --header="Select ${var_name}:" --height=40%)
      fi

      if [ -z "$value" ]; then
        printf "Enter %s: " "$var_name"
        read -r value
      fi

      [ -z "$value" ] && echo "Cancelled." && return 1
      resolved=$(echo "$resolved" | sed "s|<${var_name}>|${value}|g")
    done

    echo "$resolved"
  else
    echo "$selected_cmd"
  fi
}
