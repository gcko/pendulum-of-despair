# Stack, sign, restack, merge: the runbook

Every command here names its worktree explicitly. `git -C <wt> checkout` does
**not** change the directory a following `bash scripts/gates.sh` runs in. That
command would judge whatever checkout the shell is in. Always run
`bash <wt>/scripts/gates.sh`; the script `cd`s to its own root.

Notation: `A`, `B` and `C` are branches, bottom to top; `wt-A` is A's worktree.

**Two names for the base, never a local `main`.**

- `<base-sha>` is the `origin/main` commit a wave's builders were cut from
  (SKILL.md Step 3). It is pinned in the ledger, and builders and the
  ownership audit judge against it.
- `origin/main`, after `git fetch -q origin`, is what the stack is rebased
  onto. It may be ahead of `<base-sha>` if something merged during the wave.

A local `main` goes stale the moment anything merges on GitHub. A stale base
makes ownership audits flag other people's paths and puts rebases on the wrong
commit.

**Record every branch tip in the ledger before rewriting it.** A restack needs
the old tip, and after a force-rebase that tip is gone from the branch.

**Base-only pushes.** Sections 3, 5 and 6 push branches whose own content has
not changed: they only moved onto a new base. These are the one named
exception to "the PUSH-GATE is the only push point" (SKILL.md rule 3). A
base-only push carries nothing else. Unpushed review fixes always go through
the child's own `/pr-review-response` PUSH-GATE first.

## 1. Form the stack and sign every commit

All builders branched from `<base-sha>`. Sign the bottom too. A stack built
only with `rebase --gpg-sign <parent>` never rewrites the bottom branch, so an
unsigned builder commit in A survives.

```bash
git fetch -q origin
git -C wt-A rebase --force-rebase --gpg-sign origin/main
git -C wt-B rebase --force-rebase --gpg-sign A     # run after A is rewritten
git -C wt-C rebase --force-rebase --gpg-sign B
```

This first stacking of B onto A is a plain rebase because B branched from
`<base-sha>` and carries no A commits yet. Every later restack needs `--onto`
(section 3).

`--force-rebase` is what makes signing reliable. Plain `--gpg-sign` is a
**no-op** when the branch is already current with its base. Git drops a
duplicate commit a sibling already made as a clean cherry-pick
(`skipped previously applied commit`), and drops a commit that becomes empty
(`--empty=drop` is the non-interactive default).

For independent PRs (no stack), run the `origin/main` line for every branch.

**Conflicts on a gated hot file are expected.** They happen whenever two
branches each updated a derived value for their own changes. Do not pick a
side. Recompute the value for this branch's tip (count the lines, or re-run
whatever the gate measures), stage it, and continue without an editor:
`GIT_EDITOR=true git -C wt-C rebase --continue`. Any other conflict means the
ownership split was wrong. Stop and re-plan that bundle; do not hand-merge.

Verify each branch against **its own parent**. `origin/main..C` would blame
A's and B's commits on C:

```bash
git -C wt-A log --format='%h %G? %s' origin/main..A
git -C wt-B log --format='%h %G? %s' A..B     # any N = unsigned: re-run the rebase
```

`G` is good. `E` on a GitHub-made merge commit is expected: GitHub's key is
not in the local allowed-signers file. Only `N` (no signature) or `B` (bad
signature) is a defect.

## 2. Green at its own tip

```bash
GATES_BASE=origin/main bash wt-A/scripts/gates.sh
GATES_BASE=A bash wt-B/scripts/gates.sh
GATES_BASE=B bash wt-C/scripts/gates.sh
```

The mutex in `scripts/quality-gates/godot-lock.sh` lets only one headless
Godot run at a time, so run these one after another. Running them in parallel
saves nothing.

**What counts as a pass.** Take both the `RESULT scripts=... tests=...` line
and the last status line:

- `ALL GATES PASSED` is a pass.
- `STATIC GATES PASSED` is a pass only for a branch that changes nothing under
  `game/`. On a branch that does change `game/`, it means the diff the gates
  judged was empty, so the base is wrong.

## 3. Restack after a fix lands in a lower PR

A fix on A rewrites nothing in B or C. They still sit on the old A until you
move them.

