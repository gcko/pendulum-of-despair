# Equipment System Design Spec

> **Gap 1.5** — weapons, armor, and accessories for all 6 party members
> across 5 acts. Creates `docs/story/equipment.md`.

**Goal:** Create the complete equipment catalog with stat tables,
per-character weapon types, tiered armor progression, effect-based
accessories, Arcanite Forging integration, and elemental infusion
system with secret synergy combos.

**Scope:** ~55-70 weapons (6 types) + ~40-50 armor (head + body) +
~30 accessories = ~125-150 total equipment pieces.

**Reference:** `docs/references/weapons/analysis.md`,
`docs/references/armor/analysis.md` — cross-game counts and curves.

---

## 1. Equipment Slots

4 equipment slots per character + the existing Ley Crystal slot
(progression.md). No shields — defensive stats come from head armor,
body armor, and accessories.

| Slot | Purpose | Stats Provided |
|------|---------|---------------|
| **Weapon** | Offensive primary | ATK (primary), sometimes MAG/SPD/LCK |
| **Head** | Defensive secondary | DEF, MDEF, sometimes status immunity |
| **Body** | Defensive primary | DEF (primary), MDEF, sometimes elemental resist |
| **Accessory** | Customization | Varied effects — stat boosts, mechanics, immunities |
| **Ley Crystal** | Existing system | Stat growth bonuses + invocations (see progression.md) |

---

## 2. Weapon Types (6 types, 1 per character)

Each character has exactly one equippable weapon type. No sharing,
no secondary types. This creates clear identity — Edren IS swords,
Lira IS hammers.

| Character | Weapon Type | Fantasy | ATK Emphasis |
|-----------|-----------|---------|-------------|
| Edren | Swords | Knight one-handers, longswords | Balanced ATK |
| Cael | Greatswords | Two-hand heavy blades | High ATK, lower SPD |
| Maren | Staves | Casting staves, arcane rods | Low ATK, bonus MAG |
| Sable | Daggers | Knives, stilettos, shivs | Moderate ATK, bonus SPD/LCK |
| Lira | Hammers | Wrenches, mallets, forge tools | High ATK, no MAG |
| Torren | Spears | Lances, pikes, javelins | Moderate ATK, reach |

### 2.1 Weapon Count per Type

~9-12 weapons per type across 6 tiers = ~55-70 total weapons.

| Tier | Act | Count per Type | Total Weapons |
|------|-----|---------------|---------------|
| 0 | Starting | 1 | 6 |
| 1 | Act I | 1-2 | 8 |
| 2 | Act II | 2 | 12 |
| 3 | Interlude | 1-2 | 8 |
| 4 | Act III | 2 | 12 |
| 5 | Ultimate | 1 | 6 |
| Forged | Various | 1-2 per type | ~8 |
| **Total** | | **~10 per type** | **~60** |

### 2.2 Weapon Stat Template

| Column | Type | Description |
|--------|------|-------------|
| Name | string | Unique weapon name |
| Type | enum | Sword, Greatsword, Staff, Dagger, Hammer, Spear |
| Tier | int | 0-5 (Starting through Ultimate) |
| ATK | int | Physical attack bonus (3-100) |
| Bonus Stat | string | Optional secondary stat (+MAG, +SPD, +LCK, etc.) or "—" |
| Element | string | Elemental affinity or "—" (can be changed by infusion) |
| Special | string | Special effect or "—" |
| Price | int | Buy price in Gold (0 = not sold, quest/drop only) |
| Wielder | string | Character name |
| Acquired | string | Shop tier, dungeon chest, boss drop, Forgewright |

---

## 3. ATK Growth Adjustment

### 3.1 The Change

To make weapon upgrades more impactful at every stage, character ATK
growth rates are **reduced by ~20%** from the current values in
progression.md.

