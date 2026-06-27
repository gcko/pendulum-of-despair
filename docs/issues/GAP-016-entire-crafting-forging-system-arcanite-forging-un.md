# GAP-016: Entire crafting/forging system (Arcanite Forging) unimplemented — data exists, zero gameplay

| Field | Value |
|-------|-------|
| **ID** | GAP-016 |
| **Area** | Items/Economy |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | items |

## Summary

All crafting data exists (13 devices, 9 recipes, 7 infusions, 7 synergies) but no gameplay consumes it: no device/forge menus, no AC pool mechanics, no loadout, no infusions, no synergy discovery, no Pallor malfunction/Calibrate. The save schema hardcodes a dead crafting block; rest items don't restore AC by tier.

## Current state (implementation)

No scripts reference arcanite_charge/device_loadout/forge/synergy/infusion. rest_party never restores AC; only rest_at_inn sets current_ac=12, ignoring tiered 25/50/100% restoration. Save-point device reconfiguration (Lira) is unavailable.

## Desired state (per design)

Lira-only device crafting at save points/inns; forge-location equipment forging; elemental infusions; 7 secret synergies with discovery channels; 12-AC pool with tiered rest restoration + Arcanite Shard; device loadout locking; 15% Pallor malfunction mitigated by Calibrate.

## Proposed approach

Phase 1: AC pool + device crafting field menu + tiered rest AC restoration + save-point reconfiguration. Phase 2: forging + infusions menu. Phase 3: synergy discovery + malfunction/Calibrate.

## Acceptance criteria

- [ ] AC pool exists, is spent on devices, and restores by rest tier
- [ ] Lira can craft/reconfigure devices at a save point
- [ ] Forge locations forge equipment with materials+gold and tag '(Forged)'
- [ ] At least the 3 Act-I devices are usable in battle

## Design references

- docs/story/crafting.md
- docs/story/items.md §Forgewright Battle Devices
- docs/story/equipment.md §Arcanite Forging

## Code references

- game/data/crafting/devices.json|recipes.json|synergies.json
- game/scripts/autoload/inventory_helpers.gd:303-309 (dead crafting stub)
- game/scripts/autoload/party_state.gd:604

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
