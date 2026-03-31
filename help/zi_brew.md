---
category: Brew
description: manage Homebrew packages with fzf
---
# zi_brew

## Homebrew package manager

Interactive fzf-powered interface for managing Homebrew packages.

### Usage

```bash
zi_brew             # list installed packages
zi_brew search vim  # search for packages
zi_brew outdated    # show outdated packages
```

### Keybindings (list mode)

| Key | Action |
|-----|--------|
| enter | show package info |
| ctrl-u | update selected |
| ctrl-x | uninstall selected (with confirmation) |
| ctrl-s | switch to search mode |
| ctrl-o | show outdated packages |
