# Review Gap Analysis & Skill Improvement Design Spec

**Date:** 2026-03-19
**Status:** Draft
**Scope:** Refactor story-review-loop skill architecture (extract agent
prompts, add Canonical Verifier agent, add verification checklists), add
Copilot gap analysis to pr-review-response skill.

---

## 1. Problem Statement

Across PRs #13, #14, and #15, GitHub Copilot consistently finds valid
issues that our story-review-loop misses. Analysis of 30+ Copilot comments
reveals 6 root-cause patterns, all stemming from one core failure: our
review agents check the PR diff against itself but don't systematically
verify values against canonical source docs.

Additionally, the story-review-loop SKILL.md has grown to ~500 lines with
5 full agent prompts inline. Adding more checks to each agent will make
the file unmanageable.

## 2. Design Goals

1. Close the 6 identified gap patterns so future reviews catch what
   Copilot currently catches.
2. Refactor story-review-loop into a lean orchestrator with modular
   agent prompts and reference files.
3. Add a feedback loop: every Copilot review round produces skill
   improvements, not just comment replies.
4. Keep skills lean — process in SKILL.md, details in reference files.

## 3. Gap Patterns (From PR #13-#15 Analysis)

| # | Pattern | Root Cause | Frequency |
|---|---------|-----------|-----------|
| 1 | Act assignment mismatch with canonical source | Agent doesn't verify acts against dungeons-world.md/locations.md | High |
| 2 | Dungeon type/classification mismatch (world vs city) | Agent doesn't verify dungeon type against source doc | High |
| 3 | Numeric property mismatch across files (timing, duration, stages) | Propagation check focuses on names/HP, not all numeric values | Medium |
| 4 | Mechanic exception contradicts general rule | No agent tracks exception-to-rule consistency | Medium |
| 5 | Cross-file reference format broken (section numbers, headings) | No agent validates citation format against target doc | Medium |
| 6 | Spec/plan mirror staleness after story doc fix | Mirror check instruction exists but lacks systematic mapping | Medium |

All 6 gaps share one cause: insufficient canonical source verification.

## 4. Architecture Changes

### 4.1 story-review-loop File Structure

Current (monolithic):
```
.claude/skills/story-review-loop/
  SKILL.md  (~500 lines, everything inline)
```

New (modular):
```
.claude/skills/story-review-loop/
  SKILL.md                          # Process orchestrator (~200 lines)
  agents/
    propagation.md                  # Agent 1: Entity propagation
    narrative.md                    # Agent 2: Narrative coherence
    technical.md                    # Agent 3: Technical passes A-K
    script-supervisor.md            # Agent 4: Item & continuity
    devils-advocate.md              # Agent 5: Adversarial fresh eyes
    canonical-verifier.md           # Agent 6: NEW — source verification
  references/
    verification-checklists.md      # Evolving checklist of what to verify
    gap-analysis-log.md             # Running log: Copilot finding → improvement
```

### 4.2 pr-review-response File Structure

Current:
```
.claude/skills/pr-review-response/
  SKILL.md  (~134 lines)
```

New:
```
.claude/skills/pr-review-response/
  SKILL.md                          # Core process + gap analysis step
  references/
    copilot-gap-taxonomy.md         # Gap pattern categories for classification
```

## 5. New Agent: Canonical Verifier (Agent 6)

### 5.1 Mission

For every entity referenced in the PR diff, open the canonical source
document and verify every property matches. Pure verification — no
narrative judgment.

### 5.2 What It Checks

| Entity Type | Canonical Source | Properties Verified |
|-------------|-----------------|-------------------|
| Location/town | `locations.md` | Name (exact), acts available, faction, accessibility |
| World dungeon | `dungeons-world.md` | Name (exact), acts, floor count, boss names |
| City dungeon | `dungeons-city.md` | Name (exact), acts, parent city, type classification |
| Character | `characters.md` | Name, pronouns, role/title |
| NPC | `npcs.md` | Name, location, act presence, death timing |
| Corruption stage | `dynamic-world.md`, `biomes.md` | Stage number, stage name, affected locations |
| Numeric values | Source doc for that value | Duration, timing, HP, counts — exact match |
| Cross-references | Target document | Section heading exists, format matches |

### 5.3 Why Separate From Existing Agents

- **Agent 3 (Technical)** already runs 11 passes (A-K). Adding source
  verification to every pass would overload it.
- A dedicated verifier is **focused and exhaustive** — it doesn't need
  narrative judgment, just grep + read + compare.
- It runs **in parallel** with the other 5 agents, adding no latency.
- It's the easiest agent to make comprehensive — bounded, mechanical
  work that doesn't require creative assessment.

### 5.4 Deconfliction With Agent 1 (Propagation)

