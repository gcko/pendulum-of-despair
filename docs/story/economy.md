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
(Caldera, Corrund, and affiliated ports). Mechanically identical to Gold — no
conversion rate, no separate wallet. The name evokes the Compact's controlled
economy. Functions identically to how "Gil" works in Final Fantasy VI: same
item, different label on the coin.

**Sell price rule:** all items, equipment, and materials sell to vendors at
**50% of buy price** by default.

- **Exception — Sea Prince's Signet (accessory):** raises sell rate to 57.5%
  of buy price for all items while equipped. Marginal but meaningful for
  players liquidating large material stockpiles.

**No vendor trash:** crafting materials serve dual purpose — sell them now for
gold, or save them for recipes. No items exist solely as gold bags. Every sell
decision carries an opportunity cost.

**No special financial services:** there is no money lender, bank, or interest
mechanic. Economic complexity comes from the sell-or-save decision on crafting
materials and from the Caldera inflation system. Keeping the rules simple
ensures players focus on party decisions, not spreadsheets.

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

> **Caldera note:** the base inn cost in Caldera is 300g (150% of the 200g
> standard-equivalent rate). Without the Caldera Employee Card the party pays
> 450g. With the card they pay 300g — still above market rate.

---

## Rest Item Progression

Rest items restore HP and MP at save points, functioning as the dungeon
alternative to inns. They are single-use and consumed on activation.

| Item | Buy | Sell | Effect | First Available |
|------|-----|------|--------|-----------------|
| Sleeping Bag | 250g | 125g | Restore 25% HP/MP to all party (save point only) | Act I |
| Tent | 500g | 250g | Restore 50% HP/MP to all party (save point only) | Act I |
| Pavilion | 1,200g | 600g | Restore 100% HP/MP to all party (save point only) | Act II |

**Stack limit:** 99 for all rest items.

**Design note:** inns are cheaper per-rest but require being in town. Rest items
trade gold efficiency for flexibility — essential in long dungeons. The
Pavilion's high price reflects its power as a full heal outside of town.

---

## Caldera Inflation

The Carradan Compact's economic exploitation of Caldera manifests as inflated
shop prices across the entire city.

**Markup: 150%** — all Caldera vendors (items, equipment, inn) charge 1.5×
standard price. A Potion that costs 100g elsewhere costs 150g in Caldera.

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
| Clarity Band | 800g | Silence immunity |
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

> To be filled in Task 5.

---

## Boss Gold Drop System

> To be filled in Task 5.

---

## Sable's Steal Economy

> To be filled in Task 6.

---

## Crafting Economy

> To be filled in Task 6.

---

## Quest Reward Guidelines

> To be filled in Task 6.

---

## Gold Pacing Targets

> To be filled in Task 7.

---

## Wealth Curve & Verification

> To be filled in Task 7.

---

## Cross-References

> To be filled in Task 7.
