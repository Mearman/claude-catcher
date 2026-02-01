#!/usr/bin/env bats

load test_helper

@test "ps: no strays shows message and exits 0" {
  run "$CATCHER" ps
  [ "$status" -eq 0 ]
  [[ "$output" == *"No stray Claude processes found."* ]]
}

@test "ps: with strays shows count and PID list" {
  spawn_stray
  wait_for_processes
  run "$CATCHER" ps
  [ "$status" -eq 0 ]
  [[ "$output" == *"stray Claude process(es):"* ]]
  [[ "$output" == *"PID"* ]]
}

@test "ls: alias works same as ps" {
  run "$CATCHER" ls
  [ "$status" -eq 0 ]
  [[ "$output" == *"No stray Claude processes found."* ]]
}
