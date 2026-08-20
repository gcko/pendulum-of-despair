---
name: milestone-burndown
description: >
  Use when driving a whole GitHub milestone to zero open issues, rather than
  one issue or one bundle at a time. Covers grouping issues by file-ownership
  boundary, running several bundles in parallel worktrees and rebasing them
  into a stacked-PR chain, keeping every PR green at its own tip, routing each
  one through the mandatory review push-gate, the merge-and-close sequence
  including the traps GitHub does not warn about, and controlling the follow-up
  issues each wave generates.
---

# Milestone burn-down

For taking a milestone from N open to zero. `/issue-bundle` handles one
coherent bundle; this is the layer above it — several bundles in flight, a
stacked chain, and several waves before the count reaches zero.

Expect **waves**, not one pass. A real milestone went 17 -> 14 -> 7 -> 3 -> 1
-> 0 across five waves, because reviewing work honestly finds more work. That
is the process succeeding. What matters is that each wave's follow-ups are
smaller and more specific than the last; if they are not, the reviews are
generating opinions rather than findings (see *Controlling follow-ups*).

## 1. Prep: read every issue, verify every claim

**The issue text is evidence, not truth.** Line numbers drift, and a
surprising share of issues are already fixed or wrong about their own example.
Verify before bundling:

- Issues whose fix already landed — close them with the evidence, do not
  re-do the work. One wave found 5 of 14 already fixed.
- Issues whose named example is wrong but whose defect is real — fix the real
  thing and say the example was wrong.
- Issues that ask for the wrong fix. Two agents correctly REFUSED a resolver
  change twice because it broke live callers, before a third solved it by
  measuring first.

## 2. Bundle by file-ownership boundary, not by topic

Group so that no two bundles edit the same file. Topic is a weak proxy; the
file list is the real constraint, because that is what conflicts.

For each bundle write an explicit, literal pair:

```
FILES YOU OWN:      docs/superpowers/**, docs/story/progression.md
FILES YOU DO NOT OWN: docs/issues/** (bundle C), scripts/quality-gates/** (bundle A)
```

Name the owning bundle for each exclusion — an agent that knows a sibling is
mid-edit records a **cross-bundle note** instead of "just fixing" it. Those
notes are how the real seams get found: one bundle correctly left two British
spellings alone because they sat inside a section another bundle owned, which
would otherwise have shipped a sweep that missed its largest file.

## 3. Implement in parallel, THEN rebase into a stack

Do **not** create the stack up front and have each agent branch from an
unfinished parent. Branch every bundle from `main`, run them in parallel
worktrees, then rebase them into a chain.

This produced **zero conflicts** across nine shared files, versus resolving
the same conflicts four times on merge.

```bash
git -C wt-B rebase --gpg-sign <branch-A>
git -C wt-C rebase --gpg-sign <branch-B>
```

`--gpg-sign` is the part that matters — see section 5 on why an unsigned
subagent commit blocks the PR with no visible reason. Duplicate work needs no
flag: git drops a commit a sibling already made as a clean cherry-pick
(`warning: skipped previously applied commit ...`), and drops one that merely
becomes empty by default, since `drop` is already `--empty`'s default for a
non-interactive rebase.

## 4. Every PR must be green at ITS OWN tip

A stack that is only green at the top is not reviewable — the middle PRs get
merged red. Judge each branch against **its own parent**, not `main`, or the
diff includes the parent's work and the result tells you nothing about this PR:

```bash
git -C wt-B checkout <branch-B>
GATES_BASE=<branch-A> bash scripts/gates.sh    # not the default BASE of main
```

The recurring case is a **derived value** that several branches move: a line
count, a test count, a table of file sizes. Fix it in the **last branch that
changes the underlying thing**, not the first. Fixing it early guarantees
another stale value one rebase later.

Worked example: three branches each edited `technical-architecture.md`, and
`game-dev-gaps.md` asserts its line count. The count belongs to whichever
branch last changes the file's length — the branch that adds a section, not
the branch that rewords a sentence in place.

## 5. Route every PR through `/pr-review-response` before it is pushed again

Green at its own tip is not the same as reviewed. Each PR in the stack goes
through `/pr-review-response`, and that skill's **PUSH-GATE (Step 6b)** is the
only authorized push point once Copilot has commented: fixes committed locally,
Copilot gap analysis done, `/story-review-loop <PR#> 1` reporting CLEAN, and
only then `git push`. Do not push around it — AGENTS.md lists this under Do NOT,
not under suggestions.

Read `.claude/skills/pr-review-response/SKILL.md` from disk. The
system-reminder summary of that skill omits Steps 6 and 6b entirely, which is
how the gate has been skipped before.

A stack multiplies this: N PRs means N review passes, and the one you skip is
the one that gets merged red at position 2 of 4.

## 6. Merge bottom-up, and mind two traps GitHub does not warn about

**Signed commits.** If the repo's ruleset requires signatures, subagent
commits are sometimes unsigned. The PR sits at `mergeStateStatus: BLOCKED`
with green CI and no visible reason, and `branches/<b>/protection` returns 404
because the rule lives in a *ruleset*. Diagnose with
`git log --format='%h %G? %s' main..HEAD` and look for `N`. Fix with
`git rebase --force-rebase --gpg-sign <base>` — plain `--gpg-sign` is a
**no-op** when the branch is already current with its base.

**Retargeted PRs do not re-parse `Closes #N`.** GitHub binds closing keywords
only for PRs targeting the default branch at creation. When a stacked PR is
auto-retargeted to `main` after its parent merges, its `Closes` refs are
**never** activated. The issues stay open and the project board goes stale —
13 items at once, in one wave. So after merging a stack:

- verify each issue actually closed, and close the stragglers by hand with the
  evidence,
- re-audit the project board for `closed-but-not-Done` and fix it.

## 7. Controlling the follow-ups

Each wave generates new issues. That is healthy while they are *findings*, and
a problem once they are *opinions*. When the milestone is closing, raise the
bar explicitly in the agent brief:

> File an issue ONLY for a genuine defect that someone must fix and that you
> cannot fix inside your own ownership. Do NOT file observations, "could be
> stronger" notes, or hardening ideas — put those in your report instead,
> where they inform without creating work.

Give the report schema an `observations` field so the finding still surfaces.
This took a wave from 7 new issues to 1.

Every issue filed still needs `--milestone` (see AGENTS.md), and the milestone
is chosen by the topic of the **fix**, not the PR that surfaced it.

## 8. Declaring it done

Check the **milestone counter**, not the issues you happened to work on:

```bash
gh api repos/<owner>/<repo>/milestones --paginate -q '.[] | "\(.title): open=\(.open_issues)"'
```

Saying "milestone complete" while the counter reads 7 is a real mistake that
has been made here.

Then confirm `main` is actually green. Run on `main`, `HEAD` equals the default
`BASE`, so the diff is empty and `gates.sh` takes its fast path and skips the
whole GUT suite. A pass on that signal means nothing:

```bash
git -C <main-worktree> checkout main
GATES_FORCE_GODOT=1 bash scripts/gates.sh    # or the run never touched Godot
```

Read the `RESULT scripts=... tests=...` line and check the counts moved the way
the milestone's commits said they would. Zero open, that line seen with your own
eyes, and the board audited — then it is done.

## Related

- `/issue-bundle` — one coherent bundle, one PR
- `/quality-gate-authoring` — for any gate or guard a bundle adds
- `/gut-tdd` — the behavioral standard tests must meet
- `/pr-review-response` — the mandatory PUSH-GATE when Copilot has commented
