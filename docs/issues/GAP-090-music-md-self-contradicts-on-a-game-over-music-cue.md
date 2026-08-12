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

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
