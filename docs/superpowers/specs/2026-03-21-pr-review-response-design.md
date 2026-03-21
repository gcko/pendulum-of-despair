# PR Review Response Orchestrator Design Spec

**Date:** 2026-03-21
**Status:** Draft
**Scope:** Migrate pr-review-response skill from `~/.claude/skills/` into
this repo at `.claude/skills/pr-review-response/`, redesign as the single
post-PR orchestrator that detects PR type, runs appropriate upstream
reviews, and addresses all feedback. Also update pod-dev, story-designer,
and create-pr skills with explicit handoff language.

---

## 1. Purpose

Make `/pr-review-response <PR#>` the single entry point after a PR is
created. It detects the PR type from changed files, runs the appropriate
upstream review pipeline if one hasn't been run yet, then addresses all
human and bot review comments. This eliminates the manual "which skill
do I run next?" decision.

## 2. Design Principles

1. **Single entry point.** After creating a PR, the user runs one
   command: `/pr-review-response <PR#>`. The skill figures out the rest.
2. **PR-type-aware.** Story PRs get story-review-loop. Code PRs get
   lint/test/type-check. Mixed PRs get both. The type is detected
   automatically from the diff.
3. **Idempotent.** Re-running the skill on the same PR skips upstream
   reviews that have already been posted and only addresses new
   unaddressed comments. Safe to run multiple times.
4. **Feedback loop.** When Copilot finds issues our review agents
   missed, the skill proposes improvements to the story-review-loop
   verification checklists — closing the gap over time.
5. **Explicit handoffs.** Every skill in the chain names the next skill
   in its exit message. No ambiguity about what to do next.

## 3. PR Type Detection

### 3.1 Detection Rules

Based on `git diff main --name-only` for the PR's changed files:

| Pattern | PR Type |
|---------|---------|
| `docs/story/**` or `docs/superpowers/**` | Story |
| `packages/*/src/**` or `*.ts` or `*.js` (in packages/) | Code |
| Both Story and Code patterns | Mixed |
| `.claude/**`, `.github/**`, config files only | Tooling |

**Priority:** If both Story and Code files are present, type is Mixed.
Tooling files (`.claude/`, `.github/`, `*.json` config) are ignored
for type detection — they're incidental to the real content.

### 3.2 "Already Reviewed" Detection

Before running upstream review, check if it's already been done:

- **Story review:** Search PR comments for the string
  `"Story Review Loop Summary"`. If found, skip story-review-loop.
- **Code review:** Search PR comments for a passing CI status check
  or a `"lint/test passed"` comment. If found, skip code verification.

This makes the skill safe to re-run. If someone already ran
`/story-review-loop 17 5`, pr-review-response won't re-run it.

## 4. Upstream Review Orchestration

### 4.1 Story PRs

Dispatch story-review-loop with 3 rounds:

```
/story-review-loop <PR#> 3
```

