---
name: milestone-burndown
description: >
  Use when driving a whole GitHub milestone to zero open issues, rather than
  one issue or one bundle at a time: several bundles in flight at once,
  parallel worktrees, stacked PRs, follow-up issues piling up across waves, or
  resuming a burn-down that a previous session started. Also use when a
  stacked PR is BLOCKED with green CI, when issues stayed open after a stack
  merged, or when the milestone counter will not reach zero.
---

# Milestone burn-down

Takes a milestone from N open to zero. `/issue-bundle` handles one coherent
bundle; this skill is the layer above it: several bundles in flight, an
orchestrator that owns every outward action, and several **waves** before the
count reaches zero.

Expect waves. Reviewing work honestly finds more work, and that is the process
succeeding. It fails when one wave's follow-ups are not smaller and more
specific than the last wave's (Step 8 has the stop rule).

## Invocation

```
/milestone-burndown <milestone number or title>
    [plan=<model>:<effort>] [build=<model>:<effort>] [review=<model>:<effort>]
    [merge=ask|wave|never] [parallel=<2-4>]
```

## Who does what

The **orchestrator** is this session. It is the only actor that talks to the
user, pushes, opens PRs, files, comments on or closes issues, merges, or
writes the ledger. **Subagents** verify, build, or review inside the bounds of
their brief and return a structured report (`references/agent-briefs.md`).
Under that split, parallel agents cannot file duplicate issues, push around
the review gate, or close something on a guess.

## The rules that are not negotiable

1. **Evidence before every outward action.** A subagent report is a claim.
   Check it before you close, push, or merge on it.
2. **Every PR is green at its own tip**, judged against its own parent.
3. **`/pr-review-response`'s PUSH-GATE (Step 6b) is the only push point for
   review fixes.** Read `.claude/skills/pr-review-response/SKILL.md` from
   disk. The system-reminder summary of that skill leaves out Steps 6 and 6b.
   The one named exception is a *base-only push*: a branch that only moved
   onto a new base and carries no new content
   (`references/stack-and-merge.md`, "Base-only pushes").
4. **Merge only into `main`, with a merge commit, after the pre-merge
   checklist** (`references/stack-and-merge.md` section 4), under the merge
   authority the user chose.
5. **Zero means zero.** Never move, relabel or close an issue to make the
   counter read zero. An issue that cannot be closed goes to the user (Step 9).
6. **The ledger is written before the next action** (`references/ledger.md`).

Breaking the letter of these rules breaks their spirit.

---

## Step 0: Intake and preflight

1. Resolve the milestone to a number and a title:
   `gh api 'repos/gcko/pendulum-of-despair/milestones?state=all' -q '.[] | "\(.number) \(.title) open=\(.open_issues)"'`.
2. Find the ledger. If this conversation created it (you wrote it, or the
   compaction summary says you did), re-read it and carry on with the settings
   it records, without asking again. If it came from another session, this is
   a **resume**: follow `references/ledger.md` "Resuming" and skip to the step
   it points at. Values given in the invocation override recorded settings in
   both cases.
3. **Ask the intake questions.** REQUIRED: read `references/intake.md` and use
   AskUserQuestion. It asks for model and effort for planning, building and
   review separately, each with a recommendation, plus merge authority.
   Values given in the invocation are not asked again. Never dispatch a
   subagent before these are answered.
4. Preflight. Every line must pass; fix or report a failure before Step 1:

   | Check | Command | Pass |
   |---|---|---|
   | main checkout clean and current | `git fetch -q origin`, `git status --porcelain`, `git rev-list --count main..origin/main` | no output; `0` (else `git -C <main-checkout> pull --ff-only`) |
   | hooks installed | `test "${HUSKY-}" != 0 && test "$(git config core.hooksPath)" = .husky/_ && ls .husky/_/h .husky/_/pre-commit .husky/_/commit-msg .husky/_/pre-push` | exits 0: the check `scripts/gates.sh` makes at startup (else `pnpm install --frozen-lockfile`; unset `HUSKY`) |
   | commit signing works | `git log -1 --format=%G? $(git commit-tree -S HEAD^{tree} -p HEAD -m probe)` | `G` (the probe is an unreferenced object, so it changes nothing) |
   | gh authenticated | `gh auth status` | logged in, `repo` scope |
   | Godot reachable | the command below the table | exits 0; without Godot, `gates.sh` refuses to report success |
   | in-flight work | `git worktree list`, `gh pr list --state open` | any open PR or worktree already serving a milestone issue is recorded, and that issue is left out of new bundles |
   | stale state | `git stash list` | stashes you did not create are reported, never dropped |

   Godot check:
   `command -v godot || test -x "${GODOT_BIN:-/Applications/Godot.app/Contents/MacOS/Godot}"`

