# Pallor Wastes Oases Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three Act III Oasis micro-settlements to the story docs — location entries, NPCs, sidequests, the Oasis C fall event with mini-boss, and gap tracker update.

**Architecture:** Updates to 11 existing story docs + gap tracker. No new story docs — the Oases integrate into existing location, NPC, sidequest, event, bestiary, and equipment files. Economy.md shop inventories are already complete and need no changes.

**Tech Stack:** Markdown documentation only. No code changes.

**Spec:** `docs/superpowers/specs/2026-03-25-pallor-wastes-oases-design.md`

---

## Chunk 1: Location Entries and Dungeon Integration

### Task 1: Add Oasis Location Entries to locations.md

**Files:**
- Modify: `docs/story/locations.md`

**Context:** locations.md has an Act III journey table (around line 1089) and Act III location entries. The three Oases need entries that define their position, services, and act availability. They are overworld map locations in the Pallor Wastes region, outside the gauntlet dungeon.

- [ ] **Step 1: Read locations.md Act III section**

Read `docs/story/locations.md` lines 1085-1109 to find the Act III journey table and understand the insertion point.

- [ ] **Step 2: Add Oasis entries to the journey table**

Insert three Oasis rows into the Act III journey order table, positioned between the overworld travel entries and The Convergence:

```markdown
| [N] | Oasis A (Valdris Refugees) | Overworld (Pallor Wastes) | Rest, shop, save. First safe harbor. Sidequest: The Last Banner. |
| [N+1] | Oasis B (Compact Refugees) | Overworld (Pallor Wastes) | Rest, shop, save. Sidequest: Amplifier Stabilization. |
| [N+2] | Oasis C (Thornmere Refugees) | Overworld (Pallor Wastes) | Rest, shop, save. Sidequest: The Cracking Stone. Falls after Archive of Ages. |
```

Adjust order numbers to fit the existing sequence.

- [ ] **Step 3: Add detailed Oasis location entries**

After the Pallor Wastes location entry (around line 1030), add a new subsection with detailed entries for each Oasis. Follow the existing location entry format:

```markdown
### Pallor Wastes Oases

Three micro-settlements built around natural ley ward stones — fissures
where ley energy seeps up, creating protective bubbles against the Grey.
Visible on the overworld map as circles of color (green/golden shimmer)
in the grey landscape. The Oases are overworld locations outside the
Pallor Wastes gauntlet dungeon.

#### Oasis A — Valdris Refugees

**Location:** Northwest Pallor Wastes, nearest to Ironmark.
**Acts:** III (available when the party enters the Pallor Wastes region).
**Services:** Shop (economy.md Oasis A inventory), Inn (50g, full
HP/MP restore), Save Point.
**Terrain:** Ley ward bubble — natural colors within ~50m radius.
Organized camp with tents in rows, makeshift Valdris banner.
**NPCs:** Displaced Valdris merchant (shopkeeper), former Valdris Crown
innkeeper, displaced knight (quest giver), refugee child (flavor).
**Sidequest:** The Last Banner — retrieve regimental banner from frozen
patrol in the Wastes. Reward: 1,500g + Valdris Crest.
**Ward stone status:** Strong. Torren: "This node runs deep."

#### Oasis B — Compact Refugees

**Location:** Central Pallor Wastes, midway between Ironmark and
the Convergence.
**Acts:** III.
**Services:** Shop (economy.md Oasis B inventory), Inn (75g), Save Point.
**Terrain:** Ley ward bubble with jury-rigged Forgewright amplifiers
extending the range. Pipes, cables, repurposed machinery.
**NPCs:** Compact quartermaster (shopkeeper), improvised rest attendant,
Compact engineer (quest giver), Oasis A survivor (flavor). After
Oasis C falls: ward keeper's apprentice (survivor NPC).
**Sidequest:** Amplifier Stabilization — find Pallor-Fused Capacitor
for the ley amplifiers. Reward: 2,000g + 2x Arcanite Shard.
**Ward stone status:** Weakening. Torren: "The engineers have done
something clever. But the core is weakening."

#### Oasis C — Thornmere Refugees

**Location:** Southeast Pallor Wastes, closest to the Convergence.
**Acts:** III (falls after Archive of Ages completion — see events.md).
**Services (before fall):** Shop (economy.md Oasis C inventory — only
source of Despair Ward), Inn (100g), Save Point.
**Services (after fall):** None. Ward stone cracked. Camp is Grey.
**Terrain:** Smallest ward bubble, visibly flickering. Woven root
shelters. Thornmere spirit-speaker rituals.
**NPCs (before fall):** Thornmere herbalist (shopkeeper), root-shelter
innkeeper, ward keeper / spirit-speaker (quest giver).
**NPCs (after fall):** The Grey Keeper (mini-boss). Petrified refugees.
**Sidequest:** The Cracking Stone — bring ley water to reinforce the
ward stone. Reward: 2,500g + Spirit Essence. (Dramatic irony: the
stone falls anyway.)
**Ward stone status:** Barely holding. Torren: "This one is barely
holding. I can feel the Grey pressing in."
```

