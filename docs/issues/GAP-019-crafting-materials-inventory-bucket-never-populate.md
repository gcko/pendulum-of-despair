# GAP-019: Crafting materials inventory bucket never populated; material drops land in consumables and become unusable

| Field | Value |
|-------|-------|
| **ID** | GAP-019 |
| **Area** | Items/Economy |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | items |

## Summary

add_item always routes drops into the consumables bucket; the materials dict is never written. Material drops (beast_hide, scrap_metal) can't resolve a name (use lookup_consumable only), there is no Materials tab, and Drake Fang's battle use is unreachable.

## Current state (implementation)

materials.json has 87 entries incl. drake_fang (battle_usable, 500 fixed dmg). No path adds to inventory['materials'] or reads materials.json for display. Items menu has only USE/ARRANGE/KEY tabs.

## Desired state (per design)

Material drops route to inventory.materials; a Materials tab lists them with sell value; Drake Fang is battle-usable from that tab.

## Proposed approach

Classify add_item by category/source (or add add_material) and route to the correct bucket; add a Materials tab reading materials.json; wire Drake Fang battle use.

## Acceptance criteria

- [ ] Dropped materials appear in inventory.materials
- [ ] Materials tab lists materials with names and sell values
- [ ] Drake Fang is usable in battle for fixed damage

## Design references

- docs/story/items.md §Inventory Structure (Materials tab)
- docs/story/items.md §Drake Fang Special Case

## Code references

- game/scripts/autoload/party_state.gd:41,463-469
- game/scripts/autoload/inventory_helpers.gd:381-395
- game/scripts/ui/menu_items.gd:4


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** party_state.gd add_item (463-469) unconditionally routes into the consumables bucket: consumables[item_id]=consumables.get(item_id,0)+quantity; inventory['materials'] (declared line 41) is never written. menu_items.gd:4 enum ItemTab {USE, ARRANGE, KEY} has no Materials tab. data/items/materials.json has 87 entries including drake_fang (battle_usable:true, battle_effect:fixed_damage, battle_value:500) which is unreachable.
- **Notes:** Real bug. M-effort: requires add_item categorization/routing, a new Materials tab, and battle wiring for Drake Fang. Not a bounded one-liner.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
