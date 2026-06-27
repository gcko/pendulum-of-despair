# GAP-089: Design docs magic.md/abilities.md still MOSTLY COMPLETE (numeric balance) but JSON + battle already consume them

| Field | Value |
|-------|-------|
| **ID** | GAP-089 |
| **Area** | Docs |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#238](https://github.com/gcko/pendulum-of-despair/issues/238) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game-design-gaps.md:808 'Magic System | magic.md | MOSTLY COMPLETE (needs numeric balance)' and :809 'Ability System | abilities.md | MOSTLY COMPLETE (needs damage values)'. JSON data exists and is consumed: game/data/spells/ (forgewright/ley_line/spirit/streetwise/void.json) and game/data/abilities/ (cael/edren/lira/maren/sable/torren.json + combos.json). magic.md does contain a 'Spell Balance Guidelines' section (:90) and 'Balance Rules' (:103); abilities.md has 'Balance Targets' (:546).
- **Notes:** Factual status caveats are accurate. The actual gap is a balance/design pass plus a doc-status upgrade — design judgement work, not a mechanical fix. The 'unbalanced placeholders' risk is speculative (balance guidelines do exist). fixNow=FALSE.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
