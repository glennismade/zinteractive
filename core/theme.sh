#!/bin/sh
# Zinteractive — color theme presets

_zi_load_theme() {
  local theme="${ZI_THEME:-dracula}"
  ZI_RESET='\033[0m'

  # ANSI color numbers: 30=black 31=red 32=green 33=yellow 34=blue 35=magenta 36=cyan 37=white
  # fzf color names:  border, label, header, pointer, marker, prompt, info, hl, hl+, spinner

  case "$theme" in
    dracula)
      ZI_COLOR_CAT='\033[38;2;139;233;253m'   # dracula cyan #8be9fd
      ZI_COLOR_CMD='\033[38;2;189;147;249m'    # dracula purple #bd93f9
      ZI_COLOR_DESC='\033[38;2;248;248;242m'   # dracula fg #f8f8f2
      ZI_FZF_COLORS='border:#bd93f9,label:#bd93f9:bold,header:#8be9fd,pointer:#ff79c6,marker:#ff79c6,prompt:#8be9fd,info:#6272a4,hl:#ff79c6,hl+:#ff79c6:bold,spinner:#bd93f9'
      ZI_FZF_COLORS_ALT='border:#8be9fd,label:#8be9fd:bold,header:#bd93f9,pointer:#8be9fd,marker:#8be9fd,prompt:#bd93f9,info:#6272a4,hl:#8be9fd,hl+:#8be9fd:bold,spinner:#8be9fd'
      ;;
    catppuccin)
      ZI_COLOR_CAT='\033[34m'   # blue
      ZI_COLOR_CMD='\033[35m'   # magenta
      ZI_COLOR_DESC='\033[37m'  # white
      ZI_FZF_COLORS='border:34,label:34:bold,header:35,pointer:35,marker:35,prompt:34,info:90,hl:35,hl+:35:bold,spinner:35'
      ZI_FZF_COLORS_ALT='border:35,label:35:bold,header:34,pointer:35,marker:35,prompt:34,info:90,hl:35,hl+:35:bold,spinner:35'
      ;;
    nord)
      ZI_COLOR_CAT='\033[36m'   # cyan
      ZI_COLOR_CMD='\033[34m'   # blue
      ZI_COLOR_DESC='\033[37m'  # white
      ZI_FZF_COLORS='border:34,label:34:bold,header:36,pointer:34,marker:34,prompt:36,info:90,hl:34,hl+:34:bold,spinner:34'
      ZI_FZF_COLORS_ALT='border:36,label:36:bold,header:34,pointer:36,marker:36,prompt:34,info:90,hl:36,hl+:36:bold,spinner:36'
      ;;
    gruvbox)
      ZI_COLOR_CAT='\033[33m'   # yellow
      ZI_COLOR_CMD='\033[32m'   # green
      ZI_COLOR_DESC='\033[37m'  # white
      ZI_FZF_COLORS='border:33,label:33:bold,header:32,pointer:32,marker:32,prompt:33,info:90,hl:32,hl+:32:bold,spinner:32'
      ZI_FZF_COLORS_ALT='border:32,label:32:bold,header:33,pointer:32,marker:32,prompt:33,info:90,hl:32,hl+:32:bold,spinner:32'
      ;;
    plain)
      ZI_COLOR_CAT=''
      ZI_COLOR_CMD=''
      ZI_COLOR_DESC=''
      ZI_RESET=''
      ZI_FZF_COLORS=''
      ZI_FZF_COLORS_ALT=''
      ;;
    *)
      echo "[zinteractive] Unknown theme: $theme — using dracula"
      ZI_COLOR_CAT='\033[38;2;139;233;253m'
      ZI_COLOR_CMD='\033[38;2;189;147;249m'
      ZI_COLOR_DESC='\033[38;2;248;248;242m'
      ZI_FZF_COLORS='border:35,label:35:bold,header:36,pointer:35,marker:35,prompt:36,info:90,hl:35,hl+:35:bold,spinner:35'
      ZI_FZF_COLORS_ALT='border:36,label:36:bold,header:35,pointer:36,marker:36,prompt:35,info:90,hl:36,hl+:36:bold,spinner:36'
      ;;
  esac
}
