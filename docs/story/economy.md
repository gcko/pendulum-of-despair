# Economy & Pricing — Pendulum of Despair

> Canonical reference for all economic data in Pendulum of Despair.
> Cross-references: [items.md](items.md) (consumable prices),
> [equipment.md](equipment.md) (weapon/armor/accessory prices, forging costs),
> [bestiary/](bestiary/) (enemy gold drops),
> [sidequests.md](sidequests.md) (quest rewards).

---

## Table of Contents

- [Economic Philosophy](#economic-philosophy)
- [Currency & Pricing Rules](#currency--pricing-rules)
- [Inn Costs](#inn-costs)
- [Rest Item Progression](#rest-item-progression)
- [Caldera Inflation](#caldera-inflation)
- [Shop Inventories](#shop-inventories)
  - [Aelhart](#aelhart)
  - [Highcairn](#highcairn)
  - [Valdris Crown](#valdris-crown)
  - [Corrund](#corrund)
  - [Caldera](#caldera)
  - [Ashmark](#ashmark)
  - [Bellhaven](#bellhaven)
  - [Thornmere](#thornmere)
  - [Ironmark](#ironmark)
  - [Act III Oases](#act-iii-oases)
- [Event-Triggered Restocking](#event-triggered-restocking)
- [Treasure Chest Gold Formula](#treasure-chest-gold-formula)
- [Boss Gold Drop System](#boss-gold-drop-system)
- [Sable's Steal Economy](#sables-steal-economy)
- [Crafting Economy](#crafting-economy)
- [Quest Reward Guidelines](#quest-reward-guidelines)
- [Gold Pacing Targets](#gold-pacing-targets)
- [Wealth Curve & Verification](#wealth-curve--verification)
- [Cross-References](#cross-references)

---

## Economic Philosophy

The economy targets a **70% affordability rate** — a player following the
critical path should be able to purchase roughly 70% of available gear at each
town through normal play. This splits the difference between FF4's tight economy
(~60% affordability, requiring grinding) and FF6's comfortable one (~80%,
rarely forcing hard choices).

The remaining 30% requires deliberate effort: additional battles, selling
crafting materials, leveraging Sable's steals, or backtracking for missed
treasure chests. This is the "means" economy — players have the means to get
what they want, but not everything at once.

**Three gold sinks:**

1. **Equipment** (primary) — weapons, armor, and accessories are the largest
   expenses at each town. New towns introduce gear 1–2 tiers above the
   party's current level.
2. **Consumables** (ongoing) — healing items, antidotes, and revives drain
   gold steadily across the mid-game.
3. **Inns** (flavor) — cheap relative to equipment but reinforce the sense of
   traveling through a living world.

**Three gold sources:**

1. **Enemy drops** (primary) — scales via a logistic curve defined in
   [bestiary/README.md](bestiary/README.md). Most gold enters the economy here.
2. **Treasure chests** (exploration reward) — fixed windfalls that reward
   thorough dungeon exploration.
3. **Boss encounters** (paydays) — each boss drops a meaningful gold bonus,
   functioning as a checkpoint reward before the next town's shop opens.

**Crafting material tension:** most crafting materials can be sold for gold
immediately or saved for Forgewright/Arcanite Forging later. This is a
deliberate and recurring player decision throughout Acts I–II. Selling all
materials through Act II yields roughly 3,000–5,000g extra but leaves late-game
crafting under-resourced.

---

## Currency & Pricing Rules

**Gold** is the universal currency used throughout Pendulum of Despair.

**Scrip** is the regional name for Gold within Carradan Compact territory
(Caldera, Corrund, and affiliated ports). **Gil** is the Valdris name for
Gold, often styled as "gil" in dialogue and regional notes. Both are
mechanically identical to Gold — no conversion rate, no separate wallet.
Functions identically to how "Gil" works in Final Fantasy VI: same item,
different label on the coin.

**Spirit Tokens (Thornmere only)** are a localized ritual resource referenced
in [city-thornmere.md](city-thornmere.md). They are **not** a second global
currency and have no fixed conversion rate to Gold. Spirit tokens are earned
and spent within Thornmere's spirit shrines and ritual vendors only — they
cannot be used at standard shops. This is the one sanctioned exception to the
Gold-only rule. Regular shop inventories in Thornmere (as listed in this file)
still price items in Gold.

**Sell price rule:**
- **Buyable items & equipment:** sell to vendors at **50% of their listed buy
  price** by default.
- **Materials:** sell to vendors at their **explicit sell values as listed in
  [items.md](items.md)** (many materials have no buy price and are not directly
  purchasable — their sell values are set by tier formula).
- **Exception — Sea Prince's Signet (accessory):** raises sell rate to 57.5%
  of buy price for all items whose sell value is derived as a percentage of buy
  price (standard buyable items & equipment). It does not modify items that use
  explicit sell values (materials, sell-only curios). Marginal but meaningful
  for players liquidating large stockpiles of buyable goods.

**Minimal vendor trash:** crafting materials serve dual purpose — sell them now
for gold, or save them for recipes. Most items are not "gold bags," so sell
decisions usually carry an opportunity cost. A small number of curios and junk
items flagged as sell-only in [items.md](items.md) exist for flavor and gold
pacing; they are never required for crafting and simply sell for their listed
values.

**No special financial services:** there are no loan systems, interest-bearing
accounts, or time-based debt mechanics. Locations like Exchange Houses or
Moneylenders that appear in town descriptions (city-carradan.md) are
**flavor-only**: the Exchange House re-mints foreign coins into local
Compact coinage at 1:1 (no value change), and the Moneylender exists as a
narrative element and emergency gold source with a steep penalty — not a core
economic system. Economic complexity comes from the sell-or-save decision on
crafting materials and from the Caldera inflation system.

---

## Inn Costs

Inns restore all party members to full HP and MP and advance the in-game clock.
They are always available when the party is in town, regardless of story
progress.

| Town | Act | Inn Cost | Notes |
|------|-----|----------|-------|
| Aelhart | I | Free | Home village; Edren's mother runs the inn |
| Highcairn | I | 50g | Monastery hospitality — minimal charge |
| Valdris Crown | I–II | 150g | Capital city, mid-range inn |
| Corrund | II | 100g | Canal district, modest lodging |
| Caldera | II | 300g (450g without Employee Card) | Inflated by Compact exploitation; see [Caldera Inflation](#caldera-inflation) |
| Ashmark | II | 100g | Harbor district, basic |
| Bellhaven | II | 150g | Coastal trade city, tourist markup |
| Thornmere | II | 100g | Isolated but welcoming |
| Ironmark | Interlude | 75g | War-torn; discounted from desperation |
| Act III Oases | III | 50–100g | Refugee camps, scraping by |

> **Caldera note:** Caldera's standard inn rate would be ~200g (comparable to
> Valdris/Bellhaven). At 150% markup, the inflated price is **300g**. With the
> Caldera Employee Card (25% off 300g), the party pays **225g** — still above
> the ~200g standard rate, consistent with the 112.5% net rule.

---

## Rest Item Progression

Rest items restore HP and MP at save points, functioning as the dungeon
alternative to inns. They are single-use and consumed on activation.

| Item | Buy | Sell | Effect | First Available |
|------|-----|------|--------|-----------------|
| Sleeping Bag | 250g | 125g | Restore 25% HP/MP to all party (save point only) | Act I |
| Tent | 500g | 250g | Restore 50% HP/MP to all party (save point only) | Act I |
| Pavilion | 1,200g | 600g | Restore 100% HP/MP to all party (save point only) | Act II |

**Stack limit:** 99 for all rest items. Unlike standard HP/MP recovery items
(which stack to 199 per [items.md](items.md)), rest items are capped lower due
to their powerful out-of-town full-party utility.

**Design note:** inns are cheaper per-rest but require being in town. Rest items
trade gold efficiency for flexibility — essential in long dungeons. The
Pavilion's high price reflects its power as a full heal outside of town.

---

## Caldera Inflation

The Carradan Compact's economic exploitation of Caldera manifests as inflated
shop prices across the entire city.

**Markup: 150%** — all Caldera vendors (items, equipment, inn) charge 1.5×
standard price. A Potion that costs 50g elsewhere costs 75g in Caldera.

**Caldera Employee Card**

- Key item that grants a **25% discount** on all Caldera purchases.
- Net effective price with card: **112.5% of standard** — still above market
  rate, but meaningfully better than 150%.
- **Acquisition:** Sable pickpockets the card from a Compact officer during
  a story scene in Caldera.
- Applies to all Caldera vendors including the inn.

**Tash's Black Market (Caldera Undercity)**

- Uses **standard prices** — the underground economy does not participate in
  Compact pricing.
- Accessible only via Sable (party member gating).
- Carries select items not available at surface shops; see
  [Shop Inventories — Caldera](#caldera).

**All other towns:** standard pricing. No other faction modifiers exist.

---

## Shop Inventories

### Aelhart

**General Store**

| Item | Price |
|------|-------|
| Potion | 50g |
| Antidote | 50g |
| Eye Drops | 50g |
| Smoke Bomb | 100g |

> **Restock — after Ember Vein completion:** +Hi-Potion (300g), +Phoenix Feather
> (500g), +Sleeping Bag (250g), +Tent (500g).

No armorer in Aelhart. Edren starts with basic gear. Carradan trader sells
Lira's starting Forgewright tools.

---

### Highcairn

**Provisioner**

| Item | Price |
|------|-------|
| Potion | 50g |
| Antidote | 50g |
| Sleeping Bag | 250g |
| Echo Drop | 75g |

No armorer, no specialty shop. Monastery town — austere.

---

### Valdris Crown

**General Store (Lower Ward)**

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

**Armorer (Lower Ward)**

| Weapons | Price | Head Armor | Price | Body Armor | Price |
|---------|-------|------------|-------|------------|-------|
| Valdris Blade | 300g | Iron Helm | 200g | Chain Mail | 300g |
| Knight's Edge | 500g | Traveler's Hood | 250g | Iron Plate | 400g |
| Ley Wand | 250g | Ember Circlet | 350g | Silk Robe | 300g |
| Stiletto | 250g | | | Reinforced Vest | 500g |
| Iron Mallet | 300g | | | | |
| Iron Lance | 250g | | | | |

**Specialty Shop (Citizen's Walk)**

| Accessory | Price |
|-----------|-------|
| Power Ring | 300g |
| Iron Bracelet | 300g |
| Magic Earring | 400g |
| Warding Charm | 400g |
| Sprint Shoes | 500g |
| Lucky Coin | 500g |
| Antidote Charm | 600g |

> **Restock — when Act II diplomatic mission begins:** General Store adds
> Hi-Ether (800g), Smelling Salts (75g), Chronos Dust (150g). Armorer adds
> Commander's Blade (400g), Glyph Staff (500g), Pickpocket's Blade (400g),
> Pipe Hammer (500g).

---

### Corrund

**General Store (Canal District)**

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

**Armorer**

| Weapons | Price | Head Armor | Price | Body Armor | Price |
|---------|-------|------------|-------|------------|-------|
| Mythril Sword | 1,200g | Mythril Helm | 800g | Mythril Vest | 1,200g |
| Mythril Staff | 1,000g | Scholar's Cap | 900g | Steel Plate | 1,000g |
| Mythril Dagger | 1,000g | | | Ley Vestment | 1,200g |
| Mythril Spear | 1,000g | | | | |
| Compact Sledge | 1,200g | | | | |

**Sable's Black Market (Undercroft — requires Sable in active party)**

| Item | Price | Notes |
|------|-------|-------|
| Trick Blade | 1,500g | Sable dagger, early access |
| Clarity Band | 800g | Confusion immunity |
| Soft Stone | 200g | Petrify cure, rare in shops |
| Remedy | 800g | Early access |

---

### Caldera

All prices ×1.50. Caldera Employee Card reduces effective price to ×1.125.

**Company Store (General)**

| Item | Standard | Caldera Price | With Card |
|------|----------|--------------|-----------|
| Hi-Potion | 300g | 450g | 338g |
| Hi-Ether | 800g | 1,200g | 900g |
| Phoenix Feather | 500g | 750g | 563g |
| Remedy | 800g | 1,200g | 900g |
| Tent | 500g | 750g | 563g |
| Pavilion | 1,200g | 1,800g | 1,350g |

**Company Armorer**

| Item | Standard | Caldera Price | With Card |
|------|----------|--------------|-----------|
| Compact Saber | 2,000g | 3,000g | 2,250g |
| Ironbound Greatsword | 1,500g | 2,250g | 1,688g |
| Forge Hammer | 2,200g | 3,300g | 2,475g |
| Forgewright Visor | 1,000g | 1,500g | 1,125g |
| Compact Plate | 2,000g | 3,000g | 2,250g |

**Tash's Black Market (Undercity — Sable access, standard prices)**

| Item | Price | Notes |
|------|-------|-------|
| Berserk Collar | 2,000g | Standard — underground ignores inflation |
| Counter Ring | 3,000g | Standard |
| Stone Guard | 1,500g | Standard |

---

### Ashmark

**General Store**

| Item | Price |
|------|-------|
| Hi-Potion | 300g |
| Ether | 200g |
| Antidote | 50g |
| Echo Drop | 75g |
| Phoenix Feather | 500g |
| Sleeping Bag | 250g |
| Tent | 500g |

**Armorer**

| Item | Price |
|------|-------|
| Compact Saber | 2,000g |
| Twilight Edge | 2,500g |
| Runic Focus | 1,800g |
| Compact Officer's Helm | 1,200g |
| Compact Uniform | 1,800g |

> **Restock — after Ashmark liberation:** +Thornwood Pike (1,800g),
> +Whisper Edge (4,500g — early Tier 3), +Preemptive Charm (2,000g).

---

### Bellhaven

**General Store**

| Item | Price |
|------|-------|
| Potion | 50g |
| Hi-Potion | 300g |
| Ether | 200g |
| Hi-Ether | 800g |
| Antidote | 50g |
| Alarm Clock | 75g |
| Echo Drop | 75g |
| Eye Drops | 50g |
| Smelling Salts | 75g |
| Phoenix Feather | 500g |
| Smoke Bomb | 100g |
| Waystone | 300g |
| Pallor Salve | 2,500g |
| Tent | 500g |
| Pavilion | 1,200g |

> **Pallor Salve** is first available here. Limited to 3 per visit.

**Armorer**

| Item | Price |
|------|-------|
| Trick Blade | 1,500g |
| Thornwood Pike | 1,800g |
| Runic Focus | 1,800g |
| Forge Hammer | 2,200g |
| Compact Plate | 2,000g |
| Compact Uniform | 1,800g |

**Specialty (Harbor Traders)**

| Accessory | Price |
|-----------|-------|
| Flame Ring | 3,000g |
| Frost Amulet | 3,000g |
| Storm Pendant | 3,000g |
| Haste Bangle | 2,500g |
| Life Pendant | 800g |

> Bellhaven's identity: best accessory selection in Act II. The Harbor
> Traders have the widest elemental resist and utility accessory stock
> of any town before the Interlude.

---

### Thornmere

**Provisioner**

| Item | Price |
|------|-------|
| Potion | 50g |
| Hi-Potion | 300g |
| Ether | 200g |
| Antidote | 50g |
| Alarm Clock | 75g |
| Echo Drop | 75g |
| Eye Drops | 50g |
| Smelling Salts | 75g |
| Tent | 500g |

**Local Craftsman**

| Item | Price | Notes |
|------|-------|-------|
| Wyrmbone Lance | 4,500g | Unique to Thornmere; forged from local materials |
| Warding Crown | 2,800g | Thornmere specialty |
| Despair Ward | 5,000g | **Only shop selling this** |

> Thornmere's identity: the only town stocking Pallor-specific gear.
> The Despair Ward and Warding Crown are not available through normal
> shops anywhere else. Players who skip Thornmere will be locked out
> of purchasing these until Act III Oases (Despair Ward) or not at all
> (Warding Crown, which is otherwise chest-only from the Catacombs).

---

### Ironmark

**Refugee Quartermaster**

| Item | Price | Notes |
|------|-------|-------|
| Hi-Potion | 300g | |
| Hi-Ether | 800g | |
| Phoenix Feather | 500g | Limited 5 per visit |
| Pallor Salve | 2,500g | Limited 2 per visit |
| Sleeping Bag | 250g | |
| Tent | 500g | No Pavilions — luxury is gone |
| Remedy | 800g | |

**Scavenger Armorer**

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

> Ironmark's identity: stripped-down survival shopping. No accessories,
> no specialty shop, no luxuries. Pavilions are gone — the refugees
> aren't sleeping well regardless. Ironmark is the only reliable
> shopping destination during the Interlude; all other towns either
> close or reduce stock to basics after the world breaks.

---

### Act III Oases

Three distinct refugee camps scattered across the Pallor Wastes.
Each Oasis has a unique identity based on the faction that settled it.

**Oasis A — Valdris Refugees (nearest to Ironmark)**

| Item | Price | Notes |
|------|-------|-------|
| X-Potion | 1,500g | |
| Pavilion | 1,200g | |
| Phoenix Pinion | 3,000g | |
| Pallor Salve | 2,500g | Limited 3 per visit |
| Ley-Forged Longsword | 8,000g | Tier 4 sword |
| Ley Lance | 7,500g | Tier 4 spear |
| Genji Helm | 5,500g | |
| Genji Armor | 7,000g | |

**Oasis B — Compact Refugees (central Wastes)**

| Item | Price | Notes |
|------|-------|-------|
| X-Ether | 2,000g | |
| Pavilion | 1,200g | |
| Pallor Salve | 2,500g | Limited 2 per visit |
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
| Pallor Salve | 2,500g | Limited 2 per visit |
| Despair Ward | 5,000g | |
| Twilight Fang | 8,000g | Tier 4 dagger |
| Pallor Pike | 9,500g | Tier 4 spear |
| Ley Crown | 6,500g | |
| Ley-Thread Mail | 8,000g | |

> **Post-Convergence restock:** All surviving Oases expand stock. Adds
> the full consumable line, remaining Tier 4 accessories, and Elixirs
> (5,000g — first time purchasable anywhere in the game).

---

## Event-Triggered Restocking

| Event | Shops Affected | Change |
|-------|----------------|--------|
| Complete Ember Vein | Aelhart general store | +Hi-Potion (300g), +Phoenix Feather (500g), +Sleeping Bag (250g), +Tent (500g) |
| Arrive in Valdris | Valdris Crown all shops | Full Tier 1 stock unlocked |
| Diplomatic mission begins | All visited Act I towns | +Select Tier 2 consumables and weapons |
| Ashmark liberation | Ashmark shops | +Thornwood Pike (1,800g), +Whisper Edge (4,500g), +Preemptive Charm (2,000g) |
| Interlude (world breaks) | All pre-Interlude shops | Most shops close or reduce to basic consumables only — scarcity |
| Ironmark established | Ironmark refugee shops | Limited Tier 3 stock unlocked, quantity caps apply |
| Act III Oases discovered | Each Oasis individually | Unique limited stock per Oasis (see above) |
| Post-Convergence | Surviving towns + Oases | Premium stock returns: Tier 4 gear, Elixirs (5,000g), full consumable lines |

**Interlude scarcity rule:** When the world breaks, most Act I–II town
shops either close entirely or reduce to basic consumables only. Inns
remain open but armorers and specialty shops go dark. Ironmark is the
only reliable shopping destination during the Interlude — its Scavenger
Armorer and Refugee Quartermaster provide the only access to Tier 3
gear for sale.

---

## Treasure Chest Gold Formula

### Base Formula

Chest gold = percentage of the average equipment cost at the current act tier.

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

Each dungeon gets 2–4 gold chests (alongside equipment/item chests). Total gold-from-chests per dungeon = ~30–40% of one full equipment piece at that tier.

### Design Rules

- Gold chests never appear in the first room — player must commit to exploration
- Boss lair chests are the narrative justification for beast/spirit boss gold (see Boss Gold Drop System below)
- Hidden chests should be discoverable without a guide — visual clue, suspicious wall, NPC hint
- Dungeon docs (dungeons-world.md, dungeons-city.md) list chest locations; this section provides the gold amounts

---

## Boss Gold Drop System

### Formula

```
total_payday   = act_tier_base × boss_rank_multiplier
direct_gold    = floor(total_payday × narrative_split)
lair_chest_gold = total_payday - direct_gold
```

The **boss rank** determines the total gold reward. The **narrative split** determines how much the boss drops directly vs. how much is found in lair chests.

### Act Tier Base

| Act | Tier Base | Notes |
|-----|-----------|-------|
| Act I | 500g | Starting bosses |
| Act II | 1,500g | Scales with Tier 2 gear costs |
| Interlude | 2,500g | Mid-game |
| Act III | 4,000g | Endgame |
| Optional/Post-game | 6,000g | Premium |

### Boss Rank Multiplier

Not all bosses in the same act are equal.

| Rank | Multiplier | Examples |
|------|-----------|---------|
| Minor | 1.0× | First boss of an act, tutorial encounters |
| Standard | 2.0× | Most dungeon-end bosses |
| Climactic | 3.0× | Act-ending bosses, narrative-critical encounters |

### Narrative Split

Determines what fraction of the total payday the boss drops directly. The remainder goes into lair chests. The gold source must be **narratively justified:**

| Boss Type | Narrative Split | Justification |
|-----------|----------------|---------------|
| Humanoid/Military | 1.0 (all direct) | Carries gold — war chest, payment, plunder |
| Construct/Machine | 0.5 | Salvage value, workshop stash |
| Beast/Creature | 0.1 | Beasts don't carry money — lair hoard from past victims |
| Spirit/Magical | 0.1 | Guards a treasury or offering pile |
| Pallor/Corrupted | 0.05 (+ 0.7× total) | Corruption consumed the wealth — lower net payday |

**Pallor exception:** Pallor bosses reduce the **total payday** to 0.7× the normal rank amount first, because the corruption has consumed surrounding wealth. Then the 0.05 split applies to that reduced total.

### Worked Examples

| Boss | Act | Rank | Type | Total Payday | Direct Gold | Lair Chest |
|------|-----|------|------|-------------|------------|------------|
| Vein Guardian | I | Minor (1.0×) | Beast | **500g** | 50g | 450g |
| Corrupted Fenmother | I | Climactic (3.0×) | Beast | **1,500g** | 150g | 1,350g |
| Ashen Ram | II | Climactic (3.0×) | Construct | **4,500g** | 2,250g | 2,250g |
| Forge Warden | II | Standard (2.0×) | Construct | **3,000g** | 1,500g | 1,500g |
| Kole | Int | Climactic (3.0×) | Humanoid | **7,500g** | 7,500g | — |
| Ley Titan | III | Standard (2.0×) | Spirit | **8,000g** | 800g | 7,200g |
| Crystal Queen | Post | Standard (2.0×) | Pallor | **8,400g** | 420g | 7,980g |
| Vaelith | III | Climactic (3.0×) | Spirit | **12,000g** | 1,200g | 10,800g |

### Narrative Principle

Every boss encounter delivers roughly the same **total value** for its rank — the delivery mechanism just shifts to match the narrative:
- **Humanoid bosses** carry gold directly (war chest, payment)
- **Beast bosses** have gold in their lair (victims' belongings, hoard)
- **Spirit bosses** guard ancient treasuries or offering piles
- **Construct bosses** yield salvageable components
- **Pallor bosses** have consumed/corrupted the surrounding area — less to scavenge, lower net total (~0.7× tier)

---

## Sable's Steal Economy

### Steal Value Principle

Stolen items should be worth ~2–3 battles of gold income at the current act. Enough to feel rewarding, not enough to replace normal income.

### Steal Tiers by Enemy Type

| Enemy Type | Common Steal (75%) | Rare Steal (25%) | Value Range |
|------------|-------------------|------------------|-------------|
| Beast | Tier 1 material (25–40g sell) | Tier 2 material (50–100g sell) | Low — animals don't carry loot |
| Construct | Scrap Metal (35g) | Elemental Core (100g) | Moderate — salvageable parts |
| Humanoid | Consumable (Potion, Antidote) | Gold Pouch (150–500g) | High — they carry things |
| Spirit | Ether Wisp (40g) | Ley Crystal Fragment (200g) | Moderate — magical residue |
| Pallor | Grey Residue (100g) | Pallor Shard (175g) | Moderate — corrupted material |
| Undead | Bone Fragment (30g) | Ancient Glyph (300g) | Low common, high rare |

### Gold Pouch Mechanic

Humanoid enemies (soldiers, smugglers, bandits) can have "Gold Pouch" as a rare steal. Amount scales with act:

| Act | Gold Pouch Value |
|-----|-----------------|
| Act I | 150g |
| Act II | 350g |
| Interlude | 500g |
| Act III | 800g |

Sable is especially valuable in military dungeons (Valdris Siege, Compact encounters) where humanoid enemies are common.

### Boss Steals

Every boss has a unique steal documented in `bestiary/bosses.md`. These are exclusive items — accessories, rare materials, or consumables not yet available in shops. Economic value is secondary to exclusivity.

### Gold-Boosting Accessories

**Fenn's Seal** (sidequest reward — The Auditor's Conscience):
- **+25% gold from all battle sources** (enemy drops, gold pouches, boss direct gold)
- Does NOT affect shop prices, chest gold, or quest rewards
- Pays for itself over time — long-term investment

**Sea Prince's Signet** (sidequest reward):
- **+15% sell price on all items** (base 50% sell rate becomes 57.5%)
- Subtle but meaningful for players selling crafting materials
- Stacks with Fenn's Seal for a "merchant build"

---

## Crafting Economy

### Forgewright Battle Devices

Already priced in `items.md` (100–800g per device + materials). See the Forgewright Devices section in items.md for the complete recipe table. No duplication here — items.md is the canonical source.

### Arcanite Equipment Forging

`equipment.md` is the canonical source for forging recipes, fees, and materials. Key economic facts:

- **Forging fees:** 400–500g per item (low gold cost)
- **Real cost is materials:** An Arcanite Ingot sells for 1,000g; using it to forge a weapon is a 1,000g opportunity cost on top of the fee
- **Total effective cost:** Gold fee + material sell value = ~1,500–2,500g — comparable to buying Tier 3 shop equivalents (3,500–5,000g), but forged items have superior stats
- **9 forgeable items:** 6 weapons (one per character except Cael, plus Lira's Masterwork) + 3 armor pieces
- **No forged greatsword:** Intentional — Cael departs during the Interlude and returns briefly. His progression relies on shop/chest gear.

### Elemental Infusions

`equipment.md` is the canonical source. Economic summary:
- **Basic infusions (Flame/Frost/Storm/Earth):** 300g + common materials
- **Advanced infusions (Ley/Spirit/Void):** 500g + rarer materials
- **Secret Synergies:** No extra cost — the bonus effect is the reward for discovering the right weapon + element combination

### Economic Impact

Players who sell materials have more gold for shop purchases. Players who hoard materials get better gear through forging. Neither path is strictly dominant — both roughly equalize in total value, rewarding either playstyle.

---

## Quest Reward Guidelines

### Quest Reward Tiers

| Quest Tier | Gold Reward | Example |
|-----------|-------------|---------|
| Minor (fetch/delivery) | 200–500g | Deliver a message, find a lost item |
| Standard (combat/explore) | 500–1,500g | Clear a monster den, escort an NPC |
| Major (multi-step chain) | 2,000–5,000g | Ashmark liberation, Bellhaven smuggler ring |
| Epic (sidequest dungeon) | 5,000–10,000g | Dreamer's Fault floors, Grey Cleaver purification |

### Reward Composition

Not all quests pay pure gold. The mix shifts by tier:

| Quest Tier | Gold | Equipment | Materials | Consumables |
|-----------|------|-----------|-----------|-------------|
| Minor | 80% gold | — | — | 1–2 Potions/status cures |
| Standard | 50% gold | 30% chance of act-tier gear | 2–4 Tier 2 materials | — |
| Major | 40% gold | Unique accessory or weapon | 4–6 mixed materials | Elixir or rare consumable |
| Epic | 30% gold | Guaranteed unique equipment | Tier 3–4 materials | — |

### Design Rule

The best quest rewards are items you **can't buy**: unique accessories (Fenn's Seal, Sea Prince's Signet), early-access equipment, rare consumables (Megalixir, Sable's Coin). Gold is the filler; exclusivity is the incentive.

### NPC Tip Rewards

Small gold tips (50–100g) from NPCs for information or returning lost items. Flavor rewards — no economic impact, but the world feels responsive.

---

## Gold Pacing Targets

### Act I (Levels 1–12, 2 dungeons + overworld)

**Income:**

| Source | Estimate | Notes |
|--------|----------|-------|
| Enemy drops | ~1,500–2,000g | ~80 encounters × 15–25g avg |
| Treasure chests | ~800–1,200g | 4–6 gold chests, 200–300g each |
| Boss gold (Vein Guardian + Fenmother) | ~2,000g | 500g + 1,500g total paydays |
| **Total income** | **~4,300–5,200g** | Critical-path only. Optional Act I quests add ~800–1,200g (see [sidequests.md](sidequests.md)). |

**Expenses:**

| Sink | Cost | Notes |
|------|------|-------|
| Full Tier 1 equipment (4 characters) | ~6,000–7,000g | Weapon + head + body + accessory × 4 |
| Consumables | ~500–800g | Potions, status cures, Sleeping Bags |
| Inns | ~100–200g | 2–3 rests |
| **Total needed** | **~6,600–8,000g** | |

**Affordability: ~65–70%.** Player equips most of the party but skips 1–2 pieces. Selling a few crafting materials closes the gap.

### Act II (Levels 12–25, 4 dungeons + diplomatic travel)

**Income:**

| Source | Estimate | Notes |
|--------|----------|-------|
| Enemy drops | ~9,000g | ~150 encounters × 60g avg |
| Treasure chests | ~3,500g | 8–10 gold chests, 350–500g each |
| Boss gold (4 bosses: 2 standard + 1 minor + 1 climactic) | ~10,500g | Mix of ranks per formula |
| Quest rewards | ~4,500g | Mix of standard and major quests totaling ~4,500g per [sidequests.md](sidequests.md) during Act II |
| **Total income** | **~27,500g** | |

**Expenses:**

| Sink | Cost | Notes |
|------|------|-------|
| Full Tier 2 equipment (5 characters) | ~27,000g | 5 party members by end of Act II |
| Consumables | ~2,500g | Hi-Potions, Ethers, Tents |
| Inns + travel | ~600g | Multiple cities visited |
| **Total needed** | **~30,100g** | |

**Affordability: ~91% of total needs for engaged players.** Players who skip sidequests drop to ~76% (enemy drops + chests + bosses only). The 70% target reflects critical-path play; quest rewards push completionists above 80%. Caldera's 150% markup creates a pinch point mid-act.

### Interlude (Levels 25–32, scarcity arc)

**Income:**

| Source | Estimate | Notes |
|--------|----------|-------|
| Enemy drops | ~6,000g | ~100 encounters × 60g avg |
| Treasure chests | ~4,000g | 6–8 chests, higher-value Tier 3 range |
| Boss gold (3 bosses: 1 minor + 1 standard + 1 climactic) | ~15,000g | Kole (climactic) is a big payday |
| Salvage/scrounging | ~2,500g | Selling Pallor-enemy materials |
| **Total income** | **~27,500g** | |

**Expenses:**

| Sink | Cost | Notes |
|------|------|-------|
| Tier 3 equipment (selective) | ~18,000g | Limited shops — can't buy everything |
| Consumables (Pallor Salve!) | ~4,000g | Pallor Salve at 2,500g each is expensive |
| Forgewright crafting | ~1,500g | Material + gold for devices + forged gear |
| **Total needed** | **~23,500g** | |

**Affordability: ~80% of what's available.** Paradoxically higher because shops are limited — there's less to buy. Scarcity is in *availability*, not gold. Pallor Salve at 2,500g each creates a new drain.

### Act III (Levels 32–45, Pallor Wastes + endgame)

**Income:**

| Source | Estimate | Notes |
|--------|----------|-------|
| Enemy drops | ~18,000g | ~120 encounters × 150g avg |
| Treasure chests | ~10,000g | 12–15 chests, 800–1,200g each |
| Boss gold (5 bosses: 1 minor + 3 standard + 1 climactic) | ~40,000g | Climactic boss is a major payday |
| Material sales (if chosen) | ~7,000g | Tier 3–4 materials sell well |
| **Total income** | **~75,000g** | (without material sales: ~68,000g) |

**Expenses:**

| Sink | Cost | Notes |
|------|------|-------|
| Tier 4 equipment (6 characters) | ~70,000g | Full party, expensive gear |
| Consumables (X-Potions, Pavilions) | ~6,000g | Premium consumables |
| Forgewright advanced devices | ~3,000g | Arcanite Lance, Emergency Beacon |
| **Total needed** | **~79,000g** | |

**Affordability: ~86% with material sales, ~76% without.** Players still can't buy everything. The sell-or-save decision peaks here.

### Post-Game (Dreamer's Fault, Level 45+)

Gold becomes abundant. Tier 5 gear is non-purchasable (boss/quest only). The economy shifts from "can I afford this?" to "should I sell rare materials or save them for ultimate Forgewright recipes?" Gold surplus is intentional.

---

## Wealth Curve & Verification

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

1. **70% test:** At each town, sum the cost of equipping 4 active members. Multiply by 0.70. Does the player's expected wallet cover it?
2. **Consumable drain:** Can the player afford 10 Hi-Potions + 5 Ethers + 2 Phoenix Feathers per dungeon without dipping below equipment budget? (~3,000g per dungeon run in Act II)
3. **Caldera pinch:** At 150% markup, Tier 2 gear costs ~2,250–3,300g per piece. Player should feel the squeeze but not be locked out.
4. **Material sell-or-save:** Selling ALL materials through Act II gains ~3,000–5,000g extra. Closes the 70% gap to ~85%. Meaningful but not game-breaking.
5. **Sable value:** A player who steals from every humanoid encounter gains ~2,000–4,000g extra per act. Meaningful but not dominant.
6. **Forging parity:** Forged Tier 3 equipment (400–500g fee + material sell value) totals ~1,500–2,500g effective cost vs Tier 3 shop prices (3,500–5,000g). Forging is cheaper but the forged item is better — neither path is strictly dominant.
7. **Inn vs rest items:** A full dungeon run using 2 Tents (1,000g) is more expensive than 2 inn stays (~200–300g). Field resting is a convenience premium.
8. **Quest reward totals:** Sum all quest gold rewards per act. Compare against the quest income lines in the pacing tables above. Update either the tables or quest rewards if they drift significantly.

---

## Cross-References

### Document Ownership

| Document | Owns (canonical data) | economy.md Uses / Mirrors |
|----------|----------------------|--------------------------|
| economy.md | Inn prices, shop inventories (line-item prices), event restocks, gold pacing tables, boss gold formula | Defines economic structure; may restate prices when building shop tables or pacing models |
| items.md | Consumable definitions and base prices, material sell prices, Forgewright costs | Referenced for consumable prices; economy.md restates key items in rest progression and shop tables |
| equipment.md | Weapon/armor/accessory definitions, base prices, forging fees, infusion costs | Referenced for equipment prices; economy.md restates in shop inventory tables |
| bestiary/README.md | Enemy gold drop formula (logistic curve) | Referenced for gold income estimates |
| bestiary/bosses.md | Boss direct gold drops (Gold column) | Referenced for boss payday calculations |
| sidequests.md | Quest gold rewards | Referenced for quest income estimates |
| dungeons-world.md | Treasure chest contents + gold amounts | Referenced for chest income estimates |
| dungeons-city.md | Treasure chest contents + gold amounts | Referenced for chest income estimates |
| locations.md | Town & region metadata, which shops/inns exist | Referenced to attach inventories to locations |

> **Rule:** economy.md is canonical for *economic structure* (inn pricing, shop
> inventories, restocks, global targets, pacing). Per-item definitions and base
> prices remain canonical in their home docs (items.md, equipment.md, bestiary,
> quests, chests). When economy.md restates a specific price (e.g., a Potion in
> a shop table), the source doc is authoritative — keep values in sync.
