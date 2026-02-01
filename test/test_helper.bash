#!/bin/bash

# Path to the main script under test
CATCHER="${BATS_TEST_DIRNAME}/../claude-catcher"

# Track spawned PIDs for cleanup
SPAWNED_PIDS=()

# Stub log for verifying external command calls
export STUB_LOG="${BATS_TEST_TMPDIR}/stub.log"

setup() {
  # Prepend stubs to PATH so osascript/notify-send/crontab are intercepted
  export PATH="${BATS_TEST_DIRNAME}/stubs:${PATH}"
  # Override HOME so monitor writes logs to a temp dir
  export REAL_HOME="$HOME"
  export HOME="${BATS_TEST_TMPDIR}/home"
  mkdir -p "$HOME/.local/log"
  # Clear stub log
  : > "$STUB_LOG"
}

teardown() {
  for pid in "${SPAWNED_PIDS[@]}"; do
    kill -9 "$pid" 2>/dev/null || true
  done
  SPAWNED_PIDS=()
  # Clean up lockfile if tests leave it
  rmdir /tmp/claude-catcher.lock 2>/dev/null || true
}

# Create a copy of dd named "claude" for spawning fake processes.
# On macOS, exec -a sets argv[0] which ps comm reflects, so we can
# use dd directly. On Linux, ps comm reads /proc/PID/comm which is
# the executable filename — so we need an actual file named "claude".
_ensure_fake_dd() {
  if [ -n "$FAKE_CLAUDE_DD" ] && [ -x "$FAKE_CLAUDE_DD" ]; then
    return
  fi
  FAKE_CLAUDE_DD="${BATS_TEST_TMPDIR}/claude"
  cp "$(command -v dd)" "$FAKE_CLAUDE_DD"
}

# Spawn a fake "claude" process in R (running) state, no tty.
# dd if=/dev/zero of=/dev/null keeps the process CPU-bound (state R).
spawn_stray() {
  if [ "$(uname)" = "Darwin" ]; then
    bash -c 'exec -a claude dd if=/dev/zero of=/dev/null bs=1 2>/dev/null' &
  else
    _ensure_fake_dd
    "$FAKE_CLAUDE_DD" if=/dev/zero of=/dev/null bs=1 2>/dev/null &
  fi
  disown
  SPAWNED_PIDS+=($!)
}

# Spawn a fake detached claude process (sleeping state, no tty).
spawn_detached() {
  if [ "$(uname)" = "Darwin" ]; then
    bash -c 'exec -a claude sleep 300' &
  else
    _ensure_fake_dd
    # dd reading from a pipe that never produces data → sleeping state
    "$FAKE_CLAUDE_DD" bs=1 count=1 2>/dev/null < <(sleep 300) &
  fi
  disown
  SPAWNED_PIDS+=($!)
}

# Wait for spawned processes to appear in ps as "claude"
wait_for_processes() {
  local tries=0
  while [ $tries -lt 10 ]; do
    if ps -eo comm | grep -q claude; then
      return 0
    fi
    sleep 0.2
    tries=$((tries + 1))
  done
  sleep 1
}
