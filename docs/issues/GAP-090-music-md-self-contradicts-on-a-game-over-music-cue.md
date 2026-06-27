# GAP-090: music.md self-contradicts on a 'game over' music cue

| Field | Value |
|-------|-------|
| **ID** | GAP-090 |
| **Area** | Docs |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | RESOLVED — fixed in commit d06a566 |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** yes (doc)
- **Evidence:** music.md:526 'System/UI cues | ~8 | Title, victory, level up, item, save, inn, game over, shop (rule-based)'. But the detailed cue table has NO game-over track — music.md:467 'Party Wipe / Reload ... then save point jingle on reload. | No "Game Over" screen or unique game-over theme.' Implementation confirms: no game_over/gameover asset in game/assets/sfx/.
- **Notes:** Direct in-document contradiction. Clean, safe one-token doc fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