- [ ] **Step 4: Verify no contradictions with existing Pallor Wastes entries**

Re-read the existing Pallor Wastes location entry (around line 1027-1040). If it says "no shops, no rest points," add a clarifying note that this refers to the gauntlet dungeon interior, not the overworld region where the Oases sit.

- [ ] **Step 5: Commit**

```bash
git add docs/story/locations.md
```
Message: `docs(shared): add Pallor Wastes Oasis location entries to locations.md`

---

### Task 2: Add Oasis Placement to Pallor Wastes in dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md`

**Context:** dungeons-world.md has a Pallor Wastes section (line ~1626) that describes the gauntlet dungeon. The Oases are overworld locations outside the gauntlet, but the Pallor Wastes section should reference them for context. The Ley Scar section (line ~1891) already mentions "An NPC at an Act III Oasis."

- [ ] **Step 1: Read the Pallor Wastes overview**

Read `docs/story/dungeons-world.md` lines 1626-1680 to find the dungeon overview and identify where to add Oasis context.

- [ ] **Step 2: Add Oasis overworld context**

In the Pallor Wastes overview section (after the dungeon overview paragraph, before the floor descriptions), add:

```markdown
### Pallor Wastes Overworld (Pre-Gauntlet)

Before entering the gauntlet, the party traverses the Pallor Wastes
overworld. Three Oases (ley ward stone settlements) serve as safe
harbors — see [locations.md](locations.md) for full details:

- **Oasis A** (Northwest, Valdris Refugees) — first rest stop after
  Ironmark.
- **Oasis B** (Central, Compact Refugees) — midway point with
  jury-rigged ley amplifiers.
- **Oasis C** (Southeast, Thornmere Refugees) — last stop before
  the Convergence. Falls after the Archive of Ages, triggering The
  Grey Keeper mini-boss encounter.

The Oases use Tier 0 (Safe) encounter rate. The overworld between
them uses Tier 4 (Intense, increment 700, ~10 steps) with Pallor
Wastes formation rules. See combat-formulas.md for encounter details.

Once the party enters the gauntlet (Section 1), there is no retreat
to the overworld. The Oases are inaccessible during the gauntlet.
```

- [ ] **Step 3: Verify the Ley Scar NPC reference**

Read line ~2012 where an NPC at an Act III Oasis mentions the Ley Scar. Verify it's consistent with the Oasis design (it should be — the NPC could be at any of the three Oases).

- [ ] **Step 4: Commit**

```bash
git add docs/story/dungeons-world.md
```
Message: `docs(shared): add Oasis overworld context to Pallor Wastes section in dungeons-world.md`

---

## Chunk 2: NPCs and Sidequests

### Task 3: Add Oasis NPCs to npcs.md

**Files:**
- Modify: `docs/story/npcs.md`

**Context:** npcs.md organizes NPCs by faction (Valdris, Carradan Compact, Thornmere Wilds, Cross-Faction). The Oasis NPCs are displaced members of their respective factions. Add them under their faction sections with a note that they appear at the Oases in Act III.

