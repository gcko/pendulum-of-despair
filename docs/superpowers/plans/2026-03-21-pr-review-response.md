# PR Review Response Orchestrator Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the pr-review-response skill as the single post-PR
orchestrator that detects PR type, runs upstream reviews, and addresses
all feedback. Update all skills in the chain with explicit handoff language.

**Architecture:** Rewrite one skill file (pr-review-response), pull
create-pr into the project and add handoff, modify three others
(pod-dev, story-designer, story-review-loop) with handoff language.
Pure documentation/skill changes — no code changes.

**Tech Stack:** Markdown skill files, git

**Spec:** `docs/superpowers/specs/2026-03-21-pr-review-response-design.md`

---

## File Map

| File | Action | Purpose |
|------|--------|---------|
| `.claude/skills/pr-review-response/SKILL.md` | Rewrite | Orchestrator with PR type detection |
| `.claude/skills/create-pr/SKILL.md` | Create | Pull from user-level, add exit handoff |
| `.claude/skills/pod-dev/SKILL.md` | Modify | Add workflow chain section |
| `.claude/skills/story-designer/SKILL.md` | Modify | Add exit handoff message |
| `.claude/skills/story-review-loop/SKILL.md` | Modify | Note orchestrator integration |

---

## Chunk 1: Rewrite pr-review-response Skill

### Task 1: Rewrite `.claude/skills/pr-review-response/SKILL.md`

**Files:**
- Rewrite: `.claude/skills/pr-review-response/SKILL.md`
- Reference: `docs/superpowers/specs/2026-03-21-pr-review-response-design.md`

- [ ] **Step 1: Read the current skill file**

Read `.claude/skills/pr-review-response/SKILL.md` to understand what
exists. The current file has 173 lines covering: fetch, assess, fix,
verify, commit, Copilot gap analysis, reply, summarize. We keep all
of this and add orchestration on top.

- [ ] **Step 2: Write the new skill file**

Replace the entire file with the orchestrator version. The new file
structure:

```
---
name: pr-review-response
description: [updated to mention orchestration and PR type detection]
---

# PR Review Response (Orchestrator)

> Single entry point after PR creation.

## Invocation
  /pr-review-response <PR number or URL>

## Process (flow diagram)
  - Updated diagram with type detection and upstream review steps

## Step 1: Detect PR Type
  - Detection rules table (Story/Code/Mixed/Tooling/Docs)
  - Priority rules
  - Fallback for unrecognized patterns

## Step 2: Run Upstream Review (if not already run)
  ### Already Reviewed Detection
  - Story: substring match "Story Review Loop Summary" in PR comments
  - Code: match "pnpm lint && pnpm test" + "passed" in PR comments
  ### Story PRs
  - Dispatch /story-review-loop <PR#> 3
  ### Code PRs
  - pnpm lint && pnpm test
  ### Mixed PRs
  - Both pipelines, story first then code
  ### Tooling PRs
  - pnpm lint only
  ### Docs PRs
  - pnpm lint only

## Step 3: Fetch Comments
  - gh api with --paginate (CRITICAL)
  - Filter to unaddressed top-level only

## Step 4: Assess & Fix
  - Assessment table (valid/false-positive/question/nitpick)
  - Read context before deciding
  - Group related fixes
  - Verify: pnpm lint && pnpm test

## Step 5: Commit
  - Temp file for commit message
  - Push deferred if Copilot commented

## Step 6: Copilot Gap Analysis (if applicable)
  - Filter Copilot comments
  - Categorize (propagation/numeric/formatting/cross-ref/ambiguity)
  - Map to review agent (story PRs) or log (code PRs)
  - Check existing checklists
  - Propose improvements
  - Push all commits together

## Step 7: Reply
  - Reply to every comment individually
  - Copilot exception (no @mention)
  - Bot username stripping

## Step 8: Exit with Handoff
  - Exit A: "All addressed. PR ready to merge."
  - Exit B: "New comments arrived. Re-run /pr-review-response <PR#>."
  - Exit C: "Issues remain that need human decision. [list]"

## Iron Rules
  - All existing rules retained
  - Added: Explicit handoff at every exit
```

The complete content should be transcribed from spec sections 3-7,
reformatted as a skill file (remove spec section numbers, add frontmatter,
use skill conventions). Retain all code blocks, tables, and process
descriptions from the current skill where the spec doesn't replace them.

