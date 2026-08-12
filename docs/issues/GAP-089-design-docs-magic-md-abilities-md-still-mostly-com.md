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

- docs/analysis/game-design-gaps.md § Already Strong (No Gaps) > 'Magic System'
- docs/analysis/game-design-gaps.md § Already Strong (No Gaps) > 'Ability System'

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

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
