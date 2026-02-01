#!/usr/bin/env bats

load test_helper

ALIAS_DIR="${BATS_TEST_DIRNAME}/../.claude-catcher.d"

@test "stray-claude: same output as claude-catcher ps (no strays)" {
  run "$ALIAS_DIR/stray-claude"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No stray Claude processes found."* ]]
}

@test "hang-claude: kills strays like claude-catcher kill (no strays)" {
  run "$ALIAS_DIR/hang-claude"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No stray Claude processes found."* ]]
}

@test "claude-cull: culls like claude-catcher cull (no detached)" {
  run "$ALIAS_DIR/claude-cull"
  [ "$status" -eq 0 ]
  [[ "$output" == *"No detached Claude processes found."* ]]
}

@test "stray-claude: shows strays when present" {
  spawn_stray
  wait_for_processes
  run "$ALIAS_DIR/stray-claude"
  [ "$status" -eq 0 ]
  [[ "$output" == *"stray Claude process(es):"* ]]
}

@test "hang-claude: kills strays when present" {
  spawn_stray
  wait_for_processes
  local pid="${SPAWNED_PIDS[0]}"

  run "$ALIAS_DIR/hang-claude"
  [ "$status" -eq 0 ]
  [[ "$output" == *"stray(s)."* ]]

  sleep 1
  ! ps -p "$pid" -o pid= &>/dev/null
}
