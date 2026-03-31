#!/usr/bin/env fish
# Zinteractive — Fish entry point
set -gx ZI_HOME (status dirname)
set -gx ZI_HELP_DIR "$ZI_HOME/help"

source "$ZI_HOME/core/deps.sh"
_zi_check_deps

if test -f "$HOME/.config/zinteractive/config.sh"
  for line in (grep '^export ' "$HOME/.config/zinteractive/config.sh")
    set -l kv (string replace 'export ' '' $line)
    set -l key (string split -m1 '=' $kv)[1]
    set -l val (string split -m1 '=' $kv)[2]
    set -l val (string trim -c '"' $val)
    set -gx $key $val
  end
end

source "$ZI_HOME/core/theme.sh"
_zi_load_theme
source "$ZI_HOME/core/preview.sh"
source "$ZI_HOME/core/runner.sh"
source "$ZI_HOME/core/palette.sh"
source "$ZI_HOME/core/cheats.sh"
source "$ZI_HOME/core/setup.sh"

set -l _zi_builtins (test -n "$ZI_BUILTINS"; and echo $ZI_BUILTINS; or echo "git,nav,aws,pickers")
string match -q '*git*' $_zi_builtins; and source "$ZI_HOME/core/builtins/git.sh"
string match -q '*nav*' $_zi_builtins; and source "$ZI_HOME/core/builtins/nav.sh"
string match -q '*aws*' $_zi_builtins; and source "$ZI_HOME/core/builtins/aws.sh"
string match -q '*pickers*' $_zi_builtins; and source "$ZI_HOME/core/builtins/pickers.sh"

set -l _zi_terminal (test -n "$ZI_TERMINAL"; and echo $ZI_TERMINAL; or echo "auto")
if test "$_zi_terminal" = "auto"
  switch "$TERM_PROGRAM"
    case ghostty;     set _zi_terminal ghostty
    case 'iTerm.app'; set _zi_terminal iterm2
    case WezTerm;     set _zi_terminal wezterm
    case 'xterm-kitty'; set _zi_terminal kitty
    case '*';         set _zi_terminal none
  end
end
if test "$_zi_terminal" != "none" -a -f "$ZI_HOME/terminals/$_zi_terminal.sh"
  source "$ZI_HOME/terminals/$_zi_terminal.sh"
end

if test -f "$HOME/.config/zinteractive/custom_workflows.sh"
  source "$HOME/.config/zinteractive/custom_workflows.sh"
end

source "$ZI_HOME/shells/fish.fish"