- [ ] **Step 1: Read the existing NPC format**

Read `docs/story/npcs.md` lines 13-31 (King Aldren entry) to understand the format for NPC entries.

- [ ] **Step 2: Add Oasis A NPCs to the Valdris section**

Find the end of the `## Valdris` section (before `## The Carradan Compact`). Add entries for the 4 Oasis A NPCs. Use a condensed format for minor NPCs:

```markdown
### Oasis A Refugees (Act III)

Displaced Valdris citizens who found refuge at a ley ward stone in the
northwest Pallor Wastes. These NPCs appear only in Act III.

#### Maren (Merchant)

**Location:** Oasis A (Pallor Wastes), formerly Valdris Crown Market
**Role:** Shopkeeper — sells Act III equipment and consumables
**Backstory:** Ran the general goods stall in the Crown District for
twenty years. Fled when the Grey reached the outer walls. Carries what
stock she could salvage on her back.
**Dialogue hints:** "You remember my shop in the Crown District? Gone.
All Grey. But I saved what matters — the inventory ledger. Old habits."
**Act presence:** Act III only (Oasis A).

#### Oasis A Innkeeper

**Location:** Oasis A, formerly Valdris Crown
**Role:** Rest point attendant (50g, full HP/MP restore, save point)
**Dialogue hints:** "We don't charge much. Gold's just weight now. But
the soldiers say we need to keep some structure, so... fifty gold."
**Act presence:** Act III only.

#### Sir Aldric (Quest Giver)

**Location:** Oasis A
**Role:** Displaced Valdris knight, quest giver (The Last Banner)
**Backstory:** Commanded the rear guard during Valdris Crown's
evacuation. Lost half his company to the Grey. The regimental banner
was left with a frozen patrol on the road south.
**Dialogue hints:** "Our banner is out there. Third Company, Second
Regiment. They didn't make it, but the standard doesn't have to die
with them."
**Quest:** The Last Banner — retrieve the regimental banner from a
Pallor-frozen patrol in the Wastes.
**Act presence:** Act III only.

#### Oasis A Child

**Location:** Oasis A
**Role:** Flavor NPC — provides news and foreshadowing
**Dialogue hints:** "Mama says the light is keeping us safe. But I can
see it getting smaller. And there's another camp, further south —
someone said they have machines that make the light bigger."
**Act presence:** Act III only.
```

- [ ] **Step 3: Add Oasis B NPCs to the Carradan Compact section**

Find the end of `## The Carradan Compact` section. Add 4 Oasis B NPCs (5th NPC — the Oasis C survivor — is added conditionally after the fall):

Follow the same condensed format. Include the quartermaster (shopkeeper), rest attendant, engineer (quest giver), and Oasis A survivor (flavor). Add the Oasis C survivor as a conditional entry: "Appears after oasis_c_fallen flag is set."

- [ ] **Step 4: Add Oasis C NPCs to the Thornmere Wilds section**

Find the end of `## The Thornmere Wilds` section. Add 3 Oasis C NPCs (before the fall):

Include the herbalist (shopkeeper), innkeeper, and the ward keeper (quest giver + future mini-boss). The ward keeper entry should note: "Transforms into The Grey Keeper mini-boss after the Oasis falls."

- [ ] **Step 5: Commit**

```bash
git add docs/story/npcs.md
```
Message: `docs(shared): add Oasis NPCs to npcs.md (13 NPCs across 3 factions)`

---

### Task 4: Add Oasis Sidequests to sidequests.md

**Files:**
- Modify: `docs/story/sidequests.md`

**Context:** sidequests.md has Major Side Quests (7 currently) and Minor Side Quests sections. The three Oasis quests are minor — short (5-10 minutes), self-contained, no backtracking. Add them to the Minor Side Quests section.

- [ ] **Step 1: Read the Minor Side Quests section**

Read `docs/story/sidequests.md` from line 253 to find the existing minor quests and their format.

- [ ] **Step 2: Add three Oasis sidequests**

