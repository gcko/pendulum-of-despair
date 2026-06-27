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
- docs/analysis/game-dev-gaps.md:1037


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scripts/core/exploration.gd:200 loads 'dungeons/ember_vein_f1' on new game (triggered from title.gd:71-72 NEW_GAME). No Aelhart scene exists anywhere (only a data/shops 'aelhart_general' shop JSON referenced by tests). docs/story/city-valdris.md §2 (line 503) still presents 'Aelhart (Starting Village)' as Act-I location #1, the canonical tutorial opening, with Inn/General Store/Carradan Stall/watermill/Dry Well. Docs and code disagree silently.
- **Notes:** Genuine design-divergence. The 'fix' requires a human design DECISION (build Aelhart as the tutorial town vs. demote it and amend city-valdris.md/script for the Ember-Vein-first opening) — not a mechanical correction I can safely apply unilaterally, so fixNow is false. Once decided, the resolution is primarily a doc reconciliation.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
