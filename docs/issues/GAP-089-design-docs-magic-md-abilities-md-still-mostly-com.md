# GAP-089: Design docs magic.md/abilities.md still MOSTLY COMPLETE (numeric balance) but JSON + battle already consume them

| Field | Value |
|-------|-------|
| **ID** | GAP-089 |
| **Area** | Docs |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | M |
| **Epic** | No |
| **Status** | partial — 9 of 10 magnitudes resolved in PR #358; Shiv's thrown-item branch tracked as #359 |
| **GitHub Issue** | [#238](https://github.com/gcko/pendulum-of-despair/issues/238) |
| **Source domains** | tracker |

## Summary

Dev gap 1.5 (spell/ability data) is COMPLETE and battle/menus consume the JSON, but the source docs are flagged as still needing numeric balance, so power/cost values may be unbalanced placeholders.

## Current state (implementation)

As of the 2026-06-27 audit, design-gaps marked both docs MOSTLY COMPLETE with balance caveats and dev-gaps flagged the dependency risk without an issue to close it. Since the balance pass, magic.md is COMPLETE and abilities.md is MOSTLY COMPLETE with a specific, enumerated residue.

## Desired state (per design)

A balance pass on magic/abilities completed and JSON power/cost values reconciled before Act II combat tuning.

## Proposed approach

Run a balance pass, then diff against the gap-1.5 JSON values.

## Acceptance criteria

- [x] magic.md/abilities.md balance pass done
- [x] JSON values reconciled to the docs
- [ ] Docs upgraded from MOSTLY COMPLETE — magic.md is now COMPLETE.
  abilities.md stays MOSTLY COMPLETE on a single entry: PR #358 derived
  nine of the ten qualitative magnitudes (enumerated in
  game-design-gaps.md § Ability System — damage magnitudes (9 of 10
  closed)), and left Sable's Shiv thrown-item branch open because it
  needs two design decisions no document implies — the item-type ->
  element mapping and the shape of the thrown bonus. That residue is
  tracked as issue #359 and is the only thing keeping this criterion
  unmet. Two rows of combat-formulas.md § Ability Multipliers were
  corrected under issue #333; the same table's disputed Oathkeeper
  exemplar remains open under issue #346. Runtime execution of the party
  abilities is tracked as issue #321.

## Design references

- docs/analysis/game-design-gaps.md:808,809

## Code references

- game/data/spells/ (89 spells)
- game/data/abilities/ (44 abilities + combos)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence (as of the 2026-06-27 audit; both lines have since been rewritten by the balance pass):** game-design-gaps.md:808 'Magic System | magic.md | MOSTLY COMPLETE (needs numeric balance)' and :809 'Ability System | abilities.md | MOSTLY COMPLETE (needs damage values)'. JSON data exists and is consumed: game/data/spells/ (forgewright/ley_line/spirit/streetwise/void.json) and game/data/abilities/ (cael/edren/lira/maren/sable/torren.json + combos.json). magic.md does contain a 'Spell Balance Guidelines' section (:90) and 'Balance Rules' (:103); abilities.md has 'Balance Targets' (:546).
- **Notes:** Factual status caveats are accurate. The actual gap is a balance/design pass plus a doc-status upgrade — design judgement work, not a mechanical fix. The 'unbalanced placeholders' risk is speculative (balance guidelines do exist). fixNow=FALSE.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The durable, maintained anchors are the file-plus-symbol bullets under **Code references**: those must name a file that exists and a symbol that file actually defines, and `scripts/quality-gates/check_stale_counts.py` fails the build if they do not. Always verify against current code before acting._
