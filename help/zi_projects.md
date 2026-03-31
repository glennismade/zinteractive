---
category: Projects
description: jump to git repos with branch and tmux status
---
# zi_projects

## Project picker

Scans configured directories for git repos. Shows project name, current branch, and active tmux sessions.

### Usage

```bash
zi_projects    # open project picker (also ctrl-p)
```

### Configuration

```bash
# In ~/.config/zinteractive/config.sh
export ZI_PROJECT_DIRS="$HOME/Documents/GIT"
# Multiple dirs (colon-separated):
export ZI_PROJECT_DIRS="$HOME/Documents/GIT:$HOME/work"
```

### Keybindings

| Key | Action |
|-----|--------|
| enter | cd into project |
| ctrl-t | cd into project + create/attach tmux session |
