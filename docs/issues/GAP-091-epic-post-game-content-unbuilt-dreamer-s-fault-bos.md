# GAP-091: EPIC: Post-game content unbuilt (Dreamer's Fault, boss rush, The Lingering, completion tracking)

| Field | Value |
|-------|-------|
| **ID** | GAP-091 |
| **Area** | Post-game |
| **Severity** | LOW |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | tracker |

## Summary

No Dreamer's Fault dungeon, boss rush, superboss, or completion-tracking UI exists; optional enemy data exists but nothing consumes it.

## Current state (implementation)

Tracker 4.6 NOT STARTED; depends on the Acts II-IV epic.

## Desired state (per design)

20-floor Dreamer's Fault, 3-tier boss rush with Memento accessories, The Lingering superboss, and a 4-category completion tracker at the Pendulum tavern.

## Proposed approach

Last content epic after the main game; lowest priority.

## Acceptance criteria

- [ ] Dreamer's Fault built
- [ ] Boss rush + superboss exist
- [ ] Completion tracker UI exists

## Design references

- docs/story/postgame.md
- docs/story/dungeons-world.md (Dreamer's Fault 20 floors)
- docs/story/sidequests.md (The Lingering)

## Code references

- (none — no post-game scenes)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** No post-game scaffolding exists: grep for dreamer/boss_rush/'boss rush'/'the lingering' across game/scripts returns nothing (the earlier 'completion'/'lingering' hits were unrelated generic words). scenes/ tree has only maps, ui, core, overlay, entities (no postgame dir). Optional enemy data exists (game/data/enemies/optional.json) but nothing consumes it for a boss rush/superboss. Design docs exist: docs/story/postgame.md, dungeons-world.md (Dreamer's Fault), sidequests.md (The Lingering).
- **Notes:** Genuine unbuilt EPIC, correctly flagged lowest priority and dependent on the Acts II-IV epic. Not actionable now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
