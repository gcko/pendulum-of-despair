# Review Gap Analysis & Skill Improvement Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development
> (if subagents available) or superpowers:executing-plans to implement this plan.
> Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor story-review-loop into modular agent files, add a Canonical
Verifier agent, create verification checklists, and add Copilot gap analysis
to pr-review-response.

**Architecture:** Extract 5 inline agent prompts from story-review-loop SKILL.md
into `agents/*.md` files, create Agent 6 (Canonical Verifier), add reference
files for verification checklists and gap analysis log. Update pr-review-response
with a gap analysis step. No code changes — skill files only.

**Tech Stack:** Markdown, git

**Spec:** `docs/superpowers/specs/2026-03-19-review-gap-analysis-design.md`

---

## File Map

| File | Action |
|------|--------|
| `.claude/skills/story-review-loop/SKILL.md` | Modify — slim to orchestrator |
| `.claude/skills/story-review-loop/agents/propagation.md` | Create — Agent 1 prompt |
| `.claude/skills/story-review-loop/agents/narrative.md` | Create — Agent 2 prompt |
| `.claude/skills/story-review-loop/agents/technical.md` | Create — Agent 3 prompt |
| `.claude/skills/story-review-loop/agents/script-supervisor.md` | Create — Agent 4 prompt |
| `.claude/skills/story-review-loop/agents/devils-advocate.md` | Create — Agent 5 prompt |
| `.claude/skills/story-review-loop/agents/canonical-verifier.md` | Create — Agent 6 prompt (NEW) |
| `.claude/skills/story-review-loop/references/verification-checklists.md` | Create |
| `.claude/skills/story-review-loop/references/gap-analysis-log.md` | Create |
| `.claude/skills/pr-review-response/SKILL.md` | Modify — add gap analysis step |
| `.claude/skills/pr-review-response/references/copilot-gap-taxonomy.md` | Create |

---

## Chunk 1: Extract Agent Prompts and Create Reference Files

### Task 1: Create the agents/ directory and extract Agent 1 (Propagation)

**Files:**
- Create: `.claude/skills/story-review-loop/agents/propagation.md`
- Reference: `.claude/skills/story-review-loop/SKILL.md:141-186`

- [ ] **Step 1: Create agents/ directory**

```bash
mkdir -p .claude/skills/story-review-loop/agents
```

- [ ] **Step 2: Create propagation.md**

Extract the Agent 1 prompt template from SKILL.md lines 141-186. The
file should contain ONLY the prompt template content (what gets pasted
into the Agent tool call), not the SKILL.md heading or "Mission" label.
Read SKILL.md lines 141-186 and write the prompt content to
`.claude/skills/story-review-loop/agents/propagation.md`.

