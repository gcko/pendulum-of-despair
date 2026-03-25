# Pallor Wastes Oases Design

> Spec for Gap 2.6. Defines the three Act III Oases: ley ward stone
> protection mechanic, refugee micro-settlements with displaced NPCs,
> services (shops, rest, save), minor sidequests, discovery mechanics,
> the fall of Oasis C (mini-boss encounter), and post-Convergence state.

---

## 1. Overview

Three Oases serve as Act III safe harbors in the Pallor Wastes — the
last pockets of life before the Convergence. Each is built around a
**ley ward stone**, a natural ley energy node that creates a protective
bubble against the Grey. They are visible on the overworld map as
circles of color in the Grey (green/golden shimmer). Encounter rate
inside each Oasis is Tier 0 (Safe).

**Overworld vs. Gauntlet distinction:** The Oases are **overworld map
locations** in the Pallor Wastes region. They exist outside the Pallor
Wastes gauntlet dungeon (dungeons-world.md, 5 linear sections with no
retreat). The player visits Oases while traveling the overworld toward
the Convergence, before entering the gauntlet. This is the same pattern
as FF6 — towns on the overworld, dungeons entered separately.
locations.md's description of the Wastes having "no shops, no rest
points" refers to the gauntlet interior, not the overworld region.

The Oases serve three purposes:
1. **Mechanical:** Rest points, save points, and the last shops before
   the final dungeon. Shop inventories are already defined in
   economy.md (lines 511-554).
2. **Narrative:** Show the human cost of the Pallor through displaced
   refugees — including familiar NPCs from towns the player visited
   earlier. The calm-before-the-storm feel (FF6 Returner Hideout
   inspiration).
3. **Dramatic:** The fall of Oasis C mid-Act III raises the stakes
   and demonstrates the Convergence's growing power.

---

## 2. Ley Ward Stone Mechanic

Each Oasis exists because of a ley ward stone — a fissure where ley
energy seeps up from underground channels, creating a dome of
resistance against the Pallor.

### How Ward Stones Work

- Natural geological formations, not placed by anyone. The refugees
  found these spots and built camps around them.
- The ward creates a visible **color bubble** (~50m radius) in the
  grey wasteland. Inside the bubble, natural colors return — grass,
  sky, sound.
- Each ward stone has a **keeper** — a volunteer who channels their
  willpower into the stone to stabilize it. Not magic, just focused
  resistance to Despair. The keeper's job is exhausting and
  ultimately unsustainable.
- As the Convergence grows stronger, the ley nodes weaken. Ward
  stones develop cracks. The keepership becomes more draining.

### Ward Stone Strength (Torren's Commentary)

Torren can sense ward stones. He comments on their strength when the
party enters each Oasis:

- **Oasis A:** "Strong. This node runs deep. They're safe here —
  for now."
- **Oasis B:** "The engineers have done something clever. Extended
  the range. But the core is weakening."
- **Oasis C:** "This one is barely holding. I can feel the Grey
  pressing in."

These comments foreshadow the escalating danger and Oasis C's eventual
fall.

---

## 3. Oasis Discovery and Placement

### Visibility

All three Oases are **visible on the overworld map** from the moment
the party enters the Pallor Wastes. Visual indicator: a small circle
of color (green/golden shimmer) against the grey landscape. Unmistakable.

No searching required. The Pallor Wastes are already the hardest area
in the game (Tier 4 Intense encounter rate, 25% back attack chance).
Making the safe harbors easy to find is a quality-of-life choice. The
challenge is *between* the Oases, not finding them.

### Placement

The party can visit them in any order, but the natural path through
the Wastes leads A then B then C:

| Oasis | Location | Distance from Entry | Distance from Convergence |
|-------|----------|---------------------|---------------------------|
| A | Northwest Wastes | Closest to Ironmark (entry point) | Farthest |
| B | Central Wastes | Midway | Midway |
| C | Southeast Wastes | Farthest from entry | Closest to Convergence |

Oasis C is the last stop before the final dungeon — and the one that
falls.

---

## 4. The Three Oases

### Oasis A — Valdris Refugees

**Location:** Northwest Pallor Wastes, nearest to Ironmark.

