#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "open - Extension of xdg-open"
  echo ""
  echo "Usage: open [-s <cmd>] [-k] [file|url]"
  echo ""
  echo "Options:"
  echo "  -s <cmd>   pipe command output through fzf to select a file"
  echo "  -k         kill the parent process after opening"
  echo "  -h         show this help"
  echo ""
  xdg-open --help 2>&1 || true
  exit 0
}

search=""
command=""
kill_parent=""
search_projects=""

while getopts ":s:c:khp" opt; do
  case $opt in
    s) search="$OPTARG" ;;
    c) command="$OPTARG" ;;
    k) kill_parent=1 ;;
    h) usage ;;
    p) search_projects=1 ;;
    :) echo "open: option -$OPTARG requires an argument" >&2; exit 1 ;;
    \?) echo "open: unknown option -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

if [ -n "$search_projects" ]; then
  search="fd -t d -d 1 '' $XDG_PROJECTS_DIR; echo $NH_FLAKE"
fi

if [ -n "$search" ]; then
  selected=$(eval "$search" | fzf)
  [ -z "$selected" ] && exit 0
  target=("$selected")
else
  [ -z "${1:-}" ] && usage
  target=("$@")
fi

if [ -n "$command" ]; then
  command="$(printf '%s' "$command" | sd '\$op' "${target[0]%/}")"
fi

grandparent_pid=$(ps -p $PPID -o ppid= | tr -d ' ')
if [ -n "$command" ]; then
  # todo: avoid hardcoding executables
  if [[ "$command" =~ ^(vi|vim|nvim|emacs|nano)$ ]] || [[ "$command" == *vi* || "$command" == *vim* ]]; then
    "$command" "${target[@]}"
    exit_code=$?
    [ -n "$kill_parent" ] && [ $exit_code -eq 0 ] && kill "$grandparent_pid" 2>/dev/null
  else
    if command -v "$command" >/dev/null 2>&1; then
      nohup "$command" "${target[@]}" > /dev/null 2>&1 &
    else
      nohup eval "$command" "${target[@]}" > /dev/null 2>&1 &
    fi
    [ -n "$kill_parent" ] && kill "$grandparent_pid" 2>/dev/null
  fi
else
  nohup xdg-open "${target[@]}" > /dev/null 2>&1 &
  [ -n "$kill_parent" ] && kill "$grandparent_pid" 2>/dev/null
fi