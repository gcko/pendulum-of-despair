# GAP-052: Roothollow built as a 2-NPC stub vs. a 10-structure root-warren settlement

| Field | Value |
|-------|-------|
| **ID** | GAP-052 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
