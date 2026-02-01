# claude-catcher

Finds and kills runaway Claude Code processes that have detached from their terminal and are burning CPU.

## The problem

Claude Code processes occasionally become orphaned — detached from any terminal, stuck in a running state, each consuming 40-90% CPU. Left unchecked, they accumulate and grind your machine to a halt.

## Commands

| Command          | Description                                                |
| ---------------- | ---------------------------------------------------------- |
| `stray-claude`   | List stray processes                                       |
| `hang-claude`    | Kill stray processes (tries SIGTERM, escalates to SIGKILL) |
| `hang-claude -f` | Force kill with SIGKILL immediately                        |
| `claude-catcher` | Cron-friendly monitor with flags below                     |

### claude-catcher flags

| Flag       | Description                          |
| ---------- | ------------------------------------ |
| `--kill`   | Auto-kill strays (default: log only) |
| `--notify` | Send macOS notification              |
| `--quiet`  | Suppress "no strays" log entries     |

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

## Uninstall

```bash
./uninstall.sh
```

## How it works

A "stray" is any `claude` process that:

- Has no controlling terminal (`??`)
- Is in running state (`R`)

These are orphaned processes that have lost their parent session and will never exit on their own.