This runs the 6-agent multi-round review (propagation, narrative,
technical, script supervisor, devil's advocate, canonical verifier).
Fixes are committed and pushed. A summary comment is posted to the PR.

After story-review-loop completes, pr-review-response continues to
Step 3 (fetch and address any human/bot comments that arrived).

### 4.2 Code PRs

Run the project's standard quality gates:

```bash
pnpm lint    # TypeScript type-check across all packages
pnpm test    # Run all tests (server + client)
```

If either fails, fix the issues before proceeding. Post a comment
summarizing what was found and fixed (or what needs human attention).

Future: When a code-review agent is added, it would run here.

### 4.3 Mixed PRs

Run both pipelines sequentially:
1. Story review (story-review-loop)
2. Code review (lint + test)

### 4.4 Tooling PRs

Run lint only (`pnpm lint`). Tooling changes rarely need deep review
but should not break type-checking.

## 5. Comment Addressing (Core Flow)

This is the existing pr-review-response behavior, retained:

### 5.1 Fetch Comments

```bash
gh api /repos/{owner}/{repo}/pulls/{pr_number}/reviews --paginate
gh api /repos/{owner}/{repo}/pulls/{pr_number}/comments --paginate
```

**CRITICAL: Always use `--paginate`.** GitHub defaults to 30 per page.
Without it, comments beyond page 1 are silently dropped.

Parse each comment for: `id`, `user.login`, `path`, `line`, `body`,
`in_reply_to_id`.

**Filter to unaddressed only:** A top-level comment is "addressed" if
it already has a reply from the repo owner or current actor. Only
process comments with NO replies yet.

### 5.2 Assess Each Comment

| Assessment | Action |
|-----------|--------|
| Valid concern | Fix in Step 5.3 |
| False positive | Explain in Step 5.5 |
| Question/clarification | Answer in Step 5.5 |
| Nitpick/style | Fix if trivial, explain if subjective |

Read the referenced file and lines before deciding. Never dismiss
without reading context.

### 5.3 Fix Valid Concerns

- Read each file referenced by valid comments
- Implement the fix
- Group related fixes (multiple comments on same file/feature)

### 5.4 Verify

```bash
pnpm lint && pnpm test
```

All checks must pass before proceeding.

### 5.5 Commit and Push

Write commit message to a temp file:

```bash
cat > /tmp/commit-msg.txt << 'EOF'
docs(scope): address PR review feedback

- Description of change 1
- Description of change 2

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>
EOF

git add <specific-files>
git commit -F /tmp/commit-msg.txt
```

Push is deferred until after Step 6 (Copilot gap analysis) if
Copilot commented. Otherwise push immediately.

### 5.6 Reply to Each Comment

Reply to every comment individually:

```bash
gh api /repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
  -f body="@username Fixed in <sha>. <explanation>"
```

**Bot usernames:** Strip `[bot]` suffix. `claude[bot]` → `@claude`.

**Copilot exception:** Do NOT `@` mention Copilot. Mentioning it
triggers follow-up PRs. Reply without any `@` mention.

## 6. Copilot Gap Analysis

If any comments came from `copilot-pull-request-reviewer[bot]`:

1. **Filter** Copilot comments from the set.
2. **Categorize** each finding:
   - Propagation (value inconsistency across files)
   - Numeric (formula/arithmetic error)
   - Formatting (style/structure)
   - Cross-reference (broken links, stale references)
   - Ambiguity (unclear language, multiple interpretations)
3. **Map** to the story-review-loop agent that should have caught it:
   - Propagation → Agent 1 (Propagation Checker)
   - Numeric → Agent 3 (Technical) or Agent 6 (Canonical Verifier)
   - Cross-reference → Agent 6 (Canonical Verifier)
   - Ambiguity → Agent 5 (Devil's Advocate)
   - Formatting → Agent 3 (Technical, Pass K)
4. **Check** if the gap is already in
   `.claude/skills/story-review-loop/references/verification-checklists.md`
5. **For new gaps**, draft a one-line checklist item.
6. **Present** to user:
   > "Copilot found N issues our review missed. M are already in
   > checklists. K are new gaps: [list]. Apply improvements?"
7. If approved, update checklist file and commit.
8. Push all commits together (fix + improvement).

## 7. Exit Messages and Handoffs

### 7.1 pr-review-response Exit Messages

**Exit A (clean):**
> "All {N} comments addressed and pushed. PR #{number} is ready to
> merge."

**Exit B (new comments arrived):**
> "Addressed {N} comments, but {M} new comments arrived during fixes.
> Re-run `/pr-review-response {number}` to address the new round."

**Exit C (needs human decision):**
> "Addressed {N} of {total} comments. {M} require human decision:
> [list of issues needing human input]
> Resolve these, then re-run `/pr-review-response {number}`."

### 7.2 Upstream Skill Exit Messages (updates)

**story-designer exit (update):**
> "Gap {id} implemented and pushed. Next step: run `/create-pr` to
> open a PR targeting main, then `/pr-review-response <PR#>` to run
> automated review."

**create-pr exit (update):**
> "PR #{number} created: {url}. Next step: run
> `/pr-review-response {number}` to detect the PR type, run automated
> review, and address any feedback."

**story-review-loop** (no change needed — pr-review-response reads
its summary comment and continues to Step 5).

### 7.3 pod-dev Workflow Chain (update)

Add to pod-dev SKILL.md:

```markdown
## Development Workflow Chain

1. `/story-designer` — design a game system (brainstorm → spec → plan → implement)
2. `/create-pr` — open a PR targeting main
3. `/pr-review-response <PR#>` — orchestrate review + address feedback
   - Auto-detects PR type (Story / Code / Mixed / Tooling)
   - Auto-runs upstream review if not already done
   - Addresses all human and bot review comments
4. Merge when pr-review-response reports "ready to merge"
```

## 8. File Map

| File | Action | Purpose |
|------|--------|---------|
| `.claude/skills/pr-review-response/SKILL.md` | Create | The orchestrator skill |
| `.claude/skills/pod-dev/SKILL.md` | Modify | Add workflow chain section + handoff language |
| `.claude/skills/story-designer/SKILL.md` | Modify | Add exit message naming next skill |
| `.claude/skills/story-review-loop/SKILL.md` | Modify | Note that pr-review-response may call it |

## 9. Iron Rules (retained from current skill)

- Reply to every comment. Reviewers deserve acknowledgment.
- Never dismiss without reading. Open the file, read context, decide.
- Tests must pass. Do not push broken code.
- One commit per review round. Group all fixes.
- Temp file for commit messages. Heredocs break with special chars.
- Explicit handoff at every exit. Name the next action.

## 10. Out of Scope

- Code review agent (future — when code PRs need deep review beyond
  lint/test, a code-review agent can be added to Step 4.2)
- Automatic PR creation after story-designer (the user explicitly
  runs `/create-pr` — keeping the human in the loop before opening PRs)
- Automatic merge (the user decides when to merge)
