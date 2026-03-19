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

---

### PR #15 — Music Score, Copilot Review Round 3 (2026-03-19)

**Comments:** 12 total
**Gap patterns found:**
- Source verification (act assignments): 3 — would be caught by Agent 6
- Classification (world vs city dungeon): 3 — would be caught by Agent 6
- Numeric propagation (Pallor timing): 1 — would be caught by Agent 6
- Exception tracking (Millhaven Stage 4): 2 — would be caught by Agent 4
- Reference format (section citation): 1 — would be caught by Agent 3
- Mirror staleness (plan "verbatim"): 1 — would be caught by Agent 1
- Post-fix regression (Pallor timing in table): 1 — would be caught by fix step re-read

**All 12 covered by existing verification checklist items.** No new
checklist items needed. This confirms the Agent 6 + checklists refactor
addresses the gap patterns identified in the prior round.

**Effectiveness prediction:** If Agent 6 had been running, it would have
caught 8 of 12 issues. Combined with existing agents, 12 of 12 would
have been caught.

---

### PR #15 — Music Score + Skill Refactor, Copilot Review Round 4 (2026-03-19)

**Comments:** 15 total (initially missed due to API pagination bug)
**Infrastructure fix:** Added `--paginate` to all `gh api` calls in
pr-review-response and story-review skills. GitHub API defaults to 30
results per page; PR #15 had 61 total comments across 4 review rounds.

**Gap patterns found:**
- Source verification (town act assignments): 4 — Agent 6
- Classification (Corrund Sewers world vs city): 2 — Agent 6
- Self-contradiction (section numbering, bird call, diagram drift): 4 — Agent 3 (Pass F)
- Spec hygiene (plan line count, step reference): 2 — Agent 3 (Pass K)
- Workflow ambiguity (double-push): 1 — Agent 3 (Pass F)
- PR scope (not a code gap): 1 — N/A
- Exception tracking (Millhaven terminology): 1 — Agent 4

**New checklist items added (4):**
- Section numbering is monotonic
- Diagram labels match the text they summarize
- Terms in adjacent paragraphs don't contradict each other
- Multi-step workflow descriptions have unambiguous ordering

**Effectiveness note:** 10 of 15 covered by existing checklists.
4 new "Internal Coherence" items added for newly written content.
1 was a PR scope concern (not actionable as a checklist item).
