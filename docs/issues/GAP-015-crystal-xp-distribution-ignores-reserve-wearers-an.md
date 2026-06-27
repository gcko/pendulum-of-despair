# GAP-015: Crystal XP distribution ignores reserve wearers and KO status

| Field | Value |
|-------|-------|
| **ID** | GAP-015 |
| **Area** | Progression |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | progression |

## Summary

distribute_crystal_xp credits only active members' crystals at a flat 30% of full battle XP regardless of KO, and gives reserve crystals nothing.

## Current state (implementation)

KO'd active wearers are over-credited; reserve wearers are under-credited; design ties crystal XP to the wearer's actual XP (0 if KO'd, 50% if reserve).

## Desired state (per design)

Each crystal gains 30% of its wearer's actual awarded XP across active and reserve members.

## Proposed approach

Compute each member's awarded XP (0 KO'd-active, full active-alive, half reserve) and grant 30% of that to their crystal; iterate all members.

## Acceptance criteria

- [ ] KO'd active wearer's crystal gains 0
- [ ] Reserve wearer's crystal gains 30% of the 50% share
- [ ] Active-alive wearer's crystal gains 30% of full

## Design references

- docs/story/progression.md:226-229

## Code references

- game/scripts/core/exploration.gd:700-713

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