5. Snapshot the milestone into the ledger: every open issue, and wave 1's
   open-at-start count.

## Step 1: Triage. Read every issue and verify every claim

The issue text is evidence, not truth. Line numbers drift, and a surprising
share of issues are already fixed, wrong about their own example, or asking
for the wrong fix.

- In later waves, re-triage only the issues that are new or changed since
  the last verdict. A `blocked-external` or `needs-design-decision` issue
  whose blocker has not moved keeps its verdict.
- Dispatch **triage verifiers** at the planning setting, in slices of up to 6
  issues, all in one message, using the read-only brief in
  `references/agent-briefs.md`.
- Act on each verdict:

| Verdict | Orchestrator action |
|---|---|
| `open-valid` | goes into a bundle |
| `already-fixed` | **re-check the evidence yourself**, then close it with the evidence in the comment (`--reason completed`) |
| `example-wrong` | bundle the real defect; the PR says the example was wrong |
| `wrong-fix-requested` | bundle the real fix. Measure live callers before changing shared code, because the requested fix may break them |
| `duplicate` | `gh issue close <n> --duplicate-of <survivor>` |
| `needs-design-decision` | ask the user. Design docs are law, and a value is never invented |
| `blocked-external` | leave it open with the blocker in a comment. It goes to Step 9 |
| `epic-split` | propose the split to the user; do not split it unilaterally |

## Step 2: Plan the wave

The orchestrator plans the wave itself, from the triage reports. Group issues
so that **no two bundles edit the same file**, except for the declared hot files
below. Topic is a weak proxy; the file list is the real constraint, because
files are what conflict. Use triage's `files_to_touch`, not guesses.

For each bundle, write the literal ownership block from the builder brief:
`FILES YOU OWN` and `FILES YOU DO NOT OWN`, with the owning bundle named for
each exclusion. A builder who knows a sibling is mid-edit leaves a
cross-bundle note instead of "just fixing" the file. Those notes are how the
real seams get found.

**Hot files** are files that more than one bundle must change: derived values
(a line count, a test count, a size table), `scripts/quality-gates/gut-baseline.txt`,
shared indexes. Each hot file gets exactly one rule:

- **A gate checks it at every tip** (a pre-push or CI gate fails when it is
  stale): every branch that moves the underlying thing updates it in that
  branch, or that branch is red at its own tip. This forces a stack, and the
  restack will conflict on the file. That conflict is expected and resolved by
  recomputing the value (`references/stack-and-merge.md` section 1).
- **Nothing checks it** (a prose claim): one bundle owns it and updates it
  once, last. That is the bundle that last changes the underlying thing, not
  the first bundle to touch it.

**Topology:**

- **File-disjoint and no hot file:** independent PRs, each off `origin/main`. No
  stack means no retarget trap, and the PRs can merge in any order. Each
  merge leaves the open siblings' CI stale, so the next one to merge is
  rebased and re-run first (Step 7). Prefer this.
- **Otherwise, a stack.** Put the owner of any ungated hot file on top, and
  the smallest, most certain bundle at the bottom. A review fix in a lower PR
  forces a restack of everything above it. Keep a stack at 4 PRs or fewer.
- Never more bundles than the `parallel` setting.

**Wave approval gate.** Present this table and wait for a yes before Step 3.
Building is where the spend goes.

| Bundle | Issues | Owned files | Hot files | Base / stack position | Build setting |
|---|---|---|---|---|---|

Include any per-bundle build-setting override you propose
(`references/intake.md` section 5), the issues closed in triage, and the
questions waiting on the user.

## Step 3: Build in parallel, off `origin/main`

Do **not** create the stack up front with each agent branching from an
unfinished parent. Every bundle branches from the same `origin/main` commit,
the bundles run in parallel, and the stack is formed afterwards (Step 4).

