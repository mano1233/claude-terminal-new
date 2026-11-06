# An always-on Claude Code terminal: ttyd serves one tmux session over
# HTTP, so closing the browser tab detaches instead of killing the work.
FROM node:22-bookworm-slim

# Pinned. Upgrading is this line plus a VERSION bump (AGENTS.md).
# The in-app auto-updater is off: the CLI lives in the image, not on the volume,
# so an update would not survive a restart anyway. Bump it here instead.
ARG CLAUDE_CODE_VERSION=2.1.319

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      tmux tini \
      git openssh-client ca-certificates curl \
      jq ripgrep less nano procps python3 \
 && rm -rf /var/lib/apt/lists/*

# ttyd is not packaged in bookworm, so it comes from the project's static release
# binaries, pinned by checksum (from the release's SHA256SUMS).
ARG TTYD_VERSION=1.7.7
ARG TARGETARCH
RUN case "${TARGETARCH}" in \
      arm64) asset=ttyd.aarch64; sum=b38acadd89d1d396a0f5649aa52c539edbad07f4bc7348b27b4f4b7219dd4165 ;; \
      amd64) asset=ttyd.x86_64;  sum=8a217c968aba172e0dbf3f34447218dc015bc4d5e59bf51db2f2cd12b7be4f55 ;; \
      *) echo "no ttyd binary for ${TARGETARCH}" >&2; exit 1 ;; \
    esac \
 && curl -fsSL -o /usr/local/bin/ttyd "https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/${asset}" \
 && echo "${sum}  /usr/local/bin/ttyd" | sha256sum -c - \
 && chmod 755 /usr/local/bin/ttyd \
 && ttyd --version

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
