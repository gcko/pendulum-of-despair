# Stack, sign, restack, merge: the runbook

Every command here names its worktree explicitly. `git -C <wt> checkout` does
**not** change the directory a following `bash scripts/gates.sh` runs in. That
command would judge whatever checkout the shell is in. Always run
`bash <wt>/scripts/gates.sh`; the script `cd`s to its own root.

Notation: `A`, `B` and `C` are branches, bottom to top; `wt-A` is A's worktree.

**Base is always `origin/main` after a fetch.** Never use a local `main`. It
goes stale the moment anything merges on GitHub, and a stale base makes
ownership audits flag other people's paths and puts rebases on the wrong
commit. Start every section with `git fetch -q origin`.

**Record every branch tip in the ledger before rewriting it.** A restack needs
the old tip, and after a force-rebase that tip is gone from the branch.

## 1. Form the stack and sign every commit

All builders branched from `main`. Sign the bottom too. A stack built only
with `rebase --gpg-sign <parent>` never rewrites the bottom branch, so an
unsigned builder commit in A survives.

```bash
git fetch -q origin
git -C wt-A rebase --force-rebase --gpg-sign origin/main
git -C wt-B rebase --force-rebase --gpg-sign A     # run after A is rewritten
git -C wt-C rebase --force-rebase --gpg-sign B
```

This first stacking of B onto A is a plain rebase because B branched from
`origin/main`, so B carries no old A commits yet. Every later restack needs
`--onto` (section 3).

**Conflicts on a gated hot file are expected.** They happen whenever two
branches each updated a derived value for their own changes. Do not pick a
side. Recompute the value for this branch's tip (count the lines, or re-run
whatever the gate measures), stage it, and continue without an editor:
`GIT_EDITOR=true git -C wt-C rebase --continue`. Any other conflict means the
ownership split was wrong. Stop and re-plan that bundle; do not hand-merge.

`--force-rebase` is what makes signing reliable. Plain `--gpg-sign` is a
**no-op** when the branch is already current with its base. Git drops a
duplicate commit a sibling already made as a clean cherry-pick
(`skipped previously applied commit`), and drops a commit that becomes empty
(`--empty=drop` is the non-interactive default).

For independent PRs (no stack), run the `origin/main` line for every branch.

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

These runs are serialized by the headless-Godot mutex, so run them one after
another. Running them in parallel saves nothing.

## 3. Restack after a fix lands in a lower PR

A fix on A rewrites nothing in B or C. They still sit on the old A until you
move them.

- **Restack once per review pass, not once per fix.** Every push to an open PR
  can trigger a new Copilot review (`review_on_push`), and each review means
  another `/pr-review-response` round. Review the whole stack bottom-up, land
  the fixes, then restack once.
- Work **bottom-up**, starting with the child of the fixed PR. Move only each
  child's own commits, using the parent's old tip from the ledger:

  ```bash
  git -C wt-B rebase --onto A <old-A-tip> B --force-rebase --gpg-sign
  git -C wt-C rebase --onto B <old-B-tip> C --force-rebase --gpg-sign
  ```

  Without `--onto`, B keeps carrying the old copies of A's commits whenever A
  was rewritten rather than only appended to. Re-check signatures and re-run
  the section 2 gates.
- Push the children with `git -C wt-B push --force-with-lease`. Never use plain
  `--force`.
- A restack push may carry **only** the parent's changes. If a child has
  review fixes of its own that are not pushed yet, that child's
  `/pr-review-response` PUSH-GATE must pass first. A restack is never a way to
  ship review fixes around the gate.
- **When review ends for a restacked PR.** The Copilot requirement (section 4)
  is a review of the PR's **last content head**, meaning the last push that
  changed this PR's own commits. The ledger records that SHA. A restack-only
  push does not reset it. If Copilot reviews the restack anyway, handle its
  comments with `/pr-review-response`, but a comment about the parent's
  changes belongs to the parent's PR. Without this rule, every restack push
  starts another round with no end.

## 4. Pre-merge checklist, every PR, every time

Run these immediately before each merge, not once at the start of the
sequence. State changes between merges.

```bash
gh pr view <N> --json baseRefName,mergeStateStatus,headRefOid,statusCheckRollup,reviews \
  -q '{base:.baseRefName, state:.mergeStateStatus, head:.headRefOid,
       checks:[.statusCheckRollup[]|{name:(.name // .context), c:(.conclusion // .state)}],
       copilot:[.reviews[]|select(.author.login|test("copilot";"i"))|.submittedAt]}'
```

| Check | Must be | Why |
|---|---|---|
| `base` | `main` | Merging a stacked PR into its old parent branch after that parent merged lands the work on a dead branch, never on `main`. |
| `state` | `CLEAN` | `BLOCKED` with green CI is almost always an unsigned commit (section 1). The rule lives in a *ruleset*, so `branches/main/protection` returns 404 and explains nothing. |
| `checks` | all success, on the current `head` | The ruleset has **no** required-status-check rule. GitHub will merge a red PR without complaint. |
| `copilot` | a review of the last content head (section 3), or a recorded fallback | Some stacks here merged with no Copilot review at all. No review is not a clean review. Request one; if Copilot is unavailable, run `/story-review-loop-cope` and record that in the ledger. |
| ledger | the PUSH-GATE recorded as passed for this head | `/pr-review-response` Step 6b is the only authorized push point. |

## 5. Merge

```bash
gh pr merge <N> --merge
```

Always merge with a merge commit; the `main` ruleset allows nothing else. If a
parent ever lands any other way (squash, rebase, or a manual cherry-pick), the
child holds commits that are not patch-identical to anything on `main`. Move
it with `git -C wt-B rebase --onto origin/main <old-A-tip> B --force-rebase --gpg-sign`.

## 6. After each merge, before the next

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
   [ "$(git rev-parse origin/main^{tree})" = "$(git rev-parse <old-A-tip>^{tree})" ] \
     && echo "same tree: checks still valid" \
     || echo "main moved: rebase child onto main, sign, re-gate, push, wait for CI"
   ```

3. **Close what `Closes` did not.** GitHub binds closing keywords only for PRs
   that targeted the default branch **when they were created**. A retargeted
   child never activates them. For every issue the ledger maps to that PR:

   ```bash
   gh issue view <n> --json state -q .state
   gh issue close <n> --reason completed --comment "Fixed by #<PR> (merge <sha>)."
   ```

4. **Fix the project board.** The board is project 3 (`gh project list --owner gcko`).
   An issue closed by hand can stay in a non-Done column:

   ```bash
   gh project item-list 3 --owner gcko --format json --limit 500 \
     -q '.items[] | select(.content.state=="CLOSED" and .status!="Done")
         | {n:.content.number, status}'
   ```

   Move any closed item that is not Done with `gh project item-edit`, or list
   it for the user if the token lacks the `project` scope.
5. Update the ledger, then go on to the next PR.
