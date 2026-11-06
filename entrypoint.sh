#!/bin/sh
# Serve one shared tmux session over ttyd. Every browser that connects attaches
# to the same session ("new-session -A"), so a phone and a laptop see the same
# terminal, and a closed tab leaves Claude running.
set -eu

: "${TTYD_CREDENTIAL:?TTYD_CREDENTIAL must be set to user:password}"

mkdir -p "$HOME/work"
cd "$HOME/work"

# --writable: ttyd is read-only by default since 1.7.
# --ping-interval: keeps the WebSocket alive through the Tailscale proxy and
# phone network handovers.
exec ttyd \
  --port 7681 \
  --writable \
  --credential "$TTYD_CREDENTIAL" \
  --ping-interval 30 \
  --client-option titleFixed=claude \
  tmux new-session -A -s main
