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

# Create an executable named "claude" for spawning fake processes.
# On macOS, exec -a sets argv[0] which ps comm reflects.
# On Linux, ps comm derives from the kernel task->comm (the executable
# filename), so we need an actual file named "claude".
_make_fake_claude() {
  if [ -z "$FAKE_CLAUDE" ]; then
    FAKE_CLAUDE="${BATS_TEST_TMPDIR}/claude"
    if [ "$(uname)" = "Darwin" ]; then
      # On macOS, a symlink works and avoids code-signing issues with copies
      ln -sf "$(command -v bash)" "$FAKE_CLAUDE"
    else
      cp "$(command -v bash)" "$FAKE_CLAUDE"
    fi
  fi
}

# Spawn a fake "claude" process that looks like a stray (state R, no tty).
spawn_stray() {
  _make_fake_claude
  if [ "$(uname)" = "Darwin" ]; then
    # On macOS, exec -a sets the comm field via argv[0]
    bash -c 'exec -a claude bash -c "while true; do :; done"' &
  else
    "$FAKE_CLAUDE" -c 'while true; do :; done' &
  fi
  disown
  SPAWNED_PIDS+=($!)
}

# Spawn a fake detached claude process (sleeping state, no tty).
spawn_detached() {
  _make_fake_claude
  if [ "$(uname)" = "Darwin" ]; then
    bash -c 'exec -a claude sleep 300' &
  else
    "$FAKE_CLAUDE" -c 'sleep 300' &
  fi
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
  # Last resort: give it one more second
  sleep 1
}
