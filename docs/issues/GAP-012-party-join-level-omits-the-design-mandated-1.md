# GAP-012: Party join level omits the design-mandated '-1'

| Field | Value |
|-------|-------|
| **ID** | GAP-012 |
| **Area** | Progression |
| **Severity** | MEDIUM |
| **Type** | bug |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | progression |

## Summary

_get_party_avg_level returns max(1, floor(avg)); the canonical formula is max(1, floor(avg) - 1), so every recruit joins one level higher than designed.

## Current state (implementation)

Lira/Sable/Torren/Maren join at the full party average level.

## Desired state (per design)

Recruits join at max(1, floor(party_average) - 1).

## Proposed approach

Change the return to maxi(1, floori(avg) - 1); add a unit test for a known average.

## Acceptance criteria

- [ ] Recruits join at floor(avg)-1 (min 1)
- [ ] A unit test asserts join level for a sample party average

## Design references

- docs/story/progression.md:154-156,248

## Code references

- game/scripts/core/exploration.gd:444-450,425,428,437,440

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