The file should start with the role instruction ("You are the
PROPAGATION CHECKER...") and end with the report format. Include the
spec/plan mirror check instruction (instruction 6) that was added in
a prior PR.

Also add at the top: "Also read
`references/verification-checklists.md` for current verification items
to check during propagation sweeps."

- [ ] **Step 3: Verify**

Read the created file. Confirm it matches the current SKILL.md Agent 1
prompt content exactly (with the verification-checklists addition).

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/story-review-loop/agents/propagation.md
git commit -m "chore(shared): extract Agent 1 (Propagation) prompt to agents/"
```

---

### Task 2: Extract Agents 2-5

**Files:**
- Create: `.claude/skills/story-review-loop/agents/narrative.md`
- Create: `.claude/skills/story-review-loop/agents/technical.md`
- Create: `.claude/skills/story-review-loop/agents/script-supervisor.md`
- Create: `.claude/skills/story-review-loop/agents/devils-advocate.md`
- Reference: `.claude/skills/story-review-loop/SKILL.md:187-366`

- [ ] **Step 1: Create narrative.md**

Extract Agent 2 prompt from SKILL.md lines 187-232. Start with "You
are the NARRATIVE COHERENCE CHECKER..." and end with the report format.

- [ ] **Step 2: Create technical.md**

Extract Agent 3 prompt from SKILL.md lines 233-281. Start with "You
are the TECHNICAL REVIEWER..." and end with the report format. The
header in SKILL.md says "Passes A-H" but the prompt body lists
passes A-K (Pass K was added in PR #14). Use the correct range: A-K.

- [ ] **Step 3: Create script-supervisor.md**

Extract Agent 4 prompt from SKILL.md lines 282-320. Start with "You
are the SCRIPT SUPERVISOR..." and end with the report format.

- [ ] **Step 4: Create devils-advocate.md**

Extract Agent 5 prompt from SKILL.md lines 321-366. Start with "You
are the DEVIL'S ADVOCATE..." and end with the report format.

- [ ] **Step 5: Verify all 4 files**

Read each created file. Confirm content matches SKILL.md source.

- [ ] **Step 6: Commit**

```bash
git add .claude/skills/story-review-loop/agents/
git commit -m "chore(shared): extract Agents 2-5 prompts to agents/"
```

---

### Task 3: Create Agent 6 (Canonical Verifier)

**Files:**
- Create: `.claude/skills/story-review-loop/agents/canonical-verifier.md`

- [ ] **Step 1: Write the canonical verifier prompt**

This is a NEW agent, not extracted from SKILL.md. Write to
`.claude/skills/story-review-loop/agents/canonical-verifier.md`:

```markdown
You are the CANONICAL VERIFIER. Your ONLY job is checking that every
entity in the PR matches its canonical source document. You perform
no narrative judgment — just verification.

Also read `references/verification-checklists.md` for the current
list of properties to verify.

Changed files: [list]

Instructions:

1. Extract every ENTITY NAME from the PR diff:
   - Locations/towns (any proper noun that's a place)
   - Dungeons (any named dungeon or underground area)
   - Characters/NPCs (any named person)
   - Bosses (any named enemy with stat blocks)
   - Mechanics with numeric values (corruption stages, timings,
     durations, HP values)

2. For EACH entity, determine its CANONICAL SOURCE:
   - Towns/locations → `docs/story/locations.md`
   - World dungeons → `docs/story/dungeons-world.md`
   - City dungeons → `docs/story/dungeons-city.md`
   - Characters → `docs/story/characters.md`
   - NPCs → `docs/story/npcs.md`
   - Corruption stages → `docs/story/dynamic-world.md` and
     `docs/story/biomes.md`
   - Events/flags → `docs/story/events.md`

3. Open the canonical source. Find the entity's entry. Compare
   EVERY property:
   - **Name:** Exact match? No parenthetical additions, no
     abbreviations, no near-matches.
   - **Acts available:** Does the act range in the PR match the
     canonical "Acts:" field?
   - **Type/classification:** If the PR calls it a "world dungeon",
     is it in dungeons-world.md? If "city dungeon", dungeons-city.md?
   - **Faction:** Does the faction match?
   - **Numeric values:** HP, corruption stage, timing, duration,
     floor count — exact match required.
   - **Pronouns:** Match characters.md canonical pronouns.
   - **Cross-references:** If the PR says "see biomes.md Section X",
     open biomes.md and verify that section heading exists and the
     content matches.

4. For EACH mismatch, report:
   - Entity name
   - Property that mismatches
   - PR value vs. canonical value
   - Canonical source file and line number

Report: list of {entity, property, PR value, canonical value,
source file} or "No canonical mismatches found."
```

- [ ] **Step 2: Verify**

Read the created file. Confirm it covers all entity types from the
spec (Section 5.2) and includes the verification-checklists reference.

- [ ] **Step 3: Commit**

```bash
git add .claude/skills/story-review-loop/agents/canonical-verifier.md
git commit -m "feat(shared): add Agent 6 (Canonical Verifier) prompt"
```

---

### Task 4: Create reference files

**Files:**
- Create: `.claude/skills/story-review-loop/references/verification-checklists.md`
- Create: `.claude/skills/story-review-loop/references/gap-analysis-log.md`

- [ ] **Step 1: Create references/ directory**

```bash
mkdir -p .claude/skills/story-review-loop/references
```

- [ ] **Step 2: Create verification-checklists.md**

Write to `.claude/skills/story-review-loop/references/verification-checklists.md`:

```markdown
# Verification Checklists

Reference for review agents (primarily Agent 1 and Agent 6).
Each item is a single check. Grows from Copilot gap analysis.

## Entity Property Verification

- Location act availability matches locations.md
- Dungeon act availability matches dungeons-world.md or dungeons-city.md
- Dungeon classification (world/city) matches canonical source doc
- Dungeon canonical name matches exactly (no parenthetical variants)
- Character pronouns match characters.md
- Corruption stages match dynamic-world.md / biomes.md
- Numeric properties (duration, timing, HP) match across all files

## Cross-Reference Format Verification

- Section citations use correct heading format from target doc
- Relative links point to files that exist
- "Per <doc>" claims reference real sections in that doc

## Mechanic Exception Tracking

- When a general rule is stated, verify no entity has a documented
  exception that contradicts it
- When an exception is documented, verify the general rule
  acknowledges it
- "Destroyed" locations should not be assigned corruption stages

## Spec/Plan Mirror Checks

- When music.md changes, check spec sections 3-13 for mirrored content
- When events.md section 2c changes, check spec sections 4-5
- Plan "verbatim" instructions must match actual implementation
```

- [ ] **Step 3: Create gap-analysis-log.md**

Write to `.claude/skills/story-review-loop/references/gap-analysis-log.md`:

```markdown
# Gap Analysis Log

Append-only log tracking Copilot findings vs. our review loop.
One entry per Copilot review round that produced new gaps.

---

### PR #14 — Faint Mechanic (2026-03-18)

**Comments:** 18 total across 5 Copilot review rounds
**Gap patterns found:**
- Post-fix self-contradiction: 2 — Technical agent
- Spec/plan mirror staleness: 1 — Propagation agent
- Spec/plan hygiene (metadata, commands): 2 — Technical agent

**Improvements applied:**
- Added full-section re-read rule to fix step
- Added spec/plan mirror check to Propagation agent prompt
- Added Pass K (spec/plan hygiene) to Technical agent prompt
- Tightened Pass K with scope-accuracy check

---

### PR #15 — Music Score (2026-03-18/19)

**Comments:** 21 total across 2 Copilot review rounds
**Gap patterns found:**
- Act assignment mismatch with canonical source: 3 — Technical agent
- Dungeon type/classification mismatch: 3 — Technical agent
- Numeric property mismatch: 1 — Propagation agent
- Mechanic exception contradiction: 2 — Script Supervisor
- Cross-file reference format: 1 — Technical agent
- Spec/plan mirror staleness: 1 — Propagation agent

**Improvements applied:**
- Created Agent 6 (Canonical Verifier)
- Created verification-checklists.md
- Restructured SKILL.md into modular agents/ + references/
```

- [ ] **Step 4: Commit**

```bash
git add .claude/skills/story-review-loop/references/
git commit -m "chore(shared): add verification checklists and gap analysis log"
```

---

## Chunk 2: Slim SKILL.md and Update pr-review-response

### Task 5: Slim story-review-loop SKILL.md

**Files:**
- Modify: `.claude/skills/story-review-loop/SKILL.md`

This is the largest task. Replace inline agent prompts with references
to the extracted files, add Agent 6 to the dispatch, and update all
"five" references to "six".

- [ ] **Step 1: Read the full current SKILL.md**

Read `.claude/skills/story-review-loop/SKILL.md` in full to understand
the current structure before editing.

- [ ] **Step 2: Replace Agent 1-5 prompt sections with file references**

For each agent section (lines 141-366), replace the full prompt template
with a brief reference. Example for Agent 1:

```markdown
#### Agent 1: Entity Propagation Checker

**Mission:** Verify entity descriptions are consistent across ALL files.

**Prompt:** Read `agents/propagation.md` and include its full contents
as the agent's prompt in the Agent tool call.
```

Apply the same pattern for Agents 2-5.

- [ ] **Step 3: Add Agent 6 section**

After Agent 5, add:

```markdown
#### Agent 6: Canonical Verifier

**Mission:** Verify every entity in the PR matches its canonical source
document. Pure property verification — no narrative judgment.

**Prompt:** Read `agents/canonical-verifier.md` and include its full
contents as the agent's prompt in the Agent tool call.
```

- [ ] **Step 4: Update process diagram**

In the dot graph (lines 60-107), add Agent 6:

- Change subgraph label: "Review Phase (5 agents in parallel)" →
  "Review Phase (6 agents in parallel)"
- Add node: `agent6 [label="Agent 6: CANONICAL\nVerify every entity against\ncanonical source docs", fillcolor="#ccffcc"];`
- Add edges: `start -> agent6;` and `agent6 -> merge;`

- [ ] **Step 5: Update all "five" → "six" references**

Search SKILL.md for "five" and "Five" and update:
- Rules: "Five agents per round" → "Six agents per round"
- Rules: "dispatch all five" → "dispatch all six"
- Early exit: "all five agents" → "all six agents"

- [ ] **Step 6: Update log template (Step 2e)**

Add Agent 5 and Agent 6 to the round log:

```
- Agent 5 found: [list]
- Agent 6 found: [list]
```

- [ ] **Step 7: Update summary templates (Step 3)**

Add "Canonical" column to Per-Round Results table and add a row to
Agent Effectiveness table.

- [ ] **Step 8: Move PR gap analysis data to references/**

Remove the specific PR #12 and #14 data from the "Why Multi-Agent?"
section and References section. Replace with brief summaries that point
to `references/gap-analysis-log.md` for details.

- [ ] **Step 9: Add fix step reference to verification checklists**

In Step 2c (Fix Issues), add to the propagation sweep instruction:
"Agents 1 and 6 also reference
`references/verification-checklists.md` for current items to verify."

- [ ] **Step 10: Verify the slimmed file**

Read the full SKILL.md. Confirm:
- All 6 agents are listed in dispatch section
- Process diagram has 6 agents
- No inline prompt templates remain (all moved to agents/)
- All "five" references updated to "six"
- Log and summary templates include all 6 agents
- File is roughly ~200 lines (down from ~538)

- [ ] **Step 11: Commit**

```bash
git add .claude/skills/story-review-loop/SKILL.md
git commit -m "refactor(shared): slim story-review-loop SKILL.md to orchestrator

Extract 5 agent prompts to agents/ files, add Agent 6 (Canonical
Verifier), update dispatch to 6 agents, reference verification
checklists. ~200 lines down from ~538."
```

---

### Task 6: Update pr-review-response with gap analysis

**Files:**
- Modify: `.claude/skills/pr-review-response/SKILL.md`
- Create: `.claude/skills/pr-review-response/references/copilot-gap-taxonomy.md`

- [ ] **Step 1: Create references/ directory and taxonomy file**

```bash
mkdir -p .claude/skills/pr-review-response/references
```

Write to `.claude/skills/pr-review-response/references/copilot-gap-taxonomy.md`:

```markdown
# Copilot Gap Taxonomy

Categories for classifying gaps between our story-review-loop and
Copilot findings. Used by the gap analysis step in pr-review-response.

| Category | Description | Example |
|----------|-------------|---------|
| Source verification | Value in PR doesn't match canonical source doc | Act assignment wrong |
| Classification | Entity type/category wrong | World vs city dungeon |
| Numeric propagation | Number differs between files | Timing mismatch |
| Exception tracking | General rule contradicted by specific exception | Stage 4 + Millhaven |
| Reference format | Cross-file citation broken or incorrect | Section number wrong |
| Mirror staleness | Spec/plan copy diverged from story doc | Plan says verbatim but differs |
| Self-contradiction | Same doc contradicts itself | Rule says X, example shows Y |
| Post-fix regression | A fix introduced a new problem | Fixed timing but broke silence rule |

## How to Use

1. Read each Copilot comment
2. Match it to the most specific category above
3. Map to the agent that should have caught it:
   - Source verification, Classification, Numeric propagation → Agent 6 (Canonical Verifier)
   - Exception tracking → Agent 4 (Script Supervisor)
   - Reference format → Agent 3 (Technical)
   - Mirror staleness → Agent 1 (Propagation)
   - Self-contradiction → Agent 3 (Technical, Pass F)
   - Post-fix regression → Fix step (full-section re-read)
4. Check if the gap is covered by an existing item in
   `story-review-loop/references/verification-checklists.md`
5. If not, draft a new checklist item
```

- [ ] **Step 2: Read pr-review-response SKILL.md**

Read the full current file.

- [ ] **Step 3: Add step 5b to the process**

After Step 5 (Commit and Push) section and before Step 6 (Reply),
add:

```markdown
### 5b. Copilot Gap Analysis (if Copilot commented)

If any comments came from `copilot-pull-request-reviewer[bot]`, run a
gap analysis before replying:

1. **Filter** Copilot comments from the set.
2. **Categorize** each using `references/copilot-gap-taxonomy.md`.
3. **Map** to the agent that should have caught it.
4. **Check** if the gap is already in
   `story-review-loop/references/verification-checklists.md`.
5. **For new gaps**, draft:
   - A one-line checklist item for verification-checklists.md
   - A gap-analysis-log entry
6. **Present** to the user:
   > "Copilot found N issues our review missed. M are covered by
   > existing checklists. K are new gaps:
   > [list of proposed checklist additions]
   > Want me to apply these improvements?"
7. If approved, update the checklist and log files, commit.

This step ensures every Copilot review round improves our skills.
The reply step (6) can then mention "added to our verification
checklists" for each addressed gap.
```

- [ ] **Step 4: Update the process diagram**

Add step 5b to the dot graph between commit and reply nodes.

- [ ] **Step 5: Commit**

```bash
git add .claude/skills/pr-review-response/
git commit -m "feat(shared): add Copilot gap analysis to pr-review-response

New step 5b analyzes Copilot comments, categorizes gaps, proposes
skill improvements. Includes gap taxonomy reference file."
```

---

### Task 7: Final Verification and Push

- [ ] **Step 1: Verify directory structure**

```bash
find .claude/skills/story-review-loop -type f | sort
find .claude/skills/pr-review-response -type f | sort
```

Expected:
```
.claude/skills/story-review-loop/SKILL.md
.claude/skills/story-review-loop/agents/canonical-verifier.md
.claude/skills/story-review-loop/agents/devils-advocate.md
.claude/skills/story-review-loop/agents/narrative.md
.claude/skills/story-review-loop/agents/propagation.md
.claude/skills/story-review-loop/agents/script-supervisor.md
.claude/skills/story-review-loop/agents/technical.md
.claude/skills/story-review-loop/references/gap-analysis-log.md
.claude/skills/story-review-loop/references/verification-checklists.md
.claude/skills/pr-review-response/SKILL.md
.claude/skills/pr-review-response/references/copilot-gap-taxonomy.md
```

- [ ] **Step 2: Verify SKILL.md is slim**

```bash
wc -l .claude/skills/story-review-loop/SKILL.md
```

Expected: ~350 lines (down from ~538). The reduction comes from extracting inline agent prompts to agents/ files.

- [ ] **Step 3: Verify no inline prompts remain**

Search for the old inline prompt markers:

```bash
grep -c "^You are the" .claude/skills/story-review-loop/SKILL.md
```

Expected: 0 (all prompts moved to agents/).

- [ ] **Step 4: Run lint and tests**

```bash
pnpm lint && pnpm test
```

Expected: all pass (skill-only changes, no code).

- [ ] **Step 5: Push**

```bash
git push
```