> **REBALANCE FLAG:** This change affects the damage formula output
> for ALL physical attackers. The bestiary's 198 regular enemies and
> 29 bosses were balanced against the original ATK growth rates. A
> balance pass (Gap 3.4: Difficulty & Balance Framework) must verify
> that enemy HP values still produce 2-4 hit kills for regulars and
> 3-5 minute boss fights with the adjusted ATK growth. Until Gap 3.4
> is completed, the bestiary values are provisional.

**Current ATK growth (progression.md):**

| Character | Current ATK Growth | Current ATK @ Lv 50 |
|-----------|-------------------|---------------------|
| Edren | +1.8 | 106 |
| Cael | +1.5 | 88 |
| Lira | +1.2 | 73 |
| Sable | +1.4 | 82 |
| Torren | +0.8 | 49 |
| Maren | +0.5 | 30 |

**Proposed ATK growth (reduced ~20%):**

| Character | New ATK Growth | New ATK @ Lv 50 | Weapon % of Total (Tier 4, +48) |
|-----------|---------------|-----------------|-------------------------------|
| Edren | +1.4 | 87 | 87+48=135 → 36% from weapon |
| Cael | +1.2 | 73 | 73+48=121 → 40% from weapon |
| Lira | +1.0 | 63 | 63+48=111 → 43% from weapon |
| Sable | +1.1 | 68 | 68+48=116 → 41% from weapon |
| Torren | +0.6 | 39 | 39+48=87 → 55% from weapon |
| Maren | +0.4 | 26 | 26+48=74 → 65% from weapon |

**Result:** Weapons now represent 36-65% of total ATK at Lv 50 (was
28-61%). Upgrading equipment feels meaningful at every stage. Maren
and Torren (low ATK characters) benefit MOST from weapon upgrades,
which makes sense — their physical damage is weapon-dependent.

### 3.2 Damage Verification

Physical damage formula: `ATK² / 6 - DEF`

**Edren Lv 18 (end of Act I), Tier 1 weapon (+10):**
- New ATK at Lv 18: floor(18 × 1.4 + 18) = 43
- Total ATK: 43 + 10 = 53
- vs Lv 12 enemy (DEF 19): (53² / 6) - 19 = 449
- Lv 12 enemy HP ~320: dies in 1 hit. Fine — Act I enemies at
  end-of-act level should be easy.

**Edren Lv 18, Tier 2 weapon (+18, just bought in Act II):**
- Total ATK: 43 + 18 = 61
- vs Lv 18 enemy (DEF 26): (61² / 6) - 26 = 594
- Lv 18 enemy HP ~819: dies in 2 hits. Good.

**Edren Lv 35 (end of Act II), Tier 3 weapon (+32):**
- New ATK at Lv 35: floor(35 × 1.4 + 18) = 67
- Total ATK: 67 + 32 = 99
- vs Lv 35 enemy (DEF 47): (99² / 6) - 47 = 1,587
- Lv 35 enemy HP ~2,645: dies in 2 hits. Good.

**Edren Lv 50 (post-game), Tier 4 weapon (+48):**
- Total ATK: 87 + 48 = 135
- vs Lv 50 enemy (DEF 65): (135² / 6) - 65 = 2,972
- Lv 50 enemy HP ~5,120: dies in 2 hits. Good.

Numbers hold. The 20% ATK reduction is compensated by weapon ATK
contribution, maintaining the 2-hit kill target for on-level enemies.

---

## 4. Weapon ATK Progression by Tier

| Tier | Act | ATK Range | Price Range | Acquisition |
|------|-----|-----------|-------------|-------------|
| 0 | Starting | 3-5 | Free | Initial equipment |
| 1 | Act I | 8-12 | 200-600 | Act I shops, Ember Vein chests |
| 2 | Act II | 15-22 | 800-2,500 | Act II shops, dungeon chests |
| 3 | Interlude | 28-38 | 2,000-5,000 | Interlude shops (limited), chests |
| 4 | Act III | 42-55 | 4,000-10,000 | Act III shops, Pallor Wastes |
| 5 | Ultimate | 65-100 | Not sold | Sidequests, bosses, Dreamer's Fault |
| Forged | Various | Varies (+5-10 above tier) | Material cost | Lira's Arcanite Forging |

