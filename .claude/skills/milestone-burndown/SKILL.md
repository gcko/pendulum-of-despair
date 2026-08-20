---
name: milestone-burndown
description: >
  Use when driving a whole GitHub milestone to zero open issues, rather than
  one issue or one bundle at a time. Covers grouping issues by file-ownership
  boundary, running several bundles in parallel worktrees and rebasing them
  into a stacked-PR chain, keeping every PR green at its own tip, the
  merge-and-close sequence including the traps GitHub does not warn about,
  and controlling the follow-up issues each wave generates.
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
git -C wt-B rebase --gpg-sign --empty=drop <branch-A>
git -C wt-C rebase --gpg-sign --empty=drop <branch-B>
```

`--empty=drop` matters: a commit that a sibling already made becomes empty on
rebase and would otherwise stop the whole chain.

## 4. Every PR must be green at ITS OWN tip

A stack that is only green at the top is not reviewable — the middle PRs get
merged red.

The recurring case is a **derived value** that several branches move: a line
count, a test count, a table of file sizes. Fix it in the **last branch that
changes the underlying thing**, not the first. Fixing it early guarantees
another stale value one rebase later.

Worked example: three branches each edited `technical-architecture.md`, and
`game-dev-gaps.md` asserts its line count. The count belongs to whichever
branch last changes the file's length — the branch that adds a section, not
the branch that rewords a sentence in place.

## 5. Merge bottom-up, and mind two traps GitHub does not warn about

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

## 6. Controlling the follow-ups

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

## 7. Declaring it done

Check the **milestone counter**, not the issues you happened to work on:

```bash
gh api repos/<owner>/<repo>/milestones --paginate -q '.[] | "\(.title): open=\(.open_issues)"'
```

Saying "milestone complete" while the counter reads 7 is a real mistake that
has been made here. Zero open, `main` green under `scripts/gates.sh`, and the
board audited — then it is done.

## Related

- `/issue-bundle` — one coherent bundle, one PR
- `/quality-gate-authoring` — for any gate or guard a bundle adds
- `/gut-tdd` — the behavioral standard tests must meet
- `/pr-review-response` — the mandatory PUSH-GATE when Copilot has commented
