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

| Agent | Categories Caught | PR #17 Hits | PR #18 Hits |
|-------|-------------------|------------|------------|
| Agent 1 (Propagation) | Mirror staleness, Numeric propagation | 5 | 6 |
| Agent 3 (Technical) | Self-contradiction, Formula precision, Reference format | 10 | 1 |
| Agent 4 (Script Supervisor) | Exception tracking | 0 | 0 |
| Agent 5 (Devil's Advocate) | Ambiguity | 2 | 4 |
| Agent 6 (Canonical Verifier) | Source verification, Classification | 1 | 5 |

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
