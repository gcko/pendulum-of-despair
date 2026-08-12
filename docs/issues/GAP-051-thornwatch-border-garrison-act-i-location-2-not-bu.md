# GAP-051: Thornwatch border garrison (Act I location #2) not built

| Field | Value |
|-------|-------|
| **ID** | GAP-051 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#198](https://github.com/gcko/pendulum-of-despair/issues/198) |
| **Source domains** | world |

## Summary

No Thornwatch scene exists; the designed fortified outpost (Garrison Barracks, Armory, Commander Halda quest-giver, Watchtower scene, Border Rest Inn) gating Thornmere Wilds travel is absent.

## Current state (implementation)

Listed as a deferred sub-gap; referenced by the Thornmere overworld route.

## Desired state (per design)

Thornwatch built as an Act-I rest stop and quest hub per city-valdris.md §4.

## Proposed approach

Build Thornwatch in the Act-I content completion pass.

## Acceptance criteria

- [ ] Thornwatch scene exists with Armory + Provisioner shops
- [ ] Commander Halda is placed as a quest-giver
- [ ] Border Rest Inn provides a save/rest point

## Design references

- docs/story/city-valdris.md:877-1060

## Code references

- game/scenes/maps/towns/ (no thornwatch scene)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** No thornwatch scene exists in game/scenes/maps/towns/ (grep 'thornwatch' in game/ returns only dialogue references in data/dialogue/scene_7a_the_gates.json:9 and scene_7_the_capital.json:9: 'received word from Thornwatch. Commander Halda...'). Design city-valdris.md:877-1060 defines Thornwatch (Act I location #2) with Garrison Barracks, Armory, Commander Halda, Watchtower, Border Rest Inn.
- **Notes:** Accurate missing-feature gap. Building a town scene with shops/quest-giver/save is feature work, not a bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
