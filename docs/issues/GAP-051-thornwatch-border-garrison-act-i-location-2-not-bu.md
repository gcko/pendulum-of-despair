# GAP-051: Thornwatch border garrison (Act I location #2) not built

| Field | Value |
|-------|-------|
| **ID** | GAP-051 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#198](https://github.com/gcko/pendulum-of-despair/issues/198) |
| **Source domains** | world |

## Summary

No Thornwatch scene exists; the designed fortified outpost (Garrison Barracks, Armory, Commander Halda quest-giver, Watchtower scene, Border Rest Inn) gating Thornmere Wilds travel is absent.

## Current state (implementation)

Listed as a deferred sub-gap; referenced by the Thornmere overworld route.

## Desired state (per design)

Thornwatch built as an Act-I rest stop and quest hub per city-valdris.md §4.

## Proposed approach

Build Thornwatch in the Act-I content completion pass.

## Acceptance criteria

- [ ] Thornwatch scene exists with Armory + Provisioner shops
- [ ] Commander Halda is placed as a quest-giver
- [ ] Border Rest Inn provides a save/rest point

## Design references

- docs/story/city-valdris.md:877-1060

## Code references

- game/scenes/maps/towns/ (no thornwatch scene)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** No thornwatch scene exists in game/scenes/maps/towns/ (grep 'thornwatch' in game/ returns only dialogue references in data/dialogue/scene_7a_the_gates.json:9 and scene_7_the_capital.json:9: 'received word from Thornwatch. Commander Halda...'). Design city-valdris.md:877-1060 defines Thornwatch (Act I location #2) with Garrison Barracks, Armory, Commander Halda, Watchtower, Border Rest Inn.
- **Notes:** Accurate missing-feature gap. Building a town scene with shops/quest-giver/save is feature work, not a bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
