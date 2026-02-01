#!/bin/bash
# Shared library for claude-catcher commands

_realpath() { perl -MCwd -e 'print Cwd::realpath($ARGV[0])' "$1"; }

CLAUDE_CATCHER_ROOT="$(cd "$(dirname "$(_realpath "${BASH_SOURCE[0]}")")/.." && pwd)"

find_strays() {
  ps -eo pid,state,tty,comm | awk '$3 == "??" && $4 == "claude" && $2 == "R" {print $1}'
}

count_strays() {
  local pids="$1"
  if [ -z "$pids" ]; then echo 0; return; fi
  echo "$pids" | wc -l | tr -d ' '
}

show_strays() {
  local pids="$1"
  ps -o pid,%cpu,etime,state,command -p "$(echo "$pids" | tr '\n' ',')" 2>/dev/null
}

kill_strays() {
  local pids="$1"
  echo "$pids" | xargs kill 2>/dev/null
  sleep 2
  local survivors=""
  local pid
  for pid in $pids; do
    if ps -p "$pid" -o pid= &>/dev/null; then
      survivors="$survivors $pid"
    fi
  done
  if [ -n "$survivors" ]; then
    echo "$survivors" | xargs kill -9 2>/dev/null
    return 1 # needed force kill
  fi
  return 0 # clean kill
}
