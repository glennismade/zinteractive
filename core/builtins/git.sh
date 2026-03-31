#!/bin/sh
# Zinteractive — built-in git functions

_zi_git_require() {
  if [ "$ZI_HAS_GIT" != "1" ]; then
    echo "[zinteractive] git not found"
    return 1
  fi
  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "[zinteractive] Not inside a git repository"
    return 1
  fi
  return 0
}

zi_git_add() {
  _zi_git_require || return 1
  if [ "$ZI_HAS_FZF" != "1" ]; then
    echo "[zinteractive] fzf required for zi_git_add"
    return 1
  fi
  local files
  files=$(git status --short | \
    fzf --multi \
        --ansi \
        --prompt="Stage files> " \
        --header="TAB to multi-select, ENTER to stage" \
        --preview='git diff --color=always {2}' \
        --preview-window=right:60% | \
    awk '{print $2}')
  if [ -z "$files" ]; then
    echo "[zinteractive] Nothing selected"
    return 0
  fi
  echo "$files" | xargs git add --
  echo "[zinteractive] Staged:"
  echo "$files" | sed 's/^/  /'
}

zi_git_commit() {
  _zi_git_require || return 1
  printf "Commit message: "
  read -r msg
  if [ -z "$msg" ]; then
    echo "[zinteractive] Aborted: empty message"
    return 1
  fi
  git commit -m "$msg"
}

zi_git_push() {
  _zi_git_require || return 1
  git push
}

zi_git_checkout() {
  _zi_git_require || return 1
  if [ "$ZI_HAS_FZF" != "1" ]; then
    echo "[zinteractive] fzf required for zi_git_checkout"
    return 1
  fi
  local result branch
  result=$(git branch --format='%(refname:short)' | \
    fzf --print-query \
        --prompt="Branch> " \
        --header="Type a new branch name or select existing" \
        --preview='git log --oneline --color=always --decorate -20 {}' \
        --preview-window=right:60%)
  # --print-query outputs query on first line, selection on second (if any)
  local query
  query=$(printf '%s' "$result" | head -n1)
  branch=$(printf '%s' "$result" | tail -n1)
  # If the last line equals the query, no existing branch was selected
  if [ -z "$branch" ] || [ "$branch" = "$query" ]; then
    branch="$query"
  fi
  if [ -z "$branch" ]; then
    echo "[zinteractive] Aborted: no branch specified"
    return 1
  fi
  # Check if branch exists locally
  if git branch --format='%(refname:short)' | grep -qx "$branch"; then
    git checkout "$branch"
  else
    printf "Branch '%s' does not exist. Create it? [y/N] " "$branch"
    read -r answer
    case "$answer" in
      [yY]|[yY][eE][sS])
        git checkout -b "$branch"
        printf "Push '%s' to origin? [y/N] " "$branch"
        read -r push_answer
        case "$push_answer" in
          [yY]|[yY][eE][sS])
            git push -u origin "$branch"
            ;;
        esac
        ;;
      *)
        echo "[zinteractive] Aborted"
        return 1
        ;;
    esac
  fi
}

zi_git_log() {
  _zi_git_require || return 1
  if [ "$ZI_HAS_FZF" != "1" ]; then
    git log --oneline --color=always --decorate -50
    return
  fi
  git log --oneline --color=always --decorate -50 | \
    fzf --ansi \
        --no-sort \
        --prompt="Log> " \
        --header="Browse recent commits" \
        --preview='git show --color=always {1}' \
        --preview-window=right:60%
}

zi_git_diff() {
  _zi_git_require || return 1
  if [ "$ZI_HAS_BAT" = "1" ]; then
    git diff --color=always | bat --style=plain --color=always --language=diff
  else
    git diff --color=always
  fi
}

zi_git_status() {
  _zi_git_require || return 1
  git status
}

zi_git_oops() {
  _zi_git_require || return 1
  echo "Last commit:"
  git log --oneline -1
  printf "Undo this commit (soft reset)? [y/N] "
  read -r answer
  case "$answer" in
    [yY]|[yY][eE][sS])
      git reset --soft HEAD~1
      echo "[zinteractive] Commit undone (changes kept staged)"
      ;;
    *)
      echo "[zinteractive] Aborted"
      ;;
  esac
}

zi_git_wip() {
  _zi_git_require || return 1
  git add -A && git commit -m "wip"
}

_zi_detect_main_branch() {
  if git rev-parse --verify main >/dev/null 2>&1; then
    echo "main"
  elif git rev-parse --verify master >/dev/null 2>&1; then
    echo "master"
  else
    # Fall back to the default branch from remote if available
    local remote_head
    remote_head=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
    if [ -n "$remote_head" ]; then
      echo "$remote_head"
    else
      echo "main"
    fi
  fi
}

zi_git_prune() {
  _zi_git_require || return 1
  local main
  main=$(_zi_detect_main_branch)
  local merged
  merged=$(git branch --merged "$main" | grep -v "^\*" | grep -v "^[ ]*${main}$" | sed 's/^[ ]*//')
  if [ -z "$merged" ]; then
    echo "[zinteractive] No merged branches to prune"
    return 0
  fi
  echo "Branches merged into '$main':"
  echo "$merged" | sed 's/^/  /'
  printf "Delete these branches? [y/N] "
  read -r answer
  case "$answer" in
    [yY]|[yY][eE][sS])
      echo "$merged" | xargs git branch -d
      echo "[zinteractive] Pruned"
      ;;
    *)
      echo "[zinteractive] Aborted"
      ;;
  esac
}

zi_git_nuke() {
  _zi_git_require || return 1
  if [ "$ZI_HAS_FZF" != "1" ]; then
    echo "[zinteractive] fzf required for zi_git_nuke"
    return 1
  fi
  local current branch
  current=$(git rev-parse --abbrev-ref HEAD)
  branch=$(git branch --format='%(refname:short)' | \
    grep -v "^${current}$" | \
    fzf --prompt="Nuke branch> " \
        --header="Select a branch to delete locally and remotely (current: $current)" \
        --preview='git log --oneline --color=always --decorate -20 {}' \
        --preview-window=right:60%)
  if [ -z "$branch" ]; then
    echo "[zinteractive] Aborted: no branch selected"
    return 1
  fi
  if [ "$branch" = "$current" ]; then
    echo "[zinteractive] Cannot delete the currently checked-out branch"
    return 1
  fi
  printf "Delete branch '%s' locally AND from origin? [y/N] " "$branch"
  read -r answer
  case "$answer" in
    [yY]|[yY][eE][sS])
      git branch -D "$branch"
      git push origin --delete "$branch" 2>/dev/null && \
        echo "[zinteractive] Deleted remote branch '$branch'" || \
        echo "[zinteractive] Remote branch not found or already deleted"
      ;;
    *)
      echo "[zinteractive] Aborted"
      ;;
  esac
}

zi_fresh_main() {
  _zi_git_require || return 1
  local main
  main=$(_zi_detect_main_branch)
  git checkout "$main" && git pull
}
