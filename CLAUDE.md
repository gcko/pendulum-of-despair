# CLAUDE.md

@AGENTS.md

<!-- Above imports universal agent instructions. Claude-specific extensions below. -->

## Quick Reference

For detailed documentation beyond AGENTS.md essentials:

- `docs/plans/` - Architecture decisions and implementation plans
- `.claude/skills/pendulum-of-despair/` - Project skill with design references, tech stack, and game systems

## Development Environment

Always use `pnpm` as the package manager for this project. When running commands in your terminal:
- Use `pnpm run <script>` for npm scripts
- Use `pnpm exec <binary>` for executables (instead of `npx`)
- Do not use `npm`, `yarn`, or standalone `npx` commands

**Node.js version:** This project requires Node.js >= 24.0.0 (uses built-in `node:sqlite`).

## Git & PRs

- The default branch is `main`, not `master`. Always create PRs targeting `main` unless explicitly told otherwise.
- When creating PRs or commits with shell commands, avoid heredoc syntax with special characters (apostrophes, quotes). Instead, write the body to a temp file and use `--body-file` with `gh pr create` or similar approaches.
- When merging or rebasing branches, always check for and resolve merge conflicts before proceeding. Run `git status` after merge/rebase to confirm clean state.
- **PR Template is mandatory.** Every PR must use `.github/pull_request_template.md`. With `gh pr create`, the template auto-populates — fill in all sections.

## Testing

Run tests from the workspace root:
```bash
pnpm test              # Run all tests (server + client)
pnpm test -- --watch   # Watch mode
```

Or target a specific package:
```bash
pnpm --filter @pendulum/server test    # Server tests only
pnpm --filter @pendulum/client test    # Client tests only
```

The server uses `node:sqlite` with `:memory:` for test isolation — no external database needed.

## Linting & Type Checking

This project uses strict TypeScript for linting (no ESLint/Biome yet). Run type checks before committing:
```bash
pnpm lint              # TypeScript type-check across all packages
```

## Pre-Commit Hook Behavior

The pre-commit hook runs TypeScript type-check + related tests (via `vitest related`) when there are staged TypeScript/JavaScript files. Only test files whose import chain touches staged files are executed, not the full suite. Treat this as a safety net — you should still run `pnpm lint && pnpm test` from the workspace root before committing. If the hook fails, fix the issue, `git add`, then create a new commit (never `--amend` after a hook failure).

**Hook architecture:** Husky v9 uses `core.hooksPath = .husky/_`. The `_/` directory is regenerated — never edit it. User hooks live in `.husky/` (e.g., `pre-commit`). bd integration is embedded in these user hooks.

**Recovery:** `pnpm install` reinstalls husky and verifies `core.hooksPath`.

## Monorepo Structure

| Package | Purpose |
|---------|---------|
| `packages/shared` | `@pendulum/shared` — Shared types and constants |
| `packages/server` | `@pendulum/server` — Express REST API with auth + save system |
| `packages/client` | `@pendulum/client` — Phaser 3 game client with Vite |

Build order matters: `shared` must be built before `server` or `client` (handled by `predev:*` and `pretest` scripts).

## PR Review Workflow

When addressing PR review comments, after fixing code and pushing, always reply to each individual review comment on GitHub using the correct API: `POST /repos/{owner}/{repo}/pulls/{pull_number}/comments/{comment_id}/replies`.

## Session Completion (Landing the Plane)

**Work is NOT complete until `git push` succeeds.**

**Mandatory steps:**
1. File issues for remaining work
2. Run quality gates (tests, linters, builds)
3. Update issue status
4. Push to remote:
   ```bash
   git pull --rebase
   command -v bd >/dev/null && bd sync  # If using Beads
   git push
   git status  # Must show "up to date with origin"
   ```
5. Clean up stashes, prune branches
6. Hand off context for next session

**Beads (`bd sync`):** Optional for contributors. If sync fails, proceed with `git push` and document in handoff notes.

**Critical:** Never stop before pushing. Never say "ready to push when you are" — YOU must push.
