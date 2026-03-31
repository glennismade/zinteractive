# Zinteractive

A shell plugin that gives you an fzf-powered command palette, built-in git/nav/AWS workflows, navi cheat sheet integration, and per-terminal shortcut reference — all in one keystroke.

---

## Install

### Zsh

**With [zinit](https://github.com/zdharma-continuum/zinit):**
```zsh
zinit light your-username/zinteractive
```

**With [Oh My Zsh](https://ohmyz.sh/) (manual):**
```zsh
git clone https://github.com/your-username/zinteractive \
  "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zinteractive"
# Add 'zinteractive' to plugins=(...) in ~/.zshrc
```

**Manual:**
```zsh
# In ~/.zshrc
source /path/to/zinteractive/plugin.zsh
```

### Fish

```fish
# In ~/.config/fish/config.fish
source /path/to/zinteractive/plugin.fish
```

---

## Quick Start

Press **Ctrl+\\** to open the palette. Type to filter, ENTER to run.

Two more bindings are active by default:

| Binding   | Action                              |
|-----------|-------------------------------------|
| `Ctrl+\`  | Open command palette                |
| `Ctrl+F`  | File picker (inserts path at cursor)|
| `Ctrl+B`  | Branch picker (inserts checkout cmd)|

---

## Optional Setup

Run the interactive setup wizard to configure theme, built-ins, and terminal:

```zsh
zinteractive setup
```

Or set variables in `~/.config/zinteractive/config.sh`:

```sh
export ZI_THEME=dracula          # dracula | catppuccin | nord | gruvbox | plain
export ZI_TERMINAL=ghostty       # ghostty | iterm2 | wezterm | kitty | auto | none
export ZI_BUILTINS=git,nav,aws,pickers
export ZI_QUIET=1                # suppress startup warnings
export ZI_BIND_PALETTE=1        # set to 0 to disable Ctrl+\
export ZI_BIND_FILEPICK=1       # set to 0 to disable Ctrl+F
export ZI_BIND_BRANCHPICK=1     # set to 0 to disable Ctrl+B
```

---

## Keybindings

| Binding      | Action                    |
|--------------|---------------------------|
| `Ctrl+\`     | Open command palette      |
| `Ctrl+F`     | File picker               |
| `Ctrl+B`     | Branch picker             |

Inside the fzf palette:

| Key          | Action                    |
|--------------|---------------------------|
| Type         | Filter commands           |
| `Enter`      | Run selected command      |
| `Ctrl+C`/`Esc` | Cancel                  |
| Arrow keys   | Navigate                  |

---

## Adding Commands

### Option 1 — Workflow .md file

Drop a markdown file with YAML frontmatter in `~/.config/zinteractive/help/` (or `help/` in the repo):

```markdown
---
category: Dev
description: deploy to staging
steps: build_app deploy_app
---
# deploy_staging

Builds the app and deploys to the staging environment.
```

A `steps:` line chains multiple shell functions in sequence.

### Option 2 — Register a custom function

In `~/.config/zinteractive/custom_workflows.sh`:

```sh
my_deploy() {
  echo "deploying..."
}
zi_register my_deploy "Deploy to staging" "Dev"
```

Copy the template from the repo root:
```sh
cp /path/to/zinteractive/custom_workflows.sh \
   ~/.config/zinteractive/custom_workflows.sh
```

### Option 3 — Navi cheat files

Drop `.cheat` files in `~/.config/zinteractive/cheats/` or any path listed in `ZI_CHEAT_DIRS`. They appear in the palette under `[Cheat]` and support navi-style `<variable>` placeholders.

---

## Dependencies

| Tool     | Required | Used for                            |
|----------|----------|-------------------------------------|
| fzf      | Yes      | All interactive pickers and palette |
| bat      | No       | Syntax-highlighted previews         |
| git      | No       | Git built-in functions              |
| zoxide   | No       | Frecency-ranked directory picker    |
| fd       | No       | Faster file search in file picker   |
| eza      | No       | Enhanced directory listings         |
| glow     | No       | Markdown preview rendering          |

---

## License

MIT
