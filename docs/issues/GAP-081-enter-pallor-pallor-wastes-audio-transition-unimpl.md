# GAP-081: enter_pallor() / Pallor Wastes audio transition unimplemented — CROSSFADE_PALLOR constants are dead code

| Field | Value |
|-------|-------|
| **ID** | GAP-081 |
| **Area** | Audio |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | audio |

## Summary

CROSSFADE_PALLOR_MUSIC=5.0 and CROSSFADE_PALLOR_AMBIENT=3.0 are declared 'reserved for the gap 4.5 enter_pallor()' but no such method exists, so the constants are dead.

## Current state (implementation)

The constants are referenced only in their own declaration comment; Pallor Wastes is Act III so the slice is not blocked.

## Desired state (per design)

An enter_pallor() that hard-cuts music to silence, fades a Pallor drone in over 5s, and crossfades ambient over 3s, consuming the reserved constants.

## Proposed approach

Implement enter_pallor() using the constants (silence music, fade-in sub-bass drone, crossfade ambient) and add a GUT test.

## Acceptance criteria

- [ ] enter_pallor cuts music and fades in the drone
- [ ] Ambient crossfades over 3s
- [ ] Reserved constants are consumed

## Design references

- docs/story/audio.md:261
- docs/story/music.md:451

## Code references

- game/scripts/autoload/audio_manager.gd:38-43

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
