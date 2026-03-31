---
category: Picker
description: git branch + fzf picker
---
# zi_branch_pick

Lists all local git branches in an fzf picker and prints the selected branch name to stdout. Useful for scripting or command substitution.

### Usage
```bash
zi_branch_pick            # pick a branch and print its name
git diff $(zi_branch_pick)  # example: diff against a picked branch
```