- **Restack once per review pass, not once per fix.** Review the whole stack
  bottom-up, land the fixes, then restack once. Each push to a PR that targets
  `main` triggers a new Copilot review (the ruleset's `review_on_push`), and
  every review means another `/pr-review-response` round.
- Work **bottom-up**, starting with the child of the fixed PR. Move only each
  child's own commits, using the parent's previous tip from the ledger:

  ```bash
  git -C wt-B rebase --force-rebase --gpg-sign --onto A <old-A-tip> B
  git -C wt-C rebase --force-rebase --gpg-sign --onto B <old-B-tip> C
  ```

  Without `--onto`, B keeps carrying the old copies of A's commits whenever A
  was rewritten rather than only appended to. Re-check signatures and re-run
  the section 2 gates.
- Push the children with `git -C wt-B push --force-with-lease`, as a base-only
  push. Never use plain `--force`.
- **When review ends for a restacked PR.** The Copilot requirement (section 4)
  is a review of the PR's **last content head**: the last push that changed
  this PR's own commits. The ledger records that SHA. A base-only push does not
  reset it. If Copilot reviews the restack anyway, handle its comments with
  `/pr-review-response`. A comment about the parent's changes belongs to the
  parent's PR. Without this rule, every restack push starts another round with
  no end.

## 4. Pre-merge checklist, every PR, every time

Run these immediately before each merge, not once at the start of the
sequence. State changes between merges.

```bash
gh pr view <N> --json baseRefName,mergeStateStatus,headRefOid,statusCheckRollup,reviews \
  -q '{base:.baseRefName, state:.mergeStateStatus, head:.headRefOid,
       checks:[.statusCheckRollup[]|{name:(.name // .context), c:(.conclusion // .state)}],
       copilot:[.reviews[]|select(.author.login|test("copilot";"i"))
                |{commit:.commit.oid, at:.submittedAt, said:.body[0:80]}]}'
```

| Check | Must be | Why |
|---|---|---|
| `base` | `main` | Merging a stacked PR into its old parent branch after that parent merged lands the work on a dead branch, never on `main`. |
| `state` | `CLEAN` | `BLOCKED` with green CI is almost always an unsigned commit (section 1). The rule lives in a *ruleset*, so `branches/main/protection` returns 404 and explains nothing. |
| `checks` | all success, on the current `head` | The ruleset has **no** required-status-check rule. GitHub will merge a red PR without complaint. |
| `copilot` | a review whose `commit` is the ledger's last content head, and whose body is a real review; or a recorded fallback | See SKILL.md Step 6 for requesting a review and for the fallback. A body like "unable to review … insufficient remaining quota" is not a review. |
| ledger | the PUSH-GATE recorded as passed for the last content head, or the reason it did not apply | The PUSH-GATE runs only when Copilot commented and fixes were made. A PR with no Copilot comments, or one reviewed by the fallback, records that instead. |

## 5. Merge

```bash
gh pr merge <N> --merge
```

Always merge with a merge commit; the `main` ruleset allows nothing else. If a
parent ever lands any other way (squash, rebase, or a manual cherry-pick), the
child holds commits that are not patch-identical to anything on `main`. Move
the child with a base-only push:

```bash
git -C wt-B rebase --force-rebase --gpg-sign --onto origin/main <A-head-at-merge> B
```

## 6. After each merge, before the next

`<A-head-at-merge>` is the head of the PR that just merged, recorded in the
ledger at merge time.

1. **Wait for the retarget.** `delete_branch_on_merge` is on, so GitHub
   retargets the child to `main` within seconds. Re-run the section 4 query
   until `base` is `main`. If it stays on the old parent, run
   `gh pr edit <child> --base main`. Never merge it where it points.
2. **Make sure the child's CI result still applies.** A retarget is an `edited`
   event, and `gut-tests.yml` runs only on `opened`, `synchronize` and
   `reopened`. The checks shown are from the old base. They are still valid
   only if `main` now has exactly the tree the child was built on:

   ```bash
   git fetch -q origin
   [ "$(git rev-parse 'origin/main^{tree}')" = "$(git rev-parse '<A-head-at-merge>^{tree}')" ] \
     && echo "same tree: checks still valid" \
     || echo "main moved: rebase the child onto origin/main, sign, re-gate, base-only push, wait for CI"
   ```

3. **Close what `Closes` did not.** GitHub binds closing keywords only for PRs
   that targeted the default branch **when they were created**. A PR opened
   against `main` closes its issues on merge. A retargeted child never does.
   For every issue the ledger maps to that PR:

   ```bash
   gh issue view <n> --json state -q .state
   gh issue close <n> --reason completed --comment "Fixed by #<PR> (merge <sha>)."
   ```

4. **Fix the project board.** The board is project 3
   (`gh project list --owner gcko`). An issue closed by hand can stay in a
   non-Done column. Project items carry no issue state, so filter with the
   project query language:

   ```bash
   gh project item-list 3 --owner gcko --query "is:closed -status:Done" \
     --format json --limit 500 -q '.items[] | {n:.content.number, status}'
   ```

   Prove the filter is not vacuous once per burn-down:
   `--query "is:closed"` must return closed items. Move each listed item with
   `gh project item-edit`, or list it for the user if the token lacks the
   `project` scope.
5. Update the ledger, then go on to the next PR.
