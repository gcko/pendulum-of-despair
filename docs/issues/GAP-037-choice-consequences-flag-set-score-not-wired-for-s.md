# GAP-037: Choice consequences (flag_set/score) not wired for standalone NPC/zone/auto-sequence dialogue

| Field | Value |
|-------|-------|
| **ID** | GAP-037 |
| **Area** | Dialogue |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#170](https://github.com/gcko/pendulum-of-despair/issues/170) |
| **Source domains** | dialogue |

## Summary

For standalone dialogue overlays only sfx_requested is connected; flag_set_requested and choice_made are emitted into the void, so the only choice data in the project (thornmere_council scores) is inert outside cutscenes.

## Current state (implementation)

exploration connects exactly one DialogueBox signal; flag_set_requested/animation_requested are never connected for NPC/zone/cleansing/auto-sequence dialogue.

## Desired state (per design)

Any dialogue presenting a choice applies its flag_set/score consequence whether shown in a cutscene or standalone.

## Proposed approach

Add a _connect_dialogue_signals() wiring flag_set_requested (and animation_requested) to EventFlags / a score handler, reused across NPC, zone, auto-sequence, and cleansing paths; add a regression test.

## Acceptance criteria

- [ ] A standalone choice sets its flag/score
- [ ] Wiring is shared across all standalone dialogue paths
- [ ] A test asserts a standalone choice mutates state

## Design references

- docs/story/dialogue-system.md §3.4/§4.3

## Code references

- game/scripts/ui/dialogue_box.gd:260-285
- game/scripts/core/exploration.gd:527-537,292-304,397-399


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** DialogueBox emits flag_set_requested (dialogue_box.gd:277,281) and animation_requested (317) and choice_made (264). For standalone dialogue, exploration.gd only calls _connect_dialogue_sfx (lines 303,398), which connects ONLY sfx_requested (exploration.gd:529-532). flag_set_requested and animation_requested are never connected on the standalone NPC/dialogue-trigger paths. The cleansing (cleansing_sequence.gd:100,171,219), zone (exploration_zone_handler.gd:133) and auto-sequence (exploration_auto_sequence.gd:123) paths call show_dialogue with NO signal wiring at all (not even sfx). Only the cutscene path wires flag_set (cutscene_player.gd:55-58 -> cutscene_handler.gd:44/164-169). So standalone choice consequences are emitted into the void.
- **Notes:** Confirmed. thornmere_council.json (no cutscene_id, played standalone) carries the only choice/score data and its consequences are inert outside cutscenes. Fix spans 4 dialogue paths and needs a shared wiring helper + a score handler (coupled to GAP-038) + regression tests; not a small isolated change.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
