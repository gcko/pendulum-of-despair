# GAP-055: Ironmouth implemented as an escape corridor, diverging from the designed Carradan port city

| Field | Value |
|-------|-------|
| **ID** | GAP-055 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | world |

## Summary

ironmouth_docks.tscn is a linear Scene-3 escape corridor (forced combat, 3 crates, party-join dialogue) reusing the Ironmouth name, with no shops/buildings/city layout from the canonical port-city design.

## Current state (implementation)

A deliberate Act-I narrative stub that collides with the future full Ironmouth city under the same name.

## Desired state (per design)

Keep the corridor for Act I but namespace it (e.g. ironmouth_escape) and track the real city under the Carradan epic.

## Proposed approach

Rename/namespace the corridor; update design docs if Ironmouth-as-city is being cut.

## Acceptance criteria

- [ ] Corridor renamed to avoid name collision
- [ ] Full Ironmouth city tracked under the cities epic
- [ ] Docs reconciled

## Design references

- docs/story/city-carradan.md:1168-1270

## Code references

- game/scenes/maps/towns/ironmouth_docks.tscn

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