### 4.1 Per-Type ATK Modifiers

Not all weapon types have the same ATK at the same tier. Heavy
weapons (Greatswords, Hammers) have higher ATK; light weapons
(Daggers, Staves) have lower ATK but better secondary stats.

| Type | ATK Modifier | Secondary Bonus | Rationale |
|------|-------------|----------------|-----------|
| Swords | ×1.0 (baseline) | — | Balanced standard |
| Greatswords | ×1.15 | SPD -2 to -5 | Heavy = strong but slow |
| Staves | ×0.6 | MAG +5 to +20 | Casting weapon, ATK irrelevant |
| Daggers | ×0.85 | SPD +2 to +5, LCK +1 to +3 | Fast, lucky |
| Hammers | ×1.1 | — | Strong, no secondary |
| Spears | ×0.95 | — | Balanced, reach (flavor) |

Example at Tier 3 (base range 28-38):
- Sword: ATK 33 (×1.0)
- Greatsword: ATK 38 (×1.15), SPD -3
- Staff: ATK 20 (×0.6), MAG +12
- Dagger: ATK 28 (×0.85), SPD +3, LCK +2
- Hammer: ATK 36 (×1.1)
- Spear: ATK 31 (×0.95)

---

## 5. Armor System

### 5.1 Head Armor

~20-25 pieces total. Provides DEF (secondary) and MDEF. Some have
status immunities at higher tiers.

| Tier | DEF Range | MDEF Range | Price Range |
|------|-----------|-----------|-------------|
| 0 | 2-3 | 1-2 | Free |
| 1 | 5-8 | 3-5 | 100-400 |
| 2 | 10-15 | 6-10 | 500-1,500 |
| 3 | 18-24 | 12-16 | 1,500-3,500 |
| 4 | 28-35 | 20-25 | 3,000-7,000 |
| 5 | 40-55 | 30-40 | Not sold |

**Character restrictions on head armor:** None — all characters can
equip all head armor. This keeps the system simple and avoids the
"heavy/light" distinction that FF4 uses (too many items).

### 5.2 Body Armor

~20-25 pieces total. Provides DEF (primary) and sometimes elemental
resistance. Some have stat bonuses at higher tiers.

| Tier | DEF Range | MDEF Range | Price Range |
|------|-----------|-----------|-------------|
| 0 | 4-6 | 2-3 | Free |
| 1 | 8-12 | 4-6 | 200-600 |
| 2 | 15-22 | 8-12 | 800-2,500 |
| 3 | 25-35 | 15-20 | 2,000-5,000 |
| 4 | 40-50 | 25-32 | 4,000-9,000 |
| 5 | 55-75 | 35-50 | Not sold |

**Character restrictions on body armor:** Light/Heavy split.

| Category | Who Can Equip | DEF Modifier | Examples |
|----------|--------------|-------------|---------|
| Light Armor | All characters | ×1.0 | Leather, Chain, Mythril Vest |
| Heavy Armor | Edren, Lira, Torren | ×1.3 | Plate, Crystal Mail, Genji Armor |
| Robes | Maren, Torren | ×0.7, MDEF ×1.5 | Silk Robe, Ley Vestment |

This gives 3 body armor sub-types with different stat profiles,
creating meaningful choice without per-character restriction.

---

## 6. Accessories (~30 items)

### 6.1 Progression Philosophy (FF6 Relic Model)

Accessories evolve from simple stat boosts to complex effects:

| Act | Accessory Style | Examples |
|-----|----------------|---------|
| Act I | Stat boosts (+5 ATK, +5 DEF) | Power Ring, Iron Bracelet |
| Act II | Moderate stats + simple effects | Silver Earring (+8 MAG), Antidote Charm (Poison immune) |
| Interlude | Effect-focused | Haste Bangle (auto-Haste 2 turns at battle start), Counter Ring (+15% counter rate) |
| Act III | Strong effects, strategic | Despair Ward (Despair immune), Ley Amplifier (+20% spell damage), Pallor Bane (+25% damage vs Pallor) |
| Ultimate | Game-changing unique effects | Dreamer's Crest (+30 all stats), Cael's Knight Crest (+20 all stats, Edren only) |