**Population:** ~30 refugees (implied). 4 interactable NPCs.

**Flavor:** The most organized Oasis. Former Valdris soldiers maintain
order. Tents arranged in rows. A makeshift Valdris banner hangs from
the ward stone. This camp has discipline — guard rotations, rationing,
a semblance of the old kingdom.

**NPCs:**

| # | Role | Identity | Notes |
|---|------|----------|-------|
| 1 | Shopkeeper | Displaced Valdris merchant | Familiar NPC from Valdris Crown (if visited). Sells Oasis A inventory per economy.md. |
| 2 | Innkeeper | Former Valdris Crown innkeeper | Rest point (full HP/MP, save). 50g. "We don't charge much. Gold's just weight now." |
| 3 | Quest Giver | Displaced Valdris knight | Asks party to retrieve regimental banner from a Pallor-frozen patrol in the Wastes (~2 encounters away). |
| 4 | Flavor NPC | Refugee child | Describes watching Valdris Crown go Grey. Mentions "another camp further south." |

**Sidequest: The Last Banner**
- A Valdris knight asks the party to retrieve their regimental banner
  from a frozen patrol spotted on the road to the southeast.
- Location: A specific point in the Wastes, ~2 encounters from
  Oasis A. The patrol is petrified mid-march — the banner is still
  in the standard-bearer's Grey hand.