1. `git fetch -q origin`, then record `origin/main`'s SHA as this wave's
   `<base-sha>` in the ledger. Create each worktree yourself, so the branch
   names and paths are known:
   `git worktree add ../pod-wt-<slug> -b <prefix>/<slug> <base-sha>`, where
   `<prefix>` is `feature`, `fix` or `chore` (AGENTS.md), then
   `pnpm install -C ../pod-wt-<slug> --frozen-lockfile`. The install is not
   optional: `core.hooksPath` is the relative, gitignored `.husky/_`, so a new
   worktree has no hooks, its commits and pushes skip them without a word, and
   `gates.sh` exits 1 there with `GIT HOOKS NOT INSTALLED`.
2. Dispatch one **builder** per bundle, at the build setting, all in one
   message, with the builder brief. Name each one `build-<bundle>` and record
   the name in the ledger, so that after a compaction you can still reach a
   builder that is running with `SendMessage`.
3. Check every report before you trust it:
   - **Ownership audit.** `git -C <wt> diff --name-only <base-sha>...HEAD`
     must list only that bundle's owned files and gated hot files. Any other
     path is a defect. Revert it or re-dispatch.
   - **Gates.** The report quotes the `RESULT` line and the last status line
     of `gates.sh`; stack-and-merge section 2 defines a pass. Re-run the gates
     yourself for any bundle whose report is `partial`, or whose lines are
     missing or not a pass.
   - **Signatures.** `git -C <wt> log --format='%h %G? %s' <base-sha>..HEAD`.
     Step 4 re-signs, but an `N` here tells you the agent's environment
     cannot sign.
4. A `blocked` or `partial` builder: put its question to the user, or re-brief
   with the failure. Do not quietly finish its work in the orchestrator, and
   do not drop the issue without a ledger entry saying why.
5. **Route the cross-bundle notes now, before any PR opens.** Each note goes to
   the bundle that owns the file: `SendMessage` to `build-<owner>` with the
   note, then re-check that bundle's report. If the owner has finished and its
   fix would change its scope, hold the note for the next wave as a candidate
   issue (Step 8).

## Step 4: Stack, sign, and prove each tip green

Follow `references/stack-and-merge.md` sections 1 and 2: force-rebase every
branch, **including the bottom one**, with `--gpg-sign` onto its parent;
verify signatures per parent; run `GATES_BASE=<parent> bash <wt>/scripts/gates.sh`
for each branch. Each worktree has its hooks from Step 3; any worktree you add
or re-create here needs `pnpm install -C <wt> --frozen-lockfile` first, or
`gates.sh` exits 1 before judging anything.

## Step 5: Open the PRs

`/create-pr` always targets `main` and pushes the current directory's branch.
That fits independent PRs and the bottom of a stack, when run with the
worktree as the current directory. For a stacked child, do what it does
(commit with `-s`, fill every section of `.github/pull_request_template.md`)
with these overrides:

```bash
git -C <wt> push -u origin <branch>          # first push: the pre-push hook runs
test -s '<path from mktemp>' && gh pr create --base <parent-branch> --head <branch> --title "<type(scope): ...>" --body-file '<path from mktemp>' && rm -f '<path from mktemp>'
```

The body goes through the temp-file pattern from `/create-pr` steps 3
and 4: `mktemp` prints a path, the Write tool fills it, and the command
uses that literal path.

List a `Closes #N` line for every issue. On a stacked child
those lines will **not** fire (stack-and-merge section 6), so the ledger
records which issues each PR is responsible for. Do not assign PRs to the
milestone: the milestone counter can count them as open items.

## Step 6: Review every PR through the push-gate

