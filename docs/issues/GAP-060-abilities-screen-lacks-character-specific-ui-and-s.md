# GAP-060: Abilities screen lacks character-specific UI and shows hardcoded resource values

| Field | Value |
|-------|-------|
| **ID** | GAP-060 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#206](https://github.com/gcko/pendulum-of-despair/issues/206) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** ability_helpers.gd:4-11 RESOURCE_LABELS contains literal strings 'AP 0/10','AC 12/12','WG 0/100' (only the 'MP' entries are live-resolved via member current_mp/max_mp at lines 64-70). menu_abilities.gd:108-126 _update_grid only formats name + cost ('%-12s %6s'); no per-character branches for Edren stance highlight, Torren Favor pips, Sable cooldown/front-row icon, Maren Weave gauge, or Lira device qty. Design ui-design.md:7.3 table lists each character's unique UI element.
- **Notes:** Confirmed partial-impl with hardcoded headers. Depends on GAP-002 (live resource state). Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
