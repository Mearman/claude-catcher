# claude-catcher

Finds and kills runaway Claude Code processes that have detached from their terminal and are burning CPU.

## The problem

Claude Code sometimes spawns a subprocess that detaches from the terminal and gets stuck in a runaway loop, consuming 40-90% CPU. That same resource-heavy process is usually what causes the parent Claude session to hang. Killing the stray unsticks the session — and frees your CPU.

### Can't I just use a one-liner?

Yes:

```bash
ps -eo pid,state,tty,comm | awk '$4 == "claude" && $2 ~ /^R/ && $3 !~ /tty|pts|ttys/ {print $1}' | xargs kill -9
```

That's the nuclear version. `claude-catcher` wraps this with graceful shutdown (SIGTERM before SIGKILL), automated cron monitoring with logging, desktop notifications, and convenient aliases so you don't have to remember the `awk` incantation.

## The solution

`claude-catcher` detects and kills these strays. Run it manually, or set up a cron job to monitor and auto-kill them in the background.

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/Mearman/claude-catcher/main/.claude-catcher.d/install.sh | sh
```

Or manually:

```bash
git clone https://github.com/Mearman/claude-catcher ~/.claude-catcher
~/.claude-catcher/claude-catcher install
```

This symlinks the commands into `~/.local/bin` and walks you through cron configuration. Pass `--no-config` to skip the interactive cron setup.

Ensure `~/.local/bin` is on your PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

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
                    --no-config  Skip interactive cron configuration
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
| `--notify` | Send desktop notification            |
| `--quiet`  | Suppress "no strays" log entries     |

Logs are written to `~/.local/log/claude-catcher.log`.

## Requirements

macOS or Linux. Notifications use `osascript` (macOS) or `notify-send` (Linux) if available.

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

