# Bestiary Act III Design Spec (Gap 1.3, Sub-project 3a)

> **Scope:** Act III enemy bestiary — Pallor Wastes, The Convergence,
> Ley Line Depths F5, Dry Well F5–7, Forgotten Forge (secret dungeon),
> Overworld Act III, and Vaelith's combat encounters.
>
> **Target:** ~65 enemies (50 regular + 15 bosses/mini-bosses)
>
> **Files requiring changes:**
> - `docs/story/bestiary/act-iii.md` — Rewrite (from TBD)
> - `docs/story/bestiary/palette-families.md` — Update Tier 3/4 entries
> - `docs/story/bestiary/CONTINUATION.md` — Update Sub-project 3a status
> - `docs/story/bestiary/README.md` — Update index
> - `docs/analysis/game-design-gaps.md` — Check off Act III items

---

## 1. Design Pillars

### 1.1 Pallor Gradient

Corruption intensifies from the world's edges to the Convergence at
its center. Enemy composition shifts along this gradient:

| Zone | Pallor % | Tone |
|------|----------|------|
| Overworld safe zones (near towns) | ~20% | Desperate but recognizable |
| Overworld grey zones | ~80% | The world under the Grey |
| Pallor Wastes outer | ~50% | Corrupted familiar |
| Pallor Wastes inner + trials | ~80% | Pallor-born, alien |
| Ley Line Depths F5 | ~30% | Ley energy resists Pallor |
| Dry Well F5–7 | ~40% | Ancient builders, ley-warped |
| Forgotten Forge | ~50% | Ancient Constructs + leaked despair |
| The Convergence | ~90% | Pure Grey, ground zero |

### 1.2 Despair as Deformation

Pallor variants are NOT recolors. Each corruption is unique to what
that creature despaired about:

- A Pallor Wolf's legs fuse because pack hunters despair at isolation
- A Pallor Boar's tusks merge into one horn — it's forgotten how to stop
- A Hollow Walker is featureless because despair erased all identity
- A Grief Shade mimics party members because it craves the identity it lost

By Act III, Pallor corruption is visibly deforming — bodies twisted,
joints bent wrong, forms losing coherence. The Grey is not just a
visual metaphor but a metaphor for despair, which manifests in many
different forms.

### 1.3 Hope as the Key

Every trial boss presents overwhelming despair with a solvable puzzle.
The solution always involves a form of hope:

- The Crowned Hollow yields to endurance (Defend, don't attack)
- The Perfect Machine yields to acceptance (Dismantle, don't repair)
- The Last Voice yields to release (free it, don't fight it)
- The Open Door yields to courage (walk back, don't walk through)
- The Index yields to grief (read one entry, don't absorb or destroy)

The Grey Cleaver Unbound rewards fighting *through* despair — Despaired
party members deal bonus damage during its shield stance.

### 1.4 No New Families

Act III introduces zero new palette-swap families. The world is ending,
not diversifying. All family enemies are Tier 3/4 endpoints of existing
families. New unique enemies (Hollow Walker, Grief Shade, etc.) are
Pallor-born entities with no family lineage.

---

## 2. Level Ranges

Per README.md:

| Area | Enemy Level Range |
|------|-------------------|
| Overworld safe zones | 28–32 |
| Overworld grey zones | 32–35 |
| Pallor Wastes outer | 28–30 |
| Pallor Wastes inner + trials | 30–32 |
| Pallor Wastes bosses | 30–34 |
| Ley Line Depths F5 | 26–28 |
| Dry Well F5–7 | 30–36 |
| Forgotten Forge | 32–36 |
| The Convergence regular | 32–36 |
| The Convergence bosses | 34–40 |
| Vaelith (Siege, unwinnable) | 150 (scripted) |

> **Note:** README.md lists Act III enemy range as 30–45. Some
> transitional areas (Ley Depths F5 at 26–28, Pallor Wastes outer
> at 28–30, Overworld safe at 28–32) start below 30. These bridge
> the Interlude→Act III gap. README.md range should be updated to
> 26–45 during implementation.

---

## 3. Cursed Weapon Quest: Grey Cleaver → Pallor's End

An homage to FF6's Cursed Shield (256 battles to purify into the
Paladin's Shield). The Grey Cleaver is found in the Forgotten Forge,
a secret 5-floor dungeon beneath the Dry Well of Aelhart.

### 3.1 The Forgotten Forge

**Access:** Hidden builder's seal on Dry Well Floor 7. Requires the
Archivist's Codex (from Archive of Ages) to decipher.

**Theme:** Ancient ley-forging facility where pre-Pallor builders
experimented with weaponized despair. The Grey Cleaver was their
greatest failure — a weapon that absorbed despair instead of
channeling ley energy. The last master builder sealed themselves
inside the forge rather than let their creation escape.

**Floors:** 5 (linear descent into the forge depths)

| Floor | Theme | Enemies |
|-------|-------|---------|
| 1–2 | Entry halls, dormant security | Forge Sentinel, Tempered Construct |
| 3 | Failed experiments wing | Slag Elemental, Grief Residue |
| 4 | Worker quarters | Hollow Smith, Grief Residue |
| 5 | The Anvil Vault (boss arena) | The Architect's Regret (2-stage) |

### 3.2 Boss: The Architect's Regret

**Stage 1: The Architect (Lv 34, 20,000 HP, Construct)**

The last master builder, fused with their forge equipment. A ghost
trapped in a machine.

- 3 Ley Anvils (2,000 HP each) act as shields. Each absorbs one
  element (Flame, Storm, Frost). Attack an anvil with its matching
  element to overload and destroy it. Destroy all 3 to break the
  Architect's damage reduction.
- While shielded: 50% damage reduction. Summons Forge Construct adds.
  Attacks: Hammer Strike (heavy single-target), Molten Spray
  (party-wide Flame), Precision Cut (high crit chance).
- Unshielded: full damage, enraged. Faster attacks, no more summons.

**Stage 2: The Grey Cleaver Unbound (Lv 36, 25,000 HP, Pallor)**

The weapon awakens — concentrated despair of centuries given form.

- Cycles between 3 weapon stances (changes every 3 turns):
  - **Greatsword:** Heavy single-target physical. Highest ATK.
  - **Whip:** Party-wide attacks. Lower damage + Despair chance.
  - **Shield:** Counter mode. Reflects all damage. BUT — party
    members with Despair deal bonus damage (+50%) during this
    stance. Despair recognizes despair.
- Periodically casts **Weight of Ages** — party-wide Despair.
- The key: Don't cure Despair during shield stance. Attack through
  it. Players who learn this deal massive damage in the window.

### 3.3 The Grey Cleaver (Torren-exclusive greatsword)

**Tainted form:**
- ATK +15 (mediocre for Act III)
- DEF -10, MDEF -10, SPD -10
- Inflicts Despair on Torren at battle start
- Weak to all elements while equipped
- Cannot be sold or discarded

**Purification condition:**
- Win 100 encounters against Pallor-type enemies with Grey Cleaver
  equipped on Torren
- Counter does NOT reset if unequipped (per FF6 Cursed Shield rules)
- Torren must be alive when battle is won (KO'd doesn't count)
- Counter is tracked per-weapon, not per-character

**Purified form — Pallor's End:**
- ATK +55 (best greatsword in the game)
- Spirit element on all attacks
- +50% damage vs Pallor-type enemies
- Grants Despair immunity to Torren
- Absorbs Spirit element
- The weapon that learned to turn despair into strength

---

## 4. Enemy Roster by Area

### 4.1 Pallor Wastes — Outer Sections (Lv 28–30)

The corrupted familiar. Things players fought before, now deformed
by despair.

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Pallor Boar | Boar | 3 | 28 | Pallor | Rare | Tank |
| Shadow Wolf | Wolf | 3 | 28 | Beast | Standard | Glass cannon |
| Pallor Vermin | Vermin | 4 | 30 | Pallor | Standard | Swarm |
| Wraith Shade | Shade | 3 | 30 | Spirit | Standard | Caster |
| Hollow Walker | — (unique) | — | 28 | Pallor | Standard | Balanced |
| Despair Cloud | — (unique) | — | 28 | Pallor | Low | Caster |
| Petrified Beast | — (unique) | — | 30 | Pallor | Standard | Tank |
| Dread Warden | Warden | 3 | 30 | Undead | Standard | Tank |

**Design notes:**
- Hollow Walker is the iconic Pallor Wastes enemy — featureless grey
  humanoid, HP drain. Appears in every section.
- Despair Cloud is low threat individually but inflicts party-wide
  Despair. Priority target in mixed encounters.
- Shadow Wolf is Beast type (not yet Pallor) — still fighting the
  Grey. Fur matted into spines, moves in jerky bursts. Early
  deployment at Lv 28 (projected Lv 33 in palette-families.md).
- Pallor Boar: tusks fused into a single horn of grey bone. Charges
  blindly — it's forgotten how to stop.

### 4.2 Pallor Wastes — Inner Sections + Trial Clearings (Lv 30–32)

The shift toward Pallor-born — things that never existed before the
Grey.

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Pallor Knight | — (unique) | — | 32 | Pallor | Dangerous | Balanced |
| Grief Shade | — (unique) | — | 32 | Pallor | Dangerous | Caster |
| Void Wisp | Wisp | 3 | 30 | Elemental | Standard | Caster |
| Pallor Treant | Treant | 3 | 30 | Pallor | Standard | Tank |
| Marauder Captain | Bandit | 3 | 30 | Humanoid | Standard | Balanced |

**Design notes:**
- Pallor Knight is a premium encounter (Dangerous threat). Armored
  figure from a past age — warriors consumed centuries ago.
- Grief Shade mimics party member silhouettes and uses weakened
  versions of party abilities. Fighting your own shadow.
- Marauder Captain: a bandit leader who led their crew into the
  Wastes seeking treasure. Still gives orders to followers who are
  no longer there.

### 4.3 Pallor Wastes — Trial-Specific Enemies

Each trial has unique enemies that embody that trial's despair theme.
These appear ONLY within their trial clearing.

| Name | Trial | Lv | Type | Threat | Notes |
|------|-------|----|------|--------|-------|
| Hollow Knight | 1 (Crowned Hollow) | 30 | Pallor | Standard | Fight in formation. Reform unless the Crowned Hollow's crown is targeted. 1,000 HP each per dungeons-world.md. |
| Unfinished Construct | 2 (Perfect Machine) | 30 | Construct | Low | Beg to be repaired. "Healing" them spawns more. The trap of trying to fix everything. |
| Stone Spirit | 3 (Last Voice) | 30 | Spirit | Standard | Petrified nature spirits. Cannot speak. Attack with silence — literally cast Silence. |
| Shadow of Sable | 4 (Open Door) | — | Pallor | — | Non-combat trial. Copies using Sable's Tricks moveset. Fast, evasive. No stat block needed. |
| Archived | 5 (The Index) | 32 | Pallor | Standard | Humanoid figures of compressed pages. Attack by reciting facts about how things died. |

### 4.4 Pallor Wastes — Bosses

**Trial Bosses (hybrid stat block + special rules):**

| Name | Lv | HP | Type | Weakness | Resistance | Special Mechanic |
|------|----|----|------|----------|------------|-----------------|
| The Crowned Hollow | 30 | 8,000 | Boss | Spirit (150%) | Physical (75%) | Phase 2: invulnerable. Edren must Defend 3 consecutive turns to end the fight. Summons Hollow Knights. |
| The Perfect Machine | 30 | 7,000 | Boss | Void (150%) | Flame (75%) | "Healing" it adds HP and triggers counterattacks. Lira's Dismantle command is the key. |
| The Last Voice | 32 | 6,000 | Boss | Flame (150%) | Spirit (50%) | Petrified forest spirit. Silence-based attacks. Torren's Spiritcall Release command is the key — freeing the spirit, not fighting it. |
| The Open Door | — | — | — | — | — | Non-combat. Sable faces shadows. Choosing to walk through ends the trial. |
| The Index | 32 | 7,000 | Boss | Spirit (150%) | Void (50%) | Catalogues of death. Maren must Read One Entry — grieve for one person instead of absorbing/destroying the whole catalogue. |

**Vaelith, the Ashen Shepherd:**

| Phase | Lv | HP | Type | Weakness | Resistance | Immunity |
|-------|----|----|------|----------|------------|----------|
| Pre-fight (10-attack threshold) | 34 | Invulnerable | Boss | — | — | All damage = 0 |
| Phase 1 (ancient magic) | 34 | 50,000–25,000 | Boss | Spirit (125%) | Void (50%), Frost (75%) | Despair, Death |
| Phase 2 (Pallor-fueled) | 34 | 25,000–0 | Boss | Spirit (125%) | Void (50%) | Despair, Death |

Per dungeons-world.md: 800-year-old champion of Despair from the
previous Pallor cycle. Pre-fight phase mirrors the unwinnable Valdris
siege encounter — party attacks deal 0 damage. Vaelith attacks 10
times with taunting dialogue. Lira's weapon-forging cutscene breaks
the invulnerability.

Phase 1: ancient scholar magic (Flame, Frost, Void). Phase 2: pure
Pallor abilities (Grey Shockwave, Despair Aura, Ashen Command).

**Vaelith — Unwinnable Siege Encounter (Act II):**

| Lv | HP | Type | Notes |
|----|----|------|-------|
| 150 | 999,999 | Boss | Scripted loss. Party attacks deal 0–1 damage. Vaelith attacks with full power (kills in 2–3 hits). After ~5 party turns, cutscene triggers — party wakes in siege aftermath. |

Stat block exists for completeness. All immunities. The encounter
demonstrates Vaelith's overwhelming power before the party earns
the ability to fight back in Act III.

### 4.5 The Convergence — Regular Enemies (Lv 32–36)

Ground zero. The Grey at full power. Almost entirely Pallor-born or
Tier 4 Pallor variants.

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Pallor Soldier | Soldier | 4 | 34 | Pallor | Standard | Balanced |
| Pallor Drake | Drake | 4 | 36 | Pallor | Rare | Dangerous |
| Ley Construct | — (existing) | — | 34 | Construct | Standard | Balanced |
| Forgewright Automaton | Automata | 3 (biome variant) | 34 | Construct | Standard | Tank |
| Corrupted Spirit | — (unique) | — | 34 | Spirit | Standard | Caster |
| Ashen Serpent | Serpent | 4 | 34 | Pallor | Standard | Glass cannon |
| Pallor Lurker | Lurker | 4 | 36 | Pallor | Standard | Balanced |

**Phase 4: The Door (survival gauntlet):**

| Wave | Composition | Notes |
|------|-------------|-------|
| 1 | 6 Hollow Walkers | Overwhelming numbers. Party-wide Despair stacks. |
| 2 | 4 Despair Clouds + 2 Pallor Knights | Clouds debuff, Knights punish. Triage decisions. |
| 3 | 3 Grief Shades (mimicking Edren, Lira, Torren) | Uses party abilities against you. |
| 4 | 1 Pallor Echo (mini-boss, 5,000 HP) | Preview of the Pallor's full power with a complete identity. |

**Design notes:**
- Ley Construct and Forgewright Automaton are Constructs — immune to
  Pallor infection. Still running on pre-Pallor orders, attacking
  everything.
- Pallor Drake: wings fused, can't fly. Drags itself forward. Breath
  weapon is pure grey mist. Rare encounter.
- Corrupted Spirit: what spirits become when ley energy itself turns
  grey. Not infected — transformed at the source.
- Pallor Drake, Ashen Serpent, and Pallor Lurker are bestiary
  expansions beyond dungeons-world.md's Convergence encounter table,
  which only names the first 4 enemies + Pallor Wastes enemies.

### 4.6 The Convergence — Bosses (Lv 34–40)

Per dungeons-world.md encounter tables and boss descriptions.

| Name | Lv | HP | Type | Notes |
|------|----|----|------|-------|
| Pallor Echo | 34 | 5,000 | Boss | Mini-boss. Phase 4 wave finale. A complete identity consumed by the Grey. |
| Cael, Knight of Despair (Phase 1) | 36 | 45,000 | Boss | Enhanced party abilities. Counters whoever attacked last. Moments of lucidity — attacks falter when he remembers. |
| Cael, Knight of Despair (Phase 2) | 38 | 35,000 | Boss | Full Pallor. No hesitation. Faster, less precise, more dangerous. The friend is gone. |
| The Pallor Incarnate | 40 | 70,000 | Boss | 4 conduit crystals (3,000 HP each, 500 HP/turn regen each). The Grey itself given form. |

**Cael Phase 1 scripted thresholds (per dungeons-world.md):**
- 75% HP: Despair Pulse (party-wide Despair debuff)
- 50%: Shadow Step (disappears, reappears behind random party member, critical strike)
- 25%: "I'm doing this for you" — brief invulnerability during dialogue
- 0%: Pallor surges through him. Phase 2 begins.

**Cael Phase 2:**
- Raw Pallor aggression. No more calculated counters.
- Grey Shockwave (party-wide), Pallor Surge (single-target massive),
  Void Crush (ignores DEF).

**The Pallor Incarnate:**
- 4 conduit crystals must be destroyed to stop regen (4 × 500 = 2,000
  HP/turn while all active).
- Attacks: Grey Tide (party-wide), Convergence Beam (single-target,
  highest current HP), Despair Absolute (party-wide Despair + stat
  reduction), Void Collapse (massive party-wide at <25% HP).

### 4.7 Ley Line Depths Floor 5: The Ley Confluence (Lv 26–28)

The deepest ley chamber. Raw energy crystallized into living forms.
Ley energy resists Pallor — this area is less corrupted than the
surface above.

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Ley Construct | — (existing) | — | 26 | Construct | Standard | Balanced |
| Vein Stalker | — (unique) | — | 28 | Humanoid | Rare | Glass cannon |
| Confluence Elemental | Elemental | 3 | 28 | Elemental | Standard | Caster |

**Design notes:**
- Ley Construct returns from F1–3 at higher level. Rotating
  physical/magic phases on 3-turn cycle.
- Vein Stalker: eyeless humanoid of solidified ley residue. Phases
  through walls, drains MP. Rare encounter.
- Confluence Elemental: living ley vortex. Casts rotating element
  cycle (Flame→Frost→Storm→Earth). Absorbs element just cast, weak
  to NEXT element in cycle. A puzzle enemy — players track the cycle.

**Boss:**

| Name | Lv | HP | Type | Notes |
|------|----|----|------|-------|
| Ley Titan | 28 | 18,000 | Boss | Three-phase: brute force (100–60%), fractures into 3 Ley Aspects (60–30%), reforms into fast dense form (30–0%). |

Ley Aspects: Strength (physical), Precision (targeted beams),
Endurance (heals/shields). Kill order matters — Endurance first
prevents healing, Precision first prevents burst damage.

### 4.8 Dry Well of Aelhart Floors 5–7 (Lv 30–36)

Ancient builder chambers. Ley experiments gone wrong. Constructs
running corrupted programs, ley energy warping reality.

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Crystal Warden (Deep) | Guardian | 3 (biome variant) | 30 | Construct | Standard | Tank |
| Pictograph Wisp | Wisp | 3 | 30 | Elemental | Standard | Caster |
| Ley-Warped Construct | Automata | 3 | 32 | Construct | Standard | Balanced |
| Warp Sentinel | Sentry | 3 | 32 | Construct | Standard | Balanced |
| Ley-Born Echo | — (unique) | — | 34 | Spirit | Standard | Caster |

**Design notes:**
- Crystal Warden (Deep): deeper version of earlier Crystal Wardens.
  Crystalline armor that regenerates.
- Pictograph Wisp: ghostly text fragments — builders' records given
  form. Casts by "reading" attack descriptions aloud.
- Ley-Warped Construct: automaton whose ley core overloaded.
  Glitching between functions — attacks with tools, mining drills,
  structural beams. Unpredictable.
- Warp Sentinel: ancient security. Teleports short distances, fires
  precision ley beams.
- Ley-Born Echo: not a ghost — a ley imprint of a person who died
  here. Repeats their last moments.

**Bosses:**

| Name | Lv | HP | Type | Notes |
|------|----|----|------|-------|
| Archive Keeper | 32 | 3,000–12,000 (variable) | Boss | Mini-boss. HP scales inversely with Builder Tablets collected — knowledge is the key. |
| Wellspring Guardian | 36 | 28,000 | Boss | Three-phase: Test of Arms (100–60%), Test of Knowledge (60–30%, translation challenge), Test of Resolve (30–0%, Builder's Weight Despair stacking debuff). |

### 4.9 The Forgotten Forge (Secret Dungeon, Lv 32–36)

5 floors beneath the Dry Well. Ancient ley-forging facility where
builders experimented with weaponized despair.

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Forge Sentinel | Sentry | 3 | 32 | Construct | Standard | Tank |
| Tempered Construct | Guardian | 3 | 34 | Construct | Standard | Balanced |
| Slag Elemental | Elemental | 3 | 34 | Elemental | Standard | Caster |
| Grief Residue | — (unique) | — | 34 | Pallor | Standard | Caster |
| Hollow Smith | — (unique) | — | 34 | Pallor | Standard | Balanced |

**Design notes:**
- Forge Sentinel: larger than the Warp Sentinels. Ley-powered shield
  generator — absorbs one element per turn, cycling.
- Tempered Construct: builder war machine sealed for centuries.
  Attacks with superheated ley-infused arms. Still following its
  last order: "let no one reach the vault."
- Slag Elemental: molten ley waste given form. Failed forging
  experiment runoff. Absorbs Flame, weak to Frost.
- Grief Residue: the despair the Grey Cleaver absorbed over
  centuries, leaked into the forge air. Formless, poisonous.
  Inflicts Despair and drains MP.
- Hollow Smith: forge workers who couldn't leave. Grey imprints
  hammering at empty anvils. They don't know they're dead.

**Boss: The Architect's Regret** — see Section 3.2 for full details.

### 4.10 Overworld Act III — Safe Zones (Lv 28–32)

Near surviving towns (Bellhaven, The Pendulum). Tier 3 family enemies
displaced by the Grey — desperate, aggressive, not yet corrupted.

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Thunder Drake | Drake | 3 | 30 | Beast | Dangerous | Dangerous |
| Deserter Captain | Soldier | 3 | 30 | Humanoid | Standard | Balanced |
| Blight Leech | Leech | 3 | 30 | Beast | Dangerous | Caster |
| Void Moth | Moth | 3 | 30 | Elemental | Standard | Caster |
| Storm Wraith | Wraith | 2 | 30 | Spirit | Standard | Caster |
| Roc | Hawk | 3 | 32 | Beast | Rare | Dangerous |

**Design notes:**
- Thunder Drake: storm-charged, driven from mountain roosts by the
  Grey. Attacks anything near its new territory.
- Deserter Captain: deserters from Valdris and Carradan armies. No
  allegiance left — just survival.
- Roc: massive raptor. Rare overworld encounter. Swoops from above —
  preemptive strike chance for the enemy.

### 4.11 Overworld Act III — Grey Zones (Lv 32–35)

Approaching the Convergence. Pallor Tier 4 variants and Pallor-born.
The closer to the Convergence, the higher the encounter rate.

| Name | Family | Tier | Lv | Type | Threat | Role |
|------|--------|------|----|------|--------|------|
| Pallor Revenant | Dead | 4 | 34 | Pallor | Standard | Balanced |
| Pallor Wolf | Wolf | 4 | 34 | Pallor | Standard | Glass cannon |
| Pallor Crawler | Crawler | 4 | 34 | Pallor | Standard | Balanced |
| Pallor Wraith | Wraith | 4 | 34 | Pallor | Standard | Caster |
| Pallor Roc | — (unique) | — | 34 | Pallor | Rare | Dangerous |
| Void Crystal | Crystal | 3 | 32 | Elemental | Standard | Caster |

**Design notes:**
- Pallor Wolf: pack hunters with fused legs, jaw split into three.
  Fast, vicious. Despair manifests as loss of pack identity.
- Pallor Revenant: arms too long, joints bent wrong. Not undead —
  Pallor. The dead risen by grey energy.
- Pallor Roc: a Roc consumed by the Grey. Wings fused into grey
  membranes. Rare, powerful.
- Void Crystal: ley crystals corrupted by proximity to Convergence.
  Static encounter — visible on overworld, avoidable.

---

## 5. Palette Family Updates

### 5.1 Existing Families Gaining Tier 3 Entries

These families gain their projected Tier 3 variants in Act III:

> **Tier 2 early deployment:** Storm Wraith (Wraith Tier 2, Lv 30 vs
> projected Lv 32) also deploys in Act III overworld safe zones.

| Family | Tier 3 Name | Lv | Type | Location |
|--------|-------------|----|------|----------|
| Drake | Thunder Drake | 30 | Beast | Overworld safe |
| Leech | Blight Leech | 30 | Beast | Overworld safe |
| Moth | Void Moth | 30 | Elemental | Overworld safe |
| Hawk | Roc | 32 | Beast | Overworld safe (rare) |
| Shade | Wraith Shade | 30 | Spirit | Pallor Wastes outer |
| Warden | Dread Warden | 30 | Undead | Pallor Wastes outer |
| Wisp | Void Wisp | 30 | Elemental | Pallor Wastes inner |
| Treant | Pallor Treant | 30 | Pallor | Pallor Wastes inner |
| Bandit | Marauder Captain | 30 | Humanoid | Pallor Wastes inner |
| Crystal | Void Crystal | 32 | Elemental | Overworld grey |
| Elemental | Confluence Elemental | 28 | Elemental | Ley Confluence |
| Sentry | Forge Sentinel | 32 | Construct | Forgotten Forge |
| Sentry | Warp Sentinel | 32 | Construct | Dry Well F6 |
| Guardian | Tempered Construct | 34 | Construct | Forgotten Forge |
| Elemental | Slag Elemental | 34 | Elemental | Forgotten Forge |
| Wisp | Pictograph Wisp | 30 | Elemental | Dry Well F5 |
| Guardian | Crystal Warden (Deep) | 30 | Construct | Dry Well F5 |
| Automata | Ley-Warped Construct | 32 | Construct | Dry Well F6 |
| Automata | Forgewright Automaton | 34 | Construct | Convergence |
| Soldier | Deserter Captain | 30 | Humanoid | Overworld safe |
| Boar | Pallor Boar | 28 | Pallor | Pallor Wastes outer (early deployment; projected Lv 36) |

### 5.2 Existing Families Gaining Tier 4 Entries

Pallor Tier 4 — the final corruption. Type changes to Pallor for
all except Construct families.

| Family | Tier 4 Name | Lv | Type | Location |
|--------|-------------|----|------|----------|
| Vermin | Pallor Vermin | 30 | Pallor | Pallor Wastes outer |
| Wolf | Pallor Wolf | 34 | Pallor | Overworld grey |
| Dead | Pallor Revenant | 34 | Pallor | Overworld grey |
| Crawler | Pallor Crawler | 34 | Pallor | Overworld grey |
| Wraith | Pallor Wraith | 34 | Pallor | Overworld grey |
| Drake | Pallor Drake | 36 | Pallor | Convergence (rare) |
| Serpent | Ashen Serpent | 34 | Pallor | Convergence |
| Lurker | Pallor Lurker | 36 | Pallor | Convergence |

### 5.3 Family Notes

- **Soldier family** gains Tier 3 (Deserter Captain, Humanoid) but
  Tier 4 (Pallor Soldier) was already deployed in the Interlude.
  The Convergence Pallor Soldier appears at the projected full-power
  level (Lv 34) rather than the early deployment level (Lv 26).
- **Sentry family** gains two Tier 3 biome variants: Warp Sentinel
  (Dry Well) and Forge Sentinel (Forgotten Forge).
- **Elemental family** gains two Tier 3 biome variants: Confluence
  Elemental (Ley Depths) and Slag Elemental (Forgotten Forge).
- **Wisp family** gains Tier 3 biome variant: Pictograph Wisp (Dry
  Well) alongside existing Void Wisp projection.
- **Automata family** gains two Tier 3 variants: Ley-Warped Construct
  (Dry Well) and Forgewright Automaton (Convergence).
- **Guardian family** gains Tier 3 biome variants: Crystal Warden
  Deep (Dry Well) and Tempered Construct (Forgotten Forge), both
  Construct type. Crystal Warden (Deep) moved from Warden to
  Guardian family because the Warden family is Undead throughout
  and Constructs cannot be Undead.
- **Automata family** Forgewright Automaton is a Tier 3 biome variant
  alongside the projected Haywire Colossus (both Tier 3, different
  locations).

---

## 6. Unique Enemies (No Family)

These are Pallor-born or situational enemies with no palette-swap
lineage. They exist because the Grey creates novel forms of despair.

| Name | Lv | Type | Location | Description |
|------|----|------|----------|-------------|
| Hollow Walker | 28 | Pallor | Wastes (all), Convergence | Grey humanoid. Identity erased by despair. HP drain. |
| Despair Cloud | 28 | Pallor | Wastes (all), Convergence | Formless grey mass. Party-wide Despair. Low HP, high evasion. |
| Petrified Beast | 30 | Pallor | Wastes outer | Grey stone creature. Heavy physical, slow. Final corruption stage. |
| Pallor Knight | 32 | Pallor | Wastes inner, Convergence | Ancient armored warrior. Premium encounter. |
| Grief Shade | 32 | Pallor | Wastes inner, Convergence | Mimics party members. Uses weakened party abilities. |
| Corrupted Spirit | 34 | Spirit | Convergence | Grey-tinted spirit. Void magic. Ley energy turned grey at the source. |
| Pallor Echo | 34 | Pallor | Convergence Phase 4 | Mini-boss. Complete identity consumed by the Grey. |
| Vein Stalker | 28 | Humanoid | Ley Confluence | Solidified ley residue. Phases through walls. MP drain. Rare. |
| Ley-Born Echo | 34 | Spirit | Dry Well F7 | Ley imprint of a dead builder. Repeats their last moments. |
| Grief Residue | 34 | Pallor | Forgotten Forge | Leaked despair from the Grey Cleaver. Formless. Despair + MP drain. |
| Hollow Smith | 34 | Pallor | Forgotten Forge | Dead forge workers. Hammer at empty anvils. Spectral forge tool attacks. |
| Hollow Knight | 30 | Pallor | Trial 1 | Formation fighters. 1,000 HP each. Reform unless crown is targeted. |
| Unfinished Construct | 30 | Construct | Trial 2 | Beg to be repaired. Healing spawns more. |
| Stone Spirit | 30 | Spirit | Trial 3 | Petrified nature spirits. Silence attacks. |
| Archived | 32 | Pallor | Trial 5 | Compressed page figures. Recite facts of death. |

---

## 7. Boss Summary

| # | Boss | HP | Lv | Type | Location |
|---|------|----|-----|------|----------|
| 1 | The Crowned Hollow | 8,000 | 30 | Boss | Pallor Wastes Trial 1 |
| 2 | The Perfect Machine | 7,000 | 30 | Boss | Pallor Wastes Trial 2 |
| 3 | The Last Voice | 6,000 | 32 | Boss | Pallor Wastes Trial 3 |
| 4 | The Open Door | — | — | — | Pallor Wastes Trial 4 (non-combat) |
| 5 | The Index | 7,000 | 32 | Boss | Pallor Wastes Trial 5 |
| 6 | Vaelith, the Ashen Shepherd | 50,000 | 34 | Boss | Pallor Wastes Section 5 |
| 7 | Vaelith (Siege, unwinnable) | 999,999 | 150 | Boss | Valdris Siege (Act II) |
| 8 | Ley Titan | 18,000 | 28 | Boss | Ley Line Depths F5 |
| 9 | Archive Keeper | 3,000–12,000 | 32 | Boss | Dry Well F5 |
| 10 | Wellspring Guardian | 28,000 | 36 | Boss | Dry Well F7 |
| 11 | The Architect's Regret (Stage 1) | 20,000 | 34 | Boss | Forgotten Forge F5 |
| 12 | The Grey Cleaver Unbound (Stage 2) | 25,000 | 36 | Boss | Forgotten Forge F5 |
| 13 | Pallor Echo | 5,000 | 34 | Boss | Convergence Phase 4 |
| 14 | Cael, Knight of Despair (Phase 1) | 45,000 | 36 | Boss | Convergence |
| 15 | Cael, Knight of Despair (Phase 2) | 35,000 | 38 | Boss | Convergence |
| 16 | The Pallor Incarnate | 70,000 | 40 | Boss | Convergence |

**Total: 15 bosses + 1 non-combat trial = 16 boss encounters**

---

## 8. Stat Computation Rules

All stats computed using the canonical formulas from README.md:

```
HP   = floor(level² × 1.8 + level × 12 + 20)
MP   = floor(level × 3.5)
ATK  = floor(level × 1.6 + 8)
DEF  = floor(level × 1.2 + 5)
MAG  = floor(level × 1.4 + 6)
MDEF = floor(level × 1.0 + 4)
SPD  = floor(level × 0.8 + 8)
```

Gold/Exp use the logistic bounded-growth formulas × threat multiplier.

Role adjustments per README.md:
- Swarm (Trivial): HP up to -32%
- Glass cannon: ATK +15%, DEF/HP up to -28%
- Caster: MAG +15%, ATK up to -23%
- Tank: DEF/HP +15%, SPD up to -22%

Boss HP values are hand-tuned per dungeons-world.md and
dungeons-city.md. Boss stats use formulas at the listed level with
Boss-type multipliers.

Type rules:
- Construct: MP=0, immune to Poison/Sleep/Confusion/Berserk/Despair
- Spirit: immune to Poison/Petrify, 50% physical reduction
- Pallor: Weak→Spirit, immune to Despair/Death, 2% HP regen while
  party has Despair
- Undead: immune to Poison/Death, healed by Poison element, damaged
  by healing
- Boss: immune to Death/Petrify/Stop/Sleep/Confusion (can be
  overridden per boss)

---

## 9. Implementation Notes

### 9.1 File Structure

`act-iii.md` will follow the same structure as `interlude.md`:
- One `##` section per dungeon/area
- Stat tables with all 19 columns
- Boss notes with phases, abilities, and special mechanics
- Trial boss sections include both stat blocks AND special rules

### 9.2 Palette Family Updates

`palette-families.md` gains ~21 Tier 3 entries and ~10 Tier 4 entries.
Some families gain multiple biome variants at the same tier (Sentry,
Elemental, Wisp, Automata, Warden) — consistent with the dual-variant
pattern established in the Interlude.

### 9.3 Vaelith Siege Encounter Placement

The unwinnable Vaelith siege encounter (Lv 150) goes in act-iii.md
as a special section, NOT in act-ii.md. Rationale: it belongs with
Vaelith's complete combat arc, and act-ii.md is already merged. A
cross-reference note in act-ii.md is not needed since
dungeons-world.md already documents the encounter.

### 9.4 Forgotten Forge

The Forgotten Forge is a new secret dungeon not currently in
dungeons-world.md or dungeons-city.md. The spec documents its
enemies and boss for the bestiary; the dungeon layout, puzzles,
and floor structure will be designed when Gap 2.4 (Encounter Rates)
or a dedicated dungeon design gap is addressed.

### 9.5 Grey Cleaver Equipment Stats

The Grey Cleaver's stat details (Section 3.3) are documented in this
spec for context. The actual equipment entry belongs in Gap 1.5
(Equipment Stat Tables). This spec provides the reference data that
1.5 will consume.

### 9.6 Enemy Count Verification

| Area | Count |
|------|-------|
| Pallor Wastes outer | 8 |
| Pallor Wastes inner | 5 |
| Pallor Wastes trials | 5 (+ 1 non-combat) |
| Pallor Wastes bosses | 2 (Vaelith + Vaelith Siege) |
| Trial bosses | 5 (4 combat + 1 non-combat) |
| Ley Confluence | 3 + 1 boss |
| Dry Well F5–7 | 5 + 2 bosses |
| Forgotten Forge | 5 + 2 boss stages |
| Convergence regular | 7 |
| Convergence gauntlet | (reuses Wastes enemies) |
| Convergence bosses | 4 (Echo, Cael P1, P2, Incarnate) |
| Overworld safe | 6 |
| Overworld grey | 6 |
| **Total** | **~65** |
