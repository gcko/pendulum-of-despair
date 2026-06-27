# GAP-054: Duskfen settlement unbuilt — only the spirit-shrine hub exists

| Field | Value |
|-------|-------|
| **ID** | GAP-054 |
| **Area** | World |
| **Severity** | MEDIUM (verified: LOW) |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | world |

## Summary

Only the small shrine hub (save + Caden event + overworld shortcut) exists; the full bog settlement (stilt structures, shops, NPCs) that is the Act-II Thornmere alliance hub is unbuilt and is filed under dungeons/ though it is a town.

## Current state (implementation)

Acceptable for the Act-I slice; the shrine is the only Act-I-relevant part.

## Desired state (per design)

Full Duskfen settlement built under the Act-II content epic.

## Proposed approach

Track the full settlement under GAP-049; note the misfiled dungeon path.

## Acceptance criteria

- [ ] Full Duskfen settlement tracked under the cities epic
- [ ] Settlement has shops/NPCs/trade goods
- [ ] Path/classification corrected (town not dungeon)

## Design references

- docs/story/city-thornmere.md:207-350

## Code references

- game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/dungeons/duskfen_spirit_shrine.tscn contains only a SavePoint, CadenPostEvent NPC (auto_sequence 'caden_binding', visible_when_flag 'caden_binding_complete'), and OverworldExit/from_spirit_path/from_overworld markers — i.e. shrine hub only. It lives under dungeons/ though it is a settlement hub. Full bog settlement (stilt structures/shops/NPCs) per city-thornmere.md:207-350 is unbuilt.
- **Notes:** Confirmed and the issue itself notes this is acceptable for the Act-I slice (the shrine is the only Act-I-relevant part) — hence LOW. The 'misfiled under dungeons/' point is valid but cosmetic; moving the .tscn would break res:// path references used by exploration_auto_sequence.gd and load_map calls, so not a safe bounded fix. Full settlement correctly rolls up under GAP-049.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
