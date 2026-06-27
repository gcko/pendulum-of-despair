# GAP-056: Valdris Crown Act-I interiors deferred: Chapel, Cael's Quarters, Court interiors

| Field | Value |
|-------|-------|
| **ID** | GAP-056 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | world |

## Summary

The Chapel is only an exterior save point and Cael's Quarters is absent; Court Quarter buildings (Haren's Estate, Council Chambers, Court Mage Tower, Noble Archive) have no interiors.

## Current state (implementation)

Lower Ward has no chapel-interior or Cael's-Quarters transition; an unexpected 'OldHarren' NPC is present that is not in the design directory.

## Desired state (per design)

Chapel of the Old Pacts interior (Thessa, spirit-pact tablets, save) and Cael's Quarters Act-I cutscene interior; remaining Court interiors under the Act-II epic.

## Proposed approach

Prioritize Chapel + Cael's Quarters for Act-I narrative completeness; verify/remove the unexpected OldHarren node.

## Acceptance criteria

- [ ] Chapel interior exists with Thessa and save point
- [ ] Cael's Quarters interior exists for the Act-I beat
- [ ] Unexpected OldHarren node verified or removed

## Design references

- docs/story/city-valdris.md:286-318
- docs/story/dungeons-city.md:1131
- docs/story/interiors.md:464-631

## Code references

- game/scenes/maps/towns/valdris_lower_ward.tscn

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