Add after the last minor sidequest entry:

```markdown
### [N]. The Last Banner

**Quest Giver:** Sir Aldric (Oasis A, Pallor Wastes)
**Location(s):** Pallor Wastes overworld (nearby frozen patrol)
**Availability:** Act III, after discovering Oasis A
**Estimated Length:** Short (5-10 minutes)

**Narrative Arc:** Sir Aldric asks the party to retrieve the regimental
banner of the Third Company from a Pallor-frozen patrol on the road
southeast of Oasis A. The patrol is petrified mid-march — the banner
is still in the standard-bearer's Grey hand. The party fights 1-2
random encounters en route, retrieves the banner, and returns. Sir
Aldric salutes it and plants it next to the ward stone. No fanfare —
just quiet pride.

**Rewards:** 1,500 gold + Valdris Crest (key item — unlocks bonus
dialogue in Edren's Pallor trial)
**Thematic Resonance:** Memory and identity persist even when everything
else is lost. The banner is a symbol, not a weapon — but symbols matter.

### [N+1]. Amplifier Stabilization

**Quest Giver:** Compact Engineer (Oasis B, Pallor Wastes)
**Location(s):** Pallor Wastes overworld (nearby ruined outpost) or
enemy drops
**Availability:** Act III, after discovering Oasis B
**Estimated Length:** Short (5-10 minutes)

**Narrative Arc:** The Compact engineer's jury-rigged ley amplifiers
are flickering. They need a Pallor-Fused Capacitor — a component
corrupted by the Grey that paradoxically conducts ley energy well. The
party can find one at a nearby ruined Compact outpost (~2 encounters
away) or as an uncommon drop from Construct-type enemies in the Wastes.
The engineer installs it, the ward stone's hum grows louder. "Bought
us another week. Maybe."

**Rewards:** 2,000 gold + 2x Arcanite Shard (Tier 3 crafting material)
**Thematic Resonance:** Compact engineering — practical, improvised,
keeping people alive through ingenuity rather than magic.

### [N+2]. The Cracking Stone

**Quest Giver:** Ward Keeper (Oasis C, Pallor Wastes)
**Location(s):** Pallor Wastes overworld (nearby ley fissure)
**Availability:** Act III, after discovering Oasis C (before the fall)
**Estimated Length:** Short (5 minutes)

**Narrative Arc:** The ward keeper is on their knees by the cracking
ward stone, visibly strained. They ask the party to bring ley water
from a fissure they sensed nearby (~1 encounter away). The party
retrieves it and returns. The keeper pours it into the crack. The
stone stabilizes. The shimmer brightens. "This will hold. For now."

The next time the player returns (after the Archive of Ages), the
Oasis has fallen. The ley water bought days, not salvation. The player
tried to help and it wasn't enough.

**Rewards:** 2,500 gold + Spirit Essence (Tier 2 crafting material)
**Thematic Resonance:** Not every effort succeeds. The tragedy is that
you did everything right and it still wasn't enough — the core theme
of the Pallor.
```

- [ ] **Step 3: Update quest count if tracked**

Check if sidequests.md has a total quest count or summary table. If so, update it to reflect the 3 new minor quests.

- [ ] **Step 4: Commit**

```bash
git add docs/story/sidequests.md
```
Message: `docs(shared): add 3 Oasis minor sidequests to sidequests.md`

---

## Chunk 3: Events, Dynamic World, and Bestiary

### Task 5: Add Oasis C Fall Event to events.md and dynamic-world.md

**Files:**
- Modify: `docs/story/events.md`
- Modify: `docs/story/dynamic-world.md`

**Context:** The fall of Oasis C is a story event triggered after the Archive of Ages dungeon. It needs an event entry in events.md (cutscene catalog) and a world state flag in dynamic-world.md.

- [ ] **Step 1: Read events.md Act III section**

Read `docs/story/events.md` around line 892 (Act III section) to find the cutscene catalog format.

- [ ] **Step 2: Add Oasis C fall event to events.md**

Add to the Act III events section:

