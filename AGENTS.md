# AGENTS.md

Instructions for AI coding agents working with this repository.

## Project Overview

Pendulum of Despair is a JRPG inspired by 16-bit golden age RPGs (FF4/VI, Chrono Trigger, Secret of Mana). The game will be built with **Godot Engine** as a locally-run desktop application.

**Status:** All mechanical game design is complete (25 gaps closed across 4 tiers in `docs/story/`). The Godot 4.8 project lives in `game/` with 6 autoload singletons; its main scene (`run/main_scene`) is `res://scenes/core/title.tscn`.

---

## Critical Constraints

### Do NOT:
- Bypass pre-commit hooks (never use `--no-verify`)
- Commit sensitive data (`.env`, credentials, API keys)
- Use interactive git commands (`git rebase -i`, `git add -i`)
- Use `npm`, `yarn`, or `npx` (use `pnpm` for tooling)
- **Do NOT run `git push` in pr-review-response without completing Step 6b (story-review-loop).** This is a structural rule, not a suggestion. The only authorized push point in pr-review-response is the PUSH-GATE inside Step 6b. See `.claude/skills/pr-review-response/SKILL.md` Step 6b for the full gate.

### Always:
- Use `pnpm` for commitlint/husky tooling
- **Run story-review-loop after fixing PR review comments.** When `/pr-review-response` fixes valid Copilot comments (any file edit, not just replies), `/story-review-loop <PR#> 1` MUST run before pushing. This is non-negotiable and enforced by the PUSH-GATE in the skill.
- **Read the FULL skill file, not the system-reminder version.** The system-reminder version of `/pr-review-response` is INCOMPLETE — it omits Steps 6 (gap analysis) and 6b (story-review-loop) entirely. You MUST read `.claude/skills/pr-review-response/SKILL.md` before executing the skill.

### pr-review-response PUSH-GATE (mandatory)

When running `/pr-review-response` and Copilot has commented, STOP
before `git push`. Complete ALL steps in order:

- [ ] **Step 5:** Fixes committed locally (NO push)
- [ ] **Step 6:** Copilot gap analysis completed — categorize every
  comment using `copilot-gap-taxonomy.md`, map to responsible agent,
  check verification-checklists.md for existing coverage, propose
  new checklist items, present to user for approval, commit updates
- [ ] **Step 6b:** `/story-review-loop <PR#> 1` run and reports CLEAN
- [ ] **Step 6b fixes:** If the loop found issues, fix and re-commit
- [ ] **ONLY THEN:** `git push`

If ANY checkbox is unchecked, DO NOT PUSH. This is the ONLY
authorized push point in the entire pr-review-response workflow.

---

## Essential Commands

| Task | Command |
|------|---------|
| **Install tooling** | `pnpm install` |
| **Open in editor** | Open `game/` directory in Godot 4.8+ editor |
| **Run the gates on work the hooks cannot see yet** | `bash scripts/gates.sh` (add `GATES_BASE=<parent>` on a stacked branch) |

`scripts/gates.sh` does not replace the hooks and is not a general "run the
tests" command — `/create-pr`'s Iron Rule still holds, and the hooks still run
on every commit and push. Reach for the script only where the hooks are blind:
work sitting uncommitted in a parallel worktree, or a stacked branch that must
be judged against its own parent rather than `main`. It also serializes headless
Godot, which matters when several worktrees run at once.

---

## Repository Layout

| Directory | Purpose |
|-----------|---------|
| `game/` | **Godot 4.8 project root** (open this in the editor) |
| `game/scripts/autoload/` | 6 autoload singletons (GameManager, DataManager, AudioManager, SaveManager, EventFlags, PartyState) |
| `game/scenes/` | Scene files (.tscn) — core, overlay, entities, maps |
| `game/data/` | JSON game data (enemies, items, equipment, shops, etc.) |
| `game/assets/` | Art and audio assets (sprites, tilesets, music, SFX) |
| `docs/story/` | Canonical game design documents (35+ files) |
| `docs/story/bestiary/` | Enemy stat tables, type rules, families |
| `docs/story/script/` | Full dialogue script (8 files, 6,300+ lines) |
| `docs/analysis/` | Gap analysis and audit docs |
| `docs/references/` | Reference data (SNES, audio, graphics) |
| `docs/plans/` | Architecture decisions and implementation plans |
| `docs/superpowers/` | Design specs and implementation plans |
| `.husky/` | Git hooks (conventional commits, branch protection) |

## Where to Add Code

| Change Type | Location |
|-------------|----------|
| GDScript game logic | `game/scripts/` |
| Autoload singletons | `game/scripts/autoload/` |
| Scene files (.tscn) | `game/scenes/` |
| JSON game data | `game/data/` |
| Sprites and tilesets | `game/assets/sprites/`, `game/assets/tilesets/` |
| Audio (music/SFX/ambient) | `game/assets/music/`, `game/assets/sfx/`, `game/assets/ambient/` |
| Game design docs | `docs/story/` |
| Enemy data | `docs/story/bestiary/` |
| Dialogue script | `docs/story/script/` |

