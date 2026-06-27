# GAP-068: Auto-save triggers are not wired into exploration

| Field | Value |
|-------|-------|
| **ID** | GAP-068 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#209](https://github.com/gcko/pendulum-of-despair/issues/209) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** save_manager.gd:97-99 defines auto_save(); repo-wide grep for `auto_save` across scripts/ and scenes/ returns ONLY the definition — zero callers. save-system.md §6 (referenced) defines floor/town/boss/quest triggers.
- **Notes:** Confirmed no callers. Wiring into scene transitions + quest completion with mid-floor/boss-rush suppression is new cross-system logic needing tests. Not bounded. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
