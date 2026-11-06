# An always-on Claude Code terminal: ttyd serves one tmux session over
# HTTP, so closing the browser tab detaches instead of killing the work.
FROM node:22-bookworm-slim

# Pinned. Upgrading is this line plus a VERSION bump (AGENTS.md).
# The in-app auto-updater is off: the CLI lives in the image, not on the volume,
# so an update would not survive a restart anyway. Bump it here instead.
ARG CLAUDE_CODE_VERSION=2.1.319

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ttyd tmux tini \
      git openssh-client ca-certificates curl \
      jq ripgrep less nano procps python3 \
 && rm -rf /var/lib/apt/lists/*

RUN npm install -g "@anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}" \
 && npm cache clean --force

# The base image's uid 1000 user, renamed. Its home is the PVC mount, so
# nothing is put there at build time -- the volume would hide it.
RUN groupmod -n claude node \
 && usermod -l claude -d /home/claude node \
 && mkdir -p /home/claude \
 && chown claude:claude /home/claude

COPY tmux.conf /etc/tmux.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

USER claude
WORKDIR /home/claude

ENV HOME=/home/claude \
    LANG=C.UTF-8 \
    TERM=xterm-256color \
    DISABLE_AUTOUPDATER=1

EXPOSE 7681

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
