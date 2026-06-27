# GAP-039: Dialogue animation system: when-timing stubbed, standalone routing unconnected, clear/hold-reset missing

| Field | Value |
|-------|-------|
| **ID** | GAP-039 |
| **Area** | Dialogue |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | dialogue |

## Summary

_fire_animations ignores the when field (fires all at entry start); animation_requested is unconnected for standalone dialogue; cutscene_player collapses per-line timing to per-entry; and the clear control command + hold/reset rule are unimplemented (play_animation no-ops on 'clear').

## Current state (implementation)

Sprite emotion only animates inside embedded cutscenes; after_line_0 vs after_line_1 cannot be distinguished; cry can never be cleared; held anims never reset at sequence end.

## Desired state (per design)

Animations fire at the correct before_line/after_line index and route to the speaking entity in standalone dialogue; clear cancels looping/held anims to idle; held anims auto-reset at sequence end.

## Proposed approach

Implement per-box when filtering in DialogueBox, drive cutscenes box-by-box, connect animation_requested in the standalone wiring helper (GAP-037), and special-case anim=='clear' + sequence-end reset. Add cry-then-clear and held-reset tests.

## Acceptance criteria

- [ ] Animations fire at the correct line index
- [ ] Standalone NPC dialogue routes emotion to the entity
- [ ] clear returns the sprite to idle and held anims reset at sequence end

## Design references

- docs/story/dialogue-system.md §2.1/§2.2/§2.3/§3.5/§4.5

## Code references

- game/scripts/ui/dialogue_box.gd:304-318
- game/scripts/core/cutscene_player.gd:187-228
- game/scripts/entities/npc.gd:236-245
- game/scripts/core/exploration.gd:529-532


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** dialogue_box.gd:304-318 _fire_animations takes _timing_filter (underscore-prefixed = unused) and the docstring/comment (304-306) admits 'Timing filter is stubbed — all animations fire at entry start regardless of when field'; it loops and emits every animation immediately. animation_requested is unconnected for standalone dialogue (exploration only wires sfx, see GAP-037 evidence). cutscene_player.gd:216-228 _fire_entry_animations filters by when prefix (before_line/after_line) but only at entry boundaries — it calls show_dialogue([entry]) for the whole multi-line entry (line 194), so after_line_0 vs after_line_1 within one entry cannot be distinguished. npc.gd:236-245 play_animation no-ops on 'clear' (has_animation('clear') is false -> warns and returns), and there is no sequence-end held-anim reset anywhere. Design dialogue-system.md §2.2 (73-91) specifies per-line timing, cry-loop-until-clear, and hold/reset-at-sequence-end.
- **Notes:** All four sub-claims confirmed against §2.1/2.2. Fix requires per-box when filtering, box-by-box cutscene driving, standalone animation wiring (shared with GAP-037), and clear/hold-reset special-casing + tests. Not bounded.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