- Reward: 1,500 gold + Valdris Crest (key item — unlocks bonus
  dialogue in Edren's Pallor trial).
- Completion: Return banner to the knight. He salutes it, plants it
  next to the ward stone. No fanfare — just quiet pride.

**Services:** Shop (economy.md Oasis A inventory), Inn (50g, full
restore), Save Point (near ward stone).

---

### Oasis B — Compact Refugees

**Location:** Central Pallor Wastes, midway between Ironmark and
the Convergence.

**Population:** ~20 refugees (implied). 4 interactable NPCs (5 after
Oasis C falls).

**Flavor:** The most pragmatic Oasis. Former Compact engineers have
jury-rigged ley amplifiers around the ward stone, extending its range
slightly. Pipes, cables, and repurposed Forgewright machinery
surround the stone. Functional, not comfortable. The engineers treat
the ward stone like a machine to be optimized, not a sacred site.

**NPCs:**

| # | Role | Identity | Notes |
|---|------|----------|-------|
| 1 | Shopkeeper | Compact quartermaster | Familiar NPC from Corrund or Ashmark (if visited). Sells Oasis B inventory per economy.md. |
| 2 | Innkeeper | Improvised rest area | 75g. The "inn" is a cleared section of pipe. "It's warm. Don't ask why." |
| 3 | Quest Giver | Compact engineer | Needs a Pallor-Fused Capacitor to stabilize the ley amplifiers. |
| 4 | Flavor NPC | Oasis A survivor | Reports the ward stone at Oasis A is "dimmer than last week." Foreshadows weakening nodes. |
| 5 | Oasis C survivor (post-fall only) | Ward keeper's apprentice | Appears after Oasis C falls. Reports the fall and that the keeper "held on longer than anyone thought possible." |

**Sidequest: Amplifier Stabilization**
- A Compact engineer's ley amplifiers are flickering. They need a
  Pallor-Fused Capacitor — a component corrupted by the Grey that
  paradoxically conducts ley energy well.
- Acquisition: Dropped by Pallor Wastes enemies (uncommon drop from
  any Construct-type enemy in the Wastes) or found at a specific
  ruined Compact outpost nearby (~2 encounters away).
- Reward: 2,000 gold + 2x Arcanite Shard (crafting material).
- Completion: The engineer installs the capacitor. The ward stone's
  hum gets louder. "Bought us another week. Maybe."

**Services:** Shop (economy.md Oasis B inventory), Inn (75g, full
restore), Save Point.

---

### Oasis C — Thornmere Refugees

**Location:** Southeast Pallor Wastes, closest to the Convergence.

**Population:** ~15 refugees (implied). 3 interactable NPCs (before
the fall).

**Flavor:** The most fragile Oasis. Thornmere spirit-speakers maintain
the ward stone with traditional rituals. The color bubble is smaller
than the other Oases and flickers visibly. Wind sounds leak through.
The refugees here are the quietest — they know they're closest to the
source and have the least protection.

**NPCs (before the fall):**

| # | Role | Identity | Notes |
|---|------|----------|-------|
| 1 | Shopkeeper | Thornmere herbalist | Familiar NPC from Roothollow or Greywood (if visited). Sells Oasis C inventory per economy.md. Best shop — only source of Despair Ward. |
| 2 | Innkeeper | Root-shelter clearing | 100g. Small clearing with woven root shelters around the ward stone. |
| 3 | Ward Keeper / Quest Giver | Thornmere spirit-speaker | Asks party to bring ley water from a nearby fissure to reinforce the cracking stone. |

**Sidequest: The Cracking Stone**
- The ward keeper is visibly strained — half-kneeling by the stone,
  hands pressed to a visible crack. They ask the party to bring ley
  water from a fissure they sensed nearby (~1 encounter away).
- The party retrieves the ley water and returns. The keeper pours it
  into the crack. The stone stabilizes. The shimmer brightens briefly.
- Reward: 2,500 gold + Spirit Essence (crafting material).
- The keeper says: "This will hold. For now."
- **Dramatic irony:** The next time the player returns, the Oasis has
  fallen. The ley water bought days, not salvation. The player tried
  to help and it wasn't enough — this is the emotional core of the
  Oasis C storyline.

**Services (before the fall):** Shop (economy.md Oasis C inventory),
Inn (100g, full restore), Save Point.

---

## 5. The Fall of Oasis C

### Trigger

Story progression — automatic when the **player first visits Oasis B**.
Oasis C falls off-screen during the party's travel to Oasis B. The
player discovers it by visiting Oasis C on the overworld afterward, or
learns about it from the survivor NPC (Senna) who arrives at Oasis B
with the news.

**Why this trigger:** The Pallor Trials occur inside the Pallor Wastes
gauntlet, which has a no-retreat rule. The player cannot return to the
overworld once inside. By triggering the fall when the player visits
Oasis B (a natural mid-overworld event), the player can still visit the
fallen Oasis C on the overworld before entering the gauntlet. This
creates a natural "last stop" at Oases A/B before the final push.

### What the Player Sees

1. **Overworld:** The green shimmer on the map is gone. The Oasis C
   marker turns grey.
2. **Entering:** The ward stone is cracked in half. The color bubble
   is gone. Everything is Grey — petrified tents, frozen belongings,
   silence. The grass is ash-colored. Sound is muffled.
3. **Services:** Shop, inn, and save point are all gone. No services
   available.
4. **Encounter rate:** Tier 0 (Safe) — but not because it's protected.
   The Pallor is still here. It's already won. There's nothing left
   to fight over.
5. **Refugees:** Most are petrified — frozen mid-stride, mid-conversation,
   mid-flight. Grey statues of people the player may have spoken to.

### The Ward Keeper (Holdout)

The ward keeper is still here — the last one standing. They're by the
cracked stone, half-Grey, on their knees. The party stumbles upon them.

**Dialogue (cutscene, 4 lines):**
1. "You came back... I held it... three days..."
2. "The stone cracked. I pushed everything I had into it."
3. "The others... some ran to the northern camp. Most didn't make it."
4. "I can feel it taking me. Don't... don't let it use me against—"

The Pallor takes them. Eyes go Grey. They stand up, wreathed in grey
energy. Transition to battle.

### Mini-Boss: The Grey Keeper

The keeper's body, fully consumed by the Pallor, channeling the broken
ward stone's residual ley energy through Pallor corruption.

| Property | Value |
|----------|-------|
| Name | The Grey Keeper |
| Type | Pallor |
| Level | 32 |
| HP | 15,000 |
| MP | 200 |
| ATK | 78 |
| DEF | 65 |
| MAG | 85 |
| MDEF | 70 |
| SPD | 45 |
| Gold | 0 (this isn't a reward — it's a tragedy) |
| Exp | 800 |
| Weak | Spirit |
| Resist | Void (×0.5) |
| Immune | Despair, Death, Petrify, Stop |
| Drop | Keeper's Resolve (100%) |

**Abilities:**
- **Despair Pulse** — Party-wide Despair status (30% chance per
  target). The keeper's grief weaponized.
- **Ley Drain** — Single target, absorbs 50 MP. Channels the broken
  ward stone's residual energy.
- **Ward Shatter** — High single-target physical damage (ATK x 2.5
  multiplier). The protective energy inverted into a weapon.
- **Grey Embrace** (below 50% HP) — Self-buff: ATK +30%, MAG +30%
  for 3 turns. The Pallor tightens its hold.

**AI Script:**
- Turn 1: Despair Pulse (guaranteed)
- Turns 2-3: Alternate Ley Drain and Ward Shatter
- Below 50% HP: Grey Embrace, then prioritize Ward Shatter
- Uses Despair Pulse every 4th turn

**Design intent:** The fight should feel wrong. The player is killing
someone they tried to save. The Spirit weakness (the element of
protection and healing) is ironic — the thing that was keeping
everyone safe is now the vulnerability. Zero gold drop because this
isn't a victory.

**Drop: Keeper's Resolve**
- Accessory: +15% Despair resistance, +5 MDEF.
- A memorial item. Not the best accessory in the game, but carrying
  it means something.

### Aftermath

- A survivor NPC appears at Oasis B (NPC #5 in the table above),
  reporting Oasis C's fall.
- Oasis C remains accessible on the overworld but has no services.
  The petrified refugees remain as a permanent reminder.
- The ward stone is dark. Torren comments: "The node is dead. The
  Grey drank it dry."

---

## 6. NPC Design: Familiar Faces

Each Oasis should include 1-2 NPCs the player may recognize from
earlier in the game. These are not new characters — they are displaced
versions of existing NPCs from locations.md and npcs.md.

**Selection criteria:**
- NPCs from towns that would logically be overrun by Act III
  (Valdris Crown, Corrund, Ashmark, Thornmere settlements)
- NPCs with enough prior dialogue that the player might remember them
- Shopkeepers and innkeepers are the best candidates — the player
  interacted with them directly

**Dialogue approach:**
- Short. These people are exhausted and scared.
- Reference their original location: "You remember my shop in the
  Crown District? Gone. All Grey."
- One piece of useful information per NPC (news about the Pallor's
  spread, a hint about what lies ahead, or a comment about another
  Oasis).
- No exposition dumps. The player should piece together what happened
  from fragments.

**Specific familiar NPC assignments:**

| Oasis | Role | Familiar NPC Source |
|-------|------|---------------------|
| A | Shopkeeper | Valdris Crown merchant (locations.md) |
| A | Innkeeper | Valdris Crown innkeeper (locations.md) |
| B | Shopkeeper | Corrund/Ashmark quartermaster (locations.md) |
| C | Shopkeeper | Roothollow/Greywood herbalist (locations.md) |

The exact NPC names should be pulled from npcs.md during implementation
to ensure canonical accuracy.

---

## 7. Post-Convergence State

After the final boss is defeated and the Pallor recedes:

- **Oases A and B survive.** Ward stones glow brighter. Refugees begin
  rebuilding. The color bubble expands as the ley nodes recover.
- **Oasis C remains fallen.** The petrified refugees do not recover —
  the Pallor held them too long. The cracked ward stone becomes a
  pilgrimage marker. This is permanent: not every cost of the Pallor
  is reversible.
- **Shop expansion:** Per economy.md (lines 555-557), surviving Oases
  expand stock post-Convergence — full consumable line, remaining
  Tier 4 accessories, Elixirs (5,000g).
- **NPC dialogue updates:** Surviving NPCs express cautious relief.
  The Oasis B engineer says the ley amplifiers are "running at 200%
  for the first time. Whatever you did in there, it worked."

---

## 8. Interaction with Existing Systems

### Economy (Gap 1.6)

- Shop inventories already defined in economy.md (lines 511-554).
  No changes needed to inventory content.
- Inn prices already defined (line 147): Oasis A 50g, Oasis B 75g,
  Oasis C 100g.
- Event-triggered restocking already defined (lines 571-572): Oasis
  discovery triggers stock, post-Convergence triggers expansion.
- The fall of Oasis C removes access to the Despair Ward and Oasis C
  equipment permanently (unless the player bought them earlier). This
  creates a meaningful consequence — players who rushed past Oasis C
  without shopping lose access to the best Act III gear.

### Encounter System (Gap 2.4)

- All Oases use Tier 0 (Safe) encounter rate — no random encounters.
- The Pallor Wastes surrounding the Oases use Tier 4 (Intense,
  increment 700, ~10 steps) with Pallor Wastes formation rules
  (62.5% Normal / 25% Back Attack / 12.5% Preemptive).
- The fallen Oasis C remains Tier 0 even after the fall.

### Bestiary (Gap 1.3)

- The Grey Keeper is a new mini-boss that needs to be added to
  `bestiary/act-iii.md` and `bestiary/bosses.md`.
- Pallor-Fused Capacitor (Oasis B quest item) needs to be added as
  a drop to an existing Construct-type enemy in act-iii.md, or
  defined as a chest pickup.

### Items (Gap 1.4)

- Keeper's Resolve (accessory drop from The Grey Keeper) needs to
  be added to equipment.md.
- Valdris Crest (key item, Oasis A quest reward) needs to be added
  to items.md.

### Events (events.md)

- Oasis C fall is a world state change triggered by story progression.
- Flag: `oasis_c_fallen` (set when the player first visits Oasis B) — implemented in events.md.
- The Oasis C overworld visual changes from green shimmer to grey.

---

## 9. Cross-References

| Document | Relationship |
|----------|-------------|
| `docs/story/economy.md` | Already defines shop inventories (lines 511-554), inn prices (line 147), restocking (lines 571-572). No changes needed. |
| `docs/story/locations.md` | **Update needed:** Add Oasis A, B, C location entries. |
| `docs/story/dungeons-world.md` | **Update needed:** Add Oasis placement details to Pallor Wastes section. Update Ley Scar NPC reference. |
| `docs/story/npcs.md` | **Update needed:** Add Oasis NPCs (shopkeepers, innkeepers, quest givers, ward keepers, flavor NPCs). |
| `docs/story/sidequests.md` | **Update needed:** Add 3 minor Oasis quests (The Last Banner, Amplifier Stabilization, The Cracking Stone). |
| `docs/story/events.md` | **Update needed:** Add Oasis C fall event trigger, world state flag (`oasis_c_fallen`), cutscene, and ward keeper dialogue. |
| `docs/story/bestiary/act-iii.md` | **Update needed:** Add The Grey Keeper mini-boss stat block. |
| `docs/story/bestiary/bosses.md` | **Update needed:** Add The Grey Keeper boss entry with AI script. |
| `docs/story/equipment.md` | **Update needed:** Add Keeper's Resolve accessory. |
| `docs/story/items.md` | **Update needed:** Add Valdris Crest key item. |
| `docs/analysis/game-design-gaps.md` | Gap 2.6 status -> COMPLETE |

---

## 10. Files Created/Modified

| Action | File | Changes |
|--------|------|---------|
| Modify | `docs/story/locations.md` | Add Oasis A, B, C location entries with coordinates, services, and act availability |
| Modify | `docs/story/dungeons-world.md` | Add Oasis placement and ward stone details to Pallor Wastes section |
| Modify | `docs/story/npcs.md` | Add ~13 Oasis NPCs across all three Oases |
| Modify | `docs/story/sidequests.md` | Add 3 minor sidequests (The Last Banner, Amplifier Stabilization, The Cracking Stone) |
| Modify | `docs/story/dynamic-world.md` | Add oasis_c_fallen flag and world state change |
| Modify | `docs/story/events.md` | Add Oasis C fall cutscene and ward keeper transformation |
| Modify | `docs/story/bestiary/act-iii.md` | Add The Grey Keeper stat block |
| Modify | `docs/story/bestiary/bosses.md` | Add The Grey Keeper boss entry with AI script |
| Modify | `docs/story/equipment.md` | Add Keeper's Resolve accessory |
| Modify | `docs/story/items.md` | Add Valdris Crest key item |
| Modify | `docs/analysis/game-design-gaps.md` | Gap 2.6 status -> COMPLETE |
