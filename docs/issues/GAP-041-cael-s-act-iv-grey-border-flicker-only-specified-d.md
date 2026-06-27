# GAP-041: Cael's Act IV grey border flicker (only specified dialogue-box visual variation) not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-041 |
| **Area** | Dialogue |
| **Severity** | LOW |
| **Type** | missing-feature |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#225](https://github.com/gcko/pendulum-of-despair/issues/225) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** No grey-border-flicker capability exists: case-insensitive search of scripts/ for grey/gray/flicker/act_iv/5566aa/border found zero matches related to a border flicker (only menu_overlay.gd:268 'greyed out' comment and ritual_meter.gd:13 'light flickers' string). Border color isn't even manipulated in GDScript (no 'border' references in scripts/). Design dialogue-system.md §1 lines 41-43 specify: 'Cael's final Act IV dialogue — the border flickers grey for 2 frames, then returns to canonical blue-grey. This is the only dialogue box visual variation in the entire game.'
- **Notes:** Confirmed missing feature, correctly gated on Act IV wiring that does not exist yet. I did not independently verify the issue's secondary claim that a tracker marks 'gap 3.7 COMPLETE' without this — the feature-absence itself is verified. Fix needs an opt-in flag/command + a 2-frame border tween + tracker-note correction; not bounded now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