### 6.2 Accessory Categories

| Category | Count | Effect Type |
|----------|-------|------------|
| Stat Boost | ~8 | +ATK, +DEF, +MAG, +MDEF, +SPD, +LCK, +HP, +MP |
| Status Immunity | ~6 | Poison immune, Sleep immune, Silence immune, etc. |
| Elemental Resistance | ~4 | Halve Flame, Halve Frost, Halve Storm, Halve Void |
| Combat Mechanic | ~6 | Auto-Haste, Counter-attack, MP Regen, Preemptive |
| Character-Specific | ~4 | Cael's Knight Crest, Dreamer's Crest, etc. |
| Unique Quest | ~2 | Forgewright Goggles, etc. |
| **Total** | **~30** | |

### 6.3 Boss Equipment Drops

18 boss drops already named in items.md cross-reference. These map to
equipment slots:

| Drop | Slot | Source Boss | Act |
|------|------|-----------|-----|
| Colossus Shard | Accessory | Ley Colossus | II |
| Drayce's Failsafe Core | Accessory | Forge Warden | II |
| Warden's Binding | Accessory | Undying Warden | Interlude |
| Kole's Epaulettes | Body Armor | General Kole | Interlude |
| Crown Shard | Accessory | Crowned Hollow | III |
| Unfinished Ring | Accessory | Perfect Machine | III |
| Ashen Scholar's Tome | Accessory | Vaelith | III |
| Titan's Core | Accessory | Ley Titan | III |
| Nexus Crest | Accessory | Wellspring Guardian | III |
| Architect's Hammer | Weapon (Lira) | The Architect | III |
| Grey Cleaver | Weapon (Torren) | Grey Cleaver Unbound | III |
| Cael's Knight Crest | Accessory | Cael Phase 1 | III |
| Cael's Memory | Accessory | Pallor Echo | III |
| Scholar's Codex | Accessory | First Scholar | Post |
| Queen's Facet | Accessory | Crystal Queen | Post |
| Root Crown | Head Armor | Rootking | Post |
| Warden's Core | Accessory | Iron Warden | Post |
| Dreamer's Crest | Accessory | Cael's Echo | Post |

---

## 7. Arcanite Forging (Equipment Crafting)

### 7.1 Forgeable Equipment (~8 pieces)

Lira can forge unique equipment pieces not available in shops. Each
requires specific crafting materials and a story unlock. Forged items
are tagged with a **"Forged"** attribute visible in the equipment menu.

| Forged Item | Slot | Type | Stats | Materials | Unlock |
|-------------|------|------|-------|-----------|--------|
| Arcanite Blade | Weapon (Edren) | Sword | ATK 35, +5 MAG | 1 Arcanite Ingot + 3 Crystal Shard | Interlude (Rail Tunnels) |
| Forgewright Maul | Weapon (Lira) | Hammer | ATK 40 | 1 Arcanite Ingot + 2 Scrap Metal + 1 Drill Fragment | Interlude (Rail Tunnels) |
| Thornspear | Weapon (Torren) | Spear | ATK 30, +3 SPD | 3 Spirit Essence + 2 Petrified Bark | Act III (Pallor Wastes) |
| Shadowsteel Knife | Weapon (Sable) | Dagger | ATK 28, +4 SPD, +3 LCK | 2 Pallor Sample + 1 Arcanite Shard | Act III (Pallor Wastes) |
| Resonance Rod | Weapon (Maren) | Staff | ATK 15, +15 MAG | 2 Elemental Core + 2 Ley Crystal Fragment | Act III (Dry Well) |
| Arcanite Helm | Head | — | DEF 30, MDEF 22 | 1 Arcanite Ingot + 2 Drill Fragment | Interlude |
| Pallor Ward Vest | Body | Light | DEF 38, MDEF 25, Despair resist 50% | 3 Pallor Sample + 2 Grey Residue + 1 Spirit Essence | Act III |
| Ley-Woven Cloak | Body | Robe | DEF 20, MDEF 40, MP Regen 3%/turn | 2 Ether Wisp + 2 Elemental Core + 1 Ley Crystal Fragment | Act III |

