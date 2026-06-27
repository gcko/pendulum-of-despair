# GAP-089: Design docs magic.md/abilities.md still MOSTLY COMPLETE (numeric balance) but JSON + battle already consume them

| Field | Value |
|-------|-------|
| **ID** | GAP-089 |
| **Area** | Docs |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | tracker |

## Summary

Dev gap 1.5 (spell/ability data) is COMPLETE and battle/menus consume the JSON, but the source docs are flagged as still needing numeric balance, so power/cost values may be unbalanced placeholders.

## Current state (implementation)

design-gaps marks both docs MOSTLY COMPLETE with balance caveats; dev-gaps flags the dependency risk without an issue to close it.

## Desired state (per design)

A balance pass on magic/abilities completed and JSON power/cost values reconciled before Act II combat tuning.

## Proposed approach

Run a balance pass, then diff against the gap-1.5 JSON values.

## Acceptance criteria

- [ ] magic.md/abilities.md balance pass done
- [ ] JSON values reconciled to the docs
- [ ] Docs upgraded from MOSTLY COMPLETE

## Design references

- docs/analysis/game-design-gaps.md:808,809

## Code references

- game/data/spells/ (89 spells)
- game/data/abilities/ (44 abilities + combos)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
