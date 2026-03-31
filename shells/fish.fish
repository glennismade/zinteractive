#!/usr/bin/env fish
# Zinteractive — Fish shell adapter

# Palette binding — Ctrl+\
function _zi_palette_fish
  set -l selected (_zi_fzf)
  or begin
    commandline -f repaint
    return
  end

  set -l cmd (echo $selected | sed 's/\x1b\[[0-9;]*m//g' | awk '{print $2}')

  if _zi_has_steps "$cmd"
    commandline -f repaint
    zi_run "$cmd"
  else
    commandline -i "$cmd "
    commandline -f repaint
  end
end

# File picker binding — Ctrl+F
function _zi_file_pick_fish
  set -l file (zi_file_pick)
  or begin
    commandline -f repaint
    return
  end
  commandline -i "$file "
  commandline -f repaint
end

# Branch picker binding — Ctrl+B
function _zi_branch_pick_fish
  set -l branch (zi_branch_pick)
  or begin
    commandline -f repaint
    return
  end
  commandline -i "git checkout $branch "
  commandline -f repaint
end

# Bind keys (respecting config)
if test "$ZI_BIND_PALETTE" != "0"
  bind \e\\ _zi_palette_fish
end
if test "$ZI_BIND_FILEPICK" != "0"
  bind \cf _zi_file_pick_fish
end
if test "$ZI_BIND_BRANCHPICK" != "0"
  bind \cb _zi_branch_pick_fish
end

# Main command
function zinteractive
  switch $argv[1]
    case setup
      _zi_setup
    case help
      zi_help $argv[2]
    case '*'
      zi_palette
  end
end
