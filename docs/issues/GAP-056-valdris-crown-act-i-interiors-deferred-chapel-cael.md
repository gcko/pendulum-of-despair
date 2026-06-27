# GAP-056: Valdris Crown Act-I interiors deferred: Chapel, Cael's Quarters, Court interiors

| Field | Value |
|-------|-------|
| **ID** | GAP-056 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — OVERSTATED |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** OVERSTATED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** TRUE parts: valdris_lower_ward.tscn has only ChapelSave (save_point_id 'valdris_chapel_save') with no chapel-interior transition, and no Cael's Quarters node/scene exists (no chapel/cael interior in towns/). FALSE part: the issue calls the 'OldHarren' node (npc_id 'old_harren') 'unexpected... not in the design directory', but the design explicitly places him there — docs/story/npcs.md:354 'Old Harren', events.md:986 'Old Harren | Valdris Crown (Lower Ward, Crown's Rest inn)', and script/npc-ambient.md:100 'Old Harren (Crown's Rest Inn)'.
- **Notes:** The core partial-impl gap (Chapel + Cael's Quarters interiors deferred) is real and MEDIUM. But the OldHarren accusation is factually wrong — the node correctly implements a designed Lower Ward NPC — so the issue is overstated and acceptance criterion #3 should be removed. Building the interiors is feature work; fixNow false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
