# GAP-037: Choice consequences (flag_set/score) not wired for standalone NPC/zone/auto-sequence dialogue

| Field | Value |
|-------|-------|
| **ID** | GAP-037 |
| **Area** | Dialogue |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
