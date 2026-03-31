#!/bin/sh
# Zinteractive — workflow runner + custom function registration

# Registration storage: simple newline-delimited entries
# Format: name|description|category
ZI_REGISTERED=""

zi_register() {
  local name="$1"
  local desc="$2"
  local category="${3:-Custom}"
  ZI_REGISTERED="${ZI_REGISTERED}${name}|${desc}|${category}
"
}

_zi_get_registered() {
  printf '%s' "$ZI_REGISTERED"
}

zi_run() {
  local name="$1"
  local helpfile="$ZI_HELP_DIR/$name.md"

  if [ ! -f "$helpfile" ]; then
    echo "No workflow found: $name"
    return 1
  fi

  local steps
  steps=$(sed -n '2,/^---$/p' "$helpfile" | grep '^steps:' | sed 's/^steps: *//')

  if [ -z "$steps" ]; then
    echo "No steps defined for: $name"
    return 1
  fi

  echo "Running workflow: $name"
  for step in $steps; do
    echo "  → $step"
    if ! "$step"; then
      echo "  ✗ Step failed: $step"
      return 1
    fi
  done
  echo "  ✓ Workflow complete: $name"
}

zi_help() {
  local name="$1"
  local helpfile="$ZI_HELP_DIR/$name.md"
  if [ -f "$helpfile" ]; then
    if command -v glow >/dev/null 2>&1; then
      glow -s dark -w 60 "$helpfile"
    else
      cat "$helpfile"
    fi
  else
    echo "No help available for: $name"
  fi
}
