# GAP-090: music.md self-contradicts on a 'game over' music cue

| Field | Value |
|-------|-------|
| **ID** | GAP-090 |
| **Area** | Docs |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | audio |

## Summary

music.md:526 lists 'game over' among the ~8 System/UI cues while music.md:467 states there is no Game Over screen or unique theme (Faint-and-Fast-Reload reuses the save jingle); the implementation correctly omits a game-over track, so the doc is wrong.

## Current state (implementation)

Direct contradiction within the same document.

## Desired state (per design)

The Track Count Summary drops/relabels 'game over' and reconciles the ~8 count.

## Proposed approach

Edit music.md:526 to remove 'game over' (or relabel as 'party wipe — reuses save jingle').

## Acceptance criteria

- [ ] music.md no longer lists a game-over cue
- [ ] The ~8 count is reconciled

## Design references

- docs/story/music.md:526,467
- docs/story/audio.md:467

## Code references

- game/assets/sfx/ (no game_over.ogg)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
