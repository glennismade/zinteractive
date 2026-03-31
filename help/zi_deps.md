---
category: Brew
description: install missing zinteractive dependencies via brew
---
# zi_deps

## Plugin dependency installer

Shows all zinteractive dependencies with their install status. Select missing ones to install via Homebrew.

### Usage

```bash
zi_deps    # open fzf picker of missing deps
```

### Dependencies checked

- **fzf** (required) — core picker engine
- **bat** — syntax-highlighted previews
- **glow** — markdown rendering
- **zoxide** — smart directory navigation
- **fd** — fast file finder
- **eza** — enhanced ls
- **git** (required) — git workflows
