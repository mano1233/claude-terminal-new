# claude-terminal

An always-on [Claude Code](https://docs.claude.com/en/docs/claude-code) terminal for the
midgard cluster. [ttyd](https://github.com/tsl0922/ttyd) serves **one shared tmux
session** over HTTP: every browser that connects (phone, laptop) attaches to the same
terminal, and closing the tab leaves Claude running.

Deployed by midgard's `claude-terminal` Terraform module behind a Tailscale ingress,
with the home directory on a persistent volume so the Claude login and history survive
restarts.

## Image

`ghcr.io/mano1233/claude-terminal:<VERSION>` (amd64 + arm64)

| | |
|---|---|
| Base | `node:22-bookworm-slim` |
| Claude Code | pinned by `CLAUDE_CODE_VERSION` in the Dockerfile, auto-updater off |
| Tools | ttyd 1.7.7 (static release binary), tmux, git, ssh, jq, ripgrep, python3, nano |
| User | `claude`, uid/gid 1000, home `/home/claude` (mount a volume here) |
| Port | 7681 |

## Configuration

| Env | Required | |
|---|---|---|
| `TTYD_CREDENTIAL` | yes | `user:password` for HTTP basic auth. The container refuses to start without it. |

## Run it locally

```bash
docker run --rm -p 7681:7681 -e TTYD_CREDENTIAL=me:secret -v claude-home:/home/claude ghcr.io/mano1233/claude-terminal:latest
```

Open http://localhost:7681, run `claude`, and log in once. Run `claude remote-control`
in a tmux window to drive the session from the Claude app as well.
