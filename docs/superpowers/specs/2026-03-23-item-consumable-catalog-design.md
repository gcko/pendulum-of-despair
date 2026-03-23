# Item & Consumable Catalog Design Spec

> **Gap 1.4** — the first post-Bestiary system. Defines every consumable,
> crafting material, key item, and Ley Crystal invocation in the game.

**Goal:** Create `docs/story/items.md` containing the complete item
catalog: consumables with effects and prices, crafting materials with
dual-purpose economy, key items with auto-use rules, Ley Crystal
invocations with limited uses, and Lira's Forgewright battle devices.

**Scope:** ~45 consumables + ~40 crafting materials + ~35 key items +
18 crystal invocations + ~12 Forgewright device recipes.

**Reference:** `docs/references/items/quick-stats.md` — FF6's 45 items
is our target for consumables. CT's stat capsules and SoM's Watts
blacksmith model inform our crafting.

---

## 1. Consumable Items (~45 items)

### 1.1 Healing Items (HP Restoration)

FF6-style 3-tier system with Pendulum-specific additions. HP/MP
healing items stack to **199** (all other consumables stack to 99).

| Item | Effect | Price | Availability |
|------|--------|-------|-------------|
| Potion | Restore 100 HP | 50 | Act I shops |
| Hi-Potion | Restore 500 HP | 300 | Act II shops |
| X-Potion | Restore 100% HP | 1,500 | Act III shops (limited) |
| Ley Tonic | Restore 300 HP to all party members | 800 | Act II shops (limited stock) |
| Elixir | Restore 100% HP and MP | — | Chests, boss drops only (not sold) |
| Megalixir | Restore 100% HP and MP to all party | — | 3 total in game (chests in Convergence, Dreamer's Fault) |
| Tent | Restore 50% HP and MP to all party. Save point use only. | 500 | Act I shops |
| Cottage | Restore 100% HP and MP to all party. Save point use only. | 1,200 | Interlude shops |

### 1.2 MP Restoration

| Item | Effect | Price | Availability |
|------|--------|-------|-------------|
| Ether | Restore 30 MP | 200 | Act I shops |
| Hi-Ether | Restore 100 MP | 800 | Act II shops |
| X-Ether | Restore 100% MP | 2,000 | Act III shops (limited) |

### 1.3 Revival

| Item | Effect | Price | Availability |
|------|--------|-------|-------------|
| Phoenix Feather | Revive one ally at 25% HP | 500 | Act I shops |
| Phoenix Pinion | Revive one ally at 100% HP | 3,000 | Act III shops (limited) |

### 1.4 Status Cure Items

Per-status cures matching the Status Effect Reference in magic.md.
Each cure maps 1:1 to a status, plus Remedy as the expensive universal.

| Item | Cures | Price | Availability |
|------|-------|-------|-------------|
| Antidote | Poison, Burn | 50 | Act I shops |
| Alarm Clock | Sleep | 75 | Act I shops |
| Echo Drop | Silence | 75 | Act I shops |
| Eye Drops | Blind | 50 | Act I shops |
| Soft Stone | Petrify | 200 | Act II shops |
| Chronos Dust | Slow | 150 | Act II shops |
| Remedy | All statuses except Stop, Despair, Faint | 1,000 | Act II shops |
| Pallor Salve | Despair (4-turn reduction → instant cure) | 2,500 | Act III Oases only (very limited stock) |
| Hope Shard | Despair (instant cure, per magic.md) | — | Rare chest/quest reward only (not sold) |

> **Design note on Despair:** Per magic.md, Despair "cannot be cured by
> standard Cleansing Draught or Purge — only by Hollow Mend (post-game
> spell) or the rare Hope Shard item." Pallor Salve is a NEW addition
> that reduces the 4-turn duration to instant cure — expensive and
> scarce, but available in Act III when Pallor encounters are heaviest.
> Hope Shard remains the ultra-rare free cure. This preserves the
> "despair is hard to cure" design while giving players a costly option.

### 1.5 Battle Utility Items

Basic shop-bought utility. Lira's Forgewright devices (Section 4)
handle the interesting combat items.

| Item | Effect | Price | Availability |
|------|--------|-------|-------------|
| Smoke Bomb | Flee from non-boss battles (100% success) | 100 | Act I shops |
| Waystone | Teleport to dungeon entrance (dungeon use only) | 300 | Act II shops |
| Sable's Coin | Preemptive strike guaranteed for next battle | 500 | Sable sidequest reward, rare chests |

### 1.6 Stat Capsules (Permanent, CT-style)

Found in sidequests, Dreamer's Fault, and hidden chests. Never sold
in shops. Each grants a permanent +1 to one stat for one character.

| Item | Effect | Total in Game |
|------|--------|--------------|
| Strength Capsule | ATK +1 (permanent) | 15 |
| Guardian Capsule | DEF +1 (permanent) | 15 |
| Arcane Capsule | MAG +1 (permanent) | 15 |
| Warding Capsule | MDEF +1 (permanent) | 15 |
| Swiftness Capsule | SPD +1 (permanent) | 12 |
| Fortune Capsule | LCK +1 (permanent) | 10 |

> **Distribution:** ~20% in Act II/Interlude hidden chests, ~30% in
> Act III exploration, ~50% in Dreamer's Fault post-game. This creates
> a long-tail reward loop for completionists. Total stat gain from all
> capsules: +82 stat points across ~6 stats = ~13 points per stat
> spread across 6 characters. Meaningful but not game-breaking.

### 1.7 Consumable Count Summary

| Category | Count |
|----------|-------|
| HP Healing | 8 |
| MP Restoration | 3 |
| Revival | 2 |
| Status Cure | 9 |
| Battle Utility | 3 |
| Stat Capsules | 6 types (~82 total) |
| **Total Consumable Types** | **31** |

With Lira's Forgewright devices (~12 types, Section 4), total
unique consumable/usable items reaches **~43** — right at the FF6
sweet spot of 45.

---

## 2. Crafting Materials (~40 items)

### 2.1 Dual-Purpose Economy

Every crafting material can be **sold for gold** OR **saved for Lira's
Forgewright recipes**. This creates meaningful loot decisions:

- Sell Beast Hide for 25g (quick gold for Potions)
- Save 5 Beast Hides for Lira to forge a Leather Repair Kit (restores
  10% party armor DEF for one dungeon)

The sell price represents the "floor value." The crafting value is
always higher — smart players save materials.

### 2.2 Material Tiers

Materials follow the existing bestiary drop patterns. 4 tiers based
on enemy level and rarity.

**Tier 1 — Common (Act I enemies, 75% steal rate):**

| Material | Source Type | Sell Price | Crafting Use |
|----------|-----------|------------|--------------|
| Beast Hide | Beast | 25 | Basic armor repair, leather goods |
| Bone Fragment | Undead | 30 | Weapon hardening, thrown items |
| Scrap Metal | Construct | 35 | Device components, basic forging |
| Element Shard | Elemental | 40 | Elemental infusions |
| Ether Wisp | Spirit | 40 | MP restoration crafting |

**Tier 2 — Uncommon (Act I–II enemies, 25% drop rate):**

| Material | Source Type | Sell Price | Crafting Use |
|----------|-----------|------------|--------------|
| Sharp Fang / Serpent Fang / etc. | Beast (specific) | 50–80 | Weapon upgrades, damage devices |
| Spirit Dust / Spirit Essence | Undead / Spirit | 60–100 | Spirit-element crafting |
| Crystal Shard | Construct | 75 | Precision components |
| Elemental Core | Elemental | 100 | Advanced elemental devices |

**Tier 3 — Rare (Interlude+ enemies, boss steals):**

| Material | Source Type | Sell Price | Crafting Use |
|----------|-----------|------------|--------------|
| Arcanite Shard | Carradan Constructs | 200 | Advanced Forgewright devices |
| Arcanite Core | Boss steal | 500 | High-tier weapon/armor forging |
| Pallor Sample | Pallor enemies | 150 | Anti-Pallor consumables, Pallor Salve |
| Grey Residue | Pallor enemies | 100 | Void-element infusions |

**Tier 4 — Epic (Act III+ bosses, post-game):**

| Material | Source Type | Sell Price | Crafting Use |
|----------|-----------|------------|--------------|
| Arcanite Ingot | Fixed dungeon locations (3 total) | 1,000 | Lira's ultimate weapon/armor |
| Pallor Core | Pallor Incarnate steal | 2,000 | Maren's ultimate staff |
| Grey Mist Essence | Vaelith drop | 1,500 | Lira's ultimate weapon |
| Dreamer's Fault materials (8 types) | Post-game age-specific | 300–800 | Age-specific crafting recipes |

### 2.3 Complete Material List

All materials already named in bestiary drop tables, organized by
source enemy type. The item catalog must include every one of these.

**Beast Parts (15):**
Beast Hide, Sharp Fang, Drake Fang, Drake Scale, Serpent Fang,
Leech Ichor, Lurker Shell, Wolf Pelt, Boar Tusk, Hawk Feather,
Hare Pelt, Beetle Carapace, Crab Claw, Viper Fang, Mite Husk,
Roach Wing, Rat Tail, Vermin Fang, Crawler Shell, Petrified Bark

**Construct Salvage (7):**
Scrap Metal, Crystal Shard, Drill Fragment, Molten Gear, Hound Gear,
Stone Fragment, Arcanite Core

**Spirit/Elemental (4):**
Ether Wisp, Spirit Essence, Spirit Dust, Element Shard, Elemental Core

**Pallor (5):**
Pallor Sample, Grey Residue, Nest Fragment, Pallor Shard, Pallor Ward

**Undead (2):**
Bone Fragment, Bone Dust

**Arcanite (3):**
Arcanite Shard, Arcanite Core, Arcanite Ingot

**Post-game Placeholders (8):**
Ancient Glyph, Carved Stone, Crystal Fragment, Prism Shard,
Living Bark, Heartwood Splint, Iron Cog, Tempered Plate

**Total: ~44 unique materials**

### 2.4 Sell Price Formula

```
sell_price = floor(base_value × tier_multiplier)
```

| Tier | Multiplier | Typical Sell Range |
|------|-----------|-------------------|
| 1 (Common, 75% steal) | ×1.0 | 25–40 |
| 2 (Uncommon, 25% drop) | ×2.0 | 50–100 |
| 3 (Rare, boss steal) | ×5.0 | 150–500 |
| 4 (Epic, fixed/unique) | ×10.0 | 1,000–2,000 |

---

## 3. Ley Crystal Invocations (18 crystals)

### 3.1 Core Mechanic

Each of the 18 Ley Crystals (per progression.md) grants a unique
combat ability accessible from the Magic/Ability menu. Inspired by
FF6's Esper summon system.

**Rules:**
- Each equipped crystal grants 1 invocation ability
- Uses are **limited per rest cycle** (restored at inns, tents, save points)
- Uses vary by crystal power tier (common: 5–8, uncommon: 3–4, rare: 1–2)
- Invocation power scales with crystal level (Lv 1–5)
- Accessed via the Magic menu (directional input, like FF6 Espers)
- Cannot be used during Ley Crystal Suppression events (see Section 3.3)

### 3.2 Invocation Catalog

| Crystal | Invocation Name | Effect (Lv 1 → Lv 5) | Uses |
|---------|----------------|----------------------|------|
| **Standard Crystals** | | | |
| Ember Shard | Forge Flare | Flame AoE: 150 → 500 damage | 5 |
| Iron Core | Ironwall | Party DEF +30% → +50%, 3 turns | 4 |
| Ley Prism | Ley Cascade | Ley AoE: 200 → 600 damage | 4 |
| Ward Stone | Null Barrier | Party MDEF +30% → +50%, 3 turns | 4 |
| Quicksilver | Time Slip | Party Haste, 2 → 4 turns | 3 |
| Fortune Stone | Fate's Hand | Party LCK +50% → +100%, 3 turns | 5 |
| Lifestone | Lifespring | Party heal: 300 → 1,500 HP | 6 |
| Wellspring | Mana Tide | Party MP restore: 20 → 80 MP | 4 |
| Spirit Tear | Spirit Call | Spirit AoE: 180 → 550 + chance Regen on party | 3 |
| Forgewright Core | Siege Engine | Non-elemental single: 400 → 1,200 + DEF break | 3 |
| **Negative-Effect Crystals** | | | |
| Flame Heart | Crucible Wrath | Flame AoE: 300 → 900 + Burn chance | 3 |
| Frost Veil | Absolute Zero | Frost AoE: 250 → 800 + Slow chance | 3 |
| Storm Eye | Tempest Surge | Storm AoE: 250 → 800 + random targeting | 4 |
| Grey Remnant | Pallor Touch | Void AoE: 350 → 1,000 + Despair chance (on enemies) | 2 |
| **Special Crystals** | | | |
| Dawn Fragment | First Light | Non-elemental AoE: 500 → 200 (DIMINISHES with level) | 8 → 2 |
| Convergence Shard | Convergence Pulse | Non-elem AoE: 100 → 100 → 100 → 100 → **2,000** (Lv 5 only) | 1 |
| Null Crystal | Void Shield | Party Despair immunity, 3 turns | 2 |
| Cael's Echo | Cael's Resolve | Party all stats +20%, 3 turns + heals 500 HP | 1 |

> **Dawn Fragment** inverts — starts powerful (500 damage, 8 uses at
> Lv 1) and weakens as it levels (200 damage, 2 uses at Lv 5). This
> mirrors its diminishing stat bonuses in progression.md. Players must
> decide: keep it at Lv 1 for combat utility, or level it for the
> (diminishing) stat gains?

> **Convergence Shard** is a sleeper — 100 damage for Lv 1–4, then
> 2,000 at Lv 5. Mirrors its stat progression. Only 1 use. The
> ultimate "patience rewarded" invocation.

> **Cael's Echo** is the most powerful invocation in the game but
> has only 1 use per rest. Narratively: Cael's lingering connection
> gives the party strength one more time.

### 3.3 Ley Crystal Suppression — Axis Tower

During the Axis Tower dungeon (Interlude climax), General Kole's
Pallor conduit channeling creates interference that suppresses all
Ley Crystal invocations.

**Mechanic:**
- On entering Axis Tower Floor 1, all crystal invocations become
  greyed out in the menu with tooltip: "Ley interference detected"
- Crystal STAT BONUSES still apply (passive, already permanent)
- Only INVOCATIONS are suppressed (active abilities)
- Defeating Kole and destroying the conduit crystals restores access
- This forces players to rely on items, abilities, and Forgewright
  devices for the Kole fight — no crystal safety net
- Narratively: the Pallor jams ley resonance at its strongest point

---

## 4. Lira's Forgewright Battle Devices (~12 recipes)

### 4.1 Core Mechanic

Lira can craft single-use combat devices from salvaged crafting
materials. Crafting happens at **save points, camps, or inns** (not
mid-battle). Any party member can USE a device in battle, but only
Lira can CRAFT them.

**Inventory limits:**
- 5 active device types carried at a time
- Each type stacks to 3
- Maximum 15 devices total in the field
- Crafting more requires being at a save point/camp
- Leftover materials stay in inventory — only the forged devices are limited

### 4.2 Device Recipes

| Device | Effect | Materials | Crafting Cost |
|--------|--------|-----------|---------------|
| **Offensive** | | | |
| Thermal Charge | Flame AoE: 400 damage | 2 Element Shard + 1 Scrap Metal | 100g |
| Frost Bomb | Frost AoE: 400 damage | 2 Element Shard + 1 Crystal Shard | 100g |
| Shock Coil | Storm single: 600 damage + Slow | 1 Elemental Core + 1 Scrap Metal | 200g |
| Pallor Grenade | Spirit AoE: 500 damage vs Pallor-type (2x) | 2 Pallor Sample + 1 Spirit Essence | 250g |
| **Defensive** | | | |
| Barrier Node | Party DEF +25%, 3 turns | 2 Scrap Metal + 1 Crystal Shard | 150g |
| Ward Emitter | Party MDEF +25%, 3 turns | 2 Crystal Shard + 1 Ether Wisp | 150g |
| Mending Engine | Heal one ally 800 HP + cure Poison/Burn | 2 Beast Hide + 1 Spirit Essence | 150g |
| **Utility** | | | |
| Flashbang | All enemies: 80% chance Blind, 2 turns | 1 Element Shard + 1 Bone Fragment | 100g |
| Gravity Anchor | All enemies: SPD -30%, 3 turns | 1 Scrap Metal + 1 Arcanite Shard | 300g |
| Disruption Pulse | Remove all buffs from all enemies | 1 Arcanite Shard + 1 Pallor Sample | 350g |
| **Advanced (Act III+)** | | | |
| Arcanite Lance | Non-elemental single: 1,500 damage | 1 Arcanite Core + 1 Elemental Core | 500g |
| Emergency Beacon | Revive all fainted allies at 50% HP | 1 Arcanite Core + 2 Spirit Essence | 800g |

### 4.3 Device Design Philosophy

**Why devices instead of shop-bought battle items?**
- Lira's identity: she's the engineer. Her out-of-combat contribution
  is preparing the party's tactical toolkit. This is SoM's Watts
  blacksmith model filtered through character identity.
- Material economy: those Beast Hides and Scrap Metal drops finally
  have a PURPOSE beyond selling. Every loot drop is a crafting decision.
- Loadout strategy: the 5-type limit forces pre-dungeon planning.
  "Pallor dungeon? Bring Pallor Grenades and Mending Engines."
  "Construct-heavy dungeon? Bring Shock Coils and Flashbangs."
- Progression: Advanced recipes unlock as Lira's story progresses
  (Arcanite Lance after Ashmark, Emergency Beacon after Convergence).

### 4.4 Recipe Unlocking

| When | Recipes Unlocked |
|------|-----------------|
| Act I (Lira joins) | Thermal Charge, Mending Engine, Flashbang |
| Act II (Ashmark Factory) | Frost Bomb, Shock Coil, Barrier Node, Ward Emitter |
| Interlude (Rail Tunnels) | Gravity Anchor, Disruption Pulse |
| Act III (Pallor Wastes) | Pallor Grenade |
| Act III (Forgotten Forge) | Arcanite Lance |
| Post-Convergence | Emergency Beacon |

---

## 5. Key Items (~35 items)

### 5.1 Inventory Design

Key items occupy a **separate inventory tab** from consumables and
materials. They cannot be sold, discarded, or stacked. They auto-use
when conditions are met (e.g., Archivist's Codex opens Ley Depths F5
when you approach the sealed door).

### 5.2 Key Item Categories

**Dungeon Access Items (auto-use):**
- Mine Water Vial (clears Dying Ember Crystal, Ember Vein F3)
- Archivist's Codex (opens Ley Depths F5 and Forgotten Forge)
- Ironmark Tunnel Map (navigates Ironmark passage)
- Ironmark Key (opens sealed Armory post-Kole)
- Forgewright Master Key (opens all Compact-era locked doors)
- Boring Engine Schematic (unlocks Lira recipe)
- Map to the Convergence (reveals Convergence on world map)
- Catacomb Map (reveals Valdris Catacombs secret passages)
- Broodchamber Map (reveals Caldera Undercity nest network)
- Keeper's Index (completes pictographic dictionary for Dry Well)

**Boss Mementos (narrative trophies, no gameplay effect):**
- Vein Guardian's Core
- Fenmother's Tear
- Operator's Badge
- Cael's Pendant
- Cael's Sword
- Vaelith's Quill
- Lost Page
- Grey Echo Shard

**Equipment/Accessory Drops (transferred to equipment system):**
These items are listed in bestiary drop tables as "100% drops" but
are actually equipment pieces. They go to the Equipment tab, not
Key Items. Listed here for cross-reference:
- Colossus Shard, Drayce's Failsafe Core, Warden's Binding,
  Kole's Epaulettes, Crown Shard, Unfinished Ring, Ashen Scholar's
  Tome, Titan's Core, Nexus Crest, Architect's Hammer, Grey Cleaver,
  Cael's Knight Crest, Cael's Memory, Scholar's Codex, Queen's Facet,
  Root Crown, Warden's Core, Dreamer's Crest

**Crafting Schematics (unlock Forgewright recipes):**
- Boring Engine Schematic (Caldera Undercity secret room)
- Forge Schematic (Architect boss steal)

**Story Items (plot triggers):**
- Fenmother's Blessing (safe passage through Fenmother's domain)
- Compact Battle Standard (Valdris Siege proof of victory)
- Pallor-Laced Iron (Ashen Ram crafting material → story item)
- Corrupted Tuning Fork (Vaelith breadcrumb, connects Forge Warden to larger plot)

