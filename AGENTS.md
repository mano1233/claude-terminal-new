# Contributing to claude-terminal

These rules apply to every contributor and every coding agent (Claude Code, Codex, or
anything else that reads this file). CI enforces the ticket rules on every pull request
(`.github/workflows/pr-conventions.yml`), so a PR that skips them cannot merge.

## Every change has a DEV ticket

Work is tracked in Jira, project `DEV` on `midgard-home.atlassian.net`.

- Start from an existing ticket, or create one (type `Task`, a short markdown
  description) before writing code.
- **Never invent or guess a key.** Before citing `DEV-<n>` anywhere, confirm it exists
  and is this work (`project = DEV ORDER BY created DESC`).

## Branch, commits, PR

- **Branch:** `DEV-<n>-<short-description>`, cut from `main`. Never push to `main`.
- **Commits:** subject `<type>: <what changed>` (`feat`, `fix`, `chore`, `docs`,
  `refactor`, `test`, `ci`, `perf`, `build`), a body that says *why*, and the bare
  ticket key on its own line as the footer.
- **PR title:** `<type>: <summary>`. PRs are squash-merged, so the title becomes the
  commit on `main`.
- **PR body:** what changed and why, how it was tested, and the ticket key on its own
  line.

## Releasing

`VERSION` is the published image tag. Every push to `main` builds
`ghcr.io/mano1233/claude-terminal:<VERSION>`. A newer VERSION also tags `v<VERSION>`,
publishes a GitHub Release, and makes midgard open the PR that deploys it. Bump it in
any PR that should reach the cluster: minor for a feature or a Claude Code upgrade,
patch for a fix. A PR that leaves VERSION alone ships nothing.

Upgrading Claude Code is a one-line change to `CLAUDE_CODE_VERSION` in the
`Dockerfile`, plus a VERSION bump.

## Keep out of git

Every credential: the ttyd password, Claude OAuth files (`.claude.json`, `.claude/`),
API keys. The password comes from the environment (`TTYD_CREDENTIAL`), set by midgard.
