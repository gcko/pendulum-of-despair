# GAP-043: Act II diplomatic-mission content is reachable/completable during Act I with no story gating

| Field | Value |
|-------|-------|
| **ID** | GAP-043 |
| **Area** | Story |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#193](https://github.com/gcko/pendulum-of-despair/issues/193) |
| **Source domains** | story |

## Summary

The Fenmother's Hollow entry has no required_flag, so the Act-II diplomatic dungeon is enterable immediately and clearing it sets duskfen_alliance; the canonical prerequisite flag 8 diplomatic_mission_start is never set anywhere.

## Current state (implementation)

Duskfen Spirit Shrine requires caden_binding_complete, but the dungeon that sets it is itself ungated; diplomatic_mission_start set in 0 files.

## Desired state (per design)

Fenmother/Duskfen gated behind diplomatic_mission_start (Act II), OR the out-of-sequence vertical slice is formally documented in events.md/trackers.

## Proposed approach

Add required_flag=diplomatic_mission_start (with its setter when Act II's dispatch scene is built), or record the deviation explicitly.

## Acceptance criteria

- [ ] Fenmother/Duskfen are gated or the deviation is documented
- [ ] diplomatic_mission_start is set by some content or removed as a dependency
- [ ] duskfen_alliance no longer sets without its prerequisite

## Design references

- docs/story/events.md flags 8/9/9a/9b; §1 (Act I->II transition)

## Code references

- game/scenes/maps/overworld.tscn
- game/scripts/core/exploration_auto_sequence.gd — `_caden_complete()` (sets duskfen_alliance with no diplomatic_mission_start prerequisite)
- game/scripts/core/cleansing_sequence.gd — `_complete()` (sets fenmother_cleansed when the ungated Act-II dungeon is cleared; it does not set duskfen_alliance)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/overworld.tscn:119-126 (FenmothersHollow Area2D, target_map dungeons/fenmothers_hollow_f1) has NO metadata/required_flag, unlike DuskfenShrineEntry at :131-139 which has required_flag=caden_binding_complete. So Fenmother's Hollow (Act-II diplomatic dungeon) is enterable immediately. `diplomatic_mission_start` is the canonical Act-I->II prerequisite (events.md:274 flag 8, events.md:856) but is NEVER set via set_flag anywhere — only appears as `restock_event` in two shop JSONs and in events.md. exploration_auto_sequence.gd:145 sets duskfen_alliance with no diplomatic_mission_start prerequisite.
- **Notes:** Confirmed divergence, but it is an intentional vertical-slice artifact (Act II content surfaced in the Act-I slice because later acts aren't built). Severity refined HIGH->MEDIUM. Not fixNow: adding required_flag=diplomatic_mission_start would make the dungeon unreachable in the slice (no setter exists) and could break exploration/cleansing tests; the alternative (documenting the deviation) requires a design-intent call on canonical wording/location. Likely resolution is a doc note in events.md/tracker.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
