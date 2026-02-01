#!/usr/bin/env bats

load test_helper

@test "help: shows usage and exits 0" {
  run "$CATCHER" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: claude-catcher"* ]]
  [[ "$output" == *"Commands:"* ]]
}

@test "-h: shows usage and exits 0" {
  run "$CATCHER" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: claude-catcher"* ]]
}

@test "--help: shows usage and exits 0" {
  run "$CATCHER" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: claude-catcher"* ]]
}

@test "unknown command: shows usage and exits 1" {
  run "$CATCHER" bogus-command
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown command: bogus-command"* ]]
  [[ "$output" == *"Usage: claude-catcher"* ]]
}
