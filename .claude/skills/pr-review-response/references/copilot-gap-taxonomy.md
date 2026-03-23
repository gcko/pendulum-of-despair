# Copilot Gap Taxonomy

Categories for classifying gaps between our story-review-loop agents
and Copilot findings. Used by the **mandatory** gap analysis step in
pr-review-response (Step 6).

## Categories

| Category | Description | Agent Responsible | Example |
|----------|-------------|-------------------|---------|
| Source verification | Value in PR doesn't match canonical source doc | Agent 6 (Canonical Verifier) | Act assignment wrong, status duration doesn't match magic.md |
| Classification | Entity type/category wrong | Agent 6 (Canonical Verifier) | World vs city dungeon mislabel |
| Numeric propagation | Number differs between files or doesn't match mechanic math | Agent 1 (Propagation) | Boss phase HP vs mechanic damage totals inconsistent |
| Exception tracking | General rule contradicted by specific exception | Agent 4 (Script Supervisor) | Stage 4 + Millhaven, immunity overriding floor |
| Reference format | Cross-file citation broken or incorrect | Agent 3 (Technical) | Section number wrong, broken link |
| Mirror staleness | Spec/plan copy diverged from story doc | Agent 1 (Propagation) | Plan says "will be updated" but update already shipped |
| Self-contradiction | Same doc contradicts itself | Agent 3 (Technical, Pass F) | Rule says X, example shows Y; summary contradicts table |
| Post-fix regression | A fix introduced a new problem | Fix step (full-section re-read) | Fixed timing but broke silence rule |
| Formula precision | Missing rounding rules, incomplete formula terms, stated ranges that don't match formula outputs | Agent 3 (Technical) | 255/256 != 1.0; floor vs round unspecified |
| Ambiguity | Unclear language, multiple interpretations, undefined edge cases | Agent 5 (Devil's Advocate) | "1.5x damage" vs "+50% damage"; timer behavior during pause |

## Agent Mapping

| Agent | Categories Caught | PR #17 Hits | PR #18 Hits | PR #22 Hits |
|-------|-------------------|------------|------------|------------|
| Agent 1 (Propagation) | Mirror staleness, Numeric propagation | 5 | 6 | 6 |
| Agent 3 (Technical) | Self-contradiction, Formula precision, Reference format | 10 | 1 | 1 |
| Agent 4 (Script Supervisor) | Exception tracking | 0 | 0 | 0 |
| Agent 5 (Devil's Advocate) | Ambiguity | 2 | 4 | 2 |
| Agent 6 (Canonical Verifier) | Source verification, Classification | 1 | 5 | 4 |

## How to Use

1. Filter Copilot comments (user.login == "Copilot")
2. For EACH comment:
   a. Match to the most specific category above
   b. Map to the responsible agent
   c. Check `story-review-loop/references/verification-checklists.md`
   d. If not covered, draft a one-line checklist item
3. Present new items to user for approval
4. Commit approved items to verification-checklists.md
5. Add entry to gap-analysis-log.md

## Gap Analysis Log

### PR #17 (2026-03-21) — 20 Copilot comments, 12 gaps

**Top patterns:**
- Formula precision (variance 100% vs 99.61%): 4 comments, same root cause
- Self-contradiction (floor omission, crit contradiction): 5 comments
- Mirror staleness (spec/plan copies stale): 3 comments

**Outcome:** 11 new checklist items proposed, all applied.

### PR #18 (2026-03-21) — 14 Copilot comments, 6 gaps

**Top patterns:**
- Mirror staleness (stale "will be updated" notes): 4 comments
- Source verification (Sleep/Petrify cures wrong): 3 comments
- Ambiguity (Berserk notation, Wait mode timers): 3 comments

**Outcome:** Checklist items from PR #17 would have caught 3 of 6.
Remaining 3 covered by new items.

### PR #19 (2026-03-22) — 30 Copilot comments across 4 rounds, ~20 gaps

**Top patterns:**
- Formatting (em dash vs double-hyphen, en dash for ranges): 8 comments
- Elemental profile mismatch (act file vs palette-families): 6 comments
- Self-contradiction (Vein Guardian type/phase, spec count): 5 comments
- Copyright/tooling (reference bestiaries, scraper): 4 comments
- Boss mechanic accuracy (Vein Guardian phases): 2 comments

**Outcome:** Story-review-loop caught 29% initially. Step 6b process
added. Verification checklists updated with role-based exception
documentation rule.

### PR #20 (2026-03-22) — 26 Copilot comments across 2 rounds, ~18 gaps

**Top patterns:**
- Mirror staleness (role bounds in spec/plan/CONTINUATION): 6 comments
- Boss mechanic divergence (Cordwyn abilities, Ashen Ram phases,
  Forge Warden resistance — details differ from dungeons-world.md): 5 comments
- Elemental profile mismatch (act-ii vs palette-families): 6 comments
- Count inconsistency (12 vs 11 families): 2 comments
- Conditional weakness not in stat table: 1 comment

**Outcome:** Story-review-loop caught 73% initially (up from 29% on
PR #19). 5 new checklist items added to "Mirror Propagation" section.
Root cause: propagation sweep after updating README.md role limits
did not grep ALL files for the old values. Boss mechanic notes need
word-by-word comparison with dungeon source, not just HP verification.

### PR #22 (2026-03-23) — 16 Copilot comments across 2 rounds, ~12 gaps

**Top patterns:**
- Classification (name collision, tier mislabel, tier cap): 4 comments
  - Pallor Regent name collision (Royal Wraith Tier 3 vs Hawk Tier 4)
  - Storm Wraith listed as Tier 3 (is Tier 2 in palette-families)
  - Hawk family only has 3 tiers — no Tier 4 exists
- Mirror staleness (type in spec/plan, elemental profiles): 6 comments
  - Void Moth type=Beast in spec/plan (should be Elemental)
  - Roc missing Weak=Storm per palette-families
  - Pictograph Wisp missing Absorbs=Ley per palette-families
  - Void Crystal weakness already fixed but Copilot reviewed old commit
- Numeric propagation (threat multiplier, level mismatch): 2 comments
  - Thunder Drake/Void Moth deployed at lower level+threat than projected
- Ambiguity (missing early deployment notes): 2 comments
  - Thunder Drake, Void Moth, Void Wisp all lacked notes
- Reference format (naming inconsistency): 1 comment
  - "Crystal Warden Deep" vs "Crystal Warden (Deep)"

**Outcome:** Story-review-loop (Round 1, pre-Copilot) caught 15 issues.
Copilot then found 16 more across 2 rounds. 5 new checklist items
proposed. Root cause: agents don't verify tier labels in summaries,
don't check name uniqueness across families, and don't enforce early
deployment notes for all level gaps >5. PROCESS FAILURE: Step 6 (gap
analysis) and Step 6b (story-review-loop) were BOTH skipped on
Copilot Round 2. Root cause identified as system-reminder loading
incomplete skill version. Structural fix applied to AGENTS.md and
skill frontmatter.

### PR #22 Round 3 (2026-03-23) — 3 Copilot comments, 2 new gaps

**Patterns:**
- Mirror staleness (Shadow Wolf elemental profile): 1 comment — already
  covered by existing checklist item
- Self-contradiction (Pictograph Wisp note says variable absorption,
  stat table says fixed Ley): 1 comment — new pattern
- Ambiguity (Confluence Elemental "—" reads as "none" when profile
  actually varies by cycle): 1 comment — new pattern

**Outcome:** 2 new checklist items added to "Stat Table Clarity" section.
First round where Step 6 gap analysis was properly executed per the
structural fix. Process working as intended.

### PR #22 Round 6 (2026-03-23) — 2 Copilot comments, 1 new gap

**Patterns:**
- Reference format (Vaelith Drop column has two items combined with
  "+", breaking single-item convention): 1 comment — new pattern
- Post-fix regression (Pallor Regent early deployment note references
  enemy not in act-iii after rename to Pallor Roc): 1 comment —
  covered by existing propagation sweep rule

**Outcome:** 1 new checklist item added to "Stat Table Clarity"
(single item per Drop/Steal cell). Propagation sweep should have
caught the stale Pallor Regent note during the rename.
