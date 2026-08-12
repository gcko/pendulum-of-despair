# GAP-019: Crafting materials inventory bucket never populated; material drops land in consumables and become unusable

| Field | Value |
|-------|-------|
| **ID** | GAP-019 |
| **Area** | Items/Economy |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — #164 |
| **GitHub Issue** | [#164](https://github.com/gcko/pendulum-of-despair/issues/164) |
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

- game/scripts/autoload/party_state.gd — `add_item()` (the routing entry point)
- game/scripts/util/progression_helpers.gd — `apply_battle_rewards()` drop routing
- game/scripts/util/inventory_helpers.gd — `bucket_for_item()`, `reroute_materials()`
- game/scripts/ui/menu_items.gd — `_lookup_material()` (the materials name resolution the finding said was missing)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** party_state.gd add_item (463-469) unconditionally routes into the consumables bucket: consumables[item_id]=consumables.get(item_id,0)+quantity; inventory['materials'] (declared line 41) is never written. menu_items.gd:4 enum ItemTab {USE, ARRANGE, KEY} has no Materials tab. data/items/materials.json has 87 entries including drake_fang (battle_usable:true, battle_effect:fixed_damage, battle_value:500) which is unreachable.
- **Notes:** Real bug. M-effort: requires add_item categorization/routing, a new Materials tab, and battle wiring for Drake Fang. Not a bounded one-liner.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
