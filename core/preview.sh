#!/bin/sh
# Zinteractive — preview rendering for palette

_zi_preview() {
  local name="$1"
  local helpfile="$ZI_HELP_DIR/$name.md"

  if [ -f "$helpfile" ]; then
    if command -v bat >/dev/null 2>&1; then
      bat --style=plain --color=always --language=markdown --wrap=auto --terminal-width=60 "$helpfile"
    elif command -v glow >/dev/null 2>&1; then
      glow -s dark -w 60 "$helpfile"
    else
      cat "$helpfile"
    fi
  else
    echo "No help available for: $name"
  fi
}
