# Economy & Pricing System Design

> Spec for Gap 1.6. Defines the complete economic system: currency,
> shop inventories, gold pacing, treasure chest formulas, boss gold
> drops, inn costs, crafting costs, steal economy, quest rewards,
> and wealth curve targets.

---

## Table of Contents

1. [Economic Philosophy & Core Rules](#1-economic-philosophy--core-rules)
2. [Inn Costs & Faction Pricing](#2-inn-costs--faction-pricing)
3. [Rest Item Progression](#3-rest-item-progression)
4. [Shop Inventories Per Town](#4-shop-inventories-per-town)
5. [Event-Triggered Restocking](#5-event-triggered-restocking)
6. [Treasure Chest Gold Formula](#6-treasure-chest-gold-formula)
7. [Boss Gold Drop Table](#7-boss-gold-drop-table)
8. [Sable's Steal Economy](#8-sables-steal-economy)
9. [Crafting Economy & Arcanite Forging Costs](#9-crafting-economy--arcanite-forging-costs)
10. [Quest Reward Gold & Material Rewards](#10-quest-reward-gold--material-rewards)
11. [Gold Pacing Targets Per Act](#11-gold-pacing-targets-per-act)
12. [Wealth Curve & Verification Targets](#12-wealth-curve--verification-targets)
13. [Cross-References](#13-cross-references)
14. [Files Created/Modified](#14-files-createdmodified)

---

## 1. Economic Philosophy & Core Rules

### Currency

**Gold** is the universal currency. "Scrip" is a regional name used in
Carradan Compact territory — mechanically identical to Gold. No
conversion rate, no separate wallet, no regional currencies. Like Gil
in Final Fantasy VI: one name, one world currency.

All references to "Scrip" in dungeon docs (dungeons-city.md) should be
read as Gold amounts.

### Affordability Target: 70%

A player progressing normally through each act (no grinding, no material
selling, no steal optimization) can afford **~70% of available
equipment** at each town. The remaining 30% requires extra effort:

- Additional battles beyond the critical path
- Selling crafting materials (the sell-or-save tension)
- Sable's steal ability (free items and gold pouches)
- Backtracking for missed treasure chests
- Completing side quests

This "means" economy splits the difference between FF4's tight (60%)
and FF6's comfortable (80%) models.

### Sell Price Rule

All items sell at **50% of buy price** (already established in
items.md). Exception: Sea Prince's Signet accessory raises sell rate
to 57.5%.

### Three Gold Sinks

1. **Equipment** — primary sink, drives progression
2. **Consumables** — ongoing drain, competes with equipment budget
3. **Inns** — minor flavor sink, tiered by town size (50–500g)

### Three Gold Sources

1. **Enemy drops** — primary income, scales with area level via logistic
   curve (bestiary README formula)
2. **Treasure chests** — percentage-of-next-upgrade formula,
   placement-scaled within dungeons
3. **Boss encounters** — full-tier payday, narratively justified (gold
   on humanoids, lair chests for beasts/spirits)

### Crafting Material Tension

Materials can be sold (Tier 1: 25–40g, Tier 4: 700–1,000g) OR saved
for Forgewright recipes and Arcanite Forging. This is the core economic
decision: gold now vs power later. The economy is designed so that
selling ALL materials through Act II gains ~3,000–5,000g extra, closing
the 70% affordability gap to ~85%. Meaningful but not game-breaking.

### Vendor Trash

There are no dedicated "vendor trash" items (items whose sole purpose
is selling). Instead, **crafting materials serve double duty** — they
can be sold or saved for forging. Humanoid enemies drop consumables and
Gold Pouches via Sable's steal (Section 8). This keeps inventory clean
and every drop meaningful.

### Special Services

No money lender, bank, or interest-bearing services exist. The game's
economy is straightforward: earn gold, spend gold. Complexity comes
from the sell-or-save material decision and Caldera's inflation, not
from financial instruments. This matches the SNES-era approach — FF4,
FF6, and CT had no banking systems.

---

## 2. Inn Costs & Faction Pricing

### Inn Costs by Town

| Town | Act | Inn Cost | Flavor |
|------|-----|----------|--------|
| Aelhart | I | Free | Home village, Edren's mother runs it |
| Highcairn | I | 50g | Monastery hospitality, minimal charge |
| Valdris Crown | I–II | 150g | Capital city, mid-range inn |
| Corrund | II | 100g | Canal district, modest lodging |
| Caldera | II | 300g (450g at company rate) | Inflated by Compact exploitation |
| Ashmark | II | 100g | Harbor district, basic |
| Bellhaven | II | 150g | Coastal trade city, tourist markup |
| Thornmere | II | 100g | Isolated but welcoming |
| Ironmark | Interlude | 75g | War-torn, discounted from desperation |
| Act III Oases | III | 50–100g | Refugee camps, scraping by |

### Caldera Inflation

**Markup: 150%** — all Caldera shops charge 1.5x standard price. This
is narrative-driven: the Compact's company store model exploits workers
and visitors alike.

**Caldera Employee Card:**
- **Effect:** 25% discount on all Caldera shop prices
- **Net price:** 150% x 0.75 = **112.5%** of standard — still above
  market rate. Even employees get squeezed.
- **Acquisition:** Sable pickpockets it from a Compact officer in
  Caldera. Requires Sable in active party during a Caldera exploration
  sequence.
- **Scope:** Applies to ALL Caldera vendors (items, equipment, inn)
- **Key item:** Cannot be sold or discarded

**Tash's Black Market (Caldera Undercity):** Uses **standard prices**.
The underground economy doesn't play by Compact rules. Accessed via
Sable.

**All other towns:** Standard pricing. No other faction modifiers.
Regional flavor comes from stock differences, not price differences.

---

## 3. Rest Item Progression

Replaces the original Tent/Cottage naming with a clear 3-tier hierarchy.

| Item | Buy Price | Sell Price | Effect | Available |
|------|-----------|-----------|--------|-----------|
| Sleeping Bag | 250g | 125g | Restore 25% HP/MP to all (save point only) | Act I |
| Tent | 500g | 250g | Restore 50% HP/MP to all (save point only) | Act I |
| Pavilion | 1,200g | 600g | Restore 100% HP/MP to all (save point only) | Act II |

**Stack limit:** 99 for all rest items (not 199 — these are bulky).

**Design note:** Inns are cheaper per-rest but only available in towns.
Rest items are the dungeon alternative. A player choosing between 2
Tents (1,000g) and 1 Pavilion (1,200g) is a real micro-decision:
Pavilion is more convenient but costs more for equivalent total healing.

---

## 4. Shop Inventories Per Town

### 4.1 Aelhart (Starting Village)

**General Store:**

| Item | Price | Notes |
|------|-------|-------|
| Potion | 50g | |
| Antidote | 50g | |
| Eye Drops | 50g | |
| Smoke Bomb | 100g | |

*Restocked after Ember Vein:* +Hi-Potion (300g), +Phoenix Feather
(500g), +Sleeping Bag (250g), +Tent (500g).

No armorer. Edren starts with basic gear. Carradan trader sells Lira's
starting Forgewright tools (not equipment).

### 4.2 Highcairn (Monastery Town)

**Provisioner (limited):**

| Item | Price |
|------|-------|
| Potion | 50g |
| Antidote | 50g |
| Sleeping Bag | 250g |
| Echo Drop | 75g |

No armorer, no specialty shop. Monastery town — austere.

### 4.3 Valdris Crown (Capital)

**General Store (Lower Ward):**

| Item | Price |
|------|-------|
| Potion | 50g |
| Hi-Potion | 300g |
| Ether | 200g |
| Antidote | 50g |
| Alarm Clock | 75g |
| Echo Drop | 75g |
| Eye Drops | 50g |
| Phoenix Feather | 500g |
| Sleeping Bag | 250g |
| Tent | 500g |
| Smoke Bomb | 100g |
| Waystone | 300g |

**Armorer (Lower Ward):**

| Weapons | Price | Head Armor | Price | Body Armor | Price |
|---------|-------|------------|-------|------------|-------|
| Valdris Blade | 300g | Iron Helm | 200g | Chain Mail | 300g |
| Knight's Edge | 500g | Traveler's Hood | 250g | Iron Plate | 400g |
| Ley Wand | 250g | Ember Circlet | 350g | Silk Robe | 300g |
| Stiletto | 250g | | | Reinforced Vest | 500g |
| Iron Mallet | 300g | | | | |
| Iron Lance | 250g | | | | |

**Specialty Shop (Citizen's Walk):**

| Accessory | Price |
|-----------|-------|
| Power Ring | 300g |
| Iron Bracelet | 300g |
| Magic Earring | 400g |
| Warding Charm | 400g |
| Sprint Shoes | 500g |
| Lucky Coin | 500g |
| Antidote Charm | 600g |

*Restocked when Act II diplomatic mission begins:* General store adds
Hi-Ether (800g), Smelling Salts (75g), Chronos Dust (150g). Armorer
adds Commander's Blade (400g), Glyph Staff (500g), Pickpocket's Blade
(400g), Pipe Hammer (500g). Represents wartime mobilization.

### 4.4 Corrund (Compact Canal City)

**General Store (Canal District):**

| Item | Price |
|------|-------|
| Potion | 50g |
| Hi-Potion | 300g |
| Ether | 200g |
| Hi-Ether | 800g |
| Antidote | 50g |
| Smelling Salts | 75g |
| Alarm Clock | 75g |
| Phoenix Feather | 500g |
| Tent | 500g |
| Smoke Bomb | 100g |

**Armorer:**

| Weapons | Price | Head Armor | Price | Body Armor | Price |
|---------|-------|------------|-------|------------|-------|
| Mythril Sword | 1,200g | Mythril Helm | 800g | Mythril Vest | 1,200g |
| Mythril Staff | 1,000g | Scholar's Cap | 900g | Steel Plate | 1,000g |
| Mythril Dagger | 1,000g | | | Ley Vestment | 1,200g |
| Mythril Spear | 1,000g | | | | |
| Compact Sledge | 1,200g | | | | |

**Sable's Black Market (Undercroft — requires Sable):**

| Item | Price | Notes |
|------|-------|-------|
| Trick Blade | 1,500g | Sable dagger, early access |
| Clarity Band | 800g | Silence immunity |
| Soft Stone | 200g | Petrify cure, rare in shops |
| Remedy | 800g | Early access |

### 4.5 Caldera (Compact Industrial City)

All prices x1.50. Employee Card reduces to x1.125.

**Company Store (General):**

| Item | Standard | Caldera | With Card |
|------|----------|---------|-----------|
| Hi-Potion | 300g | 450g | 338g |
| Hi-Ether | 800g | 1,200g | 900g |
| Phoenix Feather | 500g | 750g | 563g |
| Remedy | 800g | 1,200g | 900g |
| Tent | 500g | 750g | 563g |
| Pavilion | 1,200g | 1,800g | 1,350g |

**Company Armorer:**

| Item | Standard | Caldera | With Card |
|------|----------|---------|-----------|
| Compact Saber | 2,000g | 3,000g | 2,250g |
| Ironbound Greatsword | 1,500g | 2,250g | 1,688g |
| Forge Hammer | 2,200g | 3,300g | 2,475g |
| Forgewright Visor | 1,000g | 1,500g | 1,125g |
| Compact Plate | 2,000g | 3,000g | 2,250g |

**Tash's Black Market (Undercity — Sable access, standard prices):**

| Item | Price | Notes |
|------|-------|-------|
| Berserk Collar | 2,000g | Standard — underground ignores inflation |
| Counter Ring | 3,000g | Standard |
| Stone Guard | 1,500g | Standard |

### 4.6 Ashmark (Compact Harbor)

**General Store:**

| Item | Price |
|------|-------|
| Hi-Potion | 300g |
| Ether | 200g |
| Antidote | 50g |
| Echo Drop | 75g |
| Phoenix Feather | 500g |
| Sleeping Bag | 250g |
| Tent | 500g |

**Armorer:**

| Item | Price |
|------|-------|
| Compact Saber | 2,000g |
| Twilight Edge | 2,500g |
| Runic Focus | 1,800g |
| Compact Officer's Helm | 1,200g |
| Compact Uniform | 1,800g |

*Restocked after Ashmark liberation:* Adds Thornwood Pike (1,800g),
Whisper Edge (4,500g — early Tier 3), Preemptive Charm (2,000g).

### 4.7 Bellhaven (Coastal Trade City)

**General Store:**

| Item | Price | Notes |
|------|-------|-------|
| Full consumable line through Hi-tier | various | |
| Pallor Salve | 2,500g | **First availability**, limited 3 per visit |
| Tent | 500g | |
| Pavilion | 1,200g | |

**Armorer:**

| Item | Price |
|------|-------|
| Trick Blade | 1,500g |
| Thornwood Pike | 1,800g |
| Runic Focus | 1,800g |
| Forge Hammer | 2,200g |
| Compact Plate | 2,000g |
| Compact Uniform | 1,800g |

**Specialty (Harbor Traders):**

| Accessory | Price | Notes |
|-----------|-------|-------|
| Flame Ring | 3,000g | Trade hub has imports |
| Frost Amulet | 3,000g | |
| Storm Pendant | 3,000g | |
| Haste Bangle | 2,500g | |
| Life Pendant | 800g | |

**Bellhaven's identity:** Best accessory selection in Act II. The trade
hub has goods from everywhere. Players who save gold for Bellhaven are
rewarded.

### 4.8 Thornmere (Isolated Town)

**Provisioner:**

| Item | Price |
|------|-------|
| Potion | 50g |
| Hi-Potion | 300g |
| Ether | 200g |
| Full basic status cure line | various |
| Tent | 500g |

**Local Craftsman:**

| Item | Price | Notes |
|------|-------|-------|
| Wyrmbone Lance | 4,500g | Unique to Thornmere, local materials |
| Warding Crown | 2,800g | Thornmere specialty |
| Despair Ward | 5,000g | **Only shop selling this** |

**Thornmere's identity:** Limited general stock but carries
Pallor-specific items no one else has. Players who visit learn about
the Pallor threat early.

### 4.9 Ironmark (Interlude Refuge)

**Refugee Quartermaster:**

| Item | Price | Notes |
|------|-------|-------|
| Hi-Potion | 300g | |
| Hi-Ether | 800g | |
| Phoenix Feather | 500g | Limited 5 per visit |
| Pallor Salve | 2,500g | Limited 2 per visit |
| Sleeping Bag | 250g | |
| Tent | 500g | No Pavilions — luxury is gone |
| Remedy | 800g | |

**Scavenger Armorer:**

| Item | Price | Notes |
|------|-------|-------|
| Crystal Sword | 4,000g | Tier 3, scrounged from ruins |
| Dusk Reaver | 5,000g | |
| Arcane Conduit | 3,500g | |
| Arcanite Maul | 5,000g | |
| Crystal Helm | 2,500g | |
| Pallor Veil | 3,000g | |
| Crystal Vest | 3,500g | |
| Arcanite Plate | 4,500g | |

**Ironmark's identity:** Stripped-down survival shopping. No
accessories, no specialty items, no luxuries. Limited stock quantities
reflect scarcity. The world is broken and this is what's left.

### 4.10 Act III Oases (Pallor Wastes)

3 micro-settlements in the Pallor Wastes. No single Oasis has
everything — players must visit multiple. Each Oasis has refugees from
a specific fallen region, which determines their stock specialty.

**Oasis A — Valdris Refugees (nearest to Ironmark)**

| Item | Price | Notes |
|------|-------|-------|
| X-Potion | 1,500g | |
| Pavilion | 1,200g | |
| Phoenix Pinion | 3,000g | |
| Pallor Salve | 2,500g | Limited 3 |
| Ley-Forged Longsword | 8,000g | Tier 4 sword |
| Ley Lance | 7,500g | Tier 4 spear |
| Genji Helm | 5,500g | |
| Genji Armor | 7,000g | |

**Oasis B — Compact Refugees (central Wastes)**

| Item | Price | Notes |
|------|-------|-------|
| X-Ether | 2,000g | |
| Pavilion | 1,200g | |
| Pallor Salve | 2,500g | Limited 2 |
| Pallor Bane Charm | 3,500g | |
| Piston Driver | 8,500g | Tier 4 hammer |
| Ley Conduit | 7,000g | Tier 4 staff |
| Spiritguard Helm | 5,000g | |
| Forgeheart Plate | 8,000g | |

**Oasis C — Thornmere Refugees (deep Wastes, near Convergence)**

| Item | Price | Notes |
|------|-------|-------|
| X-Potion | 1,500g | |
| X-Ether | 2,000g | |
| Pallor Salve | 2,500g | Limited 2 |
| Despair Ward | 5,000g | |
| Twilight Fang | 8,000g | Tier 4 dagger |
| Pallor Pike | 9,500g | Tier 4 spear |
| Ley Crown | 6,500g | |
| Ley-Thread Mail | 8,000g | |

*Restocked Post-Convergence:* All surviving Oases expand stock. Adds
full consumable line, remaining Tier 4 accessories, and Elixirs (first
time purchasable, 5,000g).

---

## 5. Event-Triggered Restocking

Shops update in response to story events (tied to dynamic-world.md).

| Event | Shops Affected | Change |
|-------|---------------|--------|
| Complete Ember Vein | Aelhart general store | +Hi-Potion, +Phoenix Feather, +Sleeping Bag, +Tent |
| Arrive in Valdris | Valdris all shops | Full Tier 1 stock |
| Diplomatic mission begins | All visited Act I towns | +Select Tier 2 consumables and weapons |
| Ashmark liberation | Ashmark black market | +Tier 2–3 weapons, +Preemptive Charm |
| Interlude (world breaks) | All pre-Interlude shops | Most shops **close or reduce stock** |
| Ironmark established | Ironmark refugee shops | Limited Tier 3 stock, quantity caps |
| Act III Oases discovered | Each Oasis individually | Unique limited stock per Oasis |
| Post-Convergence | Surviving towns + Oases | Premium stock returns, Tier 4 gear, Elixirs |

**Interlude scarcity rule:** When the world breaks, most Act I–II town
shops either close entirely or reduce to basic consumables only. The
scarcity is felt by the player — reinforces the narrative. Ironmark
is the only reliable shopping destination during the Interlude.

---

## 6. Treasure Chest Gold Formula

### Base Formula

Chest gold = percentage of the average equipment cost at the current
act tier.

**Act tier average equipment costs:**
- Act I (Tier 1): ~400g average
- Act II (Tier 2): ~1,500g average
- Interlude (Tier 3): ~4,000g average
- Act III (Tier 4): ~8,000g average

### Placement Multipliers

| Chest Placement | % of Tier Avg | Act I | Act II | Interlude | Act III |
|----------------|--------------|-------|--------|-----------|---------|
| Main path (easy to find) | 15% | 60g | 225g | 600g | 1,200g |
| Side room (minor detour) | 25% | 100g | 375g | 1,000g | 2,000g |
| Hidden/puzzle (exploration) | 40% | 160g | 600g | 1,600g | 3,200g |
| Boss lair chest | 50–75% | 200–300g | 750–1,125g | 2,000–3,000g | 4,000–6,000g |

### Per-Dungeon Budget

Each dungeon gets 2–4 gold chests (alongside equipment/item chests).
Total gold-from-chests per dungeon = ~30–40% of one full equipment
piece at that tier.

### Design Rules

- Gold chests never appear in the first room — player must commit to
  exploration
- Boss lair chests are the narrative justification for beast/spirit boss
  gold (see Section 7)
- Hidden chests should be discoverable without a guide — visual clue,
  suspicious wall, NPC hint
- Dungeon docs (dungeons-world.md, dungeons-city.md) already list chest
  locations. Economy.md provides the gold amounts.

---

## 7. Boss Gold Drop Table

### Formula

```
total_payday   = act_tier_base x boss_rank_multiplier
direct_gold    = floor(total_payday x narrative_split)
lair_chest_gold = total_payday - direct_gold
```

The **boss rank** determines the total gold reward. The **narrative
split** determines how much the boss drops directly vs. how much is
found in lair chests. Every boss delivers roughly the same value for
its rank — the delivery mechanism shifts to match the narrative.

### Act Tier Base

| Act | Tier Base | Notes |
|-----|-----------|-------|
| Act I | 500g | Starting bosses |
| Act II | 1,500g | Scales with Tier 2 gear costs |
| Interlude | 2,500g | Mid-game |
| Act III | 4,000g | Endgame |
| Optional/Post-game | 6,000g | Premium |

### Boss Rank Multiplier

Not all bosses in the same act are equal. A tutorial mini-boss isn't
worth as much as the act's climactic encounter.

| Rank | Multiplier | Examples |
|------|-----------|---------|
| Minor | 1.0x | First boss of an act, tutorial encounters |
| Standard | 2.0x | Most dungeon-end bosses |
| Climactic | 3.0x | Act-ending bosses, narrative-critical encounters |

### Narrative Split (Direct Gold vs. Lair Chests)

Determines what fraction of the total payday the boss drops directly.
The remainder goes into lair chests. The gold source must be
**narratively justified:**

| Boss Type | Narrative Split | Justification |
|-----------|----------------|---------------|
| Humanoid/Military | 1.0 (all direct) | Carries gold — war chest, payment, plunder |
| Construct/Machine | 0.5 | Salvage value, workshop stash |
| Beast/Creature | 0.1 | Beasts don't carry money — lair hoard from past victims |
| Spirit/Magical | 0.1 | Guards a treasury or offering pile |
| Pallor/Corrupted | 0.05 (+ 0.7x total) | Corruption consumed the wealth — lower net payday |

**Pallor exception:** Pallor bosses reduce the **total payday** to 0.7x
the normal rank amount, because the corruption has consumed surrounding
wealth. Then the 0.05 split applies to that reduced total.

### Worked Examples

| Boss | Act | Rank | Type | Total Payday | Direct Gold | Lair Chest |
|------|-----|------|------|-------------|------------|------------|
| Vein Guardian | I | Minor (1.0x) | Beast | **500g** | 50g | 450g |
| Corrupted Fenmother | I | Climactic (3.0x) | Beast | **1,500g** | 150g | 1,350g |
| Ashen Ram | II | Climactic (3.0x) | Construct | **4,500g** | 2,250g | 2,250g |
| Forge Warden | II | Standard (2.0x) | Construct | **3,000g** | 1,500g | 1,500g |
| Kole | Int | Climactic (3.0x) | Humanoid | **7,500g** | 7,500g | — |
| Ley Titan | III | Standard (2.0x) | Spirit | **8,000g** | 800g | 7,200g |
| Crystal Queen | Post | Standard (2.0x) | Pallor | **8,400g** | 420g | 7,980g |
| Vaelith | III | Climactic (3.0x) | Spirit | **12,000g** | 1,200g | 10,800g |

---

## 8. Sable's Steal Economy

### Steal Value Principle

Stolen items should be worth ~2–3 battles of gold income at the current
act. Enough to feel rewarding, not enough to replace normal income.

### Steal Tiers by Enemy Type

| Enemy Type | Common Steal (75%) | Rare Steal (25%) | Value Range |
|------------|-------------------|------------------|-------------|
| Beast | Tier 1 material (25–40g) | Tier 2 material (50–100g) | Low |
| Construct | Scrap Metal (35g) | Elemental Core (100g) | Moderate |
| Humanoid | Consumable (Potion, Antidote) | Gold Pouch (150–500g) | High |
| Spirit | Ether Wisp (40g) | Ley Crystal Fragment (200g) | Moderate |
| Pallor | Grey Residue (100g) | Pallor Shard (175g) | Moderate |
| Undead | Bone Fragment (30g) | Ancient Glyph (300g) | Low common, high rare |

### Gold Pouch Mechanic

Humanoid enemies (soldiers, smugglers, bandits) can have "Gold Pouch"
as a rare steal. Amount scales with act:

| Act | Gold Pouch Value |
|-----|-----------------|
| Act I | 150g |
| Act II | 350g |
| Interlude | 500g |
| Act III | 800g |

Sable is especially valuable in military dungeons (Valdris Siege,
Compact encounters) where humanoid enemies are common.

### Boss Steals

Every boss has a unique steal documented in bestiary/bosses.md. These
are exclusive items — accessories, rare materials, or consumables not
yet available in shops. Economic value is secondary to exclusivity.

### Gold-Boosting Accessories

**Fenn's Seal** (sidequest reward):
- **+25% gold from all battle sources** (enemy drops, gold pouches,
  boss direct gold)
- Does NOT affect shop prices, chest gold, or quest rewards
- Pays for itself over time — long-term investment

**Sea Prince's Signet** (sidequest reward):
- **+15% sell price on all items** (base 50% becomes 57.5%)
- Subtle but meaningful for players selling crafting materials
- Stacks with Fenn's Seal for a "merchant build"

---

## 9. Crafting Economy & Arcanite Forging Costs

### Forgewright Battle Devices

Already priced in items.md (100–800g per device). No changes needed.

### Arcanite Equipment Forging

Equipment.md lists 8 forgeable items marked "— (Forged)". These need
a forging fee.

**Forging fee principle:** Low gold cost (400–500g) but significant
material investment. The real cost is the materials — Arcanite Ingots
sell for 1,000g each, so forging a weapon that requires one is a
1,000g opportunity cost on top of the 500g fee. Total investment
(gold + material sell value) roughly equals buying the shop equivalent
— but the forged item is better. You pay in flexibility (materials
you could have sold) rather than pure gold.

> **Note:** No forged greatsword exists for Cael. This is intentional —
> Cael departs during the Interlude and returns briefly. His weapon
> progression relies on shop/chest gear, not Lira's crafting.

Per equipment.md (canonical source for recipes and costs):

| Forged Item | Slot | Stats | Materials | Gold | Unlock |
|-------------|------|-------|-----------|------|--------|
| Arcanite Blade | Weapon (Edren) | ATK 35, +5 MAG | 1 Arcanite Ingot + 3 Crystal Shard | 500 | Interlude |
| Forgewright Maul | Weapon (Lira) | ATK 40 | 1 Arcanite Ingot + 2 Scrap Metal + 1 Drill Fragment | 500 | Interlude |
| Thornspear | Weapon (Torren) | ATK 30, +3 SPD | 3 Spirit Essence + 2 Petrified Bark | 400 | Act III |
| Shadowsteel Knife | Weapon (Sable) | ATK 28, +4 SPD, +3 LCK | 2 Pallor Sample + 1 Arcanite Shard | 400 | Act III |
| Resonance Rod | Weapon (Maren) | ATK 15, +15 MAG | 2 Elemental Core + 2 Ley Crystal Fragment | 500 | Act III |
| Arcanite Helm | Head | DEF 30, MDEF 22 | 1 Arcanite Ingot + 2 Drill Fragment | 400 | Interlude |
| Pallor Ward Vest | Body (Light) | DEF 38, MDEF 25, Despair resist 50% | 3 Pallor Sample + 2 Grey Residue + 1 Spirit Essence | 500 | Act III |
| Ley-Woven Cloak | Body (Robe) | DEF 20, MDEF 40, MP Regen 3%/turn | 2 Ether Wisp + 2 Elemental Core + 1 Ley Crystal Fragment | 500 | Act III |

### Elemental Infusion Costs

Applying an element to a weapon via Arcanite Forging. Permanent but
replaceable — applying a new infusion overwrites the previous one.
Infusions can be removed for free at save points.

Per equipment.md (canonical source):

| Infusion | Element | Materials | Gold |
|----------|---------|-----------|------|
| Flame Infusion | Flame | 2 Element Shard + 1 Molten Gear | 300 |
| Frost Infusion | Frost | 2 Element Shard + 1 Crystal Shard | 300 |
| Storm Infusion | Storm | 2 Element Shard + 1 Scrap Metal | 300 |
| Earth Infusion | Earth | 2 Element Shard + 1 Stone Fragment | 300 |
| Ley Infusion | Ley | 2 Elemental Core + 1 Ley Crystal Fragment | 500 |
| Spirit Infusion | Spirit | 2 Spirit Essence + 1 Ether Wisp | 500 |
| Void Infusion | Void | 2 Pallor Sample + 1 Grey Residue | 500 |

Basic infusions (Flame/Frost/Storm/Earth) are cheap at 300g. Advanced
infusions (Ley/Spirit/Void) cost 500g and use rarer materials.

### Secret Synergy Combos

The 7 hidden weapon+element combinations (documented in equipment.md)
don't cost extra — the bonus is the reward for discovering the right
pairing. The player still pays the standard infusion fee, creating
risk in experimentation.

### Economic Impact

Forging fees are low (400–500g) but the materials carry significant
opportunity cost. An Arcanite Ingot sells for 1,000g; using it to
forge a weapon means 1,000g of lost sell income plus the 500g fee.
A forged weapon's total cost (gold + material sell value) is roughly
1,500–2,500g — comparable to Tier 3 shop prices (3,500–5,000g) when
you factor in that forged weapons have superior stats (+5–10 ATK above
tier or special bonuses). Players who sell materials have more gold for
shop purchases; players who hoard materials get better gear through
forging. Both paths work.

---

## 10. Quest Reward Gold & Material Rewards

### Quest Reward Principle

Quest gold is a bonus, not a salary. Main income comes from dungeons.
Quests help close the 70% -> 85–90% affordability gap for engaged
players.

### Reward Tiers

| Quest Tier | Gold Reward | Example |
|-----------|-------------|---------|
| Minor (fetch/delivery) | 200–500g | Deliver a message, find a lost item |
| Standard (combat/explore) | 500–1,500g | Clear a monster den, escort an NPC |
| Major (multi-step chain) | 2,000–5,000g | Ashmark liberation, Bellhaven smuggler ring |
| Epic (sidequest dungeon) | 5,000–10,000g | Dreamer's Fault floors, Grey Cleaver purification |

### Reward Composition

Not all quests pay pure gold.

| Quest Tier | Gold | Equipment | Materials | Consumables |
|-----------|------|-----------|-----------|-------------|
| Minor | 80% gold | — | — | 1–2 Potions/status cures |
| Standard | 50% gold | 30% chance of act-tier gear | 2–4 Tier 2 materials | — |
| Major | 40% gold | Unique accessory or weapon | 4–6 mixed materials | Elixir or rare consumable |
| Epic | 30% gold | Guaranteed unique equipment | Tier 3–4 materials | — |

### Design Rule

The best quest rewards are items you **can't buy**: unique accessories
(Fenn's Seal, Sea Prince's Signet), early-access equipment, rare
consumables (Megalixir, Sable's Coin).

### NPC Tip Rewards

Small gold tips (50–100g) from NPCs for information or returning lost
items. Flavor rewards — no economic impact, but the world feels
responsive.

---

## 11. Gold Pacing Targets Per Act

### Act I (Levels 1–12, 2 dungeons + overworld)

| Source | Estimate | Notes |
|--------|----------|-------|
| Enemy drops | ~1,500–2,000g | ~80 encounters x 15–25g avg |
| Treasure chests | ~800–1,200g | 4–6 gold chests, 200–300g each |
| Boss gold (Vein Guardian + Fenmother) | ~2,000g | 500g + 1,500g total paydays |
| **Total income** | **~4,300–5,200g** | |

| Sink | Cost | Notes |
|------|------|-------|
| Full Tier 1 equipment (4 characters) | ~6,000–7,000g | Weapon + head + body + accessory x 4 |
| Consumables | ~500–800g | Potions, status cures, Sleeping Bags |
| Inns | ~100–200g | 2–3 rests |
| **Total needed** | **~6,600–8,000g** | |

**Affordability: ~65–70%.** Player equips most of the party but skips
1–2 pieces. Selling a few crafting materials closes the gap.

### Act II (Levels 12–25, 4 dungeons + diplomatic travel)

| Source | Estimate | Notes |
|--------|----------|-------|
| Enemy drops | ~9,000g | ~150 encounters x 60g avg |
| Treasure chests | ~3,500g | 8–10 gold chests, 350–500g each |
| Boss gold (4 bosses: 2 standard + 1 minor + 1 climactic) | ~10,500g | Mix of ranks per formula |
| Quest rewards | ~1,500g | Minor + standard quests |
| **Total income** | **~24,500g** | |

| Sink | Cost | Notes |
|------|------|-------|
| Full Tier 2 equipment (5 characters) | ~27,000g | 5 party members by end of Act II |
| Consumables | ~2,500g | Hi-Potions, Ethers, Tents |
| Inns + travel | ~600g | Multiple cities visited |
| **Total needed** | **~30,100g** | |

**Affordability: ~81% of equipment budget.** But consumable and inn
costs bring effective affordability to ~70% of total needs. Caldera's
150% markup creates a pinch point mid-act.

### Interlude (Levels 25–32, scarcity arc)

| Source | Estimate | Notes |
|--------|----------|-------|
| Enemy drops | ~6,000g | ~100 encounters x 60g avg |
| Treasure chests | ~4,000g | 6–8 chests, higher-value Tier 3 range |
| Boss gold (3 bosses: 1 minor + 1 standard + 1 climactic) | ~15,000g | Kole (climactic) is a big payday |
| Salvage/scrounging | ~2,500g | Selling Pallor-enemy materials |
| **Total income** | **~27,500g** | |

| Sink | Cost | Notes |
|------|------|-------|
| Tier 3 equipment (selective) | ~18,000g | Limited shops — can't buy everything |
| Consumables (Pallor Salve!) | ~4,000g | Pallor Salve at 2,500g each is expensive |
| Forgewright crafting | ~1,500g | Material + gold for devices + forged gear |
| **Total needed** | **~23,500g** | |

**Affordability: ~80% of what's available.** Paradoxically higher
because shops are limited — there's less to buy. Scarcity is in
*availability*, not gold. Pallor Salve at 2,500g each creates a new
drain. Players feel desperate because shelves are empty, not because
they're broke.

### Act III (Levels 32–45, Pallor Wastes + endgame)

| Source | Estimate | Notes |
|--------|----------|-------|
| Enemy drops | ~18,000g | ~120 encounters x 150g avg |
| Treasure chests | ~10,000g | 12–15 chests, 800–1,200g each |
| Boss gold (5 bosses: 1 minor + 3 standard + 1 climactic) | ~40,000g | Climactic boss is a major payday |
| Material sales (if chosen) | ~7,000g | Tier 3–4 materials sell well |
| **Total income** | **~75,000g** | (without material sales: ~68,000g) |

| Sink | Cost | Notes |
|------|------|-------|
| Tier 4 equipment (6 characters) | ~70,000g | Full party, expensive gear |
| Consumables (X-Potions, Pavilions) | ~6,000g | Premium consumables |
| Forgewright advanced devices | ~3,000g | Arcanite Lance, Emergency Beacon |
| **Total needed** | **~79,000g** | |

**Affordability: ~86% with material sales, ~76% without.** Slightly
above the 70% target because Act III has 6 characters — players need
the extra breathing room. But they still can't buy *everything*. The
sell-or-save decision peaks here: selling materials funds the last few
equipment pieces, but forfeits Forgewright options.

### Post-Game (Dreamer's Fault, Level 45+)

Gold becomes abundant. Tier 5 gear is non-purchasable. The economy
shifts from "can I afford this?" to "should I sell rare materials or
save them for ultimate Forgewright recipes?" Gold surplus is intentional.

---

## 12. Wealth Curve & Verification Targets

### Expected Wealth at Key Milestones

| Milestone | Cumulative Earned | In Wallet | Notes |
|-----------|------------------|-----------|-------|
| After Ember Vein | ~1,500g | ~800g | Bought basic gear in Aelhart |
| Arrive Valdris | ~3,000g | ~500g | Equipped at Valdris shops |
| End of Act I | ~5,000g | ~1,000g | Some Tier 1 gaps remain |
| Mid Act II (Corrund) | ~14,000g | ~2,500g | Tier 2 partially equipped |
| End of Act II | ~30,000g | ~4,000g | Most Tier 2 equipped |
| Mid Interlude | ~42,000g | ~8,000g | Limited shops, gold accumulates |
| End of Interlude | ~57,000g | ~12,000g | Tier 3 equipped, surplus building |
| Mid Act III | ~80,000g | ~8,000g | Tier 4 purchases draining wallet |
| Final dungeon | ~110,000g | ~5,000–10,000g | Fully equipped or close |
| Post-game | ~140,000g+ | ~20,000g+ | Gold surplus |

### Verification Checks

1. **70% test:** At each town, sum the cost of equipping 4 active
   members. Multiply by 0.70. Does the player's expected wallet cover
   it?

2. **Consumable drain:** Can the player afford 10 Hi-Potions + 5 Ethers
   + 2 Phoenix Feathers per dungeon without dipping below equipment
   budget? (~3,000g per dungeon run in Act II)

3. **Caldera pinch:** At 150% markup, Tier 2 gear costs ~2,250–3,300g
   per piece. Player should feel the squeeze but not be locked out.

4. **Material sell-or-save:** Selling ALL materials through Act II gains
   ~3,000–5,000g extra. Closes the 70% gap to ~85%. Meaningful but
   not game-breaking.

5. **Sable value:** A player who steals from every humanoid encounter
   gains ~2,000–4,000g extra per act. Meaningful but not dominant.

6. **Forging parity:** Forged Tier 3 equipment (400–500g fee + material
   sell value) should total roughly 1,500–2,500g effective cost vs
   Tier 3 shop prices (3,500–5,000g). Forging is cheaper but the
   forged item is better — neither path is strictly dominant.

7. **Inn vs rest items:** A full dungeon run using 2 Tents (1,000g) is
   more expensive than 2 inn stays (~200–300g). Field resting is a
   convenience premium.

---

## 13. Cross-References

| Document | Relationship |
|----------|-------------|
| `docs/story/items.md` | Consumable prices, crafting material sell prices, Forgewright device costs. **Update needed:** Rename Cottage -> Pavilion, add Sleeping Bag, update prices. |
| `docs/story/equipment.md` | All weapon, armor, accessory prices. Add Forging Fee column to Arcanite Forging table. |
| `docs/story/bestiary/README.md` | Enemy gold drop formula (logistic curve, threat multipliers). No changes needed. |
| `docs/story/bestiary/bosses.md` | Boss gold drops to be assigned per Section 7 formula. |
| `docs/story/locations.md` | Shop locations per town. Reference economy.md for stock lists. |
| `docs/story/dungeons-world.md` | Chest locations. Reference economy.md for gold amounts. Scrip -> Gold rename. |
| `docs/story/dungeons-city.md` | Chest locations and Scrip references. Scrip -> Gold rename. |
| `docs/story/sidequests.md` | Quest rewards. Add gold amounts per Section 10 tiers. |
| `docs/story/dynamic-world.md` | Event triggers for shop restocking (Section 5). |
| `docs/story/progression.md` | Level milestones to verify wealth curve alignment. |
| `docs/story/magic.md` | No changes needed. |

---

## 14. Files Created/Modified

| Action | File | Changes |
|--------|------|---------|
| Create | `docs/story/economy.md` | New file — complete economy system |
| Modify | `docs/story/items.md` | Rename Cottage -> Pavilion, add Sleeping Bag (250g), update rest item table |
| Modify | `docs/story/bestiary/bosses.md` | Add direct gold drop to each boss stat block |
| Modify | `docs/story/dungeons-world.md` | Add gold amounts to treasure chests, Scrip -> Gold |
| Modify | `docs/story/dungeons-city.md` | Add gold amounts to treasure chests, Scrip -> Gold |
| Modify | `docs/story/sidequests.md` | Add gold reward amounts to quest entries |
| Modify | `docs/story/locations.md` | Reference economy.md for shop stock lists |
| Modify | `docs/analysis/game-design-gaps.md` | Gap 1.6 status -> COMPLETE, affordability target 70% |

> **Note on equipment.md:** Forging fees and material recipes are
> already correct in equipment.md (400–500g, canonical recipes). No
> equipment.md changes needed — this spec defers to equipment.md as the
> canonical source for forging data. Elemental infusion costs are also
> already documented there (300–500g).