Run `/pr-review-response <PR#>` on each PR, bottom-up, and pass the review
setting into every reviewer agent it dispatches. Its user-facing steps (the
Step 6 gap analysis waits for the user's approval) stay with the orchestrator.
Never hand the whole skill to a subagent that cannot ask the user.

**Run it from the PR's worktree.** The review loops it calls edit, commit and
push in the current directory, and `/story-review-loop` starts with
`gh pr checkout`, which fails because the branch is already checked out in
`<wt>`. With `<wt>` as the current directory, skip that checkout. Three
burn-down rules override the loops' own:

- The diff under review is `git diff <parent>...HEAD`, not `git diff main`.
- A finding in a file this bundle does not own is not fixed here. It becomes
  a candidate issue, even where a loop says every finding must be fixed.
- A stale value in an ungated hot file owned by a later bundle is expected,
  not a defect (Step 2).

**Copilot.** "No comments" is not "clean" unless a Copilot review exists for
the ledger's last content head.

- The ruleset's automatic review covers only PRs that target `main`, so a
  stacked child often gets none. Request one on every PR that has none:
  `gh pr edit <N> --add-reviewer "@copilot"`.
- Copilot is **unavailable** when its review body says it could not review
  (quota, for example), or when no review arrives within 30 minutes of the
  request. Then use the fallback for the PR's type (`/pr-review-response`
  Step 1), and record which one ran:

  | PR type | Fallback |
  |---|---|
  | Story or Docs | `/story-review-loop-cope <PR#> 1` |
  | Code or Data | `/godot-review-loop <PR#> 1`. No Copilot emulation exists for code PRs, so say so in the PR's summary. |
  | Mixed | `/story-review-loop-cope <PR#> 1` first, then `/godot-review-loop <PR#> 1`, the order `/pr-review-response` Step 2 uses for Mixed PRs. |
  | Tooling (`.claude/**`, `.github/**`, `scripts/**`, `.husky/**`, root config) | `/story-review-loop-cope <PR#> 1`, three agents at the review setting. Keep each agent's gap categories and re-point its focus at the PR's real surface: shell, hooks, workflows, gates, test behavior, and the docs that describe them. `/godot-review-loop` is wrong for a PR with no `game/` files: its agents review GDScript, scenes and design-doc compliance. |

**Every PR, and the stack as a whole:**

- A stack of N PRs means N review passes. The PR you skip is the one that gets
  merged red at position 2 of 4.
- Once the whole stack has had its pass, restack once
  (stack-and-merge section 3) and re-prove each tip.

## Step 7: Merge bottom-up, under the chosen merge authority

For each PR, in order: run the pre-merge checklist, merge with
`gh pr merge <N> --merge`, then do all of the after-merge steps (wait for the
retarget, check the CI result still applies, close the issues `Closes` missed,
fix the board, update the ledger) before touching the next PR. If the next
PR is an independent sibling, rebase only that one onto the new `main`, and
wait for its fresh CI, immediately before its checklist; never every sibling
after every merge. All of this is in `references/stack-and-merge.md` sections
4 to 6 (siblings: section 6, "Independent siblings"). Any failed check stops
the sequence and goes back to the user.

- `merge=ask`: present each PR's checklist and merge after a yes.
- `merge=wave`: one yes covers the stack, but the checklist still runs
  immediately before each merge.
- `merge=never`: the user merges one PR at a time and tells you. You run the
  after-merge steps and the next PR's checklist before they merge that one.

## Step 8: Control the follow-ups, then decide on the next wave

Subagents never file issues. They return `candidate_issues` (defects),
`cross_bundle_notes` (work that belongs to another bundle) and `observations`
(everything else). The orchestrator then:

1. Routes each cross-bundle note. If the owning bundle's PR is still open, it
   becomes a fix in that PR, made through the review flow. If that PR has
   merged, the note becomes a candidate issue.
2. Reports observations to the user and goes no further with them.
3. Dedupes the candidates against each other and against open issues:
   `gh issue list --state open --limit 500 --search "<key terms>"`.
4. Files only a **genuine defect someone must fix**, with `--milestone` chosen
   by the topic of the **fix**, not by the PR that found it. A follow-up goes
   into this milestone only if this milestone's goal cannot be met without it.

**Stop rule.** Record the wave's numbers in the ledger. Issues closed in
triage count as closed. **Stop** and show the user the numbers and the new
issues if either is true:

- the milestone did not shrink: this wave filed at least as many issues into
  it as it closed, or
- this wave filed more follow-ups than the wave before it.

Either one means the reviews are producing opinions rather than findings, or
the milestone's scope is moving. The user decides whether to continue, raise
the filing bar, or stop. Ask with AskUserQuestion.

**Next step:**

- **Nothing open**, or **only `blocked-external` and `needs-design-decision`
  issues** left: go to Step 9.
- **Otherwise:** clean up the merged worktrees (Step 9 cleanup) and go back to
  Step 1 with the issues still open.

## Step 9: Declare done, or say why it cannot be

**The counter, not the issues you happened to work on.** Both of these must
read zero:

```bash
gh api repos/gcko/pendulum-of-despair/milestones/<number> -q '"open=\(.open_issues) closed=\(.closed_issues)"'
gh issue list --milestone "<title>" --state open --limit 500 --json number -q length
```

