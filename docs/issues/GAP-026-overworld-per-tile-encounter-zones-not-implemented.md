# GAP-026: Overworld per-tile encounter zones not implemented; 12 of 13 zones are unreachable dead data

| Field | Value |
|-------|-------|
| **ID** | GAP-026 |
| **Area** | Encounters |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — PR #268 |
| **GitHub Issue** | [#186](https://github.com/gcko/pendulum-of-despair/issues/186) |
| **Source domains** | exploration |

## Summary

Encounter zone is chosen once per map from a single floor_id meta (valdris_highlands), so the other 12 authored overworld zones can never be selected; no per-tile terrain->zone lookup exists.

## Current state (implementation)

exploration.gd:131 reads one floor_id; the zone-match loop only matches valdris_highlands. Tracker marks 'overworld encounter tables per terrain type' DONE (false-completion: data unreachable).

## Desired state (per design)

A per-tile/per-region terrain classifier selects the matching encounter zone as the party moves, activating all 13 zones.

## Proposed approach

Add a TileMapLayer terrain-tag -> zone_id map and update the current zone on tile change in the encounter step, replacing the static floor_id for the overworld.

## Acceptance criteria

- [ ] Crossing terrain changes the active encounter zone
- [ ] All 13 zones become reachable
- [ ] A test asserts zone selection by terrain tag

## Design references

- docs/story/geography.md §5 (per-tile terrain encounter zones)
- docs/story/geography.md §2

## Code references

- game/data/encounters/overworld.json (13 zones)
- game/scripts/core/exploration.gd — `get_player_tile()`, `get_zone_map()` (the per-tile zone lookup)
- game/scenes/maps/overworld.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** overworld.json defines 13 zones (zone_ids: valdris_highlands, aelhart_valley, compact_industrial, ley_scarred_plains, bellhaven_coast, ashport_coast, thornmere_wilds, deep_thornmere, wilds_edge, duskfen_marshland, frostcap_foothills, pallor_wastes_approach, roads). exploration.gd:131 reads a single _current_floor_id = get_meta('floor_id',''); overworld.tscn line 38 sets metadata/floor_id = 'valdris_highlands'. The zone-match loop exploration.gd:143-149 matches that one id against zone_id, so only valdris_highlands is ever selected; on no-match it falls back to entries[0] (also valdris_highlands). The other 12 zones are unreachable.
- **Notes:** Confirmed partial-impl / false-completion. Authored zone data is dead. Fix needs a per-tile TileMapLayer terrain-tag -> zone_id classifier updated on tile change, plus a test — new logic, not a bounded change. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._

## Resolution (PR #268, 2026-07-19)

Per-tile zone selection shipped via an ordered rect table (`game/data/encounters/overworld_zones.json`) resolved by the pure-static `ZoneResolver` on each tile step; all zones (now 15, including explicit zero-encounter `sacred_sites`/`urban` and an `act_iii_started`-gated Pallor approach) are reachable. The `entries[0]` fallback described in the evidence above was removed from the per-tile zone path — unmatched ids clear the config (legacy floors-based maps keep the first-entry fallback at map load). Act III/post-game zone transforms deferred to #266; tileset custom-data migration to #267.
