# Abilities & Magic System

This document defines unique character abilities, combo techniques, the magic system framework, and ability progression for Pendulum of Despair.

> **Overworld field abilities** (Lira's Forge Devices, Torren's Call
> Stag, Maren's Linewalk) are defined in their respective system docs
> and formalized in [ui-design.md](ui-design.md) Section 18.3. This
> document covers combat abilities only.

---

## 1. Character Unique Commands

Each party member has one unique command in their battle menu alongside Fight, Magic, and Item. These commands reflect the character's background, faction, and narrative arc.

**Unlock conditions:** Abilities show a 'Learned' column. For pure level-up abilities, this is the level required. For story-triggered abilities marked [S], the level shown is the **minimum level** — the ability unlocks when BOTH the level requirement AND the story trigger are met. If only a story trigger is needed (no level gate), the Learned column shows the story reference instead of a level.

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
| **Shatter Guard** | Level 22 | 5 AP | Edren breaks his stance explosively, dealing physical damage to all enemies equal to total damage absorbed since entering the stance (capped at 2x his max HP). Minimum damage: Edren's Attack x 1 (even if no damage was absorbed). Ends the current stance. |
| **Steadfast Resolve** | Story: `trial_edren_complete` (Pallor Wastes trial) | 6 AP | Edren steels the party's resolve. Immediately cleanses all Despair and Silence from every ally, then grants +20% DEF and +20% MDEF to all allies for 3 turns. The cleanse fires before the buff — a Despaired ally is freed, then shielded. |
| **Oathkeeper** | Story: Act IV (picks up Cael's sword) | 8 AP | Edren dual-wields his own sword and Cael's blade. For 3 turns, all Bulwark stances gain +50% absorption AND Riposte triggers automatically on every absorbed hit. While active, Edren's attack commands hit twice. |

**Synergies:**
- Edren + Torren: Torren's healing spirits can restore HP Edren loses while absorbing, creating a sustain loop.
- Edren + Maren: Maren's Resonance (see below) can amplify Aegis Veil to cover the whole party at reduced strength.
- Edren + Lira: Lira's Bulkhead device stacks with Ironwall, allowing near-total damage negation on a single target for one turn.

**Story Integration:**
- **Acts I-II:** Edren has Ironwall, Riposte, and Rampart. His kit reflects a disciplined knight protecting others.
- **Interlude:** After Cael's betrayal, Edren loses access to Bulwark temporarily during the monastery sequence (he's paralyzed by guilt — mechanically represented as the command being greyed out). Sable's arrival restores it.
- **Act III:** By this point, Edren has typically reached levels 15-22, unlocking Aegis Veil and Shatter Guard through standard leveling. Steadfast Resolve unlocks from his Pallor Wastes trial — the culmination of the theme established in Acts I-II (defending, not attacking). The party-wide Despair cleanse is invaluable in the Pallor Wastes and Convergence.
- **Act IV:** Oathkeeper unlocks when Edren picks up Cael's fallen sword. This is the culmination of his arc — carrying the weight of loss and turning it into strength.

---

### Cael — Rally

> *Cael doesn't fight alone. He fights through his brothers and sisters — lifting their spirits, calling their movements, turning six swords into one. When Cael speaks, people believe.*

**Mechanic:** Cael issues battlefield commands that buff allies and coordinate attacks. Rally commands cost MP and last a set number of turns. Only one Rally can be active at a time (issuing a new one replaces the old one). Cael must be conscious for the Rally to persist — if he's Fainted or afflicted with Silence/Sleep, the active Rally ends.

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
  - *Hold the Line* becomes **Despair's Grip** — reduces all party members' DEF by 20% for 3 turns.
  - *Press Forward* becomes **Hollow Advance** — Cael gains +25% ATK for 3 turns (self-buff, not party).
  - *Second Wind* becomes **Draining Whisper** — Cael regenerates 5% max HP per turn for 3 turns.
  - *Vanguard Strike* becomes **Marked for Sorrow** — one party member takes 1.5x damage from all sources for 2 turns.
  - *Unbreakable* becomes **False Hope** — Cael survives at 1 HP once when his Phase 2 HP would reach 0.
- The player recognizes these as twisted mirrors of abilities they once relied on. This is the mechanical expression of betrayal.

---

### Lira — Forgewright

> *Every Carradan child learns: magic is just energy, and energy is just a problem to be engineered. Lira left the Compact, but she brought its best ideas with her — and a bag full of tools.*

**Mechanic:** Lira builds and deploys **devices** in combat. She carries a pool of **Arcanite Charges (AC)** that fuel device construction. Devices are temporary constructs that persist on the battlefield for a set number of turns or until destroyed. Lira can have up to 2 devices active simultaneously. Deploying a third destroys the oldest one. **Exception:** devices deployed via dual tech combos do not count toward this limit (they are fused directly onto the target rather than placed on the field).

**Resource: Arcanite Charges (AC)**
- Max 12 AC. Starts each battle at current AC pool (12 minus any AC
  spent on pre-crafting since the last rest; see [crafting.md](crafting.md)).
- Restored when resting at save points via rest items (Sleeping Bag 25%,
  Tent 50%, Pavilion 100%), fully at inns, and by Arcanite Shards (+3 AC
  each). See [save-system.md](save-system.md).
- Lira can spend a turn to Salvage a deployed device, recovering half its AC cost (rounded down).

**Sub-Abilities:**

| Ability | Learned | AC Cost | Effect |
|---------|---------|---------|--------|
| **Shock Coil** | Level 1 | 2 AC | Device. Persists 3 turns. Deals Storm damage to a random enemy at the start of each turn. Damage scales with Lira's Magic stat: spell power 10 per tick (see § Damage Magnitudes). |
| **Bulkhead** | Level 7 | 3 AC | Device. Persists 3 turns. Reduces physical damage to one chosen ally by 40%. Can stack with Edren's Ironwall. |
| **Arc Trap** | Level 12 | 2 AC | Device. Hidden trap placed on the field. When an enemy uses a physical attack, the trap triggers, dealing Flame damage (spell power 30) and inflicting a 20% Speed debuff for 2 turns. Single use. |
| **Mending Engine** | Interlude [S] (Lv 17+) | 4 AC | Device. Persists 4 turns. Heals the most-injured ally for 15% max HP at the end of each turn. |
| **Overcharge** | Interlude [S] (Lv 22+) | 3 AC | Instant. Lira supercharges one ally's next attack, adding Storm element and +50% damage. If the target already has an elemental weapon, the attack gains dual-element: it hits with BOTH elements, checking the target's weakness to each independently and using the more favorable result. Consumed on next attack. |
| **Salvage** | Level 1 | 0 AC | Instant. Destroys one active device, recovering half its AC cost (rounded down). |
| **Thornveil Barrier** (device variant) | Act III [S] | 3 AC | Device. Persists 3 turns. Target: Single ally. Creates an Arcanite thorn barrier dealing counter-damage equal to 15% of the shielded ally's Defense to attackers. Counts toward 2-device limit. |
| **Arcanite Colossus** | Act III [S] | 8 AC | Device. Persists 2 turns. A towering Forgewright construct that acts as an additional party member with its own ATB gauge. The Colossus has HP equal to 50% of Lira's max HP, Attack equal to Lira's Attack x 1.5, and ATB speed equal to 75% of Lira's Speed. It cannot be healed but can be targeted by enemies. It attacks for physical damage equal to its Attack stat (Lira's Attack x 1.5) or can be commanded to shield an ally (absorb one hit, then it's destroyed). |

**Pallor-zone action:** Calibrate (0 AC, targets one active device, removes malfunction chance for remaining duration). Available only in Pallor-corrupted zones.

**Synergies:**
- Lira + Maren: Maren's Resonance extends the next device Lira deploys by 1 turn.
- Lira + Sable: Sable can steal Arcanite Shards from Carradan-type enemies, feeding Lira's resource pool.
- Lira + Torren: Mending Engine and Torren's healing spirits can keep the party topped up without spending MP.

**Story Integration:**
- **Acts I-II:** Lira has access to Shock Coil, Bulkhead, and Arc Trap — practical, defensive tools reflecting her cautious defection from the Compact.
- **Interlude:** While searching for Cael in the Compact, Lira reverse-engineers Pallor-corrupted Forgewright tech. This unlocks Mending Engine and Overcharge — she's turning the enemy's tools against them.
- **Act III:** Arcanite Colossus unlocks after Lira commits to fighting Cael rather than saving him. The Colossus represents her accepting that Forgewright craft isn't inherently destructive — it's what you build with it that matters. Disrupt is available as a scripted action during the Phase 2 boss fight (defined in the next bullet).
- **Act III (Pallor Trial):** Lira faces the Perfect Machine — a flawless automaton with Cael's face. Completing the trial unlocks her latent weapon forge ability (per `trial_lira_complete`). This is a prerequisite for the Vaelith fight.
- **Act III (vs. Vaelith):** When the Vaelith fight begins, Lira automatically manifests **Cael's Edge** — a weapon forged from her connection to Cael. This shatters Vaelith's Pallor barrier (the fight cannot start without it, which is why `trial_lira_complete` is a prerequisite for `vaelith_defeated`). Cael's Edge is a permanent weapon: ATK 72, Spirit element (effective against Pallor, per [equipment.md](equipment.md)). It also grants **Sever Bond** (1 use, Vaelith fight only): a 3.0× ability multiplier physical attack with Spirit element that ignores Vaelith's DEF entirely (DEF treated as 0 in the damage formula). After the Vaelith fight, Cael's Edge remains as permanent equipment (replacing her current weapon if stronger) but Sever Bond is consumed.
- **Act III Boss (vs. Cael):** Cael's machine at the Convergence uses corrupted Forgewright technology. Lira can spend a turn to **Disrupt** machine components during Phase 2, reducing the boss's abilities. (Disrupt is a scripted battle action available only during the Phase 2 boss fight. It costs 2 AC, targets one of Cael's ley line anchors, and disables it for 3 turns. Each anchor disabled reduces the machine's power by 25%.) This is a unique interaction only she can perform.

---

### Torren — Spiritcall

> *The spirits aren't servants. They're neighbors. Torren asks, and sometimes they answer. The Wilds have a long memory, and Torren speaks its oldest language.*

**Mechanic:** Torren calls upon nature spirits for varied effects. Each spirit has a **Favor** rating (0-3) that increases when Torren uses that spirit in battles where it's particularly effective (e.g., using a Frost spirit against Flame enemies). Higher Favor unlocks stronger versions of the spirit's ability. Favor is persistent across battles and acts as a secondary progression system.

**Resource: Spirit Favor**
- Each spirit starts at Favor 0.
- Favor increases by 1 when the spirit's ability is used "in harmony" (matching a weakness, protecting an ally from death, healing someone below 25% HP). These are the only conditions that increase Favor. Max Favor 3.
- At Favor 3, the spirit's ability transforms into an upgraded version permanently.
- Favor can decrease by 1 if a spirit is summoned and the battle is fled from (spirits don't appreciate being abandoned).

**Sub-Abilities:**

| Ability | Learned | MP Cost | Effect | Favor 3 Upgrade |
|---------|---------|---------|--------|-----------------|
| **Thornveil** (Briar Spirit) | Level 1 | 5 MP | Single ally gains a thorn barrier — attackers take counter-damage equal to 20% of the shielded ally's Defense for 3 turns. | **Deeproot Veil:** Counter-damage rises to 40% and the barrier also reduces incoming damage by 15%. |
| **Dewfall** (Rain Spirit) | Level 5 | 8 MP | Moderate heal to one ally (spell power 12). Removes Poison status. | **Torrent's Grace:** Heals moderate HP to all allies (spell power 12 each) and removes Poison and Sleep. |
| **Ember Wing** (Flame Spirit) | Level 11 | 10 MP | Flame damage to all enemies (spell power 10). 40% chance to inflict Burn (Flame damage over time, 3 turns). | **Inferno Gale:** Heavy Flame damage to all enemies (spell power 20). Burn is guaranteed. |
| **Stoneheart** (Earth Spirit) | Interlude [S] (Lv 16+) | 12 MP | One ally gains immunity to status effects for 2 turns. | **Mountain's Resolve:** All allies gain status immunity for 2 turns. |
| **Greyveil** (Twilight Spirit) | Interlude [S] (Lv 20+) | 14 MP | Deals non-elemental damage (channeled through a spirit) that ignores Magic Defense (spell power 28). Effective against Pallor-type enemies. | **Duskbreaker:** Heavy non-elemental damage (spell power 56). If the target is Pallor-corrupted, deals 2x damage and has a 60% chance to dispel Pallor buffs. |
| **Convergence Chorus** | Story: After stabilizing the ley line nexus (Interlude) | 20 MP | Torren calls the Briar, Rain, Flame and Earth spirits at once. Each performs its ability at 50% normal potency simultaneously, and the single-target ones are broadened to the whole party: AoE damage (spell power 5, all enemies), AoE heal (spell power 6, all allies) that also cleanses Poison, a party barrier countering for 10% of DEF, and party status immunity for 1 turn. Usable once per battle. A component whose spirit Torren has not yet learned is skipped. See § Damage Magnitudes for the 50% rule, the choice of roster and the Favor 3 figures. | N/A |
| **Rootsong** | Story: `trial_torren_complete` (Pallor Wastes trial) | 14 MP | Torren sings to all spirits at once. Heals all allies for moderate HP each (spell power 12 — the same per-target potency as Dewfall) AND increases all spirit Favor by 1 (up to max 3). Usable once per battle. The only way to boost Favor for multiple spirits in a single action. | N/A |

**Synergies:**
- Torren + Edren: Thornveil on Edren while he's in Ironwall stance means enemies take counter-damage from both Riposte and the thorn barrier.
- Torren + Maren: Maren can use Resonance to boost Spiritcall effects by 30% for one cast.
- Torren + Sable: Sable's Smokescreen reduces enemy accuracy, making Torren safer to cast without interruption.

**Story Integration:**
- **Acts I-II:** Torren has Thornveil, Dewfall, and Ember Wing. He's the party's flexible support — healing, damage, and protection in one command.
- **Interlude:** Torren's self-sacrifice to hold back the corruption in the Wilds is reflected mechanically — when the party finds him, his max HP is permanently reduced by 15% (he burned his life force). However, he gains Stoneheart, Greyveil, and Convergence Chorus. The spirits he nearly died protecting now answer more readily.
- **Act III (Pallor Trials):** During Torren's trial, the spirits turn hostile. The player fights corrupted versions of each spirit Torren has called. Defeating them without killing them (reducing to 1 HP rather than 0) preserves their Favor ratings. Killing them resets Favor to 0. This creates a meaningful combat puzzle during the trial. Completing the trial unlocks Rootsong — Torren's acceptance that imperfect protection is better than abandonment. The party-wide Favor boost reflects the spirits' renewed trust.
- **Greyveil:** This spirit is unique — it represents the boundary between the living world and the Pallor. It's the most effective tool the party has against Pallor-type enemies, but it's also the spirit most vulnerable to corruption.

**Pallor-zone action:** Purify (0 MP, reverses corrupted spirit effect to correct targets, prevents further corruption for remaining duration). Available only in Pallor-corrupted zones.

---

### Sable — Tricks

> *Sable doesn't fight fair. She doesn't fight dirty either — she fights smart. When you grow up with nothing, you learn that everything is a weapon if you're creative enough.*

**Mechanic:** Sable's Tricks command opens a sub-menu of utility abilities focused on theft, debuffs, and improvised combat. Several Tricks have bonus effects depending on what Sable has stolen in the current battle. Tricks cost little or no MP but have cooldowns (measured in Sable's turns, not global turns). Tricks can be used from any row, but **Steal abilities** (Filch, Ransack, and the item-steal component of Wild Card) **require front row** — physical contact with the target is required. Non-steal Tricks (Smokescreen, Shiv, etc.) work from either row.

**Resource: Stolen Goods**
- Sable can hold up to 3 stolen items at a time (separate from regular inventory).
- Stolen items can be used with specific Tricks for enhanced effects or kept for post-battle rewards.
- Unique steal-only items exist on many enemies (Forgewright components, spirit essences, Pallor fragments).

**Sub-Abilities:**

| Ability | Learned | MP/Cooldown | Effect |
|---------|---------|-------------|--------|
| **Filch** | Level 1 | 0 MP / 0 CD | Steal an item from one enemy. Success rate based on Sable's Speed vs. enemy Speed. Each enemy has a common and rare steal. |
| **Smokescreen** | Level 4 | 4 MP / 2 turns | Reduces all enemies' accuracy by 30% for 2 turns. If Sable has a stolen Forgewright component, also reduces enemy Speed by 15%. |
| **Shiv** | Level 8 | 0 MP / 1 turn | Quick physical attack (`ability_mult` 1.0) that ignores 50% of target's Defense. If Sable has a stolen item, she can throw it for bonus elemental damage (element depends on item type). The item is consumed. **The throw branch's magnitude is still open** — see § Damage Magnitudes. |
| **Misdirect** | Interlude [S] (Lv 14+) | 6 MP / 3 turns | Forces one enemy to target a different ally than intended on its next attack. Against AoE attacks, Misdirect has no effect. Against non-physical actions (spells), it redirects the targeting as normal. If used on a boss, instead reduces the boss's next attack damage by 25%. |
| **Ransack** | Interlude [S] (Lv 19+) | 8 MP / 4 turns | Steal from all enemies simultaneously. Lower success rate than Filch (70% of normal), but hits everyone. |
| **Wild Card** | Story: After the Interlude (Sable's journey reuniting the party) | 10 MP / 5 turns | Sable improvises a powerful technique based on her current stolen goods. 0 items: physical damage to one enemy at `ability_mult` 2.0 ("2x her Attack"). 1 item: the same 2.0 strike against all enemies, carrying the thrown item's element. 2 items: as 1 item, plus a random debuff (drawn from: Poison, Sleep, Silence, Blind, Slow) on all enemies. 3 items: heavy — `ability_mult` 3.0 against all enemies, elemental, random debuff (same list), and restores 10% HP to all allies. All stolen items are consumed. Multipliers per [combat-formulas.md](combat-formulas.md) § Physical Ability Multiplier Tiers; *which* element a given item confers is still open — see § Damage Magnitudes. |

**Synergies:**
- Sable + Lira: Stolen Forgewright components can be given to Lira between battles to restore 2 AC each.
- Sable + Cael (Acts I-II): Cael's Vanguard Strike guarantees Sable's next Filch succeeds, regardless of Speed difference.
- Sable + Edren: Misdirect can force enemies to attack Edren while he's in a Bulwark stance, feeding his AP generation.
- Sable + Maren: Stolen Pallor fragments can be consumed by Maren's Unweave for bonus damage against Pallor enemies.

**Story Integration:**
- **Acts I-II:** Sable has Filch, Smokescreen, and Shiv. She's scrappy and opportunistic — a street survivor who fights with what she finds.
- **Interlude (Sable's Journey):** This is Sable's arc — she's the playable character during the Interlude. Misdirect and Ransack unlock during this sequence as she grows from a petty thief into the party's connective thread. Her abilities evolve from self-preservation into team support.
- **Wild Card:** Unlocks after Sable reassembles the full party. Represents her growth — she's no longer just stealing to survive, she's using everything she has for the people she cares about. The scaling based on stolen goods reflects her philosophy: the more you give of yourself, the more powerful the result.
- **Act III (Pallor Trial):** Sable's trial tells her she's insignificant. During this fight, all of Sable's Tricks have their cooldowns doubled and Filch has halved success rate — the Pallor is trying to make her feel useless. Overcoming the trial permanently removes the debuff, grants Wild Card a reduced cooldown (4 turns instead of 5), and unlocks Unbreakable Thread.

**Unbreakable Thread** (passive, unlocked from `trial_sable_complete`):
Once per battle, when any ally would be reduced to 0 HP, they survive
at 1 HP instead. Triggers automatically — Sable does not need to act.
She just needs to be alive and in the active party. This mirrors Cael's
Unbreakable Rally (lost when he left) but as a permanent passive rather
than an MP-costed buff. The trial told her showing up is enough. Her
presence proves it.

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
| **Siphon** | Level 1 | 0 MP | Maren absorbs the next spell cast by an enemy, negating it and recovering MP equal to the spell's cost. Against enemies that do not use MP, Siphon restores MP equal to the spell's tier value (Tier 1: 5 MP, Tier 2: 15 MP, Tier 3: 30 MP, Tier 4: 50 MP). Functions as a stance: once selected, Maren holds Siphon until the next enemy spell is cast, then absorbs it automatically. If no enemy spell comes before Maren's next turn, the stance ends with no effect. Generates +20 WG on success. |
| **Resonance** | Level 8 | 8 MP | Amplifies the next magical action by any ally by 30%. Affects spells (damage/healing +30%), Spiritcall effects (+30% potency), and the next Forgewright device deployed (+1 turn duration). For Bulwark's Aegis Veil, converts single-target to party-wide at half strength (20% magic damage reduction for 2 turns instead of 40% for 3 turns). Must be cast before the ally acts. Generates +10 WG. |
| **Unweave** | Interlude [S] (Lv 13+) | 12 MP | Dispels all buffs from one enemy. If the enemy has Pallor-type buffs, also deals magic damage equal to Maren's Magic x 3. Generates +10 WG. |
| **Ley Surge** | Interlude [S] (Lv 18+) | 50 WG (no MP) | Consumes 50 WG. All allies' next spells cost 0 MP. Lasts until each ally has cast one free spell. |
| **Mirrorsong** | Interlude [S] (Lv 23+) | 16 MP | Maren copies the last spell cast by any combatant (ally or enemy) and casts it immediately at her own Magic stat. If no spell has been cast this battle, Mirrorsong fails with no effect and no MP/WG cost. Generates +15 WG. |
| **Annulment** | Story: After finding the ancient ruin (Interlude) | 100 WG (full gauge, no MP) | Maren unravels all active magic on the battlefield — all buffs, debuffs, status effects, devices, barriers, and ongoing spells are removed from ALL combatants (allies and enemies alike). Then deals non-elemental magic damage to all enemies equal to (Maren's Magic x 2) + (effects removed x 15 spell power). Extremely powerful but indiscriminate — requires careful timing. |

**Synergies:**
- Maren + Torren: Resonance + Spiritcall = 30% stronger spirit effects. At Favor 3, this can produce devastating results (e.g., Resonance + Duskbreaker against Pallor enemies).
- Maren + Lira: Resonance extends Lira's device durations by 1 turn. Unweave can strip enemy barriers that block Lira's devices.
- Maren + Edren: Resonance + Aegis Veil creates party-wide magic resistance. Siphon protects the party from enemy spells that bypass Edren's physical absorption.
- Maren + Sable: Stolen Pallor fragments increase Unweave damage by 50% when consumed during the cast.

**Story Integration:**
- **Acts I-II:** Maren has Siphon and Resonance. She's the party's magical expert but holds back, reflecting her secretive nature. She knows more than she lets on.
- **Interlude (Finding Maren):** In the ancient ruin, Maren discovers records of previous Pallor cycles and the meta-magic used to fight them. This unlocks Unweave, Ley Surge, and Mirrorsong — her full potential, held back until she was sure the knowledge wouldn't cause more harm.
- **Annulment:** Unlocks alongside the revelation that the Pallor has tried this before. Represents Maren's ultimate conclusion — sometimes the only way forward is to clear the board entirely and start over. It's as much philosophy as it is combat technique.
- **Act III (Pallor Trial):** Maren's trial pits her against her younger self, who casts spells Maren hasn't seen since her years at court. The Weave Gauge fills rapidly during this fight. Using Annulment during the trial triggers special dialogue: *"I didn't waste those years. I spent them learning how to do this."* Completing the trial unlocks Pallor Sight.

**Pallor Sight** (passive, unlocked from `trial_maren_complete`):
All enemies in battle have their elemental weaknesses, HP values, and
status immunities visible from battle start (normally hidden until
discovered through experimentation). Additionally, Pallor-type enemies
have their current HP regen rate displayed and any hidden phase
thresholds revealed. Pure information — no combat power increase.
Maren's knowledge IS the reward. She sees what others can't because
she paid the price to learn.
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
| 4 | **Thornfire** | Torren + Lira | 16 MP (8/8) | Torren calls Ember Wing while Lira overcharges it with Arcanite energy. Deals Flame + Storm damage to all enemies (spell power 40 (20 Flame + 20 Storm, each checked independently against the target's elemental resistance)) with guaranteed Burn and a 30% chance of Stop (the Storm energy shorts out enemy movement). | *The Flame spirit screams through Lira's Shock Coil, doubling in size and splitting into a dozen blazing arcs. Even Torren steps back.* |
| 5 | **Spiritward** | Torren + Edren | 14 MP (8/6) | Torren summons Stoneheart on the entire party while Edren channels the effect through his Bulwark stance. All allies gain status immunity for 3 turns AND 20% damage reduction. | *The earth spirit settles into Edren's shield like a heartbeat. For a moment, the whole party stands on bedrock.* |
| 6 | **Weave Theft** | Maren + Sable | 10 MP (6/4) | Sable steals an active buff from one enemy (removing it), and Maren immediately reweaves it onto one ally. If the enemy has no buffs, Sable steals an item instead and Maren converts it into a random party buff. | *Sable's hands are faster than spells. Maren's mind is faster than Sable's hands. Between the two of them, nothing the enemy has stays theirs for long.* |
| 7 | **Ley Torrent** | Maren + Torren | 18 MP (10/8) | Maren channels raw ley-line energy through Torren's spirit connection, unleashing a non-elemental blast that deals damage to all enemies equal to (Maren's Magic + Torren's Magic) x 4. Ignores Magic Defense. Generates 30 WG for Maren. | *The ley lines sing. The spirits answer. For one terrible moment, the raw voice of the world speaks through two people at once.* |
| 8 | **Ambush Protocol** | Sable + Lira | 8 MP (4/4) | Sable plants one of Lira's Arc Traps and then forces an enemy to trigger it with Misdirect. Guaranteed trigger, deals 2x normal Arc Trap damage (spell power 60), and the target loses their next turn. Does not consume Lira's AC — uses Sable's stolen Forgewright components instead (consumes 1). | *"I stole this off a Compact sergeant." "That's a proximity mine." "Is that what it's called? I just thought it was fun."* |
| 9 | **Promise of Dawn** | Lira + Cael | 16 MP (8/8) | Cael rallies Lira with a personal command. Lira's next two device deployments cost 0 AC and have double duration. Cael is unable to act for 1 turn afterward (the emotional cost of the bond). | *He looks at her and says the only words that matter: "I believe in what you're building." She builds faster.* |
| 10 | **Arcane Convergence** | Maren + Lira | 14 MP (8/6) | Maren weaves raw ley-line magic into Lira's deployed devices. All active devices trigger their effects immediately (out of turn) and gain +1 turn of duration. Generates 20 WG for Maren. | *Old magic and new craft were never meant to mix. Maren and Lira prove that wrong in six seconds flat.* |
| 11 | **Twilight Raid** | Sable + Torren | 12 MP (4/8) | Torren's Greyveil spirit cloaks Sable in shadow. Sable attacks all enemies for physical damage equal to (Sable's Attack + Torren's Magic) x 1.5, spirit-typed (effective against Pallor enemies), and steals from each target with 100% success rate. | *She vanishes into the spirit's shadow and reappears behind every enemy in the space between heartbeats. When she's done, her pockets are full and theirs are empty.* |
| 12 | **Cael's Echo** | Edren + Lira | 20 MP (10/10) | **Available only in Act IV, after Cael's departure.** Edren and Lira combine their memories of Cael — his swordsmanship, his leadership, his warmth — into a single devastating attack. Edren strikes with both swords (his and Cael's) while Lira overcharges the strikes with Arcanite energy. Deals physical + Storm damage to a single target (combined Attack x 3). Afterward, both characters are healed for 25% max HP (grief transmuted into strength). | *They don't speak. They don't need to. The sword remembers. The lightning remembers. And for one moment, he's with them again — not as a ghost, but as the man they both loved.* |

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

**Thornveil Device Variant spec:** AC Cost: 3. Duration: 3 turns. Target: Single ally. Effect: Creates an Arcanite thorn barrier that deals counter-damage equal to 15% of the shielded ally's Defense to attackers. Functions identically to Torren's base Thornveil but uses Lira's AC instead of MP and counts toward her 2-device limit.

### The Pallor's Effect on Magic

The Pallor corrupts all three magical traditions:

**Ley Line Magic:**
- In Pallor-influenced areas, ley-line spells cost +25% MP (the lines are unstable).
- Maren's Siphon becomes critical — absorbing corrupted enemy spells prevents the ley lines from further destabilization.
- Visual: Ley-line sigils flicker grey at the edges when cast in corrupted zones.

**Arcanite Channeling:**
- Forgewright devices in corrupted areas have a 15% chance to malfunction each turn (effect is randomized (equal 1/3 chance each): heal the wrong target, damage an ally, or fizzle with no effect).
- Lira can spend a turn to Calibrate a device, removing the malfunction chance for its remaining duration. (Calibrate is a free Forgewright sub-command available only in Pallor-corrupted zones. It costs 0 AC, targets one active device, and removes the malfunction chance for that device's remaining duration. Appears in Lira's battle menu alongside her regular Forgewright abilities.)
- Visual: Arcanite crystals pulse with grey veins in corrupted zones.

**Spirit Communion:**
- Spirits called in corrupted areas may arrive corrupted themselves (10% chance). A corrupted spirit performs its effect on the wrong targets (heals enemies, damages allies). For non-damage, non-healing effects (e.g., Stoneheart status immunity), corruption grants the effect to enemies instead of allies.
- Torren can spend a turn to Purify a corrupted spirit call, reversing it to the correct targets. (Purify is a free Spiritcall sub-command available only in Pallor-corrupted zones. It costs 0 MP, reverses the current corrupted spirit effect to its correct targets, and prevents further corruption for that spirit's remaining duration. Appears in Torren's battle menu alongside his regular Spiritcall abilities.)
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
| — | **[S] Steadfast Resolve** | — | Act III: Pallor Wastes trial (`trial_edren_complete`) |
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
| — | — | Wardglass (schematic) | Ashmark Archives schematic |
| — | — | Seal Tongue (cross-train) | Act III scene with Maren |
| 14 | **[S]** Thornveil device variant | — | Act III scene with Torren |
| 17 | **[S] Mending Engine** | — | Interlude: reverse-engineers Pallor tech in the Compact |
| 22 | **[S] Overcharge** | — | Interlude: reverse-engineers Pallor tech in the Compact |
| — | **[S] Arcanite Colossus** | — | Act III: commits to fighting Cael |
| — | **[S] Cael's Edge** (weapon + Sever Bond) | — | Act III: Pallor Wastes trial (`trial_lira_complete`) |

### Torren (Spiritcall)

| Level | Spiritcall Ability | Magic (Cross-Train) | Story Trigger |
|-------|-------------------|--------------------|---------------|
| 1 | Thornveil (Briar Spirit) | — | — |
| 5 | Dewfall (Rain Spirit) | — | — |
| 11 | Ember Wing (Flame Spirit) | — | — |
| 16 | **[S] Stoneheart (Earth Spirit)** | — | Interlude: party finds Torren (ley line nexus stabilization) |
| — | — | Wardglass (cross-train) | Act III scene with Maren |
| — | — | Seal Tongue (cross-train) | Act III scene with Maren |
| 20 | **[S] Greyveil (Twilight Spirit)** | — | Interlude: party finds Torren |
| — | **[S] Convergence Chorus** | — | Interlude: ley line nexus stabilization |
| — | **[S] Rootsong** | — | Act III: Pallor Wastes trial (`trial_torren_complete`) |

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
| — | **[S] Unbreakable Thread** (passive) | Act III: Pallor Wastes trial (`trial_sable_complete`) |

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
| — | **[S] Pallor Sight** (passive) | — | — | Act III: Pallor Wastes trial (`trial_maren_complete`) |

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

### Row-Restricted Abilities

**Row-restricted abilities:** Sable's Filch and Ransack require the front row, as does the item-steal component of Wild Card. All other abilities work from either row.

### Balance Targets

- **Unique commands** should be used roughly every other turn — powerful enough to justify the opportunity cost vs. Fight/Magic/Item, but not so dominant that players ignore other options.
- **Combo abilities** should be situationally powerful — worth the cost of two ATB bars, but not required for normal encounters. Boss fights should have moments where combos feel essential.
- **Spirit Favor** progression should take approximately 15-20 battles per spirit to reach Favor 3 through natural play, rewarding players who pay attention to elemental matchups.
- **Arcanite Charges** should create genuine resource tension — Lira can't deploy everything in every fight. Players should think about which devices matter most for the current encounter.
- **Weave Gauge** should fill to 100 approximately once per major battle (3-4 rounds of heavy spellcasting), making Ley Surge and Annulment feel earned rather than spammable.

### Resource Cost Invariants

The three custom resources have hard caps stated in their own sections above.
No ability may cost more than its resource's cap, or the ability would be
permanently uncastable. `game/tests/test_ability_balance.gd` asserts this
against `game/data/abilities/`.

| Resource | Cap | Most expensive ability | Cost |
|----------|-----|------------------------|------|
| Aegis Points (AP) | 10 | Oathkeeper | 8 AP |
| Arcanite Charges (AC) | 12 | Arcanite Colossus | 8 AC |
| Weave Gauge (WG) | 100 | Annulment | 100 WG |

Annulment sits exactly on the cap by design — it is the only ability that
consumes a full gauge, and it is described that way in the Arcanum table above.

*Weave Gauge derivation.* The **base** gain rules are +5 WG when Maren casts,
+10 WG when another ally casts, +15 WG when an enemy casts. A "round of heavy
spellcasting" in a four-slot party is Maren plus one other caster plus one enemy
caster: `5 + 10 + 15 = 30 WG per round`, reaching 100 on round 4. With two ally
casters alongside Maren it is `5 + 20 + 15 = 40 WG per round`, reaching 100 on
round 3. That bounds the stated 3-4 round target from both sides on the base
rules alone, so neither the base gain values nor the balance target needs
changing.

30 WG/round is a floor, not the only rate. Several Arcanum abilities generate WG
on top of the base rules — Siphon +20 on success, Resonance +10, Unweave +10,
Mirrorsong +15 — as do two combos (Ley Torrent +30, Arcane Convergence +20). A
round that includes one of these runs at roughly 35-50 WG, which pulls the fill
to the round-3 end of the stated target, and a party that lands Siphon or a
WG-generating combo every single round can reach 100 during round 2. Whether
that best case needs a cap is a tuning question for the battle layer, not a
value this balance pass changes — the base rules and the stated target agree.

*Damage magnitudes.* Abilities that use the standard physical formula take their
`ability_mult` from [combat-formulas.md](combat-formulas.md) § Ability
Multipliers (1.0 basic / 1.5 strong / 2.0 ultimate / 2.5 combo / 3.0 maximum).
Wild Card is on that ladder too — `ability_mult` 2.0 rising to 3.0, see § Damage
Magnitudes — despite the "2x her Attack" phrasing its entry uses.
Abilities with their own formula state it inline in the tables above (Unweave,
`Maren MAG x 3`; Arcanite Colossus,
`Lira ATK x 1.5`; Ley Torrent, `(Maren MAG + Torren MAG) x 4`; Twilight Raid,
`(Sable ATK + Torren MAG) x 1.5`; Cael's Echo, `combined ATK x 3`); the three
whose formula needs the battle layer's own state — Shatter Guard, Annulment and
Greyveil — are additionally spelled out in combat-formulas.md § Custom-Formula
Abilities. A combo may also modify a custom-formula ability rather than carry an
`ability_mult` of its own (Shattered Vanguard is Shatter Guard at +50% damage),
so a combo appearing in the physical multiplier table is not by itself evidence
that it uses the physical formula. The abilities that used to describe their
output qualitatively ("Flame damage to all enemies", "moderate heal") are
resolved in § Damage Magnitudes below.

### Damage Magnitudes (numeric balance pass)

Companion to § Resource Cost Invariants. That section fixed what abilities
*cost*; this one fixes what they *deal*. Ten entries described their output in
adjectives rather than numbers. Nine are resolved here and one is left open on
purpose. `game/tests/test_ability_balance.gd` asserts the numeric *fields* below
against `game/data/abilities/` — every `power`, `power_favor3`, `ability_mult`
and `ability_mult_max`, plus the two `component_powers` — so an edit that breaks
one of those fails the suite. Three quantities in this section live only in
effect prose and are pinned by nothing: the Chorus's "counter 10% of DEF" and
"status immunity, 1 turn", and Shock Coil's "3 ticks". Editing one of those
passes the suite silently.

No *number* here is a fresh design choice. Each one falls out of a rule already
written down somewhere, and the derivation sits next to the value so a reader can
check it — or overturn it, which is the point of writing it down. Three
non-numeric choices *are* made, each labelled where it is made and each stated
with the alternative it rejects:

1. How Wild Card's item branches deliver their 2.0 strike (reading (a), the
   strike itself becomes elemental and AoE). Shiv's equivalent fork is left open
   rather than settled.
2. Which spirits the Convergence Chorus composites, and how the cell's word
   "cleanse" is read. The shipped text said "all known spirits" and listed a
   "status cleanse"; this pass names four spirits and reads the cleanse as Rain's
   Poison removal plus Earth's status immunity. See *Which four spirits* below
   for the alternative and what it costs.
3. What the Chorus does when a component spirit is not yet learned. Also below.

#### The rules used

1. **MP-costed abilities are priced on magic.md's tier ladder.** Torren's
   Spiritcalls are the only abilities whose magnitude this pass *derives* from
   an MP price, and only some of them: Dewfall, Torrent's Grace, Greyveil and
   Duskbreaker. Ember Wing's MP is a check on a value rule 4 supplies, not the
   input — see its derivation. Other MP-costed abilities carry a magnitude but are priced by
   something else and so are not on this ladder: Unweave (12 MP) states its own
   formula, `Maren MAG x 3`; Wild Card (10 MP) is priced off the physical
   multiplier ladder; and combos are priced off the ability they fire (rule 4),
   which is how Ambush Protocol lands at Tier-3 power for 8 MP. This document
   defines no ladder of its own, so
   [magic.md](magic.md) § Spell Balance Guidelines supplies one: MP 3-8 = Tier 1,
   12-20 = Tier 2, 25-45 = Tier 3, 50-99 = Tier 4; single-target power bands
   12-20 / 28-40 / 50-70 / 85-120; and an AoE version carries 60-70% of the
   single-target power at Tiers 1-3. magic.md's companion *MP* rule — an AoE
   costs 1.5-2x the single-target version — is **scoped**: magic.md § Derived
   Rules binds it only to the nine named same-tier AoE/single-target pairs, and
   says a standalone AoE with no counterpart is priced inside its plain tier MP
   band instead. Torren's Spiritcalls are not spells and appear on none of those
   lists, so where this pass reaches for the MP ratio it is reasoning by analogy
   and says so at the point of use.
   AP/AC/WG abilities are **not** on this ladder — they are priced against each
   other inside their own pool, because their pools refill on different rules.
2. **A Favor 3 upgrade never reduces the per-target magnitude.** Each branch of
   this rule rests on one quantified precedent, and it is worth weighing at that
   strength. *Broadening:* Stoneheart -> Mountain's Resolve goes one ally -> all
   allies at an unchanged 2 turns. (Dewfall -> Torrent's Grace broadens the same
   way and keeps the same adjective, "moderate" -> "moderate", in both cells —
   but its magnitude is one of the values this pass is deriving, so it is
   corroboration, not independent evidence.) *Doubling:* Thornveil -> Deeproot
   Veil keeps its target set and goes 20% -> 40% of DEF. Both undefined upgrades keep
   their target set — Inferno Gale is AoE like Ember Wing, Duskbreaker
   single-target like Greyveil — so the rule leaves only the doubling branch for
   them. It is also why the 60-70% AoE reduction is *not* applied to Torrent's
   Grace: that upgrade is bought with 15-20 battles of Favor, not with MP, and
   discounting it would turn a reward into a downgrade.
3. **"Heavy" means double.** One convention, stated once. It is what Thornveil's
   quantified upgrade does, and "Heavy" is the adjective used for both undefined
   upgrades and for Wild Card's three-item branch.
4. **A combo that fires a *damaging* constituent doubles its per-application
   magnitude.** Both shipped cases state the doubling themselves rather than
   inheriting it from a rule: Ambush Protocol says "2x normal Arc Trap damage",
   and Thornfire states its total as 40, split 20 Flame + 20 Storm over Ember
   Wing and Shock Coil. The rule is the generalisation of those two, and it is
   worth exactly that much. The unit matters: for a persistent device the
   doubled quantity is one tick (Shock Coil, 10 per tick); for a single-shot one
   it is the whole burst (Arc Trap, 30). The equal-AC budget argument that sets
   Arc Trap at 30 compares Shock Coil's *three-tick total* against Arc Trap's
   burst, which is a different quantity from the per-tick 10 that rule 4 doubles
   into Thornfire.

   Combos over **buff or utility** constituents do not double a magnitude; they
   extend a duration or bolt on a rider, and the shipped cases are unanimous.
   Forged Rampart leaves Bulkhead's 40% reduction untouched and buys 5 turns
   instead of 3 plus a 20% reflect; Spiritward leaves Stoneheart's immunity as
   immunity and buys 3 turns instead of 2 plus 20% damage reduction; Shield Oath
   buys 4 turns instead of 3 on both of its buffs. So rule 4 is not a universal
   law of combos, and nothing in this pass asks it to be — the only two values it
   carries, Shock Coil 10 and Ambush Protocol 60, are both damage.

#### Resolved values

| Ability | Character | Value | Rule |
|---------|-----------|-------|------|
| Shock Coil | Lira | Spell power 10 per tick, 3 ticks | 4 |
| Arc Trap | Lira | Spell power 30 | equal-AC budget |
| Ember Wing | Torren | Spell power 10 (AoE) | 4 (checked against 1) |
| Inferno Gale (Favor 3) | Torren | Spell power 20 (AoE) | 2, 3 |
| Dewfall | Torren | Spell power 12 (heal) | 1 |
| Torrent's Grace (Favor 3) | Torren | Spell power 12 (heal, all allies) | 2 |
| Greyveil | Torren | Spell power 28 | 1 |
| Duskbreaker (Favor 3) | Torren | Spell power 56 | 2, 3 |
| Rootsong | Torren | Spell power 12 per ally | stated equality with Dewfall |
| Convergence Chorus | Torren | 50% of each component (see table below) | stated 50% rule |
| Wild Card, 0-2 items | Sable | `ability_mult` 2.0 | stated "2x her Attack" |
| Wild Card, 3 items | Sable | `ability_mult` 3.0 | 3, capped by the ladder |
| Ambush Protocol | Sable + Lira | Spell power 60 | 4 |
| **Shiv, thrown-item branch** | Sable | **still open** | — |

#### Derivations

**Dewfall — spell power 12.** Dewfall is Mend plus Cleansing Draught in a single
action, and it is priced as the sum of the two: Mend (Tier 1 heal, single ally,
power 12, 3 MP) + Cleansing Draught (Tier 1, removes one negative status, 5 MP)
= 8 MP = Dewfall, and Torren learns all three. The MP buys the same heal and the
same cleanse; what the ability adds is the turn it saves, not extra output. So
the heal component is Mend's, **power 12**, and "moderate" means Tier 1 here
because Tier 1 is what 8 MP buys.
**Torrent's Grace** keeps that 12 and broadens to all allies, adding Sleep to the
cleanse (rule 2). Cross-check: Breath of the Wilds is the shipped Tier 1 all-ally
heal at power 8 for 6 MP, and Lifetide is the Tier 3 one at power 45 for 42 MP —
so a Favor 3 reward at power 12 for 8 MP is clearly better than a Tier 1 spell
and nowhere near a Tier 3 one, which is where it belongs.

**Rootsong — spell power 12 per ally.** The table already states the answer,
"same per-target potency as Dewfall"; this pass only writes it as a number. The
6 MP it costs over Torrent's Grace buys the party-wide Favor boost and removes
the Favor 3 prerequisite.

**Ember Wing — spell power 10.** Rule 4, with the MP ladder as a check that
agrees but does not decide. Thornfire (combo #4) is Ember Wing fired through
Lira's Shock Coil, and it is the only document that states a number for either
constituent: total spell power 40, split **20 Flame + 20 Storm**. The split is
Thornfire's own text, not an assumption of this pass. Rule 4 halves each side
back to the ability that supplied it, so the Flame half gives Ember Wing
**power 10** and the Storm half gives Shock Coil 10.

*Why the MP ladder cannot carry this on its own.* Ember Wing costs 10 MP, and
10 MP falls in the gap between magic.md's Tier 1 MP band (3-8) and its Tier 2
band (12-20) — priced on the plain band it lands in no tier at all. Running the
AoE MP *ratio* backwards (a 10 MP AoE implying a 5-6.7 MP single-target
counterpart, i.e. Tier 1) is reasoning by analogy outside the nine same-tier
pairs magic.md binds that ratio to, per rule 1, so it is a corroboration and is
labelled as one. Taken that way it agrees: the shipped 5 MP Tier 1 attack spells
are Linebolt (power 15) and Arc Snap (16), and the 60-70% AoE reduction puts an
AoE counterpart in the window 9-11.2, which contains 10 — and 10 sits mid-band
in the Tier 1 AoE range of 7-14 that `game/tests/test_spell_balance.gd` already
enforces for spells. Tier 2 is ruled out by price from either direction: the
shipped Tier 2 AoE *attack* spells cost 22-25 MP (Scorch Sweep, Whiteout and
Quake Stride at 22 up to Ley Storm at 25), and the cheapest Tier 2 AoE spell of
any kind is 12 MP. Neither is 10. The window brackets Thornfire's answer; it
does not select it, because 9, 10 and 11 all sit inside it.
**Inferno Gale** doubles to **power 20** (rules 2 and 3), which lands inside the
Tier 2 AoE band of 18-28 that [magic.md](magic.md) § Spell Balance Guidelines
gives, at unchanged MP. The upgrade is worth exactly one tier, which is what
15-20 battles of Favor should buy.

**Shock Coil — spell power 10 per tick.** The Storm half of Thornfire's stated
40, halved back by the same rule-4 step that gives Ember Wing its 10 (above).
Thornfire is the input for both values and the MP ladder is the check on both,
not the other way round. Over three turns the device delivers 30 power for 2 AC,
spread across random targets.

**Arc Trap — spell power 30.** Both of Lira's damage devices resolve through the
*magic* formula: Shock Coil's entry says outright that its damage scales with
Lira's Magic stat, and Arc Trap is budgeted directly against it below, so a
spell power is the right unit for both. Their Flame and Storm elements are
therefore applied by the magic formula's `element_mod`; combat-formulas.md
§ Physical Elemental Attacks used to list Arc Trap and no longer does.
Arc Trap and Shock Coil cost the same 2 AC out of
the same 12 AC pool, so they get the same output budget: Shock Coil's
3 x 10 = **30**, delivered as one burst instead of three ticks. The trade is
even. The burst and the Speed debuff are paid for with conditionality — the trap
only fires when an enemy uses a *physical* attack, so against an all-caster group
it never fires at all — and with the device slot it occupies (one of two) until
it does. As a loose sanity check, 30 sits just above the floor of the Tier 2
single-target band (28-40), which suits a level 12 unlock on the Tier 1/2
boundary — but only as a sanity check: rule 1 keeps AC-costed abilities off the
MP ladder entirely, so the band carries no weight in the derivation. The
equal-2 AC budget argument carries it alone.
**Ambush Protocol** follows from rule 4 and the combo's own text: **60**. That
is mid-band Tier 3 for 8 MP, the cheapest combo in the table — but it costs two
ATB gauges and one stolen Forgewright component, and it is single-target where
Thornfire (40, 16 MP) hits the whole group with guaranteed Burn.

**Greyveil — spell power 28.** Rule 1 puts 14 MP in Tier 2, band 28-40. The
shipped 14 MP single-target spells that carry a spell power are Rootgrip (30),
Hoarfall (32) and Kindlepyre (32), so 30-32 is the parity point. (Five more
spells cost 14 MP and target one unit — Purge, Quickstep, Attunement,
Dispersion and Dampening Field — but they heal, buff or debuff and state no
power, so they are not comparators here.) Greyveil then adds one advantage
and takes one disadvantage: it ignores MDEF, and it is non-elemental, so it can
never be resisted — but it also can never take the 1.5x weakness bonus its
14 MP peers can. The MDEF ignore is worth roughly 2 power at the documented
milestones (at MAG 146 against MDEF 60, power 32 minus MDEF equals power 30.4
with MDEF ignored), and forfeiting the elemental multiplier costs more than that.
Netting the two riders against a 30-32 comparator puts Greyveil at the floor of
its band: **power 28**.
**Duskbreaker** doubles to **power 56** (rules 2 and 3), which sits at the low
end of the Tier 3 band (50-70) — the same one-tier step Inferno Gale takes. The "2x damage if the target
is Pallor-corrupted" clause is a separate rider stated in the same cell, so
against a Pallor target Duskbreaker resolves at an effective 112. That is
deliberate: this document calls Greyveil "the most effective tool the party has
against Pallor-type enemies". It is also the hottest number this pass produces,
and it is the first knob to turn if the Pallor-heavy back half of Act III plays
too easy.

**Convergence Chorus — 50% of each component.** The ability states a rule rather
than magnitudes: every spirit acts "at 50% normal potency". With the components
now numeric, the rule resolves. **50% halves the ability's one quantity** — its
magnitude where it has one, its duration where a duration is all it has — and
the Chorus applies each component to the whole party or the whole enemy group by
definition, which is what makes the single-target components read as "AoE".

| Component | Spirit | Base Spiritcall | In Convergence Chorus | With that spirit at Favor 3 |
|-----------|--------|-----------------|-----------------------|-----------------------------|
| AoE damage | Flame | Ember Wing, power 10 | Power 5, all enemies | Power 10 (Inferno Gale 20) |
| AoE heal | Rain | Dewfall, power 12 | Power 6, all allies, cleanses Poison | Power 6, also cleanses Sleep |
| Party barrier | Briar | Thornveil, counter 20% of DEF | Counter 10% of DEF, 3 turns | Counter 20% of DEF (Deeproot Veil 40%) |
| Status immunity | Earth | Stoneheart, 2 turns | 1 turn | 1 turn, already party-wide |

The Rain row is the same number in both columns because Dewfall's Favor 3
upgrade broadens rather than doubles (rule 2) and the Chorus has already
broadened it; Favor 3 adds only the Sleep cleanse.

*Which four spirits — a choice, not a derivation.* The shipped cell read "all
known spirits", which is roster-relative; this pass names Briar, Rain, Flame and
Earth. Two things push that way: the four effects the cell itself lists map
one-to-one onto those four, using each spirit once; and a fixed roster keeps a
20 MP once-per-battle ability stable in cost and output, where "all known
spirits" inflates it every time Torren learns another. *The alternative is
real.* Keep the roster-relative reading and add Twilight as a fifth component at
50% of Greyveil's 28 — power 14 of single-target, MDEF-ignoring damage. It is
rejected because that effect is not among the four the cell names and because an
ability that grows without bound is the harder one to balance, but it is the
first thing to revisit if the Chorus reads as too weak late.

*Reading the cell's "cleanse" is also a choice.* The shipped cell listed "status
cleanse" as its fourth effect. Read strictly, a cleanse removes statuses the
party already has; Earth's contribution, halved from Stoneheart, is *immunity*,
which prevents new ones and does nothing for a party that is already Silenced or
Blinded. This pass reads the single word as covering what the named spirits
between them actually supply — Rain's Poison removal, a real cleanse and kept in
the effect text, plus Earth's immunity — rather than inventing a fifth,
source-less cleanse component. The alternative is to keep a general cleanse and
name the spirit that supplies it, which the roster does not contain. Stated
plainly so it is not missed: against the shipped wording this **narrows** what
the Chorus does for an already-statused party, and it is the second thing to
revisit if the ability underperforms.

*If a component spirit is not yet learned.* Greyveil and Stoneheart carry level
floors that the Chorus does not — Interlude [S] at Lv 20+ and Lv 16+ against the
Chorus's bare story trigger — so a Torren who reaches the nexus below Lv 16 has
the Chorus without Stoneheart, and the Earth component would have no source
ability to take 50% of. **A component whose source Spiritcall is not yet learned
is skipped**, and the four-row table above is the fully-unlocked case. One rule
covers both spirits that can be missing, and it needs no new number.

*Sanity check on the 20 MP.* Each component is far below a Tier 2 spell —
power 5 and 6 against Whiteout's 24 and Sanctuary's 22. The 20 MP buys breadth
and a saved turn, not power, which is exactly what "50% normal potency" plus
"once per battle" describes. It also settles the question the physical
multiplier table used to raise: Convergence Chorus deals no physical damage at
all and is nowhere near a 3.0 ATK ultimate. See
[combat-formulas.md](combat-formulas.md) § Physical Ability Multiplier Tiers.

**Wild Card — `ability_mult` 2.0, rising to 3.0 at three items.** The 0-item
branch already states its magnitude, "physical damage equal to 2x her Attack",
which is `ability_mult` 2.0 in [combat-formulas.md](combat-formulas.md)
§ Physical Ability Multiplier Tiers — the tier that document labels "Ultimate
skill", which is what Wild Card is. (Read as flat arithmetic instead, `2 x ATK`
would be about 300 damage at level 70 — against the ~3,700 that same document
quotes for Sable's *basic* Shiv at the same level — so the multiplier reading is
the only one consistent with the rest of it.) The item branches then read as
follows — and the 1-item branch is a **choice**, not a derivation, flagged as
such below:

- **1 item:** 2.0 against all enemies, carrying the thrown item's element.
  Physical attacks can carry an element — combat-formulas.md § Physical
  Elemental Attacks defines that pipeline, with Lira's Overcharge and elemental
  weapons as the shipped cases.
- **2 items:** as above, plus one random debuff on all enemies.
- **3 items:** "heavy". By rule 3 that is double, but 4.0 is off the top of the
  ladder, so the branch takes the highest tier the ladder defines: **3.0**, which
  combat-formulas.md reserves for "abilities with extreme costs". Emptying the
  entire three-item Stolen Goods pool on a 5-turn cooldown is that cost, and it
  gives that tier a second shipped exemplar alongside Sever Bond.

*The 1-item branch is a choice.* The shipped text read "1 item: adds the item's
element as AoE damage", and "adds" admits the same two shapes Shiv's throw does:
**(a)** the strike itself becomes elemental and AoE at the unchanged 2.0, or
**(b)** the 2.0 single-target strike keeps its shape and a second, separate
elemental AoE hit is added on top. This pass takes **(a)** — the same reading it
recommends for Shiv — because (b) needs a magnitude for the second hit that no
document states, and inventing one is exactly what this pass is trying not to do.
The cost of (a) is real and should be named: single-target -> all-enemies at an
unchanged 2.0 for 10 MP is a large swing, and it is the first thing to revisit if
Wild Card plays too strong. Unlike Shiv, the branch is not left open, because
`target: all_enemies` was already shipped in `game/data/abilities/sable.json` and
(b) would contradict it; the entry's `target` field records the item branches,
and the 0-item branch is the single-target exception stated in the effect text.

What is *not* settled here is which element a given stolen item confers. That is
the same missing item-type -> element mapping that blocks Shiv's throw branch,
and it is one decision covering both.

**Shiv's thrown-item branch — left open**, tracked as
[#359](https://github.com/gcko/pendulum-of-despair/issues/359). The base attack is fully specified
(`ability_mult` 1.0 plus 50% DEF ignore, combat-formulas.md § Special: Shiv).
The throw is not, and it cannot be derived, because two independent decisions
are missing and neither is implied by anything already written:

1. *The mapping.* "Element depends on item type", but no document maps
   [items.md](items.md)'s consumables, materials and steal-only drops onto the
   six elements. Wild Card's item branches need the same mapping.
2. *The shape of the bonus.* "Throw it for bonus elemental damage" admits at
   least three readings, and they are not close to equivalent. **(a)** The throw
   re-elements the existing Shiv hit, changing `element_mod` and nothing else.
   **(b)** The throw adds a second, separate elemental hit at its own magnitude.
   **(c)** The throw raises Shiv's multiplier for that one use.

   **Recommendation: (a).** It is the only reading that keeps a 0 MP, one-turn
   cooldown ability from becoming Sable's best damage button; it needs no new
   number at all once the mapping exists; and it fits what is being described —
   Sable throwing a stolen bottle, not casting a spell. But (a) versus (b)
   changes how Sable plays across the whole game, and that call belongs to a
   pass with the item tables open, not to a documentation reconciliation. The
   entry stays open rather than taking an invented number.

   Wild Card's item branches face the same (a)/(b) fork and this pass *does*
   settle theirs, on reading (a) — see the Wild Card derivation above. The two
   are treated differently for one reason: Wild Card's shipped `target` field
   already says `all_enemies`, so (b) would contradict data that exists, while
   Shiv's says `single_enemy` and is consistent with either reading. Whichever
   pass closes Shiv should confirm Wild Card at the same time.
