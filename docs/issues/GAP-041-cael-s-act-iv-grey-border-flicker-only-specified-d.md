# GAP-041: Cael's Act IV grey border flicker (only specified dialogue-box visual variation) not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-041 |
| **Area** | Dialogue |
| **Severity** | LOW |
| **Type** | missing-feature |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | dialogue |

## Summary

No grey-border-flicker capability exists; tracker claims it deferred to gap 3.7, but 3.7 is marked COMPLETE without it (false-completion).

## Current state (implementation)

grep for grey/flicker/act_iv returns nothing.

## Desired state (per design)

During Cael's final Act IV dialogue the border flickers grey ~2 frames then restores blue-grey.

## Proposed approach

Add an opt-in flag (entry meta or cutscene command) triggering a 2-frame border tween; correct the tracker note. Low priority until Act IV wiring exists.

## Acceptance criteria

- [ ] A cutscene flag triggers the 2-frame grey flicker
- [ ] Border restores to canonical color afterward
- [ ] Tracker note corrected

## Design references

- docs/story/dialogue-system.md §1

## Code references

- game/scripts/ui/dialogue_box.gd
- game/scripts/core/cutscene_player.gd

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
