#!/bin/sh
# Zinteractive — Homebrew integration

_zi_brew_check() {
  if ! command -v brew >/dev/null 2>&1; then
    echo "[zinteractive] Homebrew not found"
    echo "[zinteractive] Install: https://brew.sh"
    return 1
  fi
}

zi_deps() {
  _zi_brew_check || return 1
  [ "$ZI_HAS_FZF" != "1" ] && echo "[zinteractive] fzf required" && return 1

  # Define deps: display_name|brew_package|required
  local deps="fzf|fzf|yes
bat|bat|no
glow|glow|no
zoxide|zoxide|no
fd|fd|no
eza|eza|no
git|git|yes"

  echo "$deps" | while IFS='|' read -r name pkg required; do
    local status="installed"
    if ! command -v "$name" >/dev/null 2>&1; then
      status="missing"
    fi
    local req_tag=""
    [ "$required" = "yes" ] && req_tag=" (required)"
    printf '%s\n' "[$status] $name${req_tag}"
  done | {
    local item_list
    item_list=$(cat)

    if ! echo "$item_list" | grep -q '\[missing\]'; then
      echo "[zinteractive] All dependencies installed"
      return 0
    fi

    local selected
    selected=$(echo "$item_list" | grep '\[missing\]' | fzf \
      --multi \
      --header=$'  TAB to select \u2502 enter to install \u2502 esc to cancel\n' \
      --header-first \
      --border=rounded \
      --border-label=" Install Dependencies " \
      --border-label-pos=2 \
      --margin=2,4 \
      --padding=1,2 \
      --pointer="▶" \
      --marker="●" \
      --prompt="  " \
      --separator="─" \
      --info=inline-right \
      --color="${ZI_FZF_COLORS:-default}" \
      --no-preview)

    [ -z "$selected" ] && return 0

    echo "$selected" | while IFS= read -r line; do
      local pkg_name
      pkg_name=$(echo "$line" | sed 's/\[missing\] //' | sed 's/ (required)//')
      echo "[zinteractive] Installing $pkg_name..."
      brew install "$pkg_name"
    done

    echo ""
    echo "[zinteractive] Done. Restart your shell or run: source ~/.zshrc"
  }
}

zi_brew() {
  _zi_brew_check || return 1
  [ "$ZI_HAS_FZF" != "1" ] && echo "[zinteractive] fzf required" && return 1

  local mode="${1:-list}"

  case "$mode" in
    search) _zi_brew_search "$2" ;;
    outdated) _zi_brew_outdated ;;
    *) _zi_brew_list ;;
  esac
}

_zi_brew_list() {
  local selected
  selected=$( (brew list --formula; brew list --cask | sed 's/$/ [cask]/') | sort | fzf \
    --multi \
    --header=$'  enter=info \u2502 ctrl-u=update \u2502 ctrl-x=uninstall \u2502 ctrl-s=search \u2502 ctrl-o=outdated\n' \
    --header-first \
    --border=rounded \
    --border-label=" Homebrew Packages " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --pointer="▶" \
    --marker="●" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS:-default}" \
    --ansi \
    --preview='pkg=$(echo {} | awk "{print \$1}"); if echo {} | grep -q "\[cask\]"; then brew info --cask "$pkg"; else brew info "$pkg"; fi' \
    --preview-window=right:50%:wrap:border-left \
    --preview-label=" Package Info " \
    --preview-label-pos=2 \
    --expect=ctrl-u,ctrl-x,ctrl-s,ctrl-o)

  [ -z "$selected" ] && return 0

  local key
  key=$(echo "$selected" | head -1)
  local pkgs
  pkgs=$(echo "$selected" | tail -n +2 | awk '{print $1}')

  [ -z "$pkgs" ] && return 0

  case "$key" in
    ctrl-u)
      echo "$pkgs" | while IFS= read -r pkg; do
        echo "[zinteractive] Updating $pkg..."
        brew upgrade "$pkg"
      done
      ;;
    ctrl-x)
      echo ""
      echo "  Packages to uninstall:"
      echo "$pkgs" | sed 's/^/    /'
      echo ""
      printf "  Confirm uninstall? [y/N] "
      read -r answer
      case "$answer" in
        [yY]|[yY][eE][sS])
          echo "$pkgs" | while IFS= read -r pkg; do
            echo "[zinteractive] Uninstalling $pkg..."
            brew uninstall "$pkg"
          done
          ;;
        *) echo "[zinteractive] Aborted" ;;
      esac
      ;;
    ctrl-s)
      _zi_brew_search
      ;;
    ctrl-o)
      _zi_brew_outdated
      ;;
    *)
      # enter — show full info
      echo "$pkgs" | while IFS= read -r pkg; do
        brew info "$pkg"
        echo ""
      done
      ;;
  esac
}

_zi_brew_search() {
  local term="$1"
  if [ -z "$term" ]; then
    printf "Search brew: "
    read -r term
  fi
  [ -z "$term" ] && return 0

  local results
  results=$(brew search "$term" 2>/dev/null)
  [ -z "$results" ] && echo "[zinteractive] No results for '$term'" && return 0

  local selected
  selected=$(echo "$results" | grep -v '^==>' | grep -v '^$' | fzf \
    --multi \
    --header=$'  enter=install \u2502 esc to cancel\n' \
    --header-first \
    --border=rounded \
    --border-label=" Search: $term " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --pointer="▶" \
    --marker="●" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS_ALT:-default}" \
    --preview='brew info {}' \
    --preview-window=right:50%:wrap:border-left \
    --preview-label=" Package Info " \
    --preview-label-pos=2)

  [ -z "$selected" ] && return 0

  echo "$selected" | while IFS= read -r pkg; do
    echo "[zinteractive] Installing $pkg..."
    brew install "$pkg"
  done
}

_zi_brew_outdated() {
  local outdated
  outdated=$(brew outdated 2>/dev/null)
  [ -z "$outdated" ] && echo "[zinteractive] All packages up to date" && return 0

  local selected
  selected=$(echo "$outdated" | fzf \
    --multi \
    --header=$'  enter=update \u2502 esc to cancel\n' \
    --header-first \
    --border=rounded \
    --border-label=" Outdated Packages " \
    --border-label-pos=2 \
    --margin=2,4 \
    --padding=1,2 \
    --pointer="▶" \
    --marker="●" \
    --prompt="  " \
    --separator="─" \
    --info=inline-right \
    --color="${ZI_FZF_COLORS_ALT:-default}" \
    --preview='brew info {1}' \
    --preview-window=right:50%:wrap:border-left \
    --preview-label=" Package Info " \
    --preview-label-pos=2)

  [ -z "$selected" ] && return 0

  echo "$selected" | awk '{print $1}' | while IFS= read -r pkg; do
    echo "[zinteractive] Updating $pkg..."
    brew upgrade "$pkg"
  done
}