Key differences from the current skill:
- New frontmatter description mentioning orchestration
- New Step 1 (type detection) and Step 2 (upstream review)
- "Already reviewed" detection before dispatching upstream review
- Docs type added (for non-story markdown)
- Copilot gap analysis scoped by PR type (story vs code)
- Three explicit exit messages with handoff instructions
- Claude re-review trigger REMOVED (not in this repo)

- [ ] **Step 3: Verify the skill file**

After writing:
1. Check that all process steps from the spec are represented
2. Verify the flow diagram includes type detection and upstream review
3. Confirm no references to Claude re-review workflow remain
4. Confirm the exit messages match spec Section 7.1 exactly

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/pr-review-response/SKILL.md
cat > /tmp/commit-msg.txt << 'EOF'
chore(shared): rewrite pr-review-response as orchestrator skill

Single post-PR entry point with PR type detection (Story/Code/Mixed/
Tooling/Docs), upstream review orchestration (auto-runs story-review-loop
for story PRs), and explicit exit handoffs. Removes Claude re-review
trigger. Retains Copilot gap analysis with type-aware agent mapping.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 1b: Pull create-pr skill into project and add exit handoff

**Files:**
- Create: `.claude/skills/create-pr/SKILL.md`
- Reference: `~/.claude/skills/create-pr/SKILL.md` (user-level source)

- [ ] **Step 1: Read the user-level create-pr skill**

Read `~/.claude/skills/create-pr/SKILL.md` to get the current content
(122 lines covering: test, lint, check status, push, write PR body,
create PR, output URL).

- [ ] **Step 2: Copy into project with exit handoff added**

Create `.claude/skills/create-pr/SKILL.md` with the full content from
the user-level skill, plus these changes:

1. After the "### 7. Output the PR URL" section, add a new section:

```markdown
### 8. Exit with Handoff

After outputting the PR URL, always end with:

> "PR #{number} created: {url}. Next step: run
> `/pr-review-response {number}` to detect the PR type, run automated
> review, and address any feedback."
```

2. Update the description frontmatter to mention the handoff:

```yaml
description: >
  Use when work is complete and ready to open a pull request. Runs tests,
  lint, commits, pushes, creates the PR targeting main, and names
  /pr-review-response as the next step. Invoke when asked to create or
  open a PR.
```

3. Update verification commands to match this project:
   - Replace `pnpm exec biome check` with `pnpm lint` (this project
     uses TypeScript type-checking, not Biome)
   - Remove `-s` flag from `git commit` (this project uses commitlint
     hooks, not DCO sign-off)

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/create-pr/SKILL.md
cat > /tmp/commit-msg.txt << 'EOF'
chore(shared): pull create-pr skill into project with exit handoff

Copy from user-level skill, add Step 8 exit message naming
/pr-review-response as next step. Update lint commands for this
project (pnpm lint instead of biome).
EOF
git commit -F /tmp/commit-msg.txt
```

---

## Chunk 2: Update Handoff Language in Other Skills

### Task 2: Add workflow chain to pod-dev SKILL.md

**Files:**
- Modify: `.claude/skills/pod-dev/SKILL.md` (after line ~183, end of file)

- [ ] **Step 1: Read the end of pod-dev SKILL.md**

Read the file to confirm where to add the new section. It should go
after the "How to Start a New Session" section (the last section).

- [ ] **Step 2: Add the workflow chain section**

Append after the last line:

```markdown

## Development Workflow Chain

The skills in this project form a pipeline. Each skill names the next
step in its exit message.

| Step | Skill | What It Does | Next Step |
|------|-------|-------------|-----------|
| 1 | `/story-designer` | Design a game system (brainstorm, spec, plan, implement) | `/create-pr` |
| 2 | `/create-pr` | Open a PR targeting main (tests, lint, push, create) | `/pr-review-response <PR#>` |
| 3 | `/pr-review-response <PR#>` | Orchestrate review + address feedback | Merge (or re-run) |

**How `/pr-review-response` works as orchestrator:**
- Detects PR type from changed files (Story / Code / Mixed / Tooling / Docs)
- Auto-runs upstream review if not already done:
  - Story PRs → `/story-review-loop <PR#> 3`
  - Code PRs → `pnpm lint && pnpm test`
  - Mixed → both pipelines
