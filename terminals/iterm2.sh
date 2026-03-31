#!/bin/sh
# Zinteractive — iTerm2 terminal shortcuts
_zi_terminal_items() {
  local c="$ZI_COLOR_CAT" n="$ZI_COLOR_CMD" d="$ZI_COLOR_DESC" r="$ZI_RESET"
  local tag="[Terminal]"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+N"           "New window"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+T"           "New tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+W"           "Close tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+D"           "Split vertical"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+Shift+D"     "Split horizontal"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+Opt+Arrow"   "Nav splits"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+Shift+Enter" "Max pane"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+1-9"         "Switch tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+K"           "Clear"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+F"           "Find"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+,"           "Preferences"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+Enter"       "Fullscreen"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+Shift+H"     "Paste history"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+;"           "Autocomplete"
}