---

## Development Workflow

**Before committing:** The pre-commit hook enforces branch protection (no direct commits to main) and runs GDScript quality gates (gdlint, JSON validation, gdformat). Commitlint enforces conventional commit format.

### Git Hooks Architecture

**Husky v9 dispatch chain:** `core.hooksPath` -> `.husky/_/<hook>` (thin shim) -> `_/h` (dispatcher) -> `.husky/<hook>` (user hook).

- The `_/` directory is gitignored and regenerated by `pnpm install` — **never edit files in `_/`**.
- `core.hooksPath` is the relative path `.husky/_`, so git resolves it in each worktree, and each worktree has its own `_/`. A worktree has none until `pnpm install` runs in it, and until then git runs no hooks there and gives no warning.
- Source of truth for hook logic: `.husky/pre-commit` (and sibling user hooks).
- Recovery: `pnpm install` (reinstalls husky).

**Quality checks (pre-commit):** Branch protection + GDScript quality gates (gdlint, JSON validation, gdformat check). With `.gd` files staged, a missing gdlint or gdformat fails the commit, and so does one whose `--version` is not the gdtoolkit version pinned in `scripts/quality-gates/gdtoolkit-version.txt`; either way the hook prints the install command for the pin. A commit with no staged `.gd` does not need gdtoolkit.

**Quality checks (pre-push):** Quality-gate self-tests (Gate I), data-integrity and doc scans (Gates D-G, J, K), instanced-child edits (Gate M), TileMapLayer tile data (Gate N), Godot import, and the full GUT suite with its baseline floor (Gates H, L). The gate registry at the top of `.husky/pre-push` is the authoritative list.

**Quality checks (CI):** The hooks are not the only place these run, so a push made without them is still judged once it has a PR. On every pull request, `.github/workflows/quality-gates.yml` runs the gate self-tests (Gate I) and every `scripts/quality-gates/check_*.py` (Gates D-G, J, K, M, N, plus Gate L's baseline shape check), held to the `gates` and `gate_tests` floors in `scripts/quality-gates/gut-baseline.txt`; `.github/workflows/gut-tests.yml` runs Godot import and the GUT suite with its count floor (Gates H, L). `.github/workflows/static-gates.yml` runs the pre-commit gates and commitlint, with gdtoolkit installed at the version pinned in `scripts/quality-gates/gdtoolkit-version.txt`: gdlint and `gdformat --check` over every tracked `.gd` under `game/`, JSON validation over every tracked `.json`, both outside `addons/`, and commitlint over the PR's commits. Branch protection is the one hook check CI does not repeat. `bash scripts/gates.sh` runs the pre-commit gates locally on changed files.

**Commit message validation (commit-msg):** commitlint enforces Conventional Commits format. Non-conforming messages are rejected.

If hooks fail: read error, fix issue, `git add <files>`, commit again.

---

## Commit Conventions

All commits must follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/). This is enforced by a `commit-msg` hook via commitlint.

```bash
git commit -m "docs(story): add combat formulas"
```

**Format:** `<type>(<scope>): <description>`

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `build`, `perf`, `revert`, `ci`

**Scopes:** `engine`, `story`, `assets`, `ci`, `deps`

**Branches:** `feature/`, `fix/`, `chore/` — main requires PRs.

**PR Template:** All PRs MUST use `.github/pull_request_template.md`. When creating PRs with `gh pr create`, the template auto-populates. Fill in every section — do not delete or skip them.

---

## Common Pitfalls

| Problem | Fix |
|---------|-----|
| Hooks not running | `pnpm install` (reinstalls husky) |
| Commitlint rejects message | Check format: `type(scope): description` |
| Cross-branch work | `git worktree add ../name branch && pnpm install -C ../name --frozen-lockfile`. The install is not optional: `core.hooksPath` is the relative `.husky/_`, which is gitignored, so a new worktree has no hooks and its commits and pushes skip every hook without a word. `bash scripts/gates.sh` refuses to run in a worktree until they are installed |
| PR shows `BLOCKED`, CI green, no reason given | An **unsigned commit**. `main`'s rule is a *ruleset*, so `gh api repos/.../branches/main/protection` returns 404 and tells you nothing. Check `git log --format='%h %G? %s' main..HEAD` for `N`; fix with `git rebase --force-rebase --gpg-sign <base>` — plain `--gpg-sign` is a **no-op** when the branch is already current |
| Issues stay open after a stacked PR merges | GitHub binds `Closes #N` only for PRs targeting the default branch **at creation**. A PR auto-retargeted to `main` after its parent merges never re-parses them. Verify each issue closed, close the stragglers by hand, then re-audit the project board for closed-but-not-Done |
| `TEST COUNT REGRESSION` after deleting a test on purpose | The floor lives in `scripts/quality-gates/gut-baseline.txt`. Lower it in the **same commit** and name the deleted tests in the body. Never keep a worthless test alive to hold the number up |
| Asset tests fail locally but pass in CI | Poisoned Godot import sidecars. `grep -rl 'valid=false' game/assets --include='*.import'`. They sit **beside** the asset, so `rm -rf game/.godot` does not clear them and repeated `--import` will not retry them. Delete the sidecars themselves, then re-import |

