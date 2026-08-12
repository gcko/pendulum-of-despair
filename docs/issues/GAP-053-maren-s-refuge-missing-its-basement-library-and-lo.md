# GAP-053: Maren's Refuge missing its basement library and lore layer

| Field | Value |
|-------|-------|
| **ID** | GAP-053 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#200](https://github.com/gcko/pendulum-of-despair/issues/200) |
| **Source domains** | world |

## Summary

marens_refuge.tscn is one room with only Maren, the Scene 6 trigger, and an exit; the designed exterior, ground-floor lore interactables, and Basement Library (ley-line tap, Artifact Vault, Specimen Jar) are absent.

## Current state (implementation)

No basement transition, bookshelf/lore interactables, or named POIs exist.

## Desired state (per design)

Three zones (exterior, ground floor with Pendulum Work Desk, basement library) with key items and lore per the design.

## Proposed approach

Add the basement sub-map and ground-floor lore interactables; wire the Pendulum-examination cutscene to the Work Desk.

## Acceptance criteria

- [ ] Basement Library sub-map exists
- [ ] Ground-floor lore interactables present
- [ ] Pendulum-examination cutscene wired to the Work Desk

## Design references

- docs/story/city-thornmere.md:965-1123
- docs/story/interiors.md:195-276

## Code references

- game/scenes/maps/towns/marens_refuge.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/towns/marens_refuge.tscn is a single room: Maren (npc_id 'maren_refuge'), Scene6Trigger (dialogue_scene_id 'scene_6_marens_warning'), and ExitToOverworld. No basement transition, bookshelf/lore interactables, Pendulum Work Desk, or named POIs. Design city-thornmere.md:965-1123 and interiors.md:195-276 specify exterior + ground-floor lore + Basement Library (ley-line tap, Artifact Vault, Specimen Jar).
- **Notes:** Accurate partial-impl gap. Adding a basement sub-map and wiring a cutscene is feature work, not a bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
