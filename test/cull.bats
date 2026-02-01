#!/usr/bin/env bats

load test_helper

@test "cull: no detached shows message and exits 0" {
  run "$CATCHER" cull
  [ "$status" -eq 0 ]
  [[ "$output" == *"No detached Claude processes found."* ]]
}

@test "cull: kills detached processes" {
  spawn_detached
  wait_for_processes
  local pid="${SPAWNED_PIDS[0]}"

  run "$CATCHER" cull
  [ "$status" -eq 0 ]
  [[ "$output" == *"detached Claude process(es):"* ]]
  [[ "$output" == *"Culled"* ]]
  [[ "$output" == *"process(es)."* ]]

  # Process should be gone
  sleep 0.5
  ! ps -p "$pid" -o pid= &>/dev/null
}
