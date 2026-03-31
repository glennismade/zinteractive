---
category: Picker
description: zoxide/basic directory picker
---
# zi_dir_pick

Presents an fzf picker of directories, preferring zoxide's frecency-ranked list when available. Prints the selected directory path to stdout.

### Usage
```bash
zi_dir_pick          # pick a directory and print its path
cd $(zi_dir_pick)    # example: cd to a picked directory
```
