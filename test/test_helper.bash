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

# Spawn a fake "claude" process that looks like a stray (state R, no tty).
# Uses exec -a to rename the process to "claude".
spawn_stray() {
  # The dd if=/dev/zero of=/dev/null loop keeps the process in R (running) state
  # and exec -a renames it to "claude". No TTY because we disown it.
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

# Wait briefly for spawned processes to register in ps
wait_for_processes() {
  sleep 0.5
}
