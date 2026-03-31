#!/bin/sh
# Zinteractive — Kitty terminal shortcuts
_zi_terminal_items() {
  local c="$ZI_COLOR_CAT" n="$ZI_COLOR_CMD" d="$ZI_COLOR_DESC" r="$ZI_RESET"
  local tag="[Terminal]"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+N"              "New OS window"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+T"              "New tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+W"              "Close tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Cmd+Enter"          "New split"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+]"       "Next window"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+["       "Prev window"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+Right"   "Next tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+Left"    "Prev tab"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+L"       "Next layout"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+F5"      "Reload config"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+F11"     "Fullscreen"
  printf "${c}%-11s${r} ${n}%-24s${r} ${d}%s${r}\n" "$tag" "Ctrl+Shift+Delete"  "Clear scrollback"
}
