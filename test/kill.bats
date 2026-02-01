#!/usr/bin/env bats

load test_helper

@test "kill: no strays shows message and exits 0" {
  run "$CATCHER" kill
  [ "$status" -eq 0 ]
  [[ "$output" == *"No stray Claude processes found."* ]]
}

@test "kill: with strays kills them" {
  spawn_stray
  wait_for_processes
  local pid="${SPAWNED_PIDS[0]}"

  run "$CATCHER" kill
  [ "$status" -eq 0 ]
  [[ "$output" == *"stray Claude process(es):"* ]]
  [[ "$output" == *"stray(s)."* ]]

  # Process should be gone
  sleep 1
  ! ps -p "$pid" -o pid= &>/dev/null
}

@test "kill -f: force kills immediately" {
  spawn_stray
  wait_for_processes
  local pid="${SPAWNED_PIDS[0]}"

  run "$CATCHER" kill -f
  [ "$status" -eq 0 ]
  [[ "$output" == *"Force killing (SIGKILL)..."* ]]

  # Process should be gone
  sleep 0.5
  ! ps -p "$pid" -o pid= &>/dev/null
}
