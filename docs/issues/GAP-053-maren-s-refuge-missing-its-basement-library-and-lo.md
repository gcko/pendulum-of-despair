# GAP-053: Maren's Refuge missing its basement library and lore layer

| Field | Value |
|-------|-------|
| **ID** | GAP-053 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
