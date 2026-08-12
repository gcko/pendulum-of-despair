# GAP-030: Transport/vehicle system entirely missing (Ley Stag, rail, ferry, Linewalk)

| Field | Value |
|-------|-------|
| **ID** | GAP-030 |
| **Area** | Exploration |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#168](https://github.com/gcko/pendulum-of-despair/issues/168) |
| **Source domains** | exploration, story |

## Summary

No transport code exists; all movement is uniform on-foot. The four modes (rail, Ley Stag mount, ferry, Linewalk) and the Ley Stag bonding flags (54/55/56) with the orphaned ley_stag_bonding.json are unimplemented.

## Current state (implementation)

Zero transport identifiers in scripts; stag_bonded set in 0 places; no Roothollow bonding trigger.

## Desired state (per design)

The four transport modes with unlock triggers, speeds, encounter modifiers, costs, and per-act availability (incl. Interlude collapse to Linewalk-only), and stag bonding/loss/return beats.

## Proposed approach

Implement after the continental overworld; add mount/vehicle state in PartyState, speed + danger modifiers in the encounter step, town rail/ferry entry points, and Roothollow stag bonding.

## Acceptance criteria

- [ ] At least one transport mode functions on the overworld with its speed/encounter modifier
- [ ] Ley Stag bonding sets flag 54 and grants the mount
- [ ] Rupture/return beats (55/56) fire in the Interlude

## Design references

- docs/story/transport.md
- docs/story/events.md flags 54/55/56 (Ley Stag bonding)

## Code references

- game/scripts/ (no transport logic)
- game/data/dialogue/ley_stag_bonding.json (orphaned)
- game/scenes/maps/towns/roothollow.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** No transport identifiers in scripts (grep for transport/ley_stag/stag_bonded/linewalk/ferry/rail in scripts/ = 0 hits). stag_bonded appears ONLY as a read condition: data/dialogue/scene_25_finding_torren.json:235 '"condition": "stag_bonded"' — set in 0 places. ley_stag_bonding.json exists (game/data/dialogue/ley_stag_bonding.json) but is referenced only by itself = orphaned. events.md:278/304/312 define flags 54 stag_bonded / 55 stag_lost / 56 stag_returned, none implemented.
- **Notes:** Claim accurate. Note: roothollow.tscn:58 cited in gap is actually metadata/flag="torren_joined" / torren_encounter, not a bonding trigger — gap cites it only as the proposed insertion point, which is fine. L-effort epic.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
