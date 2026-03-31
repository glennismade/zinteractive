#!/bin/zsh
# Zinteractive — Zsh shell adapter (ZLE widgets + keybindings)

# Palette widget — Ctrl+\
_zi_palette_widget() {
  local selected
  selected=$(_zi_fzf) || { zle reset-prompt; return; }
  local cmd
  cmd=$(_zi_extract_cmd "$selected")

  case "$cmd" in
    zi_cheats|zi_aliases)
      local sub_cmd
      sub_cmd=$("$cmd")
      [ -n "$sub_cmd" ] && LBUFFER="$sub_cmd "
      zle reset-prompt
      ;;
    zi_terminal)
      zi_terminal
      zle reset-prompt
      ;;
    *)
      if _zi_has_steps "$cmd"; then
        zle reset-prompt
        zi_run "$cmd"
      else
        LBUFFER="$cmd "
        zle reset-prompt
      fi
      ;;
  esac
}
zle -N _zi_palette_widget

# File picker widget — Ctrl+F
_zi_file_pick_widget() {
  local file
  file=$(zi_file_pick) || { zle reset-prompt; return; }
  LBUFFER="${LBUFFER}${file} "
  zle reset-prompt
}
zle -N _zi_file_pick_widget

# Branch picker widget — Ctrl+B
_zi_branch_pick_widget() {
  local branch
  branch=$(zi_branch_pick) || { zle reset-prompt; return; }
  LBUFFER="${LBUFFER}git checkout ${branch} "
  zle reset-prompt
}
zle -N _zi_branch_pick_widget

# Tmux widget — Ctrl+T
_zi_tmux_widget() {
  zi_tmux
  zle reset-prompt
}
zle -N _zi_tmux_widget

# Projects widget — Ctrl+P
_zi_projects_widget() {
  zi_projects
  zle reset-prompt
}
zle -N _zi_projects_widget

# Bind keys (respecting config)
[ "${ZI_BIND_PALETTE:-1}" = "1" ] && bindkey '^\' _zi_palette_widget
[ "${ZI_BIND_FILEPICK:-1}" = "1" ] && bindkey '^F' _zi_file_pick_widget
[ "${ZI_BIND_BRANCHPICK:-1}" = "1" ] && bindkey '^B' _zi_branch_pick_widget
[ "${ZI_BIND_TMUX:-1}" = "1" ] && bindkey '^T' _zi_tmux_widget
[ "${ZI_BIND_PROJECTS:-1}" = "1" ] && bindkey '^P' _zi_projects_widget

# Non-widget command for direct invocation
zinteractive() {
  case "${1:-}" in
    setup) _zi_setup ;;
    help)  zi_help "${2:-}" ;;
    *)     zi_palette ;;
  esac
}