```markdown
#### The Fall of Oasis C

**Trigger:** `oasis_c_fallen` flag (set after Archive of Ages
completion)
**Type:** Environmental — discovered by visiting Oasis C on the
overworld, or reported by survivor NPC at Oasis B.
**Tier:** Full Cutscene (T1) if visiting Oasis C directly.

**Sequence:**
1. The overworld map shows Oasis C's shimmer is gone (grey marker).
2. Entering Oasis C: the ward stone is cracked in half. Everything
   is Grey — petrified tents, frozen refugees, silence.
3. The ward keeper is found by the cracked stone, half-Grey.
4. Dialogue (4 lines):
   - "You came back... I held it... three days..."
   - "The stone cracked. I pushed everything I had into it."
   - "The others... some ran to the northern camp. Most didn't make it."
   - "I can feel it taking me. Don't... don't let it use me against—"
5. Transformation: eyes go Grey, stands up wreathed in grey energy.
6. Battle: The Grey Keeper (mini-boss, see bosses.md).
7. After battle: body dissolves into grey mist. Ward stone goes dark.
   Torren: "The node is dead. The Grey drank it dry."

**If the player visits Oasis B instead:** The survivor NPC (ward
keeper's apprentice) reports the fall. The player can then visit
Oasis C to trigger the mini-boss encounter, or skip it.

**Post-Convergence:** Oasis C remains fallen. Petrified refugees do
not recover. The cracked ward stone is a permanent memorial.
```

- [ ] **Step 3: Read dynamic-world.md Act III flags**

Read `docs/story/dynamic-world.md` lines 306-320 (Act III Flags section).

- [ ] **Step 4: Add oasis_c_fallen flag**

Add a new row to the Act III flags table:

```markdown
| [N] | `oasis_c_fallen` | Archive of Ages completed | Oasis C overworld marker turns grey. Ward stone cracked. Shop/inn/save removed. The Grey Keeper mini-boss available. Survivor NPC appears at Oasis B. | Oasis C NPCs (petrified), Oasis B survivor NPC (appears) |
```

- [ ] **Step 5: Commit**

```bash
git add docs/story/events.md docs/story/dynamic-world.md
```
Message: `docs(shared): add Oasis C fall event and oasis_c_fallen flag`

---

### Task 6: Add The Grey Keeper to Bestiary

**Files:**
- Modify: `docs/story/bestiary/act-iii.md`
- Modify: `docs/story/bestiary/bosses.md`

**Context:** The Grey Keeper is a mini-boss encountered at the fallen Oasis C. It needs a stat block in act-iii.md and a full boss entry with AI script in bosses.md.

- [ ] **Step 1: Read act-iii.md for insertion point**

Read `docs/story/bestiary/act-iii.md` lines 435-445 to find the end of enemy entries and the summary section.

- [ ] **Step 2: Add Grey Keeper stat block to act-iii.md**

Insert before the Act III Summary section:

```markdown
## Oasis C — The Grey Keeper

The ward keeper of Oasis C, consumed by the Pallor after the ley ward
stone cracked. Encountered as a mini-boss when the party visits the
fallen Oasis C.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Drop (100%) | Steal | Weak | Resist | Absorb | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------------|-------|------|--------|--------|-------------------|-------------|
| The Grey Keeper | Boss | 32 | 15,000 | 200 | 78 | 65 | 85 | 70 | 45 | 0 | 800 | Keeper's Resolve (100%) | Spirit Essence (100%) | Spirit | Void (×0.5) | — | Despair, Death, Petrify, Stop | Oasis C (Pallor Wastes, after fall) |

> **Design note:** Zero gold drop — this is a tragedy, not a reward.
> The Spirit weakness is ironic: the element of protection is the
> vulnerability of the corrupted protector.
```

- [ ] **Step 3: Add Pallor-Fused Capacitor as enemy drop**

