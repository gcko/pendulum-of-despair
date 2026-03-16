# Abilities & Magic System

This document defines unique character abilities, combo techniques, the magic system framework, and ability progression for Pendulum of Despair.

---

## 1. Character Unique Commands

Each party member has one unique command in their battle menu alongside Fight, Magic, and Item. These commands reflect the character's background, faction, and narrative arc.

---

### Edren — Bulwark

> *The old ley-line oaths weren't just words. They were shields. Edren channels them still — not because the kingdom demands it, but because the people behind him need someone to stand.*

**Mechanic:** Edren enters a defensive stance that persists until his next turn. While in a Bulwark stance, he generates **Aegis Points (AP)** based on damage absorbed or redirected. AP fuel his offensive counter-abilities. Stances are mutually exclusive — choosing a new stance replaces the old one.

**Resource: Aegis Points (AP)**
- Max 10 AP. Starts each battle at 0.
- Gained per hit absorbed while in a stance: 1 AP per hit. Bonus +1 AP if the absorbed hit exceeds 10% of Edren's max HP (rewards tanking heavy hits). Also gained by successful counters (Riposte grants 1 AP on hit).
- AP decay: lose 1 AP at the start of each of Edren's turns if he took no damage since his last turn (encourages active tanking).

**Sub-Abilities:**

| Ability | Learned | AP Cost | Effect |
|---------|---------|---------|--------|
| **Ironwall** | Level 1 | 0 | Stance. Edren guards a single ally, absorbing 50% of physical damage dealt to them. AP generated per the standard hit-based rule above. |
| **Rampart** | Level 10 | 0 | Stance. Edren guards the entire back row, absorbing 30% of all damage dealt to back-row allies. Lower absorption rate but wider coverage. |
| **Riposte** | Level 6 | 2 AP | Reaction. When Edren absorbs an attack in any stance, he counters with a physical strike dealing 1.5x normal damage. Can trigger once per enemy turn. |
| **Aegis Veil** | Level 15 | 3 AP | Edren channels ley-line energy into a magical barrier on one ally, reducing magic damage by 40% for 3 turns. |
| **Shatter Guard** | Level 22 | 5 AP | Edren breaks his stance explosively, dealing physical damage to all enemies equal to total damage absorbed since entering the stance (capped at 2x his max HP). Ends the current stance. |
| **Oathkeeper** | Story: Act IV (picks up Cael's sword) | 8 AP | Edren dual-wields his own sword and Cael's blade. For 3 turns, all Bulwark stances gain +50% absorption AND Riposte triggers automatically on every absorbed hit. While active, Edren's attack commands hit twice. |

**Synergies:**
- Edren + Torren: Torren's healing spirits can restore HP Edren loses while absorbing, creating a sustain loop.
- Edren + Maren: Maren's Resonance (see below) can amplify Aegis Veil to cover the whole party at reduced strength.
- Edren + Lira: Lira's Bulkhead device stacks with Ironwall, allowing near-total damage negation on a single target for one turn.

**Story Integration:**
- **Acts I-II:** Edren has Ironwall, Riposte, and Rampart. His kit reflects a disciplined knight protecting others.
- **Interlude:** After Cael's betrayal, Edren loses access to Bulwark temporarily during the monastery sequence (he's paralyzed by guilt — mechanically represented as the command being greyed out). Sable's arrival restores it.
- **Act III:** Aegis Veil and Shatter Guard become available, reflecting his renewed resolve and deeper connection to the ley lines.
- **Act IV:** Oathkeeper unlocks when Edren picks up Cael's fallen sword. This is the culmination of his arc — carrying the weight of loss and turning it into strength.

---

### Cael — Rally

> *Cael doesn't fight alone. He fights through his brothers and sisters — lifting their spirits, calling their movements, turning six swords into one. When Cael speaks, people believe.*

**Mechanic:** Cael issues battlefield commands that buff allies and coordinate attacks. Rally commands cost MP and last a set number of turns. Only one Rally can be active at a time (issuing a new one replaces the old one). Cael must be conscious for the Rally to persist — if he's KO'd or afflicted with Silence/Sleep, the active Rally ends.

**Sub-Abilities:**

| Ability | Learned | MP Cost | Effect |
|---------|---------|---------|--------|
| **Hold the Line** | Level 1 | 6 MP | Rally. All allies gain +15% Defense and +15% Magic Defense for 3 turns. |
| **Press Forward** | Level 5 | 8 MP | Rally. All allies gain +20% Attack and +10% Speed for 3 turns. |
| **Second Wind** | Level 9 | 12 MP | Rally. All allies regenerate 5% max HP at the start of each of their turns for 4 turns. |
| **Vanguard Strike** | Level 14 | 10 MP | Command. Cael designates one enemy. The next ally to act gains a guaranteed critical hit against that target. |
| **Unbreakable** | Level 18 | 18 MP | Rally. Once during this Rally's duration (3 turns), if any ally would be reduced to 0 HP, they survive with 1 HP instead. Triggers once then the Rally ends. |

**Synergies:**
- Cael + Edren: Press Forward on Edren while Edren is in a Bulwark stance means Riposte counters deal boosted damage.
- Cael + Lira: Vanguard Strike combined with Lira's Overcharge device results in devastating single-target burst.
- Cael + Sable: Hold the Line makes Sable durable enough to stay in melee range for her Tricks.

