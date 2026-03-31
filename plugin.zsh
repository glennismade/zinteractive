#!/bin/zsh
# Zinteractive — Zsh entry point
export ZI_HOME="${0:A:h}"
export ZI_HELP_DIR="$ZI_HOME/help"

source "$ZI_HOME/core/deps.sh"
_zi_check_deps
[ -f "$HOME/.config/zinteractive/config.sh" ] && source "$HOME/.config/zinteractive/config.sh"

# Load non-prefixed env vars (Jira, etc.) from .env
if [ -f "$HOME/.config/zinteractive/.env" ]; then
  while IFS='=' read -r key value; do
    case "$key" in
      "#"*|"") continue ;;
    esac
    key="${key## }"; key="${key%% }"
    value="${value## }"; value="${value%% }"; value="${value%\"}"; value="${value#\"}"; value="${value%\'}"; value="${value#\'}"
    # Only export vars without underscore-separated prefixes matching known groups
    # i.e. export JIRA_TOKEN but not AWS_STAGING_ACCESS_KEY_ID
    case "$key" in
      AWS_STAGING_*|AWS_PROD_*|CONFLUENT_STAGING_*|CONFLUENT_PREPROD_*|CONFLUENT_PROD_*|CONFLUENT_CLOUD_*) ;;
      *) export "$key=$value" ;;
    esac
  done < "$HOME/.config/zinteractive/.env"
fi
source "$ZI_HOME/core/theme.sh"
_zi_load_theme
source "$ZI_HOME/core/preview.sh"
source "$ZI_HOME/core/runner.sh"
source "$ZI_HOME/core/palette.sh"
source "$ZI_HOME/core/cheats.sh"
source "$ZI_HOME/core/setup.sh"

_zi_builtins="${ZI_BUILTINS:-git,nav,aws,pickers,brew,tmux,projects}"
case "$_zi_builtins" in *git*)     source "$ZI_HOME/core/builtins/git.sh" ;; esac
case "$_zi_builtins" in *nav*)     source "$ZI_HOME/core/builtins/nav.sh" ;; esac
case "$_zi_builtins" in *aws*)     source "$ZI_HOME/core/builtins/aws.sh" ;; esac
case "$_zi_builtins" in *pickers*) source "$ZI_HOME/core/builtins/pickers.sh" ;; esac
case "$_zi_builtins" in *brew*)    source "$ZI_HOME/core/builtins/brew.sh" ;; esac
case "$_zi_builtins" in *tmux*)     source "$ZI_HOME/core/builtins/tmux.sh" ;; esac
case "$_zi_builtins" in *projects*) source "$ZI_HOME/core/builtins/projects.sh" ;; esac

_zi_terminal="${ZI_TERMINAL:-auto}"
if [ "$_zi_terminal" = "auto" ]; then
  case "${TERM_PROGRAM:-}" in
    ghostty)     _zi_terminal="ghostty" ;;
    iTerm.app)   _zi_terminal="iterm2" ;;
    WezTerm)     _zi_terminal="wezterm" ;;
    xterm-kitty) _zi_terminal="kitty" ;;
    *)           _zi_terminal="none" ;;
  esac
fi
[ "$_zi_terminal" != "none" ] && [ -f "$ZI_HOME/terminals/${_zi_terminal}.sh" ] && \
  source "$ZI_HOME/terminals/${_zi_terminal}.sh"

[ -f "$HOME/.config/zinteractive/custom_workflows.sh" ] && \
  source "$HOME/.config/zinteractive/custom_workflows.sh"

source "$ZI_HOME/shells/zsh.zsh"