The Oasis B sidequest (Amplifier Stabilization) requires a Pallor-Fused Capacitor, obtainable as a drop from Construct-type enemies in the Pallor Wastes. Find an existing Construct-type enemy in act-iii.md (e.g., a Pallor Wastes construct or Ley-Warped Colossus) and add "Pallor-Fused Capacitor" as a rare drop (25%) or steal item. If no suitable Construct exists in the Wastes, add it as a chest pickup at a specific location in dungeons-world.md's Pallor Wastes overworld section instead.

- [ ] **Step 4: Update act-iii.md summary counts**

Read the Act III Summary section and update enemy/boss counts to include The Grey Keeper.

- [ ] **Step 5: Read bosses.md Act III section**

Read `docs/story/bestiary/bosses.md` around line 1126 (Act III Bosses) to find the format and insertion point.

- [ ] **Step 6: Add Grey Keeper boss entry to bosses.md**

Add after the trial bosses section (or as a separate subsection for Oasis bosses):

```markdown
### The Grey Keeper (Oasis C Mini-Boss)

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Drop (100%) | Steal | Weak | Resist | Absorb | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------------|-------|------|--------|--------|-------------------|-------------|
| The Grey Keeper | Boss | 32 | 15,000 | 200 | 78 | 65 | 85 | 70 | 45 | 0 | 800 | Keeper's Resolve (100%) | Spirit Essence (100%) | Spirit | Void (×0.5) | — | Despair, Death, Petrify, Stop | Oasis C (fallen) |

**Modes:** 2 (Normal, Desperate)

**AI Script:**

Phase 1 (Normal, HP > 50%):
- Turn 1: Despair Pulse (guaranteed — party-wide Despair status, 30%
  chance per target)
- Turns 2-3: Alternate Ley Drain (single target, absorbs 50 MP) and
  Ward Shatter (single target, ATK × 2.5 physical)
- Repeat: Despair Pulse every 4th turn

Phase 2 (Desperate, HP <= 50%):
- Trigger: Grey Embrace (self-buff, ATK +30%, MAG +30%, 3 turns)
- Prioritize Ward Shatter (highest damage output)
- Despair Pulse every 3rd turn (faster than Phase 1)
- Ley Drain when MP pool is available on targets

Scripted Events:
- Battle start: "The keeper's eyes go Grey. Their body rises, wreathed
  in corrupted ley energy. The cracked ward stone pulses behind them."
- 50% HP: "Grey tendrils erupt from the ward stone, feeding the keeper.
  Their attacks grow desperate — frantic."
- Defeat: "The grey energy dissipates. The keeper's body crumbles into
  grey mist. The ward stone goes completely dark."

**Design Note:** The fight should feel wrong. The player is killing
someone they tried to save (if they completed The Cracking Stone
quest). The Spirit weakness — the element of protection and healing —
is ironic. Zero gold because this isn't a victory. The Keeper's
Resolve drop is a memorial, not loot.
```

- [ ] **Step 7: Commit**

```bash
git add docs/story/bestiary/act-iii.md docs/story/bestiary/bosses.md
```
Message: `docs(shared): add The Grey Keeper mini-boss to bestiary`

---

### Task 7: Add Keeper's Resolve and Valdris Crest to Equipment/Items

**Files:**
- Modify: `docs/story/equipment.md`
- Modify: `docs/story/items.md`

**Context:** Two new items from the Oasis content: Keeper's Resolve (accessory, dropped by The Grey Keeper) and Valdris Crest (key item, Oasis A quest reward).

- [ ] **Step 1: Read equipment.md Character-Specific/Boss Drop section**

Read `docs/story/equipment.md` around line 509 to find the Boss Drop accessories table.

- [ ] **Step 2: Add Keeper's Resolve**

Add to the Character-Specific / Boss Drop Accessories table:

```markdown
| Keeper's Resolve | +15% Despair resistance, +5 MDEF | — | III | The Grey Keeper drop (Oasis C) |
```

- [ ] **Step 3: Update accessory summary count**

Update the Accessory Summary total (currently 41) to 42.

- [ ] **Step 4: Read items.md Key Items section**

Read `docs/story/items.md` around line 459 to find the Key Items format.