---

## Additional Resources

- **[CLAUDE.md](./CLAUDE.md)** - Claude-specific extensions and session workflow
- **[`/milestone-burndown`](./.claude/skills/milestone-burndown/SKILL.md)** - Milestone-scale work: drives a whole milestone to zero with several bundles in parallel worktrees (one bundle at a time is `/issue-bundle`)

## Quick Reference (GitHub Issues)

This project uses **GitHub Issues** for issue tracking (via the `gh` CLI).

```bash
gh issue list                     # Find available work
gh issue view <number>            # View issue details
gh issue create --title "..." --body "..."   # File new work
gh issue close <number>           # Complete work
```

## Non-Interactive Shell Commands

**ALWAYS use non-interactive flags** with file operations to avoid hanging on confirmation prompts.

Shell commands like `cp`, `mv`, and `rm` may be aliased to include `-i` (interactive) mode on some systems, causing the agent to hang indefinitely waiting for y/n input.

**Use these forms instead:**
```bash
# Force overwrite without prompting
cp -f source dest           # NOT: cp source dest
mv -f source dest           # NOT: mv source dest
rm -f file                  # NOT: rm file

# For recursive operations
rm -rf directory            # NOT: rm -r directory
cp -rf source dest          # NOT: cp -r source dest
```

**Other commands that may prompt:**
- `scp` - use `-o BatchMode=yes` for non-interactive
- `ssh` - use `-o BatchMode=yes` to fail instead of prompting
- `apt-get` - use `-y` flag
- `brew` - use `HOMEBREW_NO_AUTO_UPDATE=1` env var

## Issue Tracking with GitHub Issues

**IMPORTANT**: This project uses **GitHub Issues** (via the `gh` CLI) for ALL
issue tracking. Do NOT use markdown TODOs, task lists, or `.beads`/bd — beads
was removed because its `.beads/*.jsonl` exports caused recurring merge
conflicts and hook failures.

### Quick Start

**Check for available work:**

```bash
gh issue list --state open
gh issue list --label bug          # filter by label
```

**Create new issues:**

```bash
gh issue create --title "Issue title" --body "Detailed context" \
  --label bug --milestone "Phase 2 — Combat Completion"
```

**`--milestone` is mandatory on every `gh issue create`.** An unmilestoned
issue is invisible to the milestone-by-milestone workflow and silently
falls out of the plan. Pick the milestone from the topic of the *fix*,
not from which PR surfaced it — an encounter-roster bug found during a
docs pass belongs to the world milestone, not the docs one. Run
`gh api repos/gcko/pendulum-of-despair/milestones -q '.[].title'` for the
current list. If genuinely none fit, say so explicitly in your report so
a new milestone can be created — do not leave the field empty.

**View and complete work:**

```bash
gh issue view <number>
gh issue close <number> --comment "Fixed in <PR/commit>"
```

### Labels

Use GitHub labels in place of bd's types/priorities:

- Type: `bug`, `feature`, `task`, `chore`
- Priority: `p0`-critical, `p1`-high, `p2`-medium, `p3`-low

### Workflow for AI Agents

1. **Check open work**: `gh issue list` shows available issues
2. **Work on it**: Implement, test, document; reference the issue in the PR
   (e.g. "Closes #123") so it auto-closes on merge
3. **Discover new work?** File a linked issue, always with a milestone:
   `gh issue create --title "Found bug" --body "Details. Discovered in #<parent>" --milestone "<milestone>"`
4. **Complete**: close the issue (or let the merged PR auto-close it)

### Important Rules

- Use GitHub Issues for ALL task tracking
- **Every issue gets a `--milestone` at creation time** (see above)
- Before filing, check whether a sibling agent in the same review wave
  already filed it — parallel reviews duplicate findings often
- Reference issues from PRs/commits (`Closes #N`, `Refs #N`)
- Do NOT create markdown TODO lists
- Do NOT reintroduce `.beads`/bd or other parallel trackers

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **File GitHub Issues for remaining work** - `gh issue create` for anything that needs follow-up
2. **Run quality gates** (if code changed) - Tests, linters, builds
3. **Update issue status** - Close finished work, comment on in-progress items
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune remote branches
6. **Verify** - All changes committed AND pushed
7. **Hand off** - Provide context for next session

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds
- NEVER stop before pushing - that leaves work stranded locally
- NEVER say "ready to push when you are" - YOU must push
- If push fails, resolve and retry until it succeeds
