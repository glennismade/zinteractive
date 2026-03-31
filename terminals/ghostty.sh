#!/bin/sh
# Zinteractive — Ghostty terminal shortcuts
_zi_terminal_items() {
  local c="$ZI_COLOR_CAT" n="$ZI_COLOR_CMD" d="$ZI_COLOR_DESC" r="$ZI_RESET"
  local tag="[Terminal]"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+N"          "New window"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+T"          "New tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+W"          "Close tab/split"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+D"          "Split right"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+Shift+D"    "Split down"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+]"          "Next split"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+["          "Previous split"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+Shift+Enter" "Toggle split zoom"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+1-9"        "Switch tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+K"          "Clear"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+F"          "Find"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+,"          "Config"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+Enter"      "Fullscreen"
}
