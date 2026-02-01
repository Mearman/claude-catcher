#!/bin/bash
# Shared library for claude-catcher commands

# Resolve real path through symlinks
CLAUDE_CATCHER_ROOT="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.." && pwd)"

find_strays() {
  ps -eo pid,state,tty,comm | awk '$3 == "??" && $4 == "claude" && $2 == "R" {print $1}'
}

count_strays() {
  local pids="$1"
  echo "$pids" | wc -l | tr -d ' '
}

show_strays() {
  local pids="$1"
  ps -o pid,%cpu,etime,state,command -p $(echo $pids | tr '\n' ',') 2>/dev/null
}

kill_strays() {
  local pids="$1"
  kill $pids 2>/dev/null
  sleep 2
  local survivors
  survivors=$(find_strays)
  if [ -n "$survivors" ]; then
    kill -9 $survivors 2>/dev/null
    return 1 # needed force kill
  fi
  return 0 # clean kill
}
