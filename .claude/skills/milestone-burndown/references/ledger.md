# The burn-down ledger

A burn-down outlives any single context window. It spans several waves and
usually more than one session. Conversation memory does not survive that, but
the ledger does. **Re-read the ledger first** after a compaction, after a
resumed session, and whenever you are unsure what state something is in.

## Where it lives

```bash
LEDGER="$(git rev-parse --path-format=absolute --git-common-dir)/milestone-burndown/<milestone-number>.md"
mkdir -p "$(dirname "$LEDGER")"
```

The ledger sits in the **common** git dir, so every worktree resolves the same
file. It is never committed, so it cannot conflict or leak into a PR. It
survives sessions, and `git worktree remove` does not delete it.

## When to write it

Write the ledger after every state change, before you take the next action:
an issue closed, a bundle dispatched, a report received, a rebase, a push, a PR
opened, a review gate passed, a merge, a follow-up filed. If you crash between
the action and the write, re-derive the state from GitHub and fix the ledger.
Never fix it from memory.

## Format

```markdown
# Burn-down: <milestone title> (#<number>)

## Settings
plan=fable:high  build=opus:high  review=opus:xhigh  merge=ask  parallel=3
substitutions: none
wave base-sha: 6622cf5

## Waves
| wave | started | open at start | closed | filed into milestone | open at end |
|------|---------|---------------|--------|----------------------|-------------|
| 1    | 2026-10-28 | 8 | 5 | 1 | 4 |

## Issues
| # | verdict | bundle | branch | PR | state | evidence |
|---|---------|--------|--------|----|-------|----------|
| 101 | open-valid | A | fix/p4-shop-sell | 470 | merged, closed by hand | merge 1a2b3c4 |
| 102 | already-fixed | - | - | - | closed | fixed by 9f8e7d6, test test_sell_price |
| 103 | needs-design-decision | - | - | - | waiting on user | docs/story/economy.md silent on resale |

## Bundles
| bundle | agent | worktree | branch | parent | tip | last content head | owned files | hot files | PR | gate state |
|--------|-------|----------|--------|--------|-----|-------------------|-------------|-----------|----|-----------|
| A | build-A | ../pod-wt-p4a | fix/p4-shop-sell | origin/main | 3c4d5e6 | 3c4d5e6 | game/scripts/shop/** | - | 470 | PUSH-GATE passed; merged |

## Pending user decisions
- #103: design doc silent on resale value. Options given: ...

## Candidate follow-ups (not yet filed)
- from B report: ... (dedupe check: none found)
```

Exact column names are not required. Every row must answer *what it is, where
it lives, and what happens next*. A row without its next step is the one a
resumed session gets wrong.

## Resuming

1. Read the ledger.
2. Reconcile it against GitHub, which is the source of truth:
   `gh pr list --state all --head <branch>` for each branch,
   `gh issue list --milestone "<title>" --state all --limit 500`, and
   `git worktree list`.
3. Report the differences to the user before acting on them.
4. Ask "Keep these settings?" (`references/intake.md`), then continue from the
   first row whose next step is not done.
