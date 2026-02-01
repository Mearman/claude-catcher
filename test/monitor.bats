#!/usr/bin/env bats

load test_helper

@test "monitor: no strays + quiet → no log entry" {
  run "$CATCHER" monitor --quiet
  [ "$status" -eq 0 ]

  local log="$HOME/.local/log/claude-catcher.log"
  if [ -f "$log" ]; then
    # Log should be empty or not contain any entries
    [ ! -s "$log" ]
  fi
}

@test "monitor: no strays + not quiet → log entry written" {
  run "$CATCHER" monitor
  [ "$status" -eq 0 ]

  local log="$HOME/.local/log/claude-catcher.log"
  [ -f "$log" ]
  grep -q "No stray Claude processes" "$log"
}

@test "monitor: with strays + --kill → processes killed and logged" {
  spawn_stray
  wait_for_processes
  local pid="${SPAWNED_PIDS[0]}"

  run "$CATCHER" monitor --kill
  [ "$status" -eq 0 ]

  local log="$HOME/.local/log/claude-catcher.log"
  [ -f "$log" ]
  grep -q "stray Claude process(es):" "$log"
  grep -q "stray(s)." "$log"

  # Process should be gone
  sleep 1
  ! ps -p "$pid" -o pid= &>/dev/null
}

@test "monitor: --notify calls osascript or notify-send stub" {
  spawn_stray
  wait_for_processes

  run "$CATCHER" monitor --notify
  [ "$status" -eq 0 ]

  # Stub should have been called
  [ -f "$STUB_LOG" ]
  grep -qE "(osascript|notify-send)" "$STUB_LOG"
}

@test "monitor: lockfile prevents concurrent run" {
  mkdir -p /tmp/claude-catcher.lock
  # Touch the lockfile so it's fresh (not stale)
  touch /tmp/claude-catcher.lock

  run "$CATCHER" monitor
  [ "$status" -eq 0 ]

  # Should have exited without writing to log (lock held)
  local log="$HOME/.local/log/claude-catcher.log"
  [ ! -f "$log" ] || [ ! -s "$log" ]

  rmdir /tmp/claude-catcher.lock 2>/dev/null || true
}

@test "monitor: stale lockfile (>5min) is reclaimed" {
  mkdir -p /tmp/claude-catcher.lock
  # Make the lockfile old (>5 min)
  touch -t "$(date -v-10M +%Y%m%d%H%M.%S 2>/dev/null || date -d '10 minutes ago' +%Y%m%d%H%M.%S 2>/dev/null)" /tmp/claude-catcher.lock

  run "$CATCHER" monitor
  [ "$status" -eq 0 ]

  # Should have run successfully (reclaimed stale lock)
  local log="$HOME/.local/log/claude-catcher.log"
  [ -f "$log" ]
}
