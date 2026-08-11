# GAP-016: Entire crafting/forging system (Arcanite Forging) unimplemented — data exists, zero gameplay

| Field | Value |
|-------|-------|
| **ID** | GAP-016 |
| **Area** | Items/Economy |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#162](https://github.com/gcko/pendulum-of-despair/issues/162) |
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
- game/scripts/util/save_data_helpers.gd — dead crafting stub in `build_save_dict()`
- game/scripts/autoload/party_state.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Data exists: game/data/crafting/devices.json (13 devices), recipes.json (9 forging_recipes), synergies.json (7 synergies). The only script references are non-gameplay strings: spell_helpers.gd:4 TRADITIONS includes 'forgewright', ability_helpers.gd:7 'forgewright':'AC 12/12', and a dead save stub inventory_helpers.gd:305-306 ('arcanite_charges':12, 'device_loadout':[null x5]). party_state.gd rest_party (604) restores HP/MP only, no AC; rest_at_inn (500-507) hardcodes current_ac=12 with no tiered restoration. No device/forge/infusion/synergy gameplay exists.
- **Notes:** Genuine XL epic. The dead crafting block is written into every save (inventory_helpers.gd:303-309) but read by nothing. Issue says '7 infusions' but no infusions.json exists (only devices/recipes/synergies) — minor count imprecision, does not affect the gap.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
