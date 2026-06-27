# GAP-063: Maren's battle Weave Gauge and guest-NPC 5th party row not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-063 |
| **Area** | UI |
| **Severity** | LOW |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | ui |

## Summary

battle_party_panel hardcodes 4 rows each with only an ATBBar; there is no Weave Gauge bar for Maren and no compact 5th row for guest NPCs (Cordwyn/Kerra).

## Current state (implementation)

_rows = [null x4]; Row0-3 only; no WeaveBar node.

## Desired state (per design)

Maren's row shows a purple Weave Gauge below MP; a compact 5th guest row appears when a guest is present.

## Proposed approach

Add a conditional WeaveBar for Maren and a 5th compact Row visible when a guest occupies the party.

## Acceptance criteria

- [ ] Maren shows a Weave Gauge in battle
- [ ] A 5th row appears for guest NPCs
- [ ] Layout handles 4 vs 5 members

## Design references

- docs/story/ui-design.md §2.9/§2.3

## Code references

- game/scripts/ui/battle_party_panel.gd:11
- game/scenes/core/battle.tscn

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