**Story Integration:**
- **Acts I-II:** Cael is the party's force multiplier. His Rally commands make every other character stronger. The player should grow to depend on him.
- **The Betrayal:** When Cael leaves the party, the sudden absence of Rally buffs is felt mechanically. Fights become harder. This is intentional — the player should feel the loss.
- **Act III Boss Fight (vs. Cael):** Cael uses corrupted versions of his Rallies against the party:
  - *Hold the Line* becomes **Despair's Grip** — reduces all party members' Defense by 20%.
  - *Press Forward* becomes **Hollow Advance** — boosts all enemies' Attack by 25%.
  - *Second Wind* becomes **Draining Whisper** — enemies regenerate HP each turn.
  - *Vanguard Strike* becomes **Marked for Sorrow** — one party member takes 1.5x damage from all sources for 2 turns.
  - *Unbreakable* becomes **False Hope** — an enemy that would die instead survives at 1 HP (once per phase).
- The player recognizes these as twisted mirrors of abilities they once relied on. This is the mechanical expression of betrayal.

---

### Lira — Forgewright

> *Every Carradan child learns: magic is just energy, and energy is just a problem to be engineered. Lira left the Compact, but she brought its best ideas with her — and a bag full of tools.*

**Mechanic:** Lira builds and deploys **devices** in combat. She carries a pool of **Arcanite Charges (AC)** that fuel device construction. Devices are temporary constructs that persist on the battlefield for a set number of turns or until destroyed. Lira can have up to 2 devices active simultaneously. Deploying a third destroys the oldest one.

**Resource: Arcanite Charges (AC)**
- Max 12 AC. Starts each battle at max.
- Restored at inns, save points, and by certain items (Arcanite Shards).
- Lira can spend a turn to Salvage a deployed device, recovering half its AC cost (rounded down).

**Sub-Abilities:**

