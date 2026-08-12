# GAP-050: Aelhart starting village not built; new game starts in Ember Vein F1, contradicting the design

| Field | Value |
|-------|-------|
| **ID** | GAP-050 |
| **Area** | World |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | design-divergence |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#197](https://github.com/gcko/pendulum-of-despair/issues/197) |
| **Source domains** | world |

## Summary

No Aelhart scene exists; new-game start was moved to Ember Vein F1 while city-valdris.md still presents Aelhart as the canonical tutorial opening — docs and code disagree silently.

## Current state (implementation)

Aelhart is listed only as a deferred sub-gap; the design doc was never reconciled with the Ember-Vein-first restructure.

## Desired state (per design)

Either build Aelhart as the Act-I tutorial town (Inn save, General Store, Carradan Stall, Elder's House, watermill, Dry Well), or amend city-valdris.md/script to document the Ember-Vein-first opening and demote Aelhart.

## Proposed approach

Make an explicit decision and either build Aelhart or reconcile the docs.

## Acceptance criteria

- [ ] A decision is recorded reconciling start location
- [ ] If built, Aelhart serves as the safe tutorial opening
- [ ] If demoted, docs reflect the Ember-Vein-first start

## Design references

- docs/story/city-valdris.md:503-657 (Aelhart, Act I location #1)
- docs/story/dungeons-world.md:2689

## Code references

- game/scenes/maps/dungeons/ember_vein_f1.tscn
- docs/analysis/game-dev-gaps.md


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scripts/core/exploration.gd:200 loads 'dungeons/ember_vein_f1' on new game (triggered from title.gd:71-72 NEW_GAME). No Aelhart scene exists anywhere (only a data/shops 'aelhart_general' shop JSON referenced by tests). docs/story/city-valdris.md §2 (line 503) still presents 'Aelhart (Starting Village)' as Act-I location #1, the canonical tutorial opening, with Inn/General Store/Carradan Stall/watermill/Dry Well. Docs and code disagree silently.
- **Notes:** Genuine design-divergence. The 'fix' requires a human design DECISION (build Aelhart as the tutorial town vs. demote it and amend city-valdris.md/script for the Ember-Vein-first opening) — not a mechanical correction I can safely apply unilaterally, so fixNow is false. Once decided, the resolution is primarily a doc reconciliation.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
