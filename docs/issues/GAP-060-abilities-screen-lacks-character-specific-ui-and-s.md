# GAP-060: Abilities screen lacks character-specific UI and shows hardcoded resource values

| Field | Value |
|-------|-------|
| **ID** | GAP-060 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | ui |

## Summary

The Abilities screen renders a generic name+cost list with hardcoded resource headers ('AP 0/10','AC 12/12','WG 0/100'); none of the unique elements (Edren stance highlight, Torren Favor pips, Sable cooldown pips + front-row icon, Maren Weave gauge, Lira device qty) exist.

## Current state (implementation)

RESOURCE_LABELS returns literal strings; _update_grid only formats name + cost.

## Desired state (per design)

Each character's set shows its unique UI element and live resource value per §7.3.

## Proposed approach

Add per-command rendering branches (pips/gauge/highlight) and source live values from PartyState. Depends on GAP-002 resource state.

## Acceptance criteria

- [ ] Resource headers show live values
- [ ] Per-character unique elements render
- [ ] Values update with PartyState

## Design references

- docs/story/ui-design.md §7.3

## Code references

- game/scripts/ui/menu_abilities.gd:108-126
- game/scripts/ui/ability_helpers.gd:4-11

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