Agent 1 checks cross-file consistency: "is entity X described the
same way in file A and file B?" Agent 6 checks canonical accuracy:
"does entity X in file A match the source-of-truth definition?"

Overlap example: both might flag "Frostcap Caverns says Act II but
should be Interlude." During Step 2b (Merge Findings), deduplicate by
keeping the more specific finding. Agent 6's findings are preferred
for pure value mismatches because they cite the canonical source.
Agent 1's findings are preferred for cross-file consistency issues
where no single source is authoritative.

### 5.5 Process

1. Extract every entity name from the PR diff (locations, dungeons,
   characters, NPCs, mechanics).
2. For each entity, determine the canonical source doc.
3. Open the source doc, find the entity's entry.
4. Compare every property (name, acts, type, numbers) between the PR
   content and the canonical source.
5. Report any mismatch.

The agent reads `references/verification-checklists.md` for the current
list of properties to verify. As new gaps are discovered, new checklist
items are added — the agent automatically picks them up.

## 6. Verification Checklists (Reference File)

A living document of single-line verification items. Grows from gap
analysis. Each item is one check, not a paragraph.

### 6.1 Initial Content

Seeded from the 6 gap patterns identified in PRs #13-15:

**Entity Property Verification:**
- Location act availability matches locations.md
- Dungeon act availability matches dungeons-world.md or dungeons-city.md
- Dungeon classification (world/city) matches canonical source doc
- Dungeon canonical name matches exactly (no parenthetical variants)
- Character pronouns match characters.md
- Corruption stages match dynamic-world.md / biomes.md
- Numeric properties (duration, timing, HP) match across all files

**Cross-Reference Format Verification:**
- Section citations use correct heading format from target doc
- Relative links point to files that exist
- "Per <doc>" claims reference real sections in that doc

**Mechanic Exception Tracking:**
- When a general rule is stated, verify no entity has a documented exception
- When an exception is documented, verify the general rule acknowledges it
- "Destroyed" locations should not be assigned corruption stages

**Spec/Plan Mirror Checks:**
- When music.md changes, check spec sections 3-13 for mirrored content
- When events.md section 2c changes, check spec sections 4-5
- Plan "verbatim" instructions must match actual implementation

### 6.2 Growth Rules

- New items added only from Copilot gap analysis (not speculative)
- Each item is one line, one check
- Items are grouped by category
- Redundant items are merged, not duplicated
- Items that prove false-positive-prone are removed with a note

## 7. Gap Analysis Log (Reference File)

Append-only log tracking Copilot findings and resulting skill
improvements. One entry per Copilot review round.

### 7.1 Entry Format

```markdown
### PR #XX — Review Round N (YYYY-MM-DD)

**Comments:** N total, M valid
**Gap patterns found:**
- [pattern]: [count] — [which agent missed it]

**Improvements applied:**
- Added checklist item: "[item text]"
- Updated agent prompt: [agent name] — [what changed]

**Effectiveness prediction:** These changes should catch [X] of the
[Y] issues in this round if the review were re-run.
```

### 7.2 Purpose

- Track whether the feedback loop is working (are Copilot comment
  counts decreasing per PR?)
- Identify chronic gap patterns that need structural fixes (not just
  checklist items)
- Provide data for deciding when to add new agents vs. improve
  existing ones

## 8. pr-review-response Copilot Gap Analysis

### 8.1 New Process Step

After Step 5 (Commit & Push) and before Step 6 (Reply), add:

```
5b. COPILOT GAP ANALYSIS (if any comments came from Copilot)
```