| Ability | Learned | AC Cost | Effect |
|---------|---------|---------|--------|
| **Shock Coil** | Level 1 | 2 AC | Device. Persists 3 turns. Deals Storm damage to a random enemy at the start of each turn. Damage scales with Lira's Magic stat. |
| **Bulkhead** | Level 7 | 3 AC | Device. Persists 3 turns. Reduces physical damage to one chosen ally by 40%. Can stack with Edren's Ironwall. |
| **Arc Trap** | Level 12 | 2 AC | Device. Hidden trap placed on the field. When an enemy uses a physical attack, the trap triggers, dealing Flame damage and inflicting a 20% Speed debuff for 2 turns. Single use. |
| **Mending Engine** | Interlude [S] (Lv 17+) | 4 AC | Device. Persists 4 turns. Heals the most-injured ally for 15% max HP at the end of each turn. |
| **Overcharge** | Interlude [S] (Lv 22+) | 3 AC | Instant. Lira supercharges one ally's next attack, adding Storm element and +50% damage. If the target already has an elemental weapon, elements combine. Consumed on next attack. |
| **Arcanite Colossus** | Act III [S] | 8 AC | Device. Persists 2 turns. A towering Forgewright construct that acts as an additional party member with its own ATB gauge. It attacks for heavy physical damage or can be commanded to shield an ally (absorb one hit, then it's destroyed). |

**Synergies:**
- Lira + Maren: Maren's Resonance can extend device durations by 1 turn.
- Lira + Sable: Sable can steal Arcanite Shards from Carradan-type enemies, feeding Lira's resource pool.
- Lira + Torren: Mending Engine and Torren's healing spirits can keep the party topped up without spending MP.

**Story Integration:**
- **Acts I-II:** Lira has access to Shock Coil, Bulkhead, and Arc Trap — practical, defensive tools reflecting her cautious defection from the Compact.
- **Interlude:** While searching for Cael in the Compact, Lira reverse-engineers Pallor-corrupted Forgewright tech. This unlocks Mending Engine and Overcharge — she's turning the enemy's tools against them.
- **Act III:** Arcanite Colossus unlocks after Lira commits to fighting Cael rather than saving him. The Colossus represents her accepting that Forgewright craft isn't inherently destructive — it's what you build with it that matters.
- **Act III Boss (vs. Cael):** Cael's machine at the Convergence uses corrupted Forgewright technology. Lira can spend a turn to **Disrupt** machine components during Phase 2, reducing the boss's abilities. This is a unique interaction only she can perform.

---

### Torren — Spiritcall

> *The spirits aren't servants. They're neighbors. Torren asks, and sometimes they answer. The Wilds have a long memory, and Torren speaks its oldest language.*

**Mechanic:** Torren calls upon nature spirits for varied effects. Each spirit has a **Favor** rating (0-3) that increases when Torren uses that spirit in battles where it's particularly effective (e.g., using a Frost spirit against Flame enemies). Higher Favor unlocks stronger versions of the spirit's ability. Favor is persistent across battles and acts as a secondary progression system.

**Resource: Spirit Favor**
- Each spirit starts at Favor 0.
- Favor increases by 1 when the spirit's ability is used "in harmony" (matching a weakness, protecting an ally from death, healing someone below 25% HP, etc.). Max Favor 3.
- At Favor 3, the spirit's ability transforms into an upgraded version permanently.
- Favor can decrease by 1 if a spirit is summoned and the battle is fled from (spirits don't appreciate being abandoned).

**Sub-Abilities:**

| Ability | Learned | MP Cost | Effect | Favor 3 Upgrade |
|---------|---------|---------|--------|-----------------|
| **Thornveil** (Briar Spirit) | Level 1 | 5 MP | Single ally gains a thorn barrier — attackers take counter-damage equal to 20% of the shielded ally's Defense for 3 turns. | **Deeproot Veil:** Counter-damage rises to 40% and the barrier also reduces incoming damage by 15%. |
| **Dewfall** (Rain Spirit) | Level 5 | 8 MP | Moderate heal to one ally. Removes Poison status. | **Torrent's Grace:** Heals moderate HP to all allies and removes Poison and Sleep. |
| **Ember Wing** (Fire Spirit) | Level 11 | 10 MP | Flame damage to all enemies. Chance to inflict a burn (damage over time, 3 turns). | **Inferno Gale:** Heavy Flame damage to all enemies. Burn is guaranteed. |
| **Stoneheart** (Earth Spirit) | Interlude [S] (Lv 16+) | 12 MP | One ally gains immunity to status effects for 2 turns. | **Mountain's Resolve:** All allies gain status immunity for 2 turns. |
| **Greyveil** (Twilight Spirit) | Interlude [S] (Lv 20+) | 14 MP | Deals non-elemental spirit damage that ignores Magic Defense. Effective against Pallor-type enemies. | **Duskbreaker:** Heavy non-elemental damage. If the target is Pallor-corrupted, deals 2x damage and has a chance to dispel Pallor buffs. |
| **Convergence Chorus** | Story: After stabilizing the ley line nexus (Interlude) | 20 MP | Torren calls all known spirits at once. Each spirit performs a weakened version of its ability simultaneously — AoE heal, AoE damage, party barrier, and status cleanse in a single action. Usable once per battle. |

**Synergies:**
- Torren + Edren: Thornveil on Edren while he's in Ironwall stance means enemies take counter-damage from both Riposte and the thorn barrier.
- Torren + Maren: Maren can use Resonance to boost Spiritcall effects by 30% for one cast.
- Torren + Sable: Sable's Smokescreen reduces enemy accuracy, making Torren safer to cast without interruption.

**Story Integration:**
- **Acts I-II:** Torren has Thornveil, Dewfall, and Ember Wing. He's the party's flexible support — healing, damage, and protection in one command.
- **Interlude:** Torren's self-sacrifice to hold back the corruption in the Wilds is reflected mechanically — when the party finds him, his max HP is permanently reduced by 15% (he burned his life force). However, he gains Stoneheart, Greyveil, and Convergence Chorus. The spirits he nearly died protecting now answer more readily.
- **Act III (Pallor Trials):** During Torren's trial, the spirits turn hostile. The player fights corrupted versions of each spirit Torren has called. Defeating them without killing them (reducing to 1 HP rather than 0) preserves their Favor ratings. Killing them resets Favor to 0. This creates a meaningful combat puzzle during the trial.
- **Greyveil:** This spirit is unique — it represents the boundary between the living world and the Pallor. It's the most effective tool the party has against Pallor-type enemies, but it's also the spirit most vulnerable to corruption.

---

### Sable — Tricks

> *Sable doesn't fight fair. She doesn't fight dirty either — she fights smart. When you grow up with nothing, you learn that everything is a weapon if you're creative enough.*

**Mechanic:** Sable's Tricks command opens a sub-menu of utility abilities focused on theft, debuffs, and improvised combat. Several Tricks have bonus effects depending on what Sable has stolen in the current battle. Tricks cost little or no MP but have cooldowns (measured in Sable's turns, not global turns).

**Resource: Stolen Goods**
- Sable can hold up to 3 stolen items at a time (separate from regular inventory).
- Stolen items can be used with specific Tricks for enhanced effects or kept for post-battle rewards.
- Unique steal-only items exist on many enemies (Forgewright components, spirit essences, Pallor fragments).

**Sub-Abilities:**

| Ability | Learned | MP/Cooldown | Effect |
|---------|---------|-------------|--------|
| **Filch** | Level 1 | 0 MP / 0 CD | Steal an item from one enemy. Success rate based on Sable's Speed vs. enemy Speed. Each enemy has a common and rare steal. |
| **Smokescreen** | Level 4 | 4 MP / 2 turns | Reduces all enemies' accuracy by 30% for 2 turns. If Sable has a stolen Forgewright component, also reduces enemy Speed by 15%. |
| **Shiv** | Level 8 | 0 MP / 1 turn | Quick physical attack that ignores 50% of target's Defense. If Sable has a stolen item, she can throw it for bonus elemental damage (element depends on item type). The item is consumed. |
| **Misdirect** | Level 14 | 6 MP / 3 turns | Forces one enemy to target a different ally than intended on its next attack. If used on a boss, instead reduces the boss's next attack damage by 25%. |
| **Ransack** | Level 19 | 8 MP / 4 turns | Steal from all enemies simultaneously. Lower success rate than Filch (70% of normal), but hits everyone. |
| **Wild Card** | Story: After the Interlude (Sable's journey reuniting the party) | 10 MP / 5 turns | Sable improvises a powerful technique based on her current stolen goods. 0 items: deals physical damage equal to 2x her Attack. 1 item: adds the item's element as AoE damage. 2 items: AoE damage plus a random debuff on all enemies. 3 items: AoE heavy damage, random debuff, and restores 10% HP to all allies. All stolen items are consumed. |

**Synergies:**
- Sable + Lira: Stolen Forgewright components can be given to Lira between battles to restore 2 AC each.
- Sable + Cael (Acts I-II): Cael's Vanguard Strike guarantees Sable's next Filch succeeds, regardless of Speed difference.
- Sable + Edren: Misdirect can force enemies to attack Edren while he's in a Bulwark stance, feeding his AP generation.
- Sable + Maren: Stolen Pallor fragments can be consumed by Maren's Unweave for bonus damage against Pallor enemies.

**Story Integration:**
- **Acts I-II:** Sable has Filch, Smokescreen, and Shiv. She's scrappy and opportunistic — a street survivor who fights with what she finds.
- **Interlude (Sable's Journey):** This is Sable's arc — she's the playable character during the Interlude. Misdirect and Ransack unlock during this sequence as she grows from a petty thief into the party's connective thread. Her abilities evolve from self-preservation into team support.
- **Wild Card:** Unlocks after Sable reassembles the full party. Represents her growth — she's no longer just stealing to survive, she's using everything she has for the people she cares about. The scaling based on stolen goods reflects her philosophy: the more you give of yourself, the more powerful the result.
- **Act III (Pallor Trial):** Sable's trial tells her she's insignificant. During this fight, all of Sable's Tricks have their cooldowns doubled and Filch has halved success rate — the Pallor is trying to make her feel useless. Overcoming the trial permanently removes the debuff and grants Wild Card a reduced cooldown (4 turns instead of 5).

---

### Maren — Arcanum

> *Magic is not a gift. It's a conversation with the bones of the world. Maren has been listening longer than anyone alive — and the world has been telling her things she wishes she hadn't heard.*

**Mechanic:** Maren manipulates the flow of magic itself. Her Arcanum command lets her absorb, redirect, amplify, and disrupt spells. She maintains a **Weave Gauge (WG)** that fills when magic is cast — by anyone, ally or enemy. When the Weave Gauge is full, Maren can unleash a powerful meta-magic effect.

**Resource: Weave Gauge (WG)**
- Max 100 WG. Starts each battle at 0.
- Gains: +10 WG when any ally other than Maren casts a spell. +5 WG when Maren herself casts a spell. +15 WG when any enemy casts a spell.
- The gauge encourages Maren to be in magic-heavy fights and rewards her for letting enemies cast (rather than just silencing them).

**Sub-Abilities:**

| Ability | Learned | Cost | Effect |
|---------|---------|------|--------|
| **Siphon** | Level 1 | 0 MP | Maren absorbs the next spell cast by an enemy, negating it and recovering MP equal to the spell's cost. Against enemies that do not use MP, Siphon restores MP equal to the spell's tier value (Tier 1: 5 MP, Tier 2: 15 MP, Tier 3: 30 MP, Tier 4: 50 MP). Requires timing — must be selected before the enemy spell resolves. If no spell comes before Maren's next turn, the stance is wasted. Generates +20 WG on success. |
| **Resonance** | Level 8 | 8 MP | Amplifies the next magical action by any ally by 30%. Affects spells (damage/healing +30%), Spiritcall effects (+30% potency), and Forgewright devices (+1 turn duration). For Bulwark's Aegis Veil, converts single-target to party-wide at half strength (20% magic damage reduction for 2 turns instead of 40% for 3 turns). Must be cast before the ally acts. Generates +10 WG. |
| **Unweave** | Level 13 | 12 MP | Dispels all buffs from one enemy. If the enemy has Pallor-type buffs, also deals magic damage equal to Maren's Magic x 3. Generates +10 WG. |
| **Ley Surge** | Level 18 | 50 WG (no MP) | Consumes 50 WG. All allies' next spells cost 0 MP. Lasts until each ally has cast one free spell. |
| **Mirrorsong** | Level 23 | 16 MP | Maren copies the last spell cast by any combatant (ally or enemy) and casts it immediately at her own Magic stat. Generates +15 WG. |
| **Annulment** | Story: After finding the ancient ruin (Interlude) | 100 WG (full gauge, no MP) | Maren unravels all active magic on the battlefield — all buffs, debuffs, status effects, devices, barriers, and ongoing spells are removed from ALL combatants (allies and enemies alike). Then deals heavy non-elemental magic damage to all enemies based on the total number of effects removed. Extremely powerful but indiscriminate — requires careful timing. |

**Synergies:**
- Maren + Torren: Resonance + Spiritcall = 30% stronger spirit effects. At Favor 3, this can produce devastating results (e.g., Resonance + Duskbreaker against Pallor enemies).
- Maren + Lira: Resonance extends Lira's device durations by 1 turn. Unweave can strip enemy barriers that block Lira's devices.
- Maren + Edren: Resonance + Aegis Veil creates party-wide magic resistance. Siphon protects the party from enemy spells that bypass Edren's physical absorption.
- Maren + Sable: Stolen Pallor fragments increase Unweave damage by 50% when consumed during the cast.

**Story Integration:**
- **Acts I-II:** Maren has Siphon and Resonance. She's the party's magical expert but holds back, reflecting her secretive nature. She knows more than she lets on.
- **Interlude (Finding Maren):** In the ancient ruin, Maren discovers records of previous Pallor cycles and the meta-magic used to fight them. This unlocks Unweave, Ley Surge, and Mirrorsong — her full potential, held back until she was sure the knowledge wouldn't cause more harm.
- **Annulment:** Unlocks alongside the revelation that the Pallor has tried this before. Represents Maren's ultimate conclusion — sometimes the only way forward is to clear the board entirely and start over. It's as much philosophy as it is combat technique.
- **Act III (Pallor Trial):** Maren's trial pits her against her younger self, who casts spells Maren hasn't seen since her years at court. The Weave Gauge fills rapidly during this fight. Using Annulment during the trial triggers special dialogue: *"I didn't waste those years. I spent them learning how to do this."*
- **Act III Boss (vs. Cael, Phase 2):** Maren can use Unweave on the Pallor's corruption anchoring Cael, dealing bonus damage to the incarnation and briefly revealing the real Cael underneath.

---

## 2. Combo Abilities (Dual Techs)

Combo abilities require two specific party members to both have full ATB gauges. The initiating character selects "Combo" from their menu, which shows available combos based on who else is ready to act. Both characters' ATB gauges reset after a combo. MP cost is split between the two characters as noted.

### Combo List

| # | Name | Characters | Total MP | Effect | Flavor |
|---|------|-----------|----------|--------|--------|
| 1 | **Shield Oath** | Edren + Cael | 14 MP (7/7) | Edren enters Ironwall stance on Cael, and Cael activates Press Forward on Edren simultaneously. Both buffs last 4 turns instead of 3. | *The two knights lock blades in salute, then turn outward — one the shield, the other the sword. They've drilled this since they were squires.* |
| 2 | **Shattered Vanguard** | Edren + Sable | 10 MP (6/4) | Sable uses Misdirect on all enemies (forcing them toward Edren), and Edren immediately uses Shatter Guard at +50% damage. Requires Edren to be in a stance with stored damage. | *Sable darts between the enemy ranks, taunting and weaving, funneling them toward the immovable wall. Edren obliges.* |
| 3 | **Forged Rampart** | Edren + Lira | 12 MP (6/6) | Lira deploys a Bulkhead on Edren that lasts 5 turns instead of 3 and also reflects 20% of absorbed damage back at attackers. Does not count toward Lira's device limit. | *Lira fuses Arcanite plating directly onto Edren's shield. It hums with contained lightning. "Don't drop it," she says. He never does.* |
| 4 | **Thornfire** | Torren + Lira | 16 MP (8/8) | Torren calls Ember Wing while Lira overcharges it with Arcanite energy. Deals heavy Flame + Storm damage to all enemies with guaranteed burn and a 30% chance of Stop (the Storm energy shorts out enemy movement). | *The fire spirit screams through Lira's Shock Coil, doubling in size and splitting into a dozen blazing arcs. Even Torren steps back.* |
| 5 | **Spiritward** | Torren + Edren | 14 MP (8/6) | Torren summons Stoneheart on the entire party while Edren channels the effect through his Bulwark stance. All allies gain status immunity for 3 turns AND 20% damage reduction. | *The earth spirit settles into Edren's shield like a heartbeat. For a moment, the whole party stands on bedrock.* |
| 6 | **Weave Theft** | Maren + Sable | 10 MP (6/4) | Sable steals an active buff from one enemy (removing it), and Maren immediately reweaves it onto one ally. If the enemy has no buffs, Sable steals an item instead and Maren converts it into a random party buff. | *Sable's hands are faster than spells. Maren's mind is faster than Sable's hands. Between the two of them, nothing the enemy has stays theirs for long.* |
| 7 | **Ley Torrent** | Maren + Torren | 18 MP (10/8) | Maren channels raw ley-line energy through Torren's spirit connection, unleashing a non-elemental blast that deals damage to all enemies equal to (Maren's Magic + Torren's Magic) x 4. Ignores Magic Defense. Generates 30 WG for Maren. | *The ley lines sing. The spirits answer. For one terrible moment, the raw voice of the world speaks through two people at once.* |
| 8 | **Ambush Protocol** | Sable + Lira | 8 MP (4/4) | Sable plants one of Lira's Arc Traps and then forces an enemy to trigger it with Misdirect. Guaranteed trigger, deals 2x normal Arc Trap damage, and the target loses their next turn. Does not consume Lira's AC — uses Sable's stolen Forgewright components instead (consumes 1). | *"I stole this off a Compact sergeant." "That's a proximity mine." "Is that what it's called? I just thought it was fun."* |
| 9 | **Promise of Dawn** | Lira + Cael | 16 MP (8/8) | Cael rallies Lira with a personal command. Lira's next two device deployments cost 0 AC and have double duration. Cael is unable to act for 1 turn afterward (the emotional cost of the bond). | *He looks at her and says the only words that matter: "I believe in what you're building." She builds faster.* |
| 10 | **Arcane Convergence** | Maren + Lira | 14 MP (8/6) | Maren weaves raw ley-line magic into Lira's deployed devices. All active devices trigger their effects immediately (out of turn) and gain +1 turn of duration. Generates 20 WG for Maren. | *Old magic and new craft were never meant to mix. Maren and Lira prove that wrong in six seconds flat.* |
| 11 | **Twilight Raid** | Sable + Torren | 12 MP (4/8) | Torren's Greyveil spirit cloaks Sable in shadow. Sable attacks all enemies for physical damage that counts as spirit-type (effective against Pallor enemies), and steals from each target with 100% success rate. | *She vanishes into the spirit's shadow and reappears behind every enemy in the space between heartbeats. When she's done, her pockets are full and theirs are empty.* |
| 12 | **Cael's Echo** | Edren + Lira | 20 MP (10/10) | **Available only in Act IV, after Cael's departure.** Edren and Lira combine their memories of Cael — his swordsmanship, his leadership, his warmth — into a single devastating attack. Edren strikes with both swords (his and Cael's) while Lira overcharges the strikes with Arcanite energy. Deals massive physical + Storm damage to a single target. Afterward, both characters are healed for 25% max HP (grief transmuted into strength). | *They don't speak. They don't need to. The sword remembers. The lightning remembers. And for one moment, he's with them again — not as a ghost, but as the man they both loved.* |

### Combos Lost to the Story

The following combos become **permanently unavailable** after Cael's betrayal at the end of Act II:
- **Shield Oath** (Edren + Cael)
- **Promise of Dawn** (Lira + Cael)

This is intentional. The mechanical loss mirrors the narrative loss. The player should feel Cael's absence in combat, not just in cutscenes. **Cael's Echo** (Edren + Lira) is the replacement — born from grief, but no less powerful.

---

## 3. Magic System Framework

### The Three Traditions

Magic in the world of Pendulum of Despair flows from the **ley lines** — veins of raw magical energy running beneath the earth and converging at the Thornmere Wilds. The three factions have developed different relationships with this energy, resulting in three distinct magical traditions.

#### Ley Line Magic (Valdris Tradition)

**Practitioners:** Maren (primary), Edren (secondary — through Bulwark stances)

**Philosophy:** Magic is a conversation with the world. You listen to the ley lines, understand their current, and shape their energy with will and knowledge. It requires study, patience, and respect for the natural flow.

**In Combat:**
- Casting animations: Glowing sigils drawn in the air, ley-line energy rising from the ground in luminous threads
- Visual palette: Deep blue, gold, white
- Sound: Resonant tones, harmonic chords, a low hum beneath the casting
- Spells tend toward precision and control — single-target damage, dispels, buffs, barriers

**Key Ley Line Spells (Summary):**

*This is a representative subset. For the complete Ley Line spell catalog, see magic.md.*

| Spell | MP | Target | Effect | Learned By |
|-------|-----|--------|--------|------------|
| **Linebolt** | 5 | Single | Light Ley-element damage (spell power 15) | Maren (Lv 1), Cael (Lv 1), Edren (Lv 10) |
| **Wardglass** | 6 | Single | +40% Magic Defense, 5 turns | Maren (Lv 4), Cael (Lv 6), Edren (Lv 8), Lira (schematic), Torren (Act III cross-train) |
| **Seal Tongue** | 6 | Single | 70% chance to inflict Silence | Maren (Lv 6), Edren (Lv 12), Lira (Act III cross-train), Torren (Act III cross-train) |
| **Ley Cascade** | 16 | Single | Medium Ley-element damage (spell power 35) | Maren (Lv 15), Cael (Lv 17) |
| **Dispersion** | 14 | Single | Removes all buffs from target | Maren (Lv 18) |
| **Leyward** | 16 | Party | +25% Magic Defense, 4 turns | Maren (Lv 18), Edren (Lv 22) |
| **Ley Storm** | 25 | All enemies | Moderate Ley-element AoE damage (spell power 27) | Maren (Lv 22) |
| **Convergence Flare** | 38 | Single | Massive Ley-element damage (spell power 65) | Maren (Lv 34) |

#### Arcanite Channeling (Carradan Tradition)

**Practitioners:** Lira (primary — through Forgewright devices)

**Philosophy:** Magic is energy, and energy can be captured, stored, and directed. Arcanite Forging binds ley-line energy into physical objects — engines, weapons, devices. It's magic made industrial, repeatable, and scalable. The cost is that it drains the ley lines rather than working with them.

**In Combat:**
- Casting animations: Mechanical deployment — gears turning, Arcanite crystals igniting, devices unfolding from Lira's kit
- Visual palette: Orange, copper, electric blue sparks
- Sound: Metallic clanks, crackling electricity, the whirr of gears, pressurized steam
- Effects tend toward sustained area control — devices that persist, traps, buffs applied through technology

**Note:** Lira does not cast "spells" in the traditional sense. Her Forgewright command IS her magic. Her devices are the Carradan equivalent of spellcasting. She can learn a limited number of Ley Line spells through cross-training with Maren (see Cross-Training below), but they are cast through Arcanite focus crystals, not pure will.

#### Spirit Communion (Thornmere Tradition)

**Practitioners:** Torren (primary)

**Philosophy:** Magic belongs to the spirits — the living will of the land, water, fire, stone, and sky. The spirit-speakers don't command magic; they ask for it. Communion requires relationship, trust, and reciprocity. You give something of yourself, and the spirits give something of themselves.

**In Combat:**
- Casting animations: Spirit forms coalescing from the environment — wisps of flame, curtains of water, shapes in the earth
- Visual palette: Green, amber, soft red, silver
- Sound: Nature sounds (rushing water, crackling fire, wind through leaves), overlaid with faint voices
- Effects tend toward versatility and scaling — spirits grow stronger with use (Favor system), and the same spirit can be called for offense, defense, or support depending on context

**Note:** Torren has BOTH a Spiritcall unique command AND a separate Magic command. Spiritcall summons nature spirits for varied effects (his signature mechanic). His Magic command gives access to the 35 spells listed in magic.md (mostly Spirit-element healing and support). The two systems complement each other: Spiritcall is versatile and Favor-driven, Magic is reliable and MP-driven. He can also learn a limited number of Ley Line spells through cross-training (see below).

### Elemental System

The magic system uses eight elements. The first four form an elemental wheel of opposing pairs; the remaining three exist outside the wheel but have their own interactions (see magic.md for the full resistance chart):

| Element | Strong vs. (150%) | Weak vs. (75%) | Associated Tradition |
|---------|-------------------|-----------------|---------------------|
| **Flame** | Frost | Storm | Spirit Communion (Ember Wing) / Arcanite (Arc Trap) |
| **Frost** | Storm | Earth | Ley Line / Spirit Communion (future spirit) |
| **Storm** | Earth | Flame | Arcanite Channeling (primary element) |
| **Earth** | Flame | Frost | Spirit Communion (Stoneheart) |
| **Ley** | Void | Spirit | Ley Line Magic |
| **Spirit** | Ley | Void | Spirit Communion (Thornmere tradition) |
| **Void** | Spirit | Ley | The Pallor (enemy-only in most cases) |
| **Non-elemental** | -- | -- | No affinity, pure kinetic or arcane impact |

**Non-elemental** damage (Fracture, Unraveling Bolt, Greyveil spirit) bypasses elemental resistance but doesn't exploit weaknesses.

**Void-type** damage is the Pallor's element. It is strong against Spirit and weak against Ley. Void vs. Void is fully immune. Only Greyveil (Torren), Unweave (Maren), and certain story abilities interact with it directly.

### Cross-Training

Characters can learn a limited number of spells outside their native tradition. This represents the game's theme of the three factions learning to coexist.

**Rules:**
- Cross-trained spells cost 50% more MP than they would for a native caster.
- Cross-trained spells cannot exceed Tier 2 (no access to the most powerful spells of another tradition).
- Cross-training becomes available during Act III, after the party has reunited and the factions' rigid boundaries have begun to blur.
- Learning requires a specific in-game interaction (e.g., a campfire scene where Maren teaches Edren, or Torren shows Lira how to ask spirits for help).

**Cross-Training Table:**

| Character | Can Learn From | Available Spells | Story Trigger |
|-----------|---------------|------------------|---------------|
| Edren | Spirit Communion (Torren) | Kindle Breath, Breath of the Wilds | Act III campfire scene — Torren teaches Edren to ask the spirits for sustained healing |
| Lira | Ley Line (Maren) | Seal Tongue | Act III — Maren shows Lira how to weave ley-line sealing into Arcanite designs |
| Torren | Ley Line (Maren) | Wardglass, Seal Tongue | Act III — Maren shares protective incantations compatible with spirit magic |
| Sable | None (formal cross-training) | N/A | Sable's spells are one-off gifts from Torren and Maren during the Interlude, not formal cross-training (no +50% MP cost). See magic.md Sable section. |
| Maren | Spirit Communion (Torren) | Rekindling | Act III — Torren teaches Maren that magic doesn't always need to be controlled |

*Note: Cross-trained spells supplement each character's base spell list defined in magic.md. They are additional spells learned through Act III story events, cast at +50% MP cost (see Cross-Training Rules above).*

**Cross-Trained Device Variants** (unique command unlocks, not spells — tracked in abilities.md only, not magic.md):

| Character | Source Tradition | Device | Story Trigger |
|-----------|-----------------|--------|---------------|
| Lira | Spirit Communion (Torren) | Thornveil device variant | Act III — Torren helps Lira build a spirit-infused protective device |

### The Pallor's Effect on Magic

The Pallor corrupts all three magical traditions:

**Ley Line Magic:**
- In Pallor-influenced areas, ley-line spells cost +25% MP (the lines are unstable).
- Maren's Siphon becomes critical — absorbing corrupted enemy spells prevents the ley lines from further destabilization.
- Visual: Ley-line sigils flicker grey at the edges when cast in corrupted zones.

**Arcanite Channeling:**
- Forgewright devices in corrupted areas have a 15% chance to malfunction each turn (effect is randomized — might heal the wrong target, damage an ally, or simply fizzle).
- Lira can spend a turn to Calibrate a device, removing the malfunction chance for its remaining duration.
- Visual: Arcanite crystals pulse with grey veins in corrupted zones.

**Spirit Communion:**
- Spirits called in corrupted areas may arrive corrupted themselves (10% chance). A corrupted spirit performs its effect on the wrong targets (heals enemies, damages allies).
- Torren can spend a turn to Purify a corrupted spirit call, reversing it to the correct targets.
- Spirits at Favor 3 are immune to corruption.
- Visual: Spirit forms appear translucent and grey-tinged in corrupted zones.

**Pallor Resistance:**
- Characters who have completed their Act III Pallor trial gain **Pallor Resistance** — a passive that halves all Pallor-zone penalties for that character.
- The full party having Pallor Resistance removes zone penalties entirely (thematic: acceptance starves the Pallor).

---

## 4. Ability Progression Table

Story-triggered unique-command abilities are marked with **[S]** in the tables below. Other story-triggered unlocks (cross-trained spells, schematics) are labeled with their unlock method (e.g., "cross-train", "schematic") instead of [S], since they are spells tracked in magic.md rather than unique-command abilities.

### Edren (Bulwark + Ley Line Magic)

| Level | Bulwark Ability | Magic | Story Trigger |
|-------|----------------|-------|---------------|
| 1 | Ironwall | — | — |
| 6 | Riposte | — | — |
| 10 | Rampart | — | — |
| — | — | Kindle Breath (cross-train) | Act III campfire scene (story-triggered; available regardless of level once the Act III campfire event occurs) |
| — | — | Breath of the Wilds (cross-train) | Act III campfire scene (story-triggered; available regardless of level once the Act III campfire event occurs) |
| 15 | Aegis Veil | — | — |
| 22 | Shatter Guard | — | — |
| — | **[S] Oathkeeper** | — | Act IV: Picks up Cael's sword |

### Cael (Rally) — Available Acts I-II Only

| Level | Rally Ability | Story Trigger |
|-------|--------------|---------------|
| 1 | Hold the Line | — |
| 5 | Press Forward | — |
| 9 | Second Wind | — |
| 14 | Vanguard Strike | — |
| 18 | Unbreakable | — |

*Note: Cael's max effective level is approximately 18-20 at the end of Act II. Unbreakable is his final ability and should be learned shortly before the betrayal, making the loss sting more.*

### Lira (Forgewright)

| Level | Forgewright Ability | Magic (Other Sources) | Story Trigger |
|-------|--------------------|--------------------|---------------|
| 1 | Shock Coil | — | — |
| 7 | Bulkhead | — | — |
| 12 | Arc Trap | — | — |
| 13 | Wardglass (schematic) | — | Ashmark Archives schematic |
| 13 | — | Seal Tongue (cross-train) | Act III scene with Maren |
| 14 | Thornveil device variant | — | Act III scene with Torren |
| 17 | **[S] Mending Engine** | — | Interlude: reverse-engineers Pallor tech in the Compact |
| 22 | **[S] Overcharge** | — | Interlude: reverse-engineers Pallor tech in the Compact |
| — | **[S] Arcanite Colossus** | — | Act III: commits to fighting Cael |

### Torren (Spiritcall)

| Level | Spiritcall Ability | Magic (Cross-Train) | Story Trigger |
|-------|-------------------|--------------------|---------------|
| 1 | Thornveil (Briar Spirit) | — | — |
| 5 | Dewfall (Rain Spirit) | — | — |
| 11 | Ember Wing (Fire Spirit) | — | — |
| 16 | **[S] Stoneheart (Earth Spirit)** | — | Interlude: party finds Torren (ley line nexus stabilization) |
| — | — | Wardglass (cross-train) | Act III scene with Maren |
| — | — | Seal Tongue (cross-train) | Act III scene with Maren |
| 20 | **[S] Greyveil (Twilight Spirit)** | — | Interlude: party finds Torren |
| — | **[S] Convergence Chorus** | — | Interlude: ley line nexus stabilization |

*Note: Torren's Interlude unlocks represent the spirits' gratitude for his sacrifice. His max HP is permanently reduced by 15% after the Interlude — a meaningful trade.*

### Sable (Tricks)

| Level | Tricks Ability | Story Trigger |
|-------|---------------|---------------|
| 1 | Filch | — |
| 4 | Smokescreen | — |
| 8 | Shiv | — |
| 14 | **[S] Misdirect** | Interlude: Sable's journey (learned infiltrating the Compact) |
| 19 | **[S] Ransack** | Interlude: Sable's journey (learned reuniting the party) |
| — | **[S] Wild Card** | Interlude: full party reassembled |

### Maren (Arcanum + Ley Line Magic)

| Level | Arcanum Ability | Ley Line Spell | Cross-Train | Story Trigger |
|-------|----------------|---------------|-------------|---------------|
| 1 | Siphon | Linebolt | — | — |
| 4 | — | Wardglass | — | — |
| 6 | — | Seal Tongue | — | — |
| 8 | Resonance | — | — | — |
| 13 | **[S] Unweave** | — | — | Interlude: ancient ruin discovery |
| 15 | — | Ley Cascade | — | — |
| 18 | — | Dispersion | — | — |
| 18 | — | Leyward | — | — |
| 18 | **[S] Ley Surge** | — | — | Interlude: ancient ruin discovery |
| 22 | — | Ley Storm | — | — |
| 23 | **[S] Mirrorsong** | — | — | Interlude: ancient ruin discovery |
| — | — | — | Rekindling (cross-train) | Act III scene with Torren |
| 34 | — | Convergence Flare | — | — |
| — | **[S] Annulment** | — | — | Interlude: learns truth of Pallor's cycle |

---

## 5. Design Notes

### Party Composition Philosophy

The six characters fill distinct combat roles with intentional overlap to prevent any single loss from crippling the party:

| Role | Primary | Secondary |
|------|---------|-----------|
| Tank / Protector | Edren | Lira (Bulkhead) |
| Healer | Torren | Maren (Rekindling cross-train), Edren (Kindle Breath / Breath of the Wilds cross-train), Lira (Mending Engine) |
| Physical DPS | Sable | Edren (Shatter Guard / Oathkeeper) |
| Magic DPS | Maren | Torren (Ember Wing / Greyveil) |
| Support / Buffs | Cael (Acts I-II) | Torren (Stoneheart), Maren (Resonance) |
| Utility / Debuffs | Sable | Maren (Unweave), Lira (Arc Trap) |

Cael's departure at the end of Act II removes the party's dedicated buffer. This gap is intentionally painful — the player must redistribute buffing duties across Torren, Maren, and Edren's expanded kits. The combat difficulty spike after the betrayal is a feature, not a bug.

### Balance Targets

- **Unique commands** should be used roughly every other turn — powerful enough to justify the opportunity cost vs. Fight/Magic/Item, but not so dominant that players ignore other options.
- **Combo abilities** should be situationally powerful — worth the cost of two ATB bars, but not required for normal encounters. Boss fights should have moments where combos feel essential.
- **Spirit Favor** progression should take approximately 15-20 battles per spirit to reach Favor 3 through natural play, rewarding players who pay attention to elemental matchups.
- **Arcanite Charges** should create genuine resource tension — Lira can't deploy everything in every fight. Players should think about which devices matter most for the current encounter.
- **Weave Gauge** should fill to 100 approximately once per major battle (3-4 rounds of heavy spellcasting), making Ley Surge and Annulment feel earned rather than spammable.