### 5.3 Key Item Count

| Category | Count |
|----------|-------|
| Dungeon Access | 10 |
| Boss Mementos | 8 |
| Crafting Schematics | 2 |
| Story Items | 4 |
| **Total Key Items** | **~24** |

(Plus ~18 equipment drops that go to Equipment tab, not Key Items.)

---

## 6. Inventory Structure

### 6.1 Tab Layout

| Tab | Contents | Stack Limit | Slot Limit |
|-----|----------|------------|------------|
| **Consumables** | Potions, Ethers, status cures, capsules | HP/MP healing: 199; all others: 99 | Unlimited types |
| **Materials** | Crafting materials (Beast Hide, etc.) | 99 | Unlimited types |
| **Devices** | Lira's Forgewright battle devices | 3 per type | 5 types active |
| **Key Items** | Quest items, maps, mementos | 1 (unique) | Unlimited |

### 6.2 Sell Price Rules

- Consumables: sell at 50% of buy price
- Materials: sell at listed sell price (see Section 2.4)
- Devices: cannot be sold (crafted, not bought)
- Key items: cannot be sold
- Equipment: sell at 50% of buy price (handled in Gap 1.5)

---

## 7. Drake Fang — Special Case

Drake Fang (100% drop from Ember Drake mini-boss) is already
established as a dual-purpose item:
- **Consumable use:** 500 damage in the Vein Guardian boss fight
- **Crafting material:** Lira can forge it into a weapon component

