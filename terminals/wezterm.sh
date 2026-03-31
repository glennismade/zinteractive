#!/bin/sh
# Zinteractive — WezTerm terminal shortcuts
_zi_terminal_items() {
  local c="$ZI_COLOR_CAT" n="$ZI_COLOR_CMD" d="$ZI_COLOR_DESC" r="$ZI_RESET"
  local tag="[Terminal]"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+N"     "New window"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+T"     "New tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+W"     "Close tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" 'Ctrl+Shift+"'     "Split vertical"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+%"     "Split horizontal"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+Arrow" "Nav panes"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+Z"     "Zoom pane"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Tab"         "Next tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+K"     "Clear"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+F"     "Search"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+,"     "Config"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Alt+Enter"        "Fullscreen"
}
