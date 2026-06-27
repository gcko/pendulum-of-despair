# GAP-054: Duskfen settlement unbuilt — only the spirit-shrine hub exists

| Field | Value |
|-------|-------|
| **ID** | GAP-054 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
