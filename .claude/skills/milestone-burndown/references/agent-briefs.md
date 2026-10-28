# Agent briefs and report contracts

Every staged subagent gets one of these briefs, filled in, and returns the
matching report. The report is all the orchestrator sees, so the schema is the
contract. A field left empty is a field the orchestrator cannot act on.

Pass the stage's `model` and `effort` on the Agent call (`references/intake.md`
section 5). Send all of a stage's agents in **one message** so they run
concurrently.

A report is a claim, not proof. Every brief ends with the same rule: *say what
you verified and how; never report something as done or fixed without the
command or file evidence.* The orchestrator spot-checks reports before acting
on them (SKILL.md Steps 1 and 3).

Every brief carries a `SCRATCH:` line, `<scratchpad>/<stage>-<name>/`.
`<scratchpad>` is the orchestrator's session scratchpad; `<stage>-<name>` is
unique to the agent:

| Agent | `<stage>-<name>` | Example |
|---|---|---|
| triage verifier | `triage-<slice>`, the slice index | `triage-1` |
| research agent while planning (`references/intake.md` section 5) | `research-<n>` | `research-1` |
| builder | `build-<bundle>`, the agent's own name | `build-A` |
| reviewer | `review-<PR#>-<agent>` | `review-485-A` |

Agents share the scratchpad, so a shared scratch name lets one agent delete
another's files.

---

## Triage verifier (planning stage, read-only)

```
You are verifying GitHub issues for the milestone "<title>" in gcko/pendulum-of-despair.
Work read-only: no edits, commits, issue comments, or closes.
SCRATCH: <scratchpad>/triage-<slice>/
  Create it yourself. Write temporary files only inside it, and run skill
  commands with TMPDIR=<SCRATCH>, so mktemp files land there too. Never
  rm -rf a path outside it: other agents share the scratchpad.

Issues: #<n>, #<n>, ...   (a slice of at most 6)

For each issue:
1. Read it: gh issue view <n> --comments
2. Check every concrete claim against current main: paths, line numbers,
   values, and whether the described behavior still happens. Line numbers
   drift, so search for the code rather than trusting the number.
3. If it traces to docs/story/, read that doc. Design docs are law.

Report, one block per issue:
  issue: <n>
  verdict: open-valid | already-fixed | example-wrong | wrong-fix-requested |
           needs-design-decision | blocked-external | duplicate | epic-split
  evidence: <commit sha, file:line, command output that proves the verdict>
  real_defect: <one sentence, in your words, if the issue text is off>
  files_to_touch: <literal repo paths a fix would edit, globs only for whole dirs>
  derived_values: <counts/tables/baselines elsewhere that a fix would move>
  depends_on: <other issue numbers, or none>
  design_question: <the exact question for the user, if needs-design-decision>
```

## Builder (building stage, one per bundle)

```
You are implementing bundle <X> of a milestone burn-down in gcko/pendulum-of-despair.

WORKTREE: <absolute path>   BRANCH: <branch>   BASE: <base-sha>
  (<base-sha> is the origin/main commit your worktree was cut from. Judge
  everything against it, never against a local `main`, which may be stale.)
Work only inside this worktree. Do not cd anywhere else or touch another worktree.
SCRATCH: <scratchpad>/build-<bundle>/
  Create it yourself. Write temporary files only inside it, and run skill
  commands with TMPDIR=<SCRATCH>, so mktemp files land there too. Never
  rm -rf a path outside it: other agents share the scratchpad.

ISSUES: #<n> <title>, #<n> <title>
  For each: the verified defect from triage, <one line>, and its design-doc source.

FILES YOU OWN:        <literal paths/globs>
FILES YOU DO NOT OWN: <path> (bundle <Y>), <path> (bundle <Z>), everything else
HOT FILES:            <path>: gated, update it for your own changes | ungated, leave it (bundle <Y> owns it)

Use /gut-tdd for game logic and /quality-gate-authoring for any gate or guard.
Stop where /gut-tdd hands off to /create-pr: the orchestrator opens PRs.
Read AGENTS.md first. Its rules bind you, in particular: never --no-verify, and
Conventional Commits.

Commit as you go with `git commit -s`; each commit references its issue (Refs #<n>).
The orchestrator ran `pnpm install -C <worktree> --frozen-lockfile`, so the
hooks run on your commits. If gates.sh stops with GIT HOOKS NOT INSTALLED, run
that command yourself and say so in your report.
When finished, run the gates once from your worktree:
  GATES_BASE=<base-sha> bash <worktree>/scripts/gates.sh
and copy two lines into your report: the `RESULT scripts=... tests=...` line
(when Godot ran) and the last status line (ALL GATES PASSED or STATIC GATES PASSED).

Do NOT: push, open a PR, file, comment on or close any issue, edit a file you
do not own (gated hot files above excepted), or "just fix" something you noticed in someone else's file.
If a needed change falls outside your ownership, stop that piece and put it in
cross_bundle_notes. If a design doc is silent or ambiguous, do not invent a
value. Put the question in blocked.

Report:
  bundle: <X>
  status: done | partial | blocked
  per_issue: <n>: fixed | not fixed. <what changed>, <test that pins it>
  files_changed: <output of git diff --name-only <base-sha>...HEAD>
  commits: <output of git log --format='%h %G? %s' <base-sha>..HEAD>
  gates: <the RESULT line and the last status line of scripts/gates.sh, verbatim>
  cross_bundle_notes: <path, what, which bundle owns it>
  candidate_issues: <genuine defects someone must fix that you could not fix in
    your ownership; title + one-line evidence each. Do NOT file them.>
  observations: <"could be stronger" notes and hardening ideas. These inform
    the orchestrator and do not become issues.>
  blocked: <exact question or failure, or none>
```

## Reviewer additions (review stage)

The review loops have their own reviewer prompts. Do not replace them. When
they run inside a burn-down, add this block to each reviewer prompt so the
findings arrive in a shape the follow-up control (SKILL.md Step 8) can use:

```
This PR's base is <base: the parent PR's branch, or origin/main>. Judge it on its
own commits only: review git diff <base>...HEAD.
SCRATCH: <scratchpad>/review-<PR#>-<agent>/
  Create it yourself. Write temporary files only inside it, and run skill
  commands with TMPDIR=<SCRATCH>, so mktemp files land there too. Never
  rm -rf a path outside it: other agents share the scratchpad.
This bundle owns: <owned files>. Values in <ungated hot files> are owned by
bundle <Y> and are updated there; a stale value in them is expected here.
Classify every finding as:
  defect: wrong behavior, a broken gate, or a doc claim that is false now
  observation: could be clearer or stronger; nothing is wrong
Only defects block the PR. Whether an observation still gets fixed inside this
PR is decided by the loop's own rules. A defect in a file this bundle does not
own is never fixed here, whatever the loop says: report it as a candidate_issue
or, if a sibling bundle owns the file, as a cross_bundle_note.
You never file issues. Report observations as observations.
```
