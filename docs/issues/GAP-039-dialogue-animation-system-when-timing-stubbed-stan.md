# GAP-039: Dialogue animation system: when-timing stubbed, standalone routing unconnected, clear/hold-reset missing

| Field | Value |
|-------|-------|
| **ID** | GAP-039 |
| **Area** | Dialogue |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
