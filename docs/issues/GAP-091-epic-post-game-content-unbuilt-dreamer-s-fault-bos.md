# GAP-091: EPIC: Post-game content unbuilt (Dreamer's Fault, boss rush, The Lingering, completion tracking)

| Field | Value |
|-------|-------|
| **ID** | GAP-091 |
| **Area** | Post-game |
| **Severity** | LOW |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#239](https://github.com/gcko/pendulum-of-despair/issues/239) |
| **Source domains** | tracker |

## Summary

No Dreamer's Fault dungeon, boss rush, superboss, or completion-tracking UI exists; optional enemy data exists but nothing consumes it.

## Current state (implementation)

Tracker 4.6 NOT STARTED; depends on the Acts II-IV epic.

## Desired state (per design)

20-floor Dreamer's Fault, 3-tier boss rush with Memento accessories, The Lingering superboss, and a 4-category completion tracker at the Pendulum tavern.

## Proposed approach

Last content epic after the main game; lowest priority.

## Acceptance criteria

- [ ] Dreamer's Fault built
- [ ] Boss rush + superboss exist
- [ ] Completion tracker UI exists

## Design references

- docs/story/postgame.md
- docs/story/dungeons-world.md (Dreamer's Fault 20 floors)
- docs/story/sidequests.md (The Lingering)

## Code references

- (none — no post-game scenes)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** No post-game scaffolding exists: grep for dreamer/boss_rush/'boss rush'/'the lingering' across game/scripts returns nothing (the earlier 'completion'/'lingering' hits were unrelated generic words). scenes/ tree has only maps, ui, core, overlay, entities (no postgame dir). Optional enemy data exists (game/data/enemies/optional.json) but nothing consumes it for a boss rush/superboss. Design docs exist: docs/story/postgame.md, dungeons-world.md (Dreamer's Fault), sidequests.md (The Lingering).
- **Notes:** Genuine unbuilt EPIC, correctly flagged lowest priority and dependent on the Acts II-IV epic. Not actionable now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