### 7.2 Elemental Infusions (7 types)

Lira can infuse any weapon with an elemental affinity. Infusions are
**permanent but replaceable** — applying a new infusion overwrites
the old one. Infusion requires materials + gold.

| Infusion | Element Added | Materials | Gold Cost |
|----------|-------------|-----------|-----------|
| Flame Infusion | Flame | 2 Element Shard + 1 Molten Gear | 300 |
| Frost Infusion | Frost | 2 Element Shard + 1 Crystal Shard | 300 |
| Storm Infusion | Storm | 2 Element Shard + 1 Scrap Metal | 300 |
| Earth Infusion | Earth | 2 Element Shard + 1 Stone Fragment | 300 |
| Ley Infusion | Ley | 2 Elemental Core + 1 Ley Crystal Fragment | 500 |
| Spirit Infusion | Spirit | 2 Spirit Essence + 1 Ether Wisp | 500 |
| Void Infusion | Void | 2 Pallor Sample + 1 Grey Residue | 500 |

**Rules:**
- Any weapon can be infused (including Forged and Ultimate weapons)
- Infused weapons deal that element's damage type on all physical hits
- Elemental multipliers per combat-formulas.md apply (1.5x weak, 0.75x
  resist, etc.)
- Infusion is visible as a colored aura on the weapon sprite
- Infusion persists until replaced or removed (free removal at any
  save point)
- Infused weapons gain an "(Infused: Element)" suffix in the menu

### 7.3 Secret Infusion Synergies (6 combos)

When specific weapons receive specific infusions, a hidden synergy
activates — granting a bonus effect beyond the normal elemental
damage. The weapon name changes and a discovery notification appears.

| Base Weapon | Infusion | Synergy Name | Bonus Effect |
|-------------|----------|-------------|-------------|
| Grey Cleaver (tainted) | Spirit | Penitent's Edge | Purification counter accelerated: 50 encounters instead of 100 |
| Architect's Hammer | Storm | Stormforge Hammer | +25% damage vs Construct-type enemies |
| Any Torren Spear | Earth | Rootbound Lance | Physical attacks have 20% chance to inflict Slow |
| Any Maren Staff | Ley | Resonance Staff | MP cost of all spells reduced by 15% |
| Any Sable Dagger | Void | Shadowfang | Steal rate +25%, successful steals have 15% chance to inflict Despair |
| Any Lira Hammer | Flame | Crucible Maul | Forgewright device crafting gold cost reduced by 50% |

**Design intent:** Each synergy reflects the character's narrative
identity meeting the element that defines their tradition or arc:
- Torren (Thornmere wilds) + Earth = rootbound nature
- Maren (Valdris ley scholar) + Ley = ley resonance
- Sable (shadow operative) + Void = embracing the grey
- Lira (Forgewright) + Flame = forge-fire mastery
- Grey Cleaver (cursed by despair) + Spirit = despair's antithesis
- Architect's Hammer (Construct-made) + Storm = Construct weakness

Players discover these by experimentation. No in-game hints until
the synergy activates — then the discovery notification says:
"Lira senses a resonance between the [weapon] and the [element]
infusion. The weapon transforms..."

---

## 8. Equipment Prices

### 8.1 Price Formula

Equipment prices follow a tier-based curve:

```
base_price(tier) = floor(200 × 2.5^tier)
```

