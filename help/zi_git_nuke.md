---
category: Git
description: fzf delete branch locally + remotely
---
# zi_git_nuke

Opens an fzf picker to select a branch (excluding the current one) and deletes it both locally with `git branch -D` and remotely via `git push origin --delete`.

### Usage
```bash
zi_git_nuke    # pick and delete a branch locally and from origin
```
