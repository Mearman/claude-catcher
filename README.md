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
  monitor         Cron-friendly monitor (--kill --notify --quiet)
  update          Pull latest from git
  help            Show this help
```

### Shorthand aliases

`stray-claude` and `hang-claude` are also installed as shortcuts:

| Alias | Equivalent |
|---|---|
| `stray-claude` | `claude-catcher ps` |
| `hang-claude` | `claude-catcher kill` |

### Monitor flags

| Flag | Description |
|---|---|
| `--kill` | Auto-kill strays (default: log only) |
| `--notify` | Send macOS notification |
| `--quiet` | Suppress "no strays" log entries |

Logs are written to `~/.local/log/claude-catcher.log`.

## Install

```bash
git clone <repo-url> ~/Developer/claude-catcher
cd ~/Developer/claude-catcher
./install.sh
```

This symlinks the commands into `~/.local/bin` and optionally installs a cron job to auto-kill strays every 5 minutes.

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
./uninstall.sh
```

## How it works

A "stray" is any `claude` process that:
- Has no controlling terminal (`??`)
- Is in running state (`R`)

These are orphaned processes that have lost their parent session and will never exit on their own.