| Tier | Base Price | Weapon | Head | Body |
|------|-----------|--------|------|------|
| 0 | — | Free | Free | Free |
| 1 | 200 | 200-600 | 100-400 | 200-600 |
| 2 | 500 | 800-2,500 | 500-1,500 | 800-2,500 |
| 3 | 1,250 | 2,000-5,000 | 1,500-3,500 | 2,000-5,000 |
| 4 | 3,125 | 4,000-10,000 | 3,000-7,000 | 4,000-9,000 |
| 5 | — | Not sold | Not sold | Not sold |

**Sell price:** floor(buy_price / 2) — same as consumables.

### 8.2 Accessory Prices

| Act | Price Range |
|-----|-----------|
| Act I | 200-500 |
| Act II | 500-2,000 |
| Interlude | 1,500-4,000 |
| Act III | 3,000-8,000 |
| Ultimate | Not sold |

---

## 9. Elemental Equipment Distribution

### 9.1 Elemental Weapons (via infusion, not fixed)

Rather than designing dedicated "Flame Sword," "Ice Sword," etc.,
the elemental infusion system (Section 7.2) handles this. Players
choose which element to apply to their weapon. A few boss drops
have FIXED elements that cannot be changed:

| Weapon | Fixed Element | Source |
|--------|-------------|--------|
| Grey Cleaver (purified) | Spirit | Grey Cleaver Unbound boss |
| Titan's Core (accessory) | Ley | Ley Titan boss |

### 9.2 Elemental Armor

Body armor at Tier 3+ can have elemental resistance (halve damage
from one element). These replace some generic body armor slots:

| Armor | Element Resisted | Tier | Acquisition |
|-------|-----------------|------|-------------|
| Flameguard Mail | Halve Flame | 3 | Caldera shop |
| Frostweave Vest | Halve Frost | 3 | Highcairn chest |
| Stormhide Coat | Halve Storm | 3 | Bellhaven shop |
| Earthen Plate | Halve Earth | 3 | Thornmere chest |
| Ley-Woven Cloak | MP Regen (Ley-themed) | Forged | Lira crafts |
| Pallor Ward Vest | 50% Despair resist | Forged | Lira crafts |
| Spirit Shroud | Halve Spirit + Void | 5 | Dreamer's Fault |

---

## 10. Document Structure

### 10.1 File: `docs/story/equipment.md`

```markdown
# Equipment Catalog — Pendulum of Despair

## Equipment Slots
## ATK Growth Adjustment (rebalance note)
## Weapons
### Swords (Edren)
### Greatswords (Cael)
### Staves (Maren)
### Daggers (Sable)
### Hammers (Lira)
### Spears (Torren)
### Weapon Summary
## Head Armor
## Body Armor
### Light Armor
### Heavy Armor
### Robes
### Body Armor Summary
## Accessories
### Stat Boost
### Status Immunity
### Elemental Resistance
### Combat Mechanic
### Character-Specific / Quest
### Accessory Summary
## Arcanite Forging
### Forgeable Equipment
### Elemental Infusions
### Secret Synergies
## Equipment Tiers by Act
## Price Reference
## Cross-Reference (boss drops, items.md)
```

---

## 11. Scope Considerations

This is a large gap (~125-150 items). Consider sub-projects:

**Sub-project A:** Weapons (6 types × ~10 each = ~60 items) +
ATK growth rebalance note

**Sub-project B:** Armor (head ~22 + body ~25 = ~47 items) +
elemental armor

**Sub-project C:** Accessories (~30 items) + Arcanite Forging
(8 forged + 7 infusions + 6 synergies)

Each sub-project can be its own PR, similar to the bestiary approach.
Or all can be done in one large PR if preferred.

---

## 12. What This Spec Does NOT Cover

- **Shop inventories per town** — Gap 1.6 (Economy). Equipment prices
  are defined here; which shops sell which items is Economy.
- **Exact enemy rebalance** — Gap 3.4 (Difficulty & Balance). The ATK
  growth change is flagged; actual enemy HP adjustments happen later.
- **progression.md update** — The ATK growth values in progression.md
  will be updated during implementation, with a rebalance flag note.
- **Treasure chest placement** — Where specific equipment is found in
  dungeons. Defined per-dungeon, not in equipment.md.