This pattern can be extended to other boss drops if desired, but
Drake Fang is the only one currently designed with dual purpose.
All other boss drops are single-purpose (equipment, key item, or
crafting material).

---

## 8. Cross-Reference Verification

### 8.1 magic.md Status Cure Mapping

Every status in magic.md's Status Effect Reference must have an
item cure (or an explicit "no item cure" note):

| Status | Item Cure | Notes |
|--------|-----------|-------|
| Poison | Antidote | Also cures Burn |
| Burn | Antidote | Shares cure with Poison |
| Sleep | Alarm Clock | |
| Confusion | Remedy | No dedicated single cure (like FF6) |
| Silence | Echo Drop | |
| Blind | Eye Drops | |
| Petrify | Soft Stone | |
| Slow | Chronos Dust | |
| Stop | — | Wears off only (per magic.md) |
| Berserk | Remedy | No dedicated single cure |
| Faint | Phoenix Feather / Phoenix Pinion | Revival items |
| Despair | Pallor Salve (Act III), Hope Shard (rare) | Cannot be cured by Remedy |

### 8.2 Bestiary Drop Consistency

Every item name in bestiary Steal/Drop columns must appear in either:
- Section 1 (Consumables) — Potion, Smoke Bomb
- Section 2 (Materials) — Beast Hide, Scrap Metal, etc.
- Section 5 (Key Items) — Fenmother's Blessing, maps, etc.
- Gap 1.5 (Equipment) — accessories, weapons (future doc)

### 8.3 Existing Item Name Conflicts

**Items already named in magic.md "Cured By" column:**
- Antidote ✓ (Section 1.4)
- Alarm Clock ✓ (Section 1.4)
- Echo Drop ✓ (Section 1.4)
- Eye Drops ✓ (Section 1.4)
- Soft Stone ✓ (Section 1.4)
- Chronos Dust ✓ (Section 1.4)
- Remedy ✓ (Section 1.4)
- Hope Shard ✓ (Section 1.4)
- Phoenix Feather ✓ (Section 1.3)

All pre-existing item names are preserved. No renames needed.

---

## 9. What This Spec Does NOT Cover

- **Equipment** (weapons, armor, accessories) — Gap 1.5
- **Shop inventories per town** — Gap 1.6 (Economy)
- **Crafting recipe balance** (exact damage numbers for devices) —
  tuned during implementation against combat-formulas.md
- **Item acquisition matrix** (which chests contain what) — part of
  implementation, not design
- **Dreamer's Fault placeholder items** — the 8 age-specific materials
  get names and effects during implementation, not spec
