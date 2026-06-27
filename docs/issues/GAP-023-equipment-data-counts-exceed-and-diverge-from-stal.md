# GAP-023: Equipment data counts exceed and diverge from stale tracker figures

| Field | Value |
|-------|-------|
| **ID** | GAP-023 |
| **Area** | Items/Economy |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | items |

## Summary

Tracker claims 58/49/47 but live data has 61 weapons / 50 armor / 60 accessories (no dup ids); the '+13/+1/+13' additions are unverified against the canonical catalog.

## Current state (implementation)

Counts have grown past the tracker; the '[x] verified against equipment.md' claim is stale.

## Desired state (per design)

Tracker counts match data and each entry is re-verified against equipment.md (stats/tier/price/equippable_by).

## Proposed approach

Run an adversarial data-vs-doc diff for the three equipment JSONs and update game-dev-gaps.md counts.

## Acceptance criteria

- [ ] Tracker counts match actual data
- [ ] Added items are confirmed canonical or removed
- [ ] Diff is recorded

## Design references

- docs/story/equipment.md §Weapon/Armor/Accessory Summaries

## Code references

- game/data/equipment/weapons.json|armor.json|accessories.json
- docs/analysis/game-dev-gaps.md:157-159

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