- Fetches and addresses all human and bot review comments
- Proposes review skill improvements when Copilot finds gaps
- Reports "ready to merge" or "re-run needed" at exit
```

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/pod-dev/SKILL.md
cat > /tmp/commit-msg.txt << 'EOF'
chore(shared): add development workflow chain to pod-dev skill

Documents the skill-to-skill pipeline: story-designer -> create-pr ->
pr-review-response (orchestrator) -> merge. Describes how pr-review-response
auto-detects PR type and runs appropriate upstream review.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 3: Add exit handoff to story-designer SKILL.md

**Files:**
- Modify: `.claude/skills/story-designer/SKILL.md` (Design Session Flow section, ~line 217)

- [ ] **Step 1: Read the Design Session Flow section**

Read `.claude/skills/story-designer/SKILL.md` around lines 200-230 to
find the example session flow and the Rules section that follows.

- [ ] **Step 2: Update the example session exit message**

In the Design Session Flow example, the current exit is:
```
Claude: "Stat system complete. This unblocks: 1.1 (Damage Formulas),
         2.2 (ATB Mechanics). Recommend 1.1 next."
```

Replace with:
```
Claude: "Stat system complete. This unblocks: 1.1 (Damage Formulas),
         2.2 (ATB Mechanics). Recommend 1.1 next.

         Next step: run `/create-pr` to open a PR targeting main,
         then `/pr-review-response <PR#>` to run automated review."
```

- [ ] **Step 3: Add handoff rule to the Rules section**

In the Rules section (starts around line 220), add a new rule:

```markdown
- **Exit with handoff.** Every session ends by naming the next skill:
  `/create-pr` to open a PR, then `/pr-review-response <PR#>` to
  orchestrate review.
```

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/story-designer/SKILL.md
cat > /tmp/commit-msg.txt << 'EOF'
chore(shared): add exit handoff language to story-designer skill

Example session flow and rules now explicitly name /create-pr and
/pr-review-response as the next steps after gap completion.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 4: Note orchestrator integration in story-review-loop SKILL.md

**Files:**
- Modify: `.claude/skills/story-review-loop/SKILL.md` (near the top, after the dependency note)

- [ ] **Step 1: Read the top of story-review-loop SKILL.md**

Read lines 1-25 to find the dependency note block that starts with
`> **Dependency:**`.

- [ ] **Step 2: Add orchestrator integration note**

After the existing `> **Dependency:**` block (around line 20), add:

```markdown
> **Orchestrator integration:** This skill may be called automatically
> by `/pr-review-response` when it detects a Story or Mixed PR type.
> When called this way, the skill operates normally — it does not need
> to know it was dispatched by an orchestrator. Its summary comment
> (`# Story Review Loop Summary (Multi-Agent)`) is used by
> pr-review-response to detect that the review has already been run.
```

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/story-review-loop/SKILL.md
cat > /tmp/commit-msg.txt << 'EOF'
chore(shared): note orchestrator integration in story-review-loop

Documents that pr-review-response may call this skill automatically
for Story/Mixed PRs, and that the summary comment header is used for
"already reviewed" detection.
EOF
git commit -F /tmp/commit-msg.txt
```

---

### Task 5: Final Verification and Push

- [ ] **Step 1: Verify all skill files**

1. Read `.claude/skills/pr-review-response/SKILL.md` — confirm:
   - Frontmatter has updated description mentioning orchestration
   - Step 1 (type detection) has all 5 types: Story/Code/Mixed/Tooling/Docs
   - Step 2 has "already reviewed" detection with substring match
   - No Claude re-review trigger exists
   - Three exit messages match spec Section 7.1
   - Iron Rules include "Explicit handoff at every exit"

2. Read `.claude/skills/pod-dev/SKILL.md` — confirm:
   - "Development Workflow Chain" section exists at end
   - Three-step table: story-designer -> create-pr -> pr-review-response
   - pr-review-response orchestrator behavior described

3. Read `.claude/skills/story-designer/SKILL.md` — confirm:
   - Example session flow includes handoff to create-pr and pr-review-response
   - Rules section includes "Exit with handoff" rule

4. Read `.claude/skills/create-pr/SKILL.md` — confirm:
   - Step 8 exists with exit handoff naming /pr-review-response
   - Lint command is `pnpm lint` (not biome)
   - No `-s` flag on git commit

5. Read `.claude/skills/story-review-loop/SKILL.md` — confirm:
   - Orchestrator integration note exists after dependency note
   - Notes the summary comment header is used for detection

- [ ] **Step 2: Run lint and tests**

```bash
pnpm lint && pnpm test
```

Expected: all pass (skill file changes don't affect code).

- [ ] **Step 3: Push**

```bash
git push
```
