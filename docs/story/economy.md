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

> To be filled in Tasks 3–4.

### Aelhart

> To be filled in Task 3.

### Highcairn

> To be filled in Task 3.

### Valdris Crown

> To be filled in Task 3.

### Corrund

> To be filled in Task 4.

### Caldera

> To be filled in Task 4.

### Ashmark

> To be filled in Task 4.

### Bellhaven

> To be filled in Task 4.

### Thornmere

> To be filled in Task 4.

### Ironmark

> To be filled in Task 4.

### Act III Oases

> To be filled in Task 4.

---

## Event-Triggered Restocking

> To be filled in Task 4.

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
