# GAP-028: Undocumented Act I enemies in data (Compact Patrol, Compact Scout) absent from bestiary

| Field | Value |
|-------|-------|
| **ID** | GAP-028 |
| **Area** | Enemies |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | enemies |

## Summary

compact_patrol and compact_scout (ironmouth_docks) appear in act_i.json but in no bestiary row; ironmouth_docks is not an Act I bestiary zone.

## Current state (implementation)

act-i.md declares 25 enemies across Ember Vein/Fenmother/Overworld; these two humanoids are not among them.

## Desired state (per design)

Every enemy traces to a bestiary row; add them (and the Ironmouth Docks zone) to the appropriate bestiary file, or relocate them.

## Proposed approach

Add the two enemies with derived stats/threat/family to the correct bestiary file, or move them out of act_i.json.

## Acceptance criteria

- [ ] Both enemies trace to a bestiary entry
- [ ] Their zone is documented or corrected

## Design references

- docs/story/bestiary/act-i.md:8,91-103

## Code references

- game/data/enemies/act_i.json:873-901,902-930

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
