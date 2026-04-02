# CLAUDE.md

@AGENTS.md

<!-- Above imports universal agent instructions. Claude-specific extensions below. -->

## Quick Reference

For detailed documentation beyond AGENTS.md essentials:

- `docs/plans/` - Architecture decisions and implementation plans
- `.claude/skills/pod-dev/` - Project skill with design references, tech stack, and game systems

## Development Environment

This project uses `pnpm` for commitlint and husky tooling only.

- Use `pnpm install` to set up git hooks (commitlint + husky)
- Do not use `npm`, `yarn`, or standalone `npx` commands

## Godot Project

The Godot 4.6 project lives in `game/`. Open `game/` as the project
directory in the Godot editor.

- **Resolution:** 320x180 native, integer-scaled
- **Language:** GDScript only
- **Autoloads:** GameManager, DataManager, AudioManager, SaveManager, EventFlags
- **Game data:** JSON files in `game/data/`
- **Architecture reference:** `docs/plans/technical-architecture.md`

## Git & PRs

- The default branch is `main`, not `master`. Always create PRs targeting `main` unless explicitly told otherwise.
- **Conventional Commits are mandatory.** All commit messages must follow the [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/) specification. The `commit-msg` hook enforces this via commitlint. Format: `<type>(<scope>): <description>`. See AGENTS.md for allowed types and scopes.
- When creating PRs or commits with shell commands, avoid heredoc syntax with special characters (apostrophes, quotes). Instead, write the body to a temp file and use `--body-file` with `gh pr create` or similar approaches.
- When merging or rebasing branches, always check for and resolve merge conflicts before proceeding. Run `git status` after merge/rebase to confirm clean state.
- **PR Template is mandatory.** Every PR must use `.github/pull_request_template.md`. With `gh pr create`, the template auto-populates — fill in all sections.

## Pre-Commit Hook Behavior

The pre-commit hook blocks direct commits to main and runs beads (bd) flush logic. Godot-specific quality checks (GDScript linting, tests) have not yet been added to the pre-commit hook.

**Hook architecture:** Husky v9 uses `core.hooksPath = .husky/_`. The `_/` directory is regenerated — never edit it. User hooks live in `.husky/` (e.g., `pre-commit`). bd integration is embedded in these user hooks.

**Recovery:** `pnpm install` reinstalls husky and verifies `core.hooksPath`.

## PR Review Workflow

When addressing PR review comments, after fixing code and pushing, always reply to each individual review comment on GitHub using the correct API: `POST /repos/{owner}/{repo}/pulls/{pull_number}/comments/{comment_id}/replies`.

## Session Completion (Landing the Plane)

**Work is NOT complete until `git push` succeeds.**

**Mandatory steps:**
1. File issues for remaining work
2. Run quality gates (when applicable)
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
