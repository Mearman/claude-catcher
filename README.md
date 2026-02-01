# claude-catcher

Finds and kills runaway Claude Code processes that have detached from their terminal and are burning CPU.

## The problem

Claude Code processes occasionally become orphaned — detached from any terminal, stuck in a running state, each consuming 40-90% CPU. Left unchecked, they accumulate and grind your machine to a halt.

## Usage

```
claude-catcher <command> [options]

Commands:
  ps, ls          List stray Claude processes
  kill [-f]       Kill strays (SIGTERM, then SIGKILL). -f for immediate SIGKILL
  cull            SIGKILL all detached Claude processes (any state)
  monitor         Cron-friendly monitor (--kill --notify --quiet)
  config          Configure the cron job (interval, flags)
  install         Symlink commands to ~/.local/bin and configure cron
  uninstall       Remove symlinks and cron entry
  update          Pull latest from git
  help            Show this help
```

### Shorthand aliases

`stray-claude` and `hang-claude` are also installed as shortcuts:

| Alias          | Equivalent            |
| -------------- | --------------------- |
| `stray-claude` | `claude-catcher ps`   |
| `hang-claude`  | `claude-catcher kill` |
| `claude-cull`  | `claude-catcher cull` |

### Monitor flags

| Flag       | Description                          |
| ---------- | ------------------------------------ |
| `--kill`   | Auto-kill strays (default: log only) |
| `--notify` | Send macOS notification              |
| `--quiet`  | Suppress "no strays" log entries     |

Logs are written to `~/.local/log/claude-catcher.log`.

## Requirements

macOS or Linux. Notifications use `osascript` (macOS) or `notify-send` (Linux) if available.

## Install

```bash
git clone https://github.com/Mearman/claude-catcher ~/Developer/claude-catcher && ~/Developer/claude-catcher/claude-catcher install
```

This symlinks the commands into `~/.local/bin` and walks you through cron configuration.

Ensure `~/.local/bin` is on your PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Update

```bash
claude-catcher update
```

## Uninstall

```bash
claude-catcher uninstall
```

## Testing

[![CI](https://github.com/Mearman/claude-catcher/actions/workflows/ci.yml/badge.svg)](https://github.com/Mearman/claude-catcher/actions/workflows/ci.yml)

Tests use [bats-core](https://github.com/bats-core/bats-core). Install it, then:

```bash
bats test/
```

CI runs the full suite on both macOS and Ubuntu.

## How it works

A "stray" is any `claude` process that:

- Has no controlling terminal (`??`)
- Is in running state (`R`)

These are orphaned processes that have lost their parent session and will never exit on their own.