- [ ] **Step 5: Add Valdris Crest**

Add to an appropriate Key Items subsection (Boss Mementos or a new Quest Rewards subsection):

```markdown
| Valdris Crest | Sir Aldric, Oasis A (The Last Banner quest) | Carried | Unlocks bonus dialogue in Edren's Pallor trial |
```

- [ ] **Step 6: Update key item count if tracked**

Check if items.md has a total key item count. If so, update it.

- [ ] **Step 7: Commit**

```bash
git add docs/story/equipment.md docs/story/items.md
```
Message: `docs(shared): add Keeper's Resolve accessory and Valdris Crest key item`

---

### Task 8: Update Gap 2.6 to COMPLETE

**Files:**
- Modify: `docs/analysis/game-design-gaps.md`

**Context:** All Gap 2.6 checklist items are now addressed. Update the status and check off all items.

- [ ] **Step 1: Read the current Gap 2.6 section**

Read `docs/analysis/game-design-gaps.md` lines 394-415.

- [ ] **Step 2: Update Gap 2.6 status and checklist**

Replace the section with:

```markdown
### 2.6 Pallor Wastes Oases

**Status:** COMPLETE
**Priority:** P1
**Files:** `docs/story/locations.md`, `docs/story/dungeons-world.md`, `docs/story/npcs.md`, `docs/story/sidequests.md`, `docs/story/dynamic-world.md`, `docs/story/events.md`, `docs/story/bestiary/act-iii.md`, `docs/story/bestiary/bosses.md`, `docs/story/equipment.md`, `docs/story/items.md`
**Depends On:** 1.4 (Items), 1.5 (Equipment), 1.6 (Economy)
**Completed:** 2026-03-25 — Three Oases (Valdris/Compact/Thornmere refugees) with ley ward stone protection, shops/inn/save, 13 NPCs (including familiar faces from earlier acts), 3 minor sidequests, Oasis C fall event with The Grey Keeper mini-boss, post-Convergence state.

**What's Needed:**
- [x] Number and placement of Oases in Act III overworld (3 Oases: NW/Central/SE Pallor Wastes, visible on overworld map)
- [x] Each Oasis as a micro-settlement: displaced villagers from fallen towns (Valdris, Compact, Thornmere refugees with familiar NPCs)
- [x] Services per Oasis:
  - [x] Rest point (full HP/MP restore, save point) — 50g/75g/100g
  - [x] Item shop (limited supplies — unique per Oasis, per economy.md)
  - [x] Weapon/armor vendor (Tier 4 gear per economy.md inventories)
  - [x] Optional NPC quest givers (3 minor sidequests: The Last Banner, Amplifier Stabilization, The Cracking Stone)
- [x] Oasis protection mechanic: ley ward stones (natural ley energy nodes creating protective bubbles)
- [x] Narrative flavor: each Oasis has refugees from a specific fallen town with news/rumors about the Grey
- [x] Oasis discovery: visible on overworld map (green/golden shimmer), no searching required
- [x] Act progression: Oasis C falls after Archive of Ages completion. The Grey Keeper mini-boss encounter. Oases A and B survive. Post-Convergence: survivors rebuild, shops expand.

**Blocking:** ~~Act III overworld pacing, player resource management in endgame, narrative worldbuilding~~
Now complete. Unblocks nothing directly (all downstream gaps were already unblocked by Tier 1 completions).
```

- [ ] **Step 3: Add Progress Tracking row**

Add to the Progress Tracking table:

```markdown
| 2026-03-25 | 2.6 Pallor Wastes Oases | MISSING -> COMPLETE. 3 Oases with ley ward stones, 13 NPCs, 3 sidequests, Oasis C fall event + Grey Keeper mini-boss, Keeper's Resolve accessory, Valdris Crest key item. | -- |
```

- [ ] **Step 4: Run lint and tests**

```bash
pnpm lint && pnpm test
```

- [ ] **Step 5: Commit**

```bash
git add docs/analysis/game-design-gaps.md
```
Message: `docs(shared): update Gap 2.6 to COMPLETE`
