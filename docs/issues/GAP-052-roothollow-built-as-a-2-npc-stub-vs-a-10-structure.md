# GAP-052: Roothollow built as a 2-NPC stub vs. a 10-structure root-warren settlement

| Field | Value |
|-------|-------|
| **ID** | GAP-052 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#199](https://github.com/gcko/pendulum-of-despair/issues/199) |
| **Source domains** | world |

## Summary

roothollow.tscn has only Vessa + Herbalist, a save point, an exit, and the Torren-join trigger; the designed 10 structures, Root Chambers interior, hidden Root-Weaver's Workshop, Great Tree Canopy, and spirit-token barter economy are absent.

## Current state (implementation)

Tracker marks it COMPLETE as 'Vessa NPC, herbalist shop, save point'.

## Desired state (per design)

Roothollow expanded to its designed structure set with the spirit-token economy and refusal rules.

## Proposed approach

Add minimum Act-I structures (Guest Hollow inn, Trader's Nook, Hunter weapon cache, Heartwood Shrine framing, Root-Weaver's Workshop secret); defer Interlude/Act-II petrification states.

## Acceptance criteria

- [ ] Roothollow has an inn, trader, and hunter cache
- [ ] The Root-Weaver's Workshop secret is reachable
- [ ] Spirit-token barter rules are represented

## Design references

- docs/story/city-thornmere.md:131-205

## Code references

- game/scenes/maps/towns/roothollow.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/towns/roothollow.tscn Entities contain only Vessa (npc_id 'vessa'), Herbalist (npc_id/shop_id 'roothollow_herbalist'), RoothollowSave save point, ExitToOverworld, and Scene5Trigger (the party-join scene). Design city-thornmere.md:131-205 specifies ~10 structures, Root Chambers interior, hidden Root-Weaver's Workshop, Great Tree Canopy, and a spirit-token barter economy — all absent.
- **Notes:** Partial-impl gap accurately described (issue calls Scene5Trigger the 'Torren-join trigger', a harmless label nuance). Expanding to the full structure set is feature work.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
