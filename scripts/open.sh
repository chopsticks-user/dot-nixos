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
kill_parent=""
while getopts ":s:kh" opt; do
  case $opt in
    s) search="$OPTARG" ;;
    k) kill_parent=1 ;;
    h) usage ;;
    :) echo "open: option -$OPTARG requires an argument" >&2; exit 1 ;;
    \?) echo "open: unknown option -$OPTARG" >&2; exit 1 ;;
  esac
done
shift $((OPTIND - 1))

grandparent_pid=$(ps -p $PPID -o ppid= | tr -d ' ')
if [ -n "$search" ]; then
  eval "$search" | fzf | { read -r f; nohup xdg-open "$f" > /dev/null 2>&1 & [ -n "$kill_parent" ] && kill "$grandparent_pid"; }
else
  [ -z "${1:-}" ] && usage
  nohup xdg-open "$@" > /dev/null 2>&1 &
  [ -n "$kill_parent" ] && kill "$grandparent_pid"
fi