The first count can include PRs assigned to the milestone. The second counts
issues only. If they disagree, find out why before you claim anything.

**`main` is actually green.** Judge `origin/main`, not a local `main` that
may lag it. On `main`, `HEAD` equals the default base, so the diff is empty and
`gates.sh` takes its fast path, skipping the GUT suite. A pass on that signal
means nothing. Force it, in a throwaway worktree:

```bash
git fetch -q origin
git worktree add --detach ../pod-wt-verify origin/main
pnpm install -C ../pod-wt-verify --frozen-lockfile   # else gates.sh refuses: no hooks
GATES_BASE=origin/main GATES_FORCE_GODOT=1 bash ../pod-wt-verify/scripts/gates.sh
git worktree remove ../pod-wt-verify
```

Read the `RESULT scripts=... tests=...` line and check that the counts moved
the way the milestone's commits said they would.

**Unreachable zero.** If any issue is `blocked-external` or waiting on a
design decision, the milestone is not done. Say so, list the issues, and give
the user the choice. Moving an issue to another milestone needs their yes and a
comment on the issue saying why.

**Close-out**, once both counters read zero, the board audit is clean, and
`main` is green:

- Ask the user whether to close the milestone:
  `gh api -X PATCH repos/gcko/pendulum-of-despair/milestones/<number> -f state=closed`.
- **Cleanup:** for each bundle whose PR `gh pr view <N> --json state` reports
  `MERGED`: `git worktree remove <wt>`, then `git branch -D <branch>`. `-d`
  refuses, because local `main` lags `origin/main`, and the GitHub state is
  the proof the branch merged. Finish with `git worktree prune`. Leave stashes
  and worktrees you did not create alone.
- Write the ledger's final summary, then land the plane per AGENTS.md. The
  "remaining work" its first step files means genuine defects (Step 8).
  Observations are reported to the user, not filed. Every push has already
  happened from the bundles' worktrees, and nothing is pushed from the main
  checkout.

---

## Red flags: stop and re-read the step

| Thought | Reality |
|---|---|
| "A quick `until gh pr checks …; do sleep; done` will do" | It has no deadline, and a swallowed gh error looks like "pending" forever. Use `scripts/wait-ci.sh` in the background (stack-and-merge section 4, "Waiting on CI"). |
| "The builder said gates passed" | Read the RESULT line and the status line, or run the gates yourself. A report is a claim. |
| "Defaults are fine, skip the intake questions" | The user chooses the models, the effort and the merge authority. Ask. |
| "I'll fork the reviewers, it's quicker" | A fork ignores `model` and `effort`, which drops the user's choice. |
| "The bottom branch is already on main, no need to rebase it" | Then its unsigned commits ship, and the PR sits `BLOCKED` with green CI. |
| "I'll fix the derived count once, in the top branch" | Only if no gate checks it. Otherwise every lower PR is red at its own tip. |
| "This restack push only moves the base" | Then it carries nothing else. Unpushed review fixes go through the PUSH-GATE. |
| "No Copilot comments, so it's clean" | Check that a real Copilot review exists for the last content head. "Unable to review" is not one. |
| "CI was green before the retarget" | Only if `main`'s tree equals the parent's head at merge. Otherwise rebase and re-run. |
| "CI was green on the sibling before the other merged" | Those checks ran on the old `main`: not on the combined tree, and not any job the merged PR added. Rebase it just before its checklist and wait for CI on the new head (stack-and-merge section 6, "Independent siblings"). |
| "The child still targets A, merging it is fine" | A has already merged. That merge lands nowhere. Retarget to `main`. |
| "Move the blocked issue to the next milestone and we're at zero" | That is rule 5. The user decides. |
| "The subagent can just file that issue" | Only the orchestrator files: deduped, filtered for defects, milestoned. |
| "I remember where each bundle is" | After a compaction you do not. Read the ledger. |

## Related

- `/issue-bundle`: one coherent bundle, one PR
- `/pr-review-response`: the mandatory PUSH-GATE (read it from disk)
- `/story-review-loop-cope`: Copilot-style review of story, docs and tooling PRs when Copilot does not run
- `/godot-review-loop`: the review fallback for code PRs
- `/quality-gate-authoring`: for any gate or guard a bundle adds
- `/gut-tdd`: the behavioral standard tests must meet
- `references/intake.md`, `references/agent-briefs.md`,
  `references/stack-and-merge.md`, `references/ledger.md`