This runs BEFORE replying so the analysis can inform reply content
(e.g., "Fixed in <sha>. This gap has been added to our verification
checklists to prevent recurrence.").

### 8.2 Analysis Process

1. **Filter** Copilot comments from the review round.
2. **Categorize** each into a gap pattern from the taxonomy in
   `references/copilot-gap-taxonomy.md`.
3. **Map** each to the agent that should have caught it.
4. **Check** if the gap is already covered by an existing checklist
   item in `story-review-loop/references/verification-checklists.md`.
5. **For new gaps:**
   - Draft a new checklist item (one line)
   - Draft a gap-analysis-log entry
   - If the gap suggests a structural change (new agent behavior,
     not just a checklist item), note it separately
6. **Present** to the user:
   > "Copilot found N issues our review missed. M are already covered
   > by existing checklists (they just weren't caught this time). K
   > are new gaps. Here are the proposed improvements:
   > [list of checklist additions and agent changes]
   > Want me to apply these now?"
7. If approved, apply changes and commit.

### 8.3 Gap Taxonomy

The taxonomy in `references/copilot-gap-taxonomy.md` defines the
categories for classifying gaps:

| Category | Description | Example |
|----------|-------------|---------|
| Source verification | Value in PR doesn't match canonical source doc | Act assignment wrong |
| Classification | Entity type/category wrong | World vs city dungeon |
| Numeric propagation | Number differs between files | Timing mismatch |
| Exception tracking | General rule contradicted by specific exception | Stage 4 + Millhaven |
| Reference format | Cross-file citation broken or incorrect | Section number wrong |
| Mirror staleness | Spec/plan copy diverged from story doc | Plan says verbatim but content differs |
| Self-contradiction | Same doc contradicts itself | Rule says X, example shows Y |
| Post-fix regression | A fix introduced a new problem | Fixed timing but broke silence rule |

The first 6 categories map to the 6 gap patterns from Section 3. The
last 2 (self-contradiction, post-fix regression) are general categories
discovered in PR #14 that don't map to a specific gap pattern but
recur across reviews.

## 9. story-review-loop SKILL.md Changes

The SKILL.md becomes a lean process orchestrator:

### 9.1 What Stays

- Process flow diagram (updated for 6 agents — see 9.3)
- Step definitions (setup, review round, merge findings, fix, commit, push)
- Early exit conditions (updated: "five" → "six")
- Rules section (updated: "Five agents per round" → "Six agents per round")
- "Why Multi-Agent?" section (rationale, not bloat)

### 9.2 What Moves

- All 5 existing agent prompt templates → `agents/*.md`
- Fix step verification details → reference to `verification-checklists.md`
- PR #12 and #14 gap analysis data → `references/gap-analysis-log.md`

### 9.3 What's Added

- Agent 6 (Canonical Verifier) added to the dispatch list and process
  diagram. Node label: "Agent 6: CANONICAL\nVerify every entity against\ncanonical source docs" with fillcolor="#ccffcc". Edges mirror the
  other agents: start → agent6, agent6 → merge.
- Agent prompt dispatch mechanism: SKILL.md tells the orchestrator to
  "Read `agents/<name>.md` and include its full contents as the agent's
  prompt in the Agent tool call." The orchestrator reads the file and
  pastes its contents into the prompt parameter. No `@include` syntax —
  explicit file read + paste.
- Verification checklists: Agent 6 and Agent 1 (Propagation) read
  `references/verification-checklists.md` for current items. Other
  agents do NOT read it (keeps their prompts focused on their mission).
- All references to "five agents" updated to "six agents" throughout
  SKILL.md (Rules section, Early Exit, Log Template, Summary Template).

### 9.4 Stale References to Update

These specific lines in the current SKILL.md reference "five" and
must be updated to "six":

- Process diagram subgraph label: "Review Phase (5 agents in parallel)"
- Log template: "Agent 1 found... Agent 4 found" → add Agent 5 + 6
- Summary table: add "Canonical" column
- Agent Effectiveness table: add row for Canonical Verifier
- Rules: "Five agents per round. Always dispatch all five."
- Early exit: "If all five agents find zero issues"

### 9.5 Target Size

SKILL.md: ~350 lines (down from ~500)
Each agent file: ~60-100 lines
verification-checklists.md: ~40 lines initially, growing
gap-analysis-log.md: ~20 lines per entry, append-only

## 10. Files Changed

| File | Action | Purpose |
|------|--------|---------|
| `.claude/skills/story-review-loop/SKILL.md` | Modify | Slim to process orchestrator, add Agent 6 to dispatch |
| `.claude/skills/story-review-loop/agents/propagation.md` | Create | Agent 1 prompt (extracted from SKILL.md) |
| `.claude/skills/story-review-loop/agents/narrative.md` | Create | Agent 2 prompt (extracted) |
| `.claude/skills/story-review-loop/agents/technical.md` | Create | Agent 3 prompt (extracted, passes A-K) |
| `.claude/skills/story-review-loop/agents/script-supervisor.md` | Create | Agent 4 prompt (extracted) |
| `.claude/skills/story-review-loop/agents/devils-advocate.md` | Create | Agent 5 prompt (extracted) |
| `.claude/skills/story-review-loop/agents/canonical-verifier.md` | Create | Agent 6 prompt (NEW) |
| `.claude/skills/story-review-loop/references/verification-checklists.md` | Create | Living checklist |
| `.claude/skills/story-review-loop/references/gap-analysis-log.md` | Create | Copilot gap history |
| `.claude/skills/pr-review-response/SKILL.md` | Modify | Add gap analysis step 5b |
| `.claude/skills/pr-review-response/references/copilot-gap-taxonomy.md` | Create | Gap classification categories |

## 11. Out of Scope

- Changes to the story-review skill (it defines passes, not agents)
- Retroactive re-review of PRs #13-15
- Automated Copilot comment fetching without user invocation
- Changes to any story docs (this is skill-only)
