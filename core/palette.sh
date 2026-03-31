#!/bin/sh
# Zinteractive — command palette builder

_zi_help_items() {
  local c="$ZI_COLOR_CAT"
  local n="$ZI_COLOR_CMD"
  local d="$ZI_COLOR_DESC"
  local r="$ZI_RESET"
  local file first_line cat_name desc_text in_fm cmd_name tag line

  for file in "$ZI_HELP_DIR"/*.md; do
    [ -f "$file" ] || continue

    first_line=$(head -1 "$file")
    [ "$first_line" = "---" ] || continue

    cat_name="" desc_text="" in_fm=0
    while IFS= read -r line; do
      case "$line" in
        "---")
          in_fm=$((in_fm + 1))
          [ "$in_fm" -gt 1 ] && break
          ;;
        category:*) cat_name="${line#category: }" ;;
        description:*) desc_text="${line#description: }" ;;
      esac
    done < "$file"

    [ -z "$cat_name" ] || [ -z "$desc_text" ] && continue

    cmd_name=$(basename "$file" .md)
    tag="[${cat_name}]"
    printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "$cmd_name" "$desc_text"
  done
}

_zi_registered_items() {
  local c="$ZI_COLOR_CAT"
  local n="$ZI_COLOR_CMD"
  local d="$ZI_COLOR_DESC"
  local r="$ZI_RESET"

  _zi_get_registered | while IFS='|' read -r name desc category; do
    [ -z "$name" ] && continue
    local tag="[${category}]"
    printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "$name" "$desc"
  done
}

_zi_items() {
  local c="$ZI_COLOR_CAT" n="$ZI_COLOR_CMD" d="$ZI_COLOR_DESC" r="$ZI_RESET"
  local all_items known_pattern

  # Collect items, excluding Terminal (moved to submenu)
  all_items=$(_zi_help_items; _zi_registered_items)

  # Filter out Alias and Terminal categories — they get submenus
  local filtered_items
  filtered_items=$(printf '%s\n' "$all_items" | grep -v '\[Alias\]' | grep -v '\[Terminal\]')

  # Add submenu entries
  local cheat_count terminal_count alias_count

  cheat_count=$(_zi_cheat_items 2>/dev/null | wc -l | tr -d ' ')
  [ "$cheat_count" -gt 0 ] 2>/dev/null && filtered_items="${filtered_items}
$(printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}" "[Cheat]" "zi_cheats" "Browse ${cheat_count} cheatsheets...")"

  terminal_count=$(_zi_terminal_items 2>/dev/null | wc -l | tr -d ' ')
  [ "$terminal_count" -gt 0 ] 2>/dev/null && filtered_items="${filtered_items}
$(printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}" "[Terminal]" "zi_terminal" "Browse ${terminal_count} shortcuts...")"

  alias_count=$(printf '%s\n' "$all_items" | grep -c '\[Alias\]')
  [ "$alias_count" -gt 0 ] 2>/dev/null && filtered_items="${filtered_items}
$(printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}" "[Alias]" "zi_aliases" "Browse ${alias_count} aliases...")"

  for group in General Workflow Git Nav Picker Brew Tmux Projects "AWS/Infra" Dev Cheat Terminal Alias Custom; do
    printf '%s\n' "$filtered_items" | grep "\[${group}" | sort -t']' -k2
  done

  # Any categories not in the predefined order
  known_pattern="General\|Workflow\|Git\|Nav\|Picker\|Brew\|Tmux\|Projects\|Alias\|AWS/Infra\|Dev\|Cheat\|Terminal\|Custom"
  printf '%s\n' "$filtered_items" | grep -v "\[${known_pattern}" | grep -v '^$' | sort -t']' -k2
}

_zi_strip_ansi() {
  sed 's/\x1b\[[0-9;]*m//g'
}

_zi_fzf() {
  [ "${ZI_HAS_FZF:-0}" = "0" ] && echo "[zinteractive] fzf required for palette" && return 1

  _zi_items | fzf \
    --header=$'  type to filter \u2502 enter to run \u2502 esc to close\n' \
    --header-first \
    --border=rounded \
    --border-label=" Zinteractive " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --tiebreak=index \
    --pointer="▶" \
    --marker="●" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS:-default}" \
    --preview="line=\$(echo {} | sed 's/\x1b\[[0-9;]*m//g'); cmd=\$(echo \"\$line\" | awk '{print \$2}'); desc=\$(echo \"\$line\" | awk '{\$1=\"\"; \$2=\"\"; sub(/^  +/,\"\"); print}'); f=\"${ZI_HELP_DIR}/\${cmd}.md\"; if test -f \"\$f\"; then bat --style=numbers,grid --color=always --language=markdown --wrap=auto --terminal-width=58 --line-range=:50 \"\$f\" 2>/dev/null || cat -n \"\$f\"; else printf '\033[1;35m%s\033[0m\n\n%s\n\n\033[90mRegistered command — no help file.\nCreate %s/%s.md to add docs.\033[0m\n' \"\$cmd\" \"\$desc\" \"${ZI_HELP_DIR}\" \"\$cmd\"; fi" \
    --ansi \
    --preview-window=right:50%:wrap:border-left \
    --preview-label=" Help " \
    --preview-label-pos=2
}

_zi_extract_cmd() {
  echo "$1" | _zi_strip_ansi | awk '{print $2}'
}

_zi_has_steps() {
  local name="$1"
  local helpfile="$ZI_HELP_DIR/$name.md"
  [ -f "$helpfile" ] && sed -n '2,/^---$/p' "$helpfile" | grep -q '^steps:'
}

zi_terminal() {
  [ "${ZI_HAS_FZF:-0}" = "0" ] && echo "[zinteractive] fzf required" && return 1

  local selected
  selected=$(_zi_terminal_items 2>/dev/null | fzf \
    --header=$'  terminal shortcuts \u2502 esc to go back\n' \
    --header-first \
    --border=rounded \
    --border-label=" Terminal Shortcuts " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --no-sort \
    --pointer="▶" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS_ALT:-default}" \
    --ansi \
    --no-preview)
  # Terminal shortcuts are reference-only, nothing to return
}

zi_aliases() {
  [ "${ZI_HAS_FZF:-0}" = "0" ] && echo "[zinteractive] fzf required" && return 1

  local all_items
  all_items=$(_zi_help_items; _zi_registered_items)
  local alias_items
  alias_items=$(printf '%s\n' "$all_items" | grep '\[Alias\]')

  local selected
  selected=$(printf '%s\n' "$alias_items" | fzf \
    --header=$'  enter to insert \u2502 esc to go back\n' \
    --header-first \
    --border=rounded \
    --border-label=" Aliases " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --no-sort \
    --pointer="▶" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS_ALT:-default}" \
    --ansi \
    --no-preview)

  [ -z "$selected" ] && return
  local cmd
  cmd=$(echo "$selected" | _zi_strip_ansi | awk '{print $2}')
  echo "$cmd"
}

zi_cheats() {
  [ "${ZI_HAS_FZF:-0}" = "0" ] && echo "[zinteractive] fzf required" && return 1

  local selected
  selected=$(_zi_cheat_items 2>/dev/null | fzf \
    --header=$'  type to filter \u2502 enter to insert \u2502 esc to go back\n' \
    --header-first \
    --border=rounded \
    --border-label=" Cheatsheets " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --no-sort \
    --pointer="▶" \
    --marker="●" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS_ALT:-default}" \
    --ansi \
    --preview='echo {} | sed "s/\x1b\[[0-9;]*m//g" | awk "{for(i=3;i<=NF;i++) printf \"%s \", \$i; print \"\"}" | fold -s -w 60' \
    --preview-window=right:40%:wrap:border-left \
    --preview-label=" Command " \
    --preview-label-pos=2)

  [ -z "$selected" ] && return

  # Extract the full command (field 2 = truncated cmd, but we need to match back)
  # For now, return the truncated command for insertion
  local cmd
  cmd=$(echo "$selected" | _zi_strip_ansi | awk '{print $2}')
  echo "$cmd"
}

zi_palette() {
  local selected
  selected=$(_zi_fzf) || return
  local cmd
  cmd=$(_zi_extract_cmd "$selected")

  case "$cmd" in
    zi_cheats)   zi_cheats ;;
    zi_terminal) zi_terminal ;;
    zi_aliases)  zi_aliases ;;
    *)
      if _zi_has_steps "$cmd"; then
        zi_run "$cmd"
      elif type "$cmd" >/dev/null 2>&1; then
        "$cmd"
      else
        echo "Unknown command: $cmd"
      fi
      ;;
  esac
}
