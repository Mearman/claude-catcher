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

# Spawn a fake "claude" process in R (running) state, no tty.
# exec -a renames the process to "claude" in ps, dd keeps it in R state.
spawn_stray() {
  bash -c 'exec -a claude dd if=/dev/zero of=/dev/null bs=1 2>/dev/null' &
  disown
  SPAWNED_PIDS+=($!)
}

# Spawn a fake detached claude process (sleeping state, no tty).
spawn_detached() {
  bash -c 'exec -a claude sleep 300' &
  disown
  SPAWNED_PIDS+=($!)
}

# Wait for spawned processes to register in ps as "claude"
wait_for_processes() {
  local tries=0
  while [ $tries -lt 10 ]; do
    if ps -eo comm | grep -q '^claude$'; then
      return 0
    fi
    sleep 0.2
    tries=$((tries + 1))
  done
  sleep 1
}
