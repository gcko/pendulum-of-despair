# GAP-068: Auto-save triggers are not wired into exploration

| Field | Value |
|-------|-------|
| **ID** | GAP-068 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save, tracker |

## Summary

SaveManager.auto_save() exists but has zero callers; none of the four designed triggers (dungeon-floor entry, boss zone, town entry, sidequest complete) invoke it.

## Current state (implementation)

Tracker confirms auto-save triggers deferred until exploration is stable.

## Desired state (per design)

Exploration/scene-transition and quest systems call auto_save() at the four trigger points, suppressing mid-floor and boss-rush.

## Proposed approach

Hook auto-save at flagged floor/town transitions, at boss trigger zones before fight start, and on quest-complete; guard suppression cases.

## Acceptance criteria

- [ ] Auto-save fires on floor/town/boss/quest triggers
- [ ] Mid-floor and boss-rush are suppressed
- [ ] Writes to the auto slot

## Design references

- docs/story/save-system.md §6
- docs/story/difficulty-balance.md (anti-frustration)

## Code references

- game/scripts/autoload/save_manager.gd:97-99

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
