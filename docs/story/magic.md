# Magic System -- Pendulum of Despair

This document defines every learnable spell in the game: elements, categories, progression, balance, and per-character availability. All spell names are original to this world, drawn from ley line terminology (Valdris tradition), Forgewright vocabulary (Carradan tradition), and spirit-speaker language (Thornmere tradition).

> **Cross-training:** In addition to the base spell lists defined here, characters can learn 1-3 spells from another tradition through Act III story events (see abilities.md, Cross-Training section). Cross-trained spells supplement these base lists and are cast at increased MP cost (+50%).

---

## Table of Contents

1. [Element System](#element-system)
2. [Elemental Resistance Chart](#elemental-resistance-chart)
3. [Spell Balance Guidelines](#spell-balance-guidelines)
4. [Spell Progression & Learning](#spell-progression--learning)
5. [Offensive Magic](#offensive-magic)
6. [Healing Magic](#healing-magic)
7. [Status Effect Magic](#status-effect-magic)
8. [Buff & Debuff Magic](#buff--debuff-magic)
9. [Utility & Special Magic](#utility--special-magic)
10. [Void Magic (Pallor)](#void-magic-pallor)
11. [Spell Index by Character](#spell-index-by-character)
12. [Status Effect Reference](#status-effect-reference)
13. [Spell Count Summary](#spell-count-summary)
14. [Design Notes](#design-notes)

---

## Element System

Eight elements govern all magic in this world. Each is tied to a region, a tradition, and a thematic role.

| Element | Symbol | Lore Connection | Color (VFX) |
|---------|--------|----------------|-------------|
| **Flame** | Forge-fire | Carradan industry, forge-heat, destruction and creation | Orange-red, ember sparks |
| **Frost** | Still-ice | Valdris highlands, Highcairn peaks, preservation and stasis | Pale blue, white crystals |
| **Storm** | Sky-crack | Thornmere weather, coastal gales, chaos and revelation | Yellow-white, violet arcs |
| **Earth** | Deep-root | Thornmere Wilds, caverns, endurance and weight | Brown, mossy green |
| **Ley** | Line-light | Valdris ley line tradition, pure channeled magic | Gold-white, shimmering motes |
| **Spirit** | Breath-song | Thornmere spirit communion, life force, nature | Pale green, translucent wisps |
| **Void** | Hollow-dark | The Pallor, entropy, anti-magic, forbidden | Grey static, absence of color |
| **Non-elemental** | Raw-force | No affinity, pure kinetic or arcane impact | White flash, concussive ripple |

### Element Descriptions

**Flame** -- The element of transformation. Fire consumes, but it also forges. Carradan Forgewrights channel Flame constantly in their craft, and it is the most common offensive element in the early game. Associated with passion, industry, and reckless ambition.

**Frost** -- The element of stillness. Ice preserves what fire destroys. Valdris court mages have long favored Frost magic for its precision and defensive applications. Associated with patience, rigidity, and the fear of change.

**Storm** -- The element of upheaval. Lightning strikes without warning; wind reshapes the land. Storm magic is unpredictable and powerful, favored by those who embrace chaos. Associated with freedom, destruction, and truth laid bare.

**Earth** -- The element of endurance. Stone does not break easily. Root systems outlast empires. Earth magic is slow but absolute. Associated with stubbornness, protection, and the deep memory of the land.

**Ley** -- The element of pure magic. Ley energy flows through the veins of the world, and those trained in the Valdris tradition learn to channel it directly. Ley magic is versatile but tied to the health of the ley lines -- as they dim, so does this element's power. Associated with knowledge, tradition, and the cost of understanding.

**Spirit** -- The element of life itself. Spirit magic draws on the communion between the caster and the living world -- plants, animals, the unseen presences in old forests. Only the Thornmere spirit-speakers truly master it. Associated with empathy, sacrifice, and the bonds between all living things.

**Void** -- The anti-element. Void is not darkness -- it is absence. The Pallor's influence made manifest as magic. Void spells drain, suppress, and corrode. No sane mage seeks this power. It finds you. Associated with despair, entropy, and the surrender of hope.

**Non-elemental** -- Raw magical force with no elemental signature. Cannot be resisted through elemental defense, but also benefits from no elemental weakness. The brute-force option.

---

## Elemental Resistance Chart

Each element has one element it is strong against (deals 150% damage) and one it is weak against (deals 75% damage). The first four elements (Flame, Frost, Storm, Earth) form an elemental wheel. Ley, Spirit, and Void exist outside this wheel but have their own triangle of interactions: Ley beats Void, Void beats Spirit, Spirit beats Ley.

| Attacking | Strong vs. (150%) | Weak vs. (75%) |
|-----------|-------------------|-----------------|
| Flame | Frost | Storm |
| Frost | Storm | Earth |
| Storm | Earth | Flame |
| Earth | Flame | Frost |
| Ley | Void | Spirit |
| Spirit | Ley | Void |
| Void | Spirit | Ley |
| Non-elemental | -- (100% to all) | -- (100% to all) |

**Special interactions:**
- Flame vs. Flame: 50% damage (resistance)
- Frost vs. Frost: 50% damage (resistance)
- Storm vs. Storm: 50% damage (resistance)
- Earth vs. Earth: 50% damage (resistance)
- Ley vs. Ley: 50% damage (resistance)
- Spirit vs. Spirit: 50% damage (resistance)
- Void vs. Void: 0% damage (immune)
- Enemies may have innate elemental resistances, absorptions, or immunities beyond this chart (defined per-enemy in bestiary data)

---

## Spell Balance Guidelines

### MP Cost by Tier

| Tier | Label | MP Range | Availability | Spell Power Range |
|------|-------|----------|-------------|-------------------|
| 1 | Basic | 3-8 MP | Early game (Lv 1-12) | 12-20 |
| 2 | Mid | 12-20 MP | Mid-game (Lv 13-25) | 28-40 |
| 3 | High | 25-45 MP | Late game (Lv 26-40) | 50-70 |
| 4 | Ultimate | 50-99 MP | Endgame (Lv 40+) | 85-120 |

*Note: AoE **spell power** uses approximately 60-70% of the single-target ranges above (e.g., Tier 2 AoE spell power: 18-28 vs single-target 28-40) at **Tiers 1-3 only** — see "Tier 4 AoE exemption" below. AoE **MP cost** is handled separately: 1.5-2x the single-target cost (see Balance Rules below).*

### Balance Rules

- **Healing spells** cost ~80% of equivalent-tier damage spells (healers must sustain through long fights)
- **AoE versions** cost 1.5-2x the single-target version of the same tier — binds only on the named same-tier pairs; see "AoE MP pricing" under § Derived Rules below. An AoE spell with no same-tier counterpart has no ratio to take: it is held to the "AoE control is never cheaper than single-target control" floor in the same section when it is a control spell (status/buff/debuff) **and its own tier and category contain a single-target spell to measure against**, and otherwise to its plain tier MP band. A control AoE whose tier and category hold no single-target spell at all (Mass Dispersion) has nothing for the floor to bite on and falls back to the band like any other
- **Status spells** have a base hit rate of 60-80% (the *standard* band; see "Status hit rate has two bands" under § Derived Rules below for the 45-59% severe band) (modified by caster MAG vs. target MDEF)
- **Buff/debuff durations** last 4-6 turns at Tier 1, 4-8 turns at Tier 2, until end of battle at Tier 3
- **Damage formula reference:** `magic_damage = min(14999, max(1, (caster.mag * spell.power) / 4 - target.mdef) * element_mod * variance)` where `variance = random_int(240, 255) / 256`. See [combat-formulas.md](combat-formulas.md) for full resolution order.
- **Healing formula:** `heal_amount = min(14999, (caster.mag * spell.power * 0.8) * variance)` where `variance = random_int(240, 255) / 256`. See [combat-formulas.md](combat-formulas.md).

### Tier 4 AoE Exemption

**Tier 4 (Ultimate) spells use the full 85-120 spell power band even when they
target all enemies.** The 60-70% AoE reduction applies at Tiers 1-3 only.

*This document is authoritative for the power bands and for the AoE reduction.*
[combat-formulas.md](combat-formulas.md) § AoE Damage Rules restates the rule so
the combat pipeline reads in one place, and its § Magic Damage worked example is
tuned against it; if the two ever disagree, the sentence there is the bug.
Changing the band or the exemption means changing it here first, then the
restatement, then `game/tests/test_spell_balance.gd`. That test holds the
**shipped spell data** in `game/data/spells/` to the rule using bands hard-coded
in the test; it does not parse this document. So a change made here and nowhere
else will not fail the suite — the prose and the test simply drift apart. All
three have to move together, and the test is the last of the three, not a guard
on the first.

*Derivation.* [combat-formulas.md](combat-formulas.md) § Magic Damage tunes the
14,999 damage cap around Ley Ruin (power 100, AoE) at Maren Lv150: MAG 332 with
Attunement, target MDEF 80, elemental weakness, Resonance. That chain is
`(332 x 100 / 4 - 80) x 1.5 x 1.3 = 16,029`, capped to 14,999 — the documented
"perfect setup" moment. Solving the same chain for the minimum power that still
reaches the cap gives `power >= 94`.

Applying the 60-70% AoE reduction to Tier 4 would cap **AoE** power at
`120 x 0.7 = 84`, and 84 < 94, so no Tier 4 AoE spell could reach the cap. The
reduction constrains AoE spells only, so that alone does not put the cap out of
reach: a Tier 4 *single-target* spell at power 94-120 would still hit it. What
closes the gap is the shipped corpus, not the arithmetic — every Tier 4 damage
spell in `game/data/spells/` is AoE except Unmaking (power 85, Void,
enemy-only), and 85 is itself below 94. So under the reduction the cap would be
unreachable by every spell **currently shipped**, and the "perfect setup"
moment that [combat-formulas.md](combat-formulas.md) § Magic Damage is tuned
around would have nothing left to fire it.

That leaves two ways out: ship a single-target Tier 4 ultimate at power 94+, or
exempt Tier 4 from the reduction. **This document takes the second** — the
exemption is a design choice, not a forced conclusion. Ultimates are balanced by
MP cost (50-99, roughly double a Tier 3 single target at the same point in its
band) and by availability, not by a power discount. The first way out stays
open: adding a single-target Tier 4 spell later does not disturb the exemption,
it just gives the cap a second route.

Not every ultimate reaches the cap: Requiem of Thorns (power 90) tops out at
~14,410 on the same chain, and is the cheapest Tier 4 spell at 70 MP.

### Derived Rules (numeric balance pass)

These rules were derived from the shipped spell data plus the damage math in
[combat-formulas.md](combat-formulas.md) and the stat curves in
[progression.md](progression.md). They close values the rules above left
unstated. `game/tests/test_spell_balance.gd` asserts all of them against
`game/data/spells/`.

- **Status hit rate has two bands.** The 60-80% rule above is the *standard*
  band, for statuses the target can act through or that break on damage (Poison,
  Blind, Slow, Silence, Confusion, Despair, single-target Sleep). AoE versions of
  standard statuses sit at the band floor (60%). A second **severe band of
  45-59%** covers statuses that remove the target from the action economy
  outright — indefinitely (Petrify, "Until cured") or on a fixed timer the target
  cannot influence (Stop, "3 real-time seconds", which wears off only and cannot
  be broken by damage or cured) — and multi-target statuses that deny actions or
  suppress a party
  system (party-wide Sleep; Silence plus buff suppression; Despair plus healing
  suppression). Debuff spells that impose a stat penalty (Drag Tide, Fray,
  Sunder, Dampening Field, Crumble) also roll to hit and use the standard band;
  dispel-type debuffs that only strip buffs (Dispersion, Mass Dispersion) always
  land and declare `hit_rate: null`. The severe band is anchored by
  [combat-formulas.md](combat-formulas.md) § Status Accuracy at Key Points, which
  uses "Maren Lv70 Petrify (50%)" as its canonical worked example — after the
  two-stage MAG/MDEF and Magic Evasion checks that 50% base lands ~26% of the
  time against a boss, which is the intended reliability for a combat-removal
  status.
- **A status *rider* on an offensive spell sits below both hit-rate bands.** An
  offensive spell may carry a rider — a chance to inflict a status *on top of*
  full damage rather than as the spell's purpose. Pendulum's Echo is the only
  `category: offensive` spell in the corpus that carries one: Void damage at
  spell power 70, plus a 40% chance of Despair. The rule binds on
  `category: offensive` and on nothing else. The Weight (`category: special`,
  Cael boss only, no MP cost) also deals full damage and then applies Despair,
  but at a guaranteed 100% with no resistance check — that is a scripted boss
  beat, not a priced player option, and `special` is the category that says so.
  A rider is priced **below the 60% standard-band floor (30-50%)**
  precisely because the caster is already being paid in damage; pricing it
  inside either status band would make an offensive spell strictly better than
  the status spell it duplicates. A rider is **not** encoded as `hit_rate`:
  `hit_rate` is the spell's own to-hit roll, and an offensive spell's damage
  does not roll to hit, so `game/tests/test_spell_balance.gd` holds every
  non-status, non-debuff spell to `hit_rate: null`. Until the battle layer grows
  a field it can roll, a rider lives in the spell's Effect text only and nothing
  applies it in combat; when that field arrives it is named separately from
  `hit_rate` and this 30-50% band is what it must satisfy.
- **AoE MP pricing needs a named *same-tier* counterpart.** The 1.5-2x rule binds
  only on the nine AoE/single-target pairs listed below, where both halves sit in
  the same tier and deliver the same effect.

  | Single target | MP | AoE version | MP | Ratio |
  |---------------|----|-------------|----|-------|
  | Kindlepyre (T2) | 14 | Scorch Sweep | 22 | 1.57x |
  | Hoarfall (T2) | 14 | Whiteout | 22 | 1.57x |
  | Galeforce (T2) | 15 | Squall Line | 24 | 1.60x |
  | Ley Cascade (T2) | 16 | Ley Storm | 25 | 1.56x |
  | Rootgrip (T2) | 14 | Quake Stride | 22 | 1.57x |
  | Spiritfang (T2) | 15 | Wilds Chorus | 23 | 1.53x |
  | Mend (T1) | 3 | Breath of the Wilds | 6 | 2.00x |
  | Deepmend (T2) | 10 | Sanctuary | 18 | 1.80x |
  | Resurgence (T3) | 28 | Lifetide | 42 | 1.50x |

  The ratio, not the tier MP band, is the binding constraint for these nine AoE
  spells. Multiplying a single-target cost by 1.5-2x routinely lands above the
  plain tier band (Ley Storm 25 and Squall Line 24 against a Tier 2 ceiling of
  20) and above the ~80% healing band (Sanctuary 18 against a Tier 2 healing
  ceiling of 16; Lifetide 42 against a Tier 3 healing ceiling of 36). That is the
  intended outcome — a party-wide effect is worth more than its tier band alone
  would allow — so a paired AoE spell is measured against its counterpart and is
  *not* measured against the tier MP band or the healing discount.

- **Cross-tier AoE escalations are not pairs.** Several AoE spells reproduce a
  lower-tier single-target effect one tier up. They are new spells at a new tier,
  not a repriced version of the same spell, so the 1.5-2x rule does not bind on
  them. They are priced inside their own plain tier MP band — or, where they are
  also control spells with a single-target spell of their own tier and category to
  measure against (four of the six below: Flashblind, Miasma, Bogsink, Eventide),
  by the AoE control floor further down, which can push one past that band.
  Rekindling is a `healing` spell rather than a control spell, and Mass Dispersion
  is the only Tier 3 debuff of any kind, so both are priced inside their plain
  tier band. Their ratios against the lower-tier original are recorded here so the
  relationship is not mistaken for a broken pair:

  | Lower-tier single target | MP | Cross-tier AoE | MP | Ratio |
  |--------------------------|----|----------------|----|-------|
  | Murk Veil (T1, Blind) | 4 | Flashblind (T2) | 19 | 4.75x |
  | Vilethorn (T1, Poison) | 5 | Miasma (T2) | 20 | 4.00x |
  | Leaden Step (T1, Slow) | 5 | Bogsink (T2) | 20 | 4.00x |
  | Slumber Mote (T1, Sleep) | 6 | Eventide (T2) | 22 | 3.67x |
  | Kindle Breath (T1, Regen) | 6 | Rekindling (T2) | 16 | 2.67x |
  | Dispersion (T2, dispel) | 14 | Mass Dispersion (T3) | 30 | 2.14x |

  Note that Sanctuary, not Rekindling, is Deepmend's party version: Deepmend is a
  direct heal (spell power 30) and Rekindling is the party form of Kindle
  Breath's regeneration.

  A standalone AoE spell with no single-target counterpart at any tier (Drift,
  Smokeveil, and every Tier 4 ultimate) is likewise priced inside its plain tier
  MP band — there is no single-target cost to multiply. Leyward and Bulwark Line
  are standalone in that sense too, but they are *control* spells and the AoE
  control floor below binds on them instead. The enemy-only Void AoE spells
  (Pallor Tide, Silence of Ages, The Weight, Grey Horizon) carry no MP cost at
  all and are outside this rule entirely.
- **AoE control is never cheaper than single-target control.** A `status`,
  `buff`, or `debuff` spell that targets an entire side costs **strictly more
  than every single-target spell of the same tier and category, and at most 2x
  the dearest of them**. This is the floor the 1.5-2x pair rule cannot supply:
  none of these spells has a same-tier single-target counterpart to take a ratio
  against, so before this rule every one of them sat legally inside its tier MP
  band while undercutting a single-target spell of the same tier — a party-wide
  60% Poison for less than one Petrify. Like the paired AoE spells above, a
  control AoE **may exceed the plain tier MP band**, because a party-wide control
  effect is worth more than its tier band alone allows — but only in the two
  cases below. Clearing the floor is not on its own a licence to leave the band,
  and a floor-priced spell outside both cases is still held to the band:

  1. **The floor forces it.** Every single-target spell of that tier and category
     already sits at or above the band ceiling, so nothing strictly dearer fits
     inside the band. No shipped spell is in this position today; the rule is
     stated so that the guard has a principle rather than a list of names.
  2. **The status is severe-band.** The floor orders its members by severity (see
     below), and a severe-band AoE status is priced above the standard-band ones,
     which can carry it past the ceiling. Eventide is the only such spell today.

  | Tier / category | Dearest single target | MP | AoE control | MP | Ratio |
  |-----------------|----------------------|----|-------------|----|-------|
  | T2 status | Grey Gaze (Petrify) | 18 | Flashblind (Blind) | 19 | 1.06x |
  | T2 status | Grey Gaze (Petrify) | 18 | Miasma (Poison) | 20 | 1.11x |
  | T2 status | Grey Gaze (Petrify) | 18 | Bogsink (Slow) | 20 | 1.11x |
  | T2 status | Grey Gaze (Petrify) | 18 | Eventide (Sleep) | 22 | 1.22x |
  | T2 buff | Leymirror | 18 | Bulwark Line | 20 | 1.11x |
  | T2 buff | Leymirror | 18 | Leyward | 20 | 1.11x |

  Within the floor, order by severity: the three standard-band AoE statuses
  (Flashblind, Miasma, Bogsink) sit below the severe-band one (Eventide, a
  party-wide Sleep), and Eventide is the one spell here that clears the Tier 2
  ceiling of 20. Mass Dispersion (T3, all enemies, 30 MP) has no same-tier
  single-target debuff to measure against, so the floor is vacuous for it and it
  is priced inside the plain Tier 3 band.

  *These six numbers are a designer judgement about relative worth, not a
  playtest result.* The floor — AoE control above single-target control — is the
  part meant to hold; the exact spread inside it is the first thing to revisit
  once the combat playtest harness reports encounter lengths.
- **Revival spells take no healing discount.** Spirit Recall (Tier 2, 20 MP) and
  Second Dawn (Tier 3, 40 MP) are priced inside the *full* tier MP band, above
  the ~80% healing band (Tier 2 ceiling 16, Tier 3 ceiling 36) — restoring a
  fainted ally restores that ally's entire remaining action economy.
- **Substitute-cost spells are exempt from the MP band.** Leydraught costs 0 MP
  and 15% of the caster's max HP. A spell that pays in a resource other than MP
  states that cost explicitly and is not measured against the MP table.
- **Enemy-only spells carry no MP cost.** Spells cast only by an enemy or boss
  (the Void list, other than Hollow Mend and Pendulum's Echo) encode
  `mp_cost: null` — enemies do not spend MP. Their spell power still follows the
  tier bands so that [combat-formulas.md](combat-formulas.md) damage math applies
  unchanged.
- **`duration: null` is meaningful.** A null duration means one of four things:

  1. **The duration belongs to the inflicted status, not to the spell.** This is
     the dominant case — fourteen of the fifteen `category: status` spells encode
     `duration: null` for this reason. Murk Veil and Flashblind inflict Blind,
     so they last "4 turns or until cured"; Leaden Step and Bogsink inflict Slow,
     so they last 5 turns; Befuddle inflicts Confusion (3 turns or until damaged);
     Vilethorn and Miasma inflict Poison, Slumber Mote and Eventide inflict Sleep,
     Grey Gaze inflicts Petrify and Stillwatch inflicts Stop — all open-ended or
     real-time rather than turn-counted. The authority for every one of those
     numbers is § Status Effect Reference below, keyed on the spell's `status`
     field. A status spell must therefore either declare `duration: null` or
     restate its status's canonical turn count exactly; Ashen Whisper is the one
     spell that restates it (`duration: 4`, matching the Despair row) because its
     effect text names the number.
  2. **The effect is instantaneous** (Dispersion, Mass Dispersion).
  3. **The effect is charge-limited rather than turn-limited** (Leymirror: next
     3 spells), or field-scoped and measured in real time or steps rather than
     turns (Veilstep: 120 seconds or 200 steps).
  4. **The effect lasts until end of battle** (Last Breath, and every Tier 3
     buff/debuff per the rule above).

  Buff and debuff spells that *are* turn-counted must fall inside their tier's
  turn range.
- **Cross-training is per-learner, not per-spell.** The same spell is native to
  one character and cross-trained for another, so the flag cannot live on the
  spell. Every `learned_by` entry marked `cross_trained: true` carries
  `mp_penalty: 1.5`, matching the "+50% MP cost" wording in this document's
  preamble and in each spell's "Who learns" line; a native learner carries
  neither key. There is deliberately **no spell-level `cross_trained` or
  `mp_penalty` field** — one existed, was `false`/`null` on all 89 spells, was
  read by nothing, and invited someone to set it and expect an effect.
  *The multiplier is data only so far:* the cast path spends the spell's base
  `mp_cost` without consulting the learner's entry, so no character is charged
  the +50% yet.

---

## Spell Progression & Learning

Each character learns spells through a tradition that reflects their background and story arc.

### Ley Line Tradition (Maren, Edren)

**Maren** is a master of the old ways. She begins with a broad spell list and learns new spells by leveling up and discovering ancient texts in ruins and libraries. She has access to nearly every non-Void spell, plus a curated set of Spirit-tradition healing spells learned through her research into all magical traditions. She is the party's primary offensive caster and lore-keeper.

**Edren** is a knight-commander, not a mage. He learned a small set of defensive and support spells during his training under Maren. His spell list is narrow (14 spells total: 12 base via level-up, plus 2 Spirit-tradition cross-trained spells from Torren in Act III) but focused on protection and leadership.

### Forgewright Tradition (Lira)

**Lira** does not cast spells in the traditional sense. Her unique command is "Forgewright" -- she channels Arcanite energy through her tools. However, she can learn 8-10 spells that represent Arcanite-enhanced casting: primarily Flame-element offensive magic and technical support spells (barriers, analysis). She learns through level-up and by studying Forgewright schematics found in Carradan locations.

### Spirit Tradition (Torren)

**Torren** learns through communion with the spirits of the Thornmere Wilds. His spells are primarily Spirit-element and Earth-element, with some Storm and Ley spells reflecting his broad connection to the natural world. Focused on healing, regeneration, and nature-based offense. He learns through level-up, story events (spirit communion scenes), and Act III cross-training (2 Ley spells from Maren). His versions of common spells have unique spirit-flavored names and slightly different visual effects.

### Streetwise (Sable)

**Sable** is not a mage. She has 5 utility spells representing tricks picked up on the streets of the Carradan underbelly: smokescreens, distractions, a rudimentary analysis trick. Smokeveil is innate (she's always known it). The remaining four are learned through story events during the Interlude — practical tricks picked up from party members and her own street experience. These are not cross-trained spells (no +50% MP penalty); they are one-off gifts tailored to her streetwise style.

### Corrupted Tradition (Cael)

**Cael** has access to Ley Line spells during Acts I-II when he is a party member. After his corruption and departure, his spell list converts to Void-element versions when faced as a boss. If any Void spells become learnable by the party post-game, they are acquired as bittersweet rewards after his defeat.

---

## Offensive Magic

### Flame Spells

#### 1. Ember Lance
- **Element:** Flame
- **Category:** Offensive
- **Tier:** 1
- **MP Cost:** 4
- **Target:** Single enemy
- **Effect:** Spell power 14. A focused bolt of fire.
- **Description:** A needle of forge-fire streaks toward the target, trailing cinder. The simplest offensive spell a Carradan apprentice learns.
- **Who learns:** Maren (Lv 1), Lira (Lv 5), Cael (Lv 1)
- **Visual:** A thin orange streak arcs from caster to target; small ember particles scatter on impact.

#### 2. Kindlepyre
- **Element:** Flame
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 14
- **Target:** Single enemy
- **Effect:** Spell power 32. A concentrated blast of fire.
- **Description:** The air shimmers and ignites in a pillar of forge-heat. Carradan war-mages once leveled barricades with this.
- **Who learns:** Maren (Lv 14), Lira (Lv 18), Cael (Lv 14)
- **Visual:** A column of orange-red fire erupts beneath the target; heat-shimmer distortion radiates outward.

#### 3. Crucible Wrath
- **Element:** Flame
- **Category:** Offensive
- **Tier:** 3
- **MP Cost:** 32
- **Target:** Single enemy
- **Effect:** Spell power 58. Devastating concentrated fire.
- **Description:** White-hot forge-fire engulfs the target in a roaring crucible. The air itself screams.
- **Who learns:** Maren (Lv 30), Lira (Lv 35)
- **Visual:** A sphere of white-hot flame encases the target; molten droplets rain down; the screen tints orange briefly.

#### 4. Scorch Sweep
- **Element:** Flame
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 22
- **Target:** All enemies
- **Effect:** Spell power 24. AoE fire damage.
- **Description:** A wave of heat rolls across the battlefield like wind from an open furnace. Nothing escapes the forge-breath.
- **Who learns:** Maren (Lv 18), Lira (Lv 22)
- **Visual:** A horizontal wave of fire sweeps across all enemies from left to right; sparks trail behind.

### Frost Spells

#### 5. Rime Shard
- **Element:** Frost
- **Category:** Offensive
- **Tier:** 1
- **MP Cost:** 4
- **Target:** Single enemy
- **Effect:** Spell power 14. A spike of ice.
- **Description:** Moisture in the air crystallizes into a dagger of ice and hurtles forward. The first spell taught in the Valdris frost-halls.
- **Who learns:** Maren (Lv 1), Edren (Lv 8), Cael (Lv 3)
- **Visual:** A translucent blue-white shard forms mid-air and launches at the target; frost particles linger.

#### 6. Hoarfall
- **Element:** Frost
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 14
- **Target:** Single enemy
- **Effect:** Spell power 32. A heavy blast of freezing cold.
- **Description:** The temperature plummets. Ice crawls across the ground and erupts upward through the target like frozen roots.
- **Who learns:** Maren (Lv 14), Cael (Lv 16)
- **Visual:** Ice crystals race along the ground toward the target; a burst of jagged ice erupts vertically on impact.

#### 7. Glacial Tomb
- **Element:** Frost
- **Category:** Offensive
- **Tier:** 3
- **MP Cost:** 32
- **Target:** Single enemy
- **Effect:** Spell power 58. Encases the target in killing cold.
- **Description:** A prison of absolute cold forms around the target. For one terrible moment, even time seems to freeze.
- **Who learns:** Maren (Lv 30)
- **Visual:** A sphere of pale blue ice encases the target completely, then shatters outward in crystalline fragments.

#### 8. Whiteout
- **Element:** Frost
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 22
- **Target:** All enemies
- **Effect:** Spell power 24. AoE frost damage.
- **Description:** A blinding squall of ice and wind sweeps the field. Highland soldiers call it "the cairn-maker."
- **Who learns:** Maren (Lv 18)
- **Visual:** The screen fills with driving white particles; ice shards rake across all enemies; brief whiteout flash.

### Storm Spells

#### 9. Arc Snap
- **Element:** Storm
- **Category:** Offensive
- **Tier:** 1
- **MP Cost:** 5
- **Target:** Single enemy
- **Effect:** Spell power 16. A bolt of lightning. Slightly higher power than other Tier 1 spells, balanced by slightly higher cost.
- **Description:** A jagged line of white-violet light leaps from the caster's hand. Brief, bright, and merciless.
- **Who learns:** Maren (Lv 3), Cael (Lv 5)
- **Visual:** A crackling lightning bolt arcs from caster to target in a zigzag path; violet afterimage lingers.

#### 10. Galeforce
- **Element:** Storm
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 15
- **Target:** Single enemy
- **Effect:** Spell power 34. A concentrated blast of wind and lightning.
- **Description:** The sky splits. A fist of compressed wind drives the target down while lightning follows through the gap.
- **Who learns:** Maren (Lv 16), Cael (Lv 18)
- **Visual:** Dark clouds gather above the target; a downward wind-burst flattens them; a lightning strike follows immediately.

#### 11. Tempest Reign
- **Element:** Storm
- **Category:** Offensive
- **Tier:** 3
- **MP Cost:** 35
- **Target:** Single enemy
- **Effect:** Spell power 62. A devastating storm concentrated on one point.
- **Description:** A cyclone of wind and lightning descends on the target. The thunder lasts longer than the spell.
- **Who learns:** Maren (Lv 32)
- **Visual:** A spiraling vortex of dark cloud and lightning descends; multiple bolts strike in rapid succession; screen shakes.

#### 12. Squall Line
- **Element:** Storm
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 24
- **Target:** All enemies
- **Effect:** Spell power 26. AoE storm damage.
- **Description:** A wall of howling wind and scattered lightning advances across the battlefield. There is no shelter.
- **Who learns:** Maren (Lv 20)
- **Visual:** A horizontal wall of dark cloud and lightning bolts sweeps across all enemies; wind particles fly.

### Earth Spells

#### 13. Tremor Spike
- **Element:** Earth
- **Category:** Offensive
- **Tier:** 1
- **MP Cost:** 4
- **Target:** Single enemy
- **Effect:** Spell power 14. A pillar of stone erupts beneath the target.
- **Description:** The ground cracks and a fist of stone punches upward. The Wilds remember every footstep -- and some, they answer.
- **Who learns:** Torren (Lv 1), Maren (Lv 5)
- **Visual:** The ground fractures beneath the target; a jagged stone column erupts upward; dust and pebbles scatter.

#### 14. Rootgrip
- **Element:** Earth
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 14
- **Target:** Single enemy
- **Effect:** Spell power 30. Crushing roots and stone.
- **Description:** Ancient roots burst from the earth, coiling around the target and dragging them down. The deep-root holds fast.
- **Who learns:** Torren (Lv 12), Maren (Lv 16)
- **Visual:** Thick brown-green roots erupt from below, wrapping the target; rocks tumble as the ground shifts.

#### 15. Landshatter
- **Element:** Earth
- **Category:** Offensive
- **Tier:** 3
- **MP Cost:** 34
- **Target:** Single enemy
- **Effect:** Spell power 60. The earth itself strikes.
- **Description:** The ground opens beneath the target like a jaw. Boulders the size of carts rise and crash together. The spirit-speakers say the land is angry.
- **Who learns:** Torren (Lv 30), Maren (Lv 34)
- **Visual:** The ground splits open with a seismic crack; massive boulders rise and collide on the target; dust cloud.

#### 16. Quake Stride
- **Element:** Earth
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 22
- **Target:** All enemies
- **Effect:** Spell power 24. AoE earth damage. Note: does not affect floating enemies.
- **Description:** The battlefield heaves and buckles. Everything touching the ground feels the deep-root's displeasure.
- **Who learns:** Torren (Lv 16), Maren (Lv 20)
- **Visual:** The entire ground surface ripples like water; cracks radiate outward; all grounded enemies bounce upward.

### Ley Spells

#### 17. Linebolt
- **Element:** Ley
- **Category:** Offensive
- **Tier:** 1
- **MP Cost:** 5
- **Target:** Single enemy
- **Effect:** Spell power 15. A bolt of raw ley energy.
- **Description:** The caster draws a thread from the nearest ley line and hurls it like a spear. Pure, gold-white, and humming with old power.
- **Who learns:** Maren (Lv 1), Cael (Lv 1), Edren (Lv 10)
- **Visual:** A gold-white beam fires from the caster's hand; shimmering motes trail behind; bright flash on impact.

#### 18. Ley Cascade
- **Element:** Ley
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 16
- **Target:** Single enemy
- **Effect:** Spell power 35. A torrent of channeled ley energy.
- **Description:** The caster opens themselves as a conduit and the ley line answers. Gold-white light pours through them and into the target.
- **Who learns:** Maren (Lv 15), Cael (Lv 17)
- **Visual:** The caster glows gold briefly; a wide beam of shimmering energy strikes the target; ley-motes drift upward.

#### 19. Convergence Flare
- **Element:** Ley
- **Category:** Offensive
- **Tier:** 3
- **MP Cost:** 38
- **Target:** Single enemy
- **Effect:** Spell power 65. The full force of ley line energy focused on one point.
- **Description:** Multiple ley lines answer at once. The target is caught in a crossfire of gold-white light that burns without heat.
- **Who learns:** Maren (Lv 34)
- **Visual:** Three beams of gold-white light converge on the target from different angles; a blinding flash; motes rain down.

#### 20. Ley Storm
- **Element:** Ley
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 25
- **Target:** All enemies
- **Effect:** Spell power 27. AoE ley energy.
- **Description:** The ley line beneath the battlefield surges. Energy erupts from the ground in scattered pillars of gold-white light.
- **Who learns:** Maren (Lv 22)
- **Visual:** Multiple columns of gold-white light erupt from the ground at random positions, striking all enemies.

### Spirit Spells

#### 21. Thornlash
- **Element:** Spirit
- **Category:** Offensive
- **Tier:** 1
- **MP Cost:** 4
- **Target:** Single enemy
- **Effect:** Spell power 13. A whip of living vine and thorn.
- **Description:** The spirits of the undergrowth lend their thorns. A tendril of green-white light lashes out, sharp as any blade.
- **Who learns:** Torren (Lv 1)
- **Visual:** A glowing green-white vine whips from below the caster and strikes the target; pale leaf particles scatter.

#### 22. Spiritfang
- **Element:** Spirit
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 15
- **Target:** Single enemy
- **Effect:** Spell power 33. A spirit-beast strikes the target.
- **Description:** Torren calls and the wilds answer. A translucent predator -- wolf, hawk, or serpent -- lunges from the spirit world.
- **Who learns:** Torren (Lv 14)
- **Visual:** A translucent pale-green animal shape (randomized) leaps from behind the caster and passes through the target.

#### 23. Ancestor's Fury
- **Element:** Spirit
- **Category:** Offensive
- **Tier:** 3
- **MP Cost:** 36
- **Target:** Single enemy
- **Effect:** Spell power 62. The collected wrath of generations of spirit-speakers.
- **Description:** The air fills with whispers. A hundred translucent figures rise from the earth and pour their fury into a single point.
- **Who learns:** Torren (Lv 32, after Act III spirit communion scene)
- **Visual:** Dozens of translucent humanoid shapes rise from the ground around the target; they converge and detonate in pale light.

#### 24. Wilds Chorus
- **Element:** Spirit
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 23
- **Target:** All enemies
- **Effect:** Spell power 25. AoE spirit damage.
- **Description:** Every living thing on the battlefield adds its voice. The chorus is beautiful -- and it cuts.
- **Who learns:** Torren (Lv 18)
- **Visual:** Pale green sound-wave ripples emanate from the caster in concentric rings, passing through all enemies.

### Non-Elemental Spells

#### 25. Fracture
- **Element:** Non-elemental
- **Category:** Offensive
- **Tier:** 2
- **MP Cost:** 18
- **Target:** Single enemy
- **Effect:** Spell power 36. Raw concussive force. Cannot be resisted elementally.
- **Description:** No fire, no ice, no light. Just force. The air between caster and target compresses and detonates.
- **Who learns:** Maren (Lv 20)
- **Visual:** A distortion-wave ripple travels from caster to target; on impact, a white flash and concussive ring.

#### 26. Unraveling Bolt
- **Element:** Non-elemental
- **Category:** Offensive
- **Tier:** 3
- **MP Cost:** 40
- **Target:** Single enemy
- **Effect:** Spell power 68. Immense non-elemental damage.
- **Description:** The caster tears at the fabric of magic itself. For a moment, the target simply ceases to be shielded by anything.
- **Who learns:** Maren (Lv 36)
- **Visual:** The target's sprite flickers and distorts; a web of white cracks appears over them; sharp detonation.

### Ultimate Spells

#### 27. Worldfire
- **Element:** Flame
- **Category:** Offensive
- **Tier:** 4
- **MP Cost:** 75
- **Target:** All enemies
- **Effect:** Spell power 95. Apocalyptic fire damage to all enemies.
- **Description:** The caster calls on every forge ever lit, every hearth ever warmed, every pyre ever burned. The battlefield becomes a furnace that rivals the sun.
- **Who learns:** Maren (Lv 42)
- **Visual:** The screen goes dark; a point of white-hot light appears center-screen and expands into a wall of fire that consumes everything; slow fade back to normal.

#### 28. Ley Ruin
- **Element:** Ley
- **Category:** Offensive
- **Tier:** 4
- **MP Cost:** 80
- **Target:** All enemies
- **Effect:** Spell power 100. The most powerful ley spell. Massive ley damage to all enemies.
- **Description:** Every ley line in range detonates simultaneously. The old magic screams as it is spent. This is the spell that ended the last age.
- **Who learns:** Maren (Lv 45, after discovering the Convergence text in the Ancient Ruins)
- **Visual:** Gold-white cracks appear across the entire screen like shattering glass; ley energy erupts from every crack; blinding flash; all enemies engulfed.

#### 29. Requiem of Thorns
- **Element:** Spirit
- **Category:** Offensive
- **Tier:** 4
- **MP Cost:** 70
- **Target:** All enemies
- **Effect:** Spell power 90. Devastating spirit-element AoE.
- **Description:** Torren sings the death-song of the Wilds. Every root, every vine, every sleeping spirit answers. The battlefield becomes a garden of killing beauty.
- **Who learns:** Torren (Lv 40, after completing his Pallor trial)
- **Visual:** Massive thorned vines erupt across the entire battlefield; pale green spirit-light fills the screen; translucent animal shapes charge through all enemies.

---

## Healing Magic

#### 30. Mend
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 1
- **MP Cost:** 3
- **Target:** Single ally
- **Effect:** Spell power 12. Restores minor HP.
- **Description:** A warm pulse of spirit-light knits torn flesh and soothes bruised bone. The simplest and most essential gift of the healers.
- **Who learns:** Torren (Lv 1), Maren (Lv 3), Edren (Lv 5)
- **Visual:** A soft green-white glow envelops the target from below; tiny leaf-like particles drift upward.

#### 31. Leybalm
- **Element:** Ley
- **Category:** Healing
- **Tier:** 1
- **MP Cost:** 3
- **Target:** Single ally
- **Effect:** Spell power 12. Restores minor HP using ley energy.
- **Description:** Gold-white ley-light seeps into wounds like warm water. The Valdris tradition's answer to the spirit-speakers' healing arts.
- **Who learns:** Maren (Lv 1), Edren (Lv 3), Cael (Lv 1)
- **Visual:** Gold-white motes descend onto the target like gentle rain; wounds glow briefly and fade.

#### 32. Deepmend
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 2
- **MP Cost:** 10
- **Target:** Single ally
- **Effect:** Spell power 30. Restores moderate HP.
- **Description:** The caster reaches deeper into the spirit-bond. Bones reset. Bleeding stops. The body remembers how to be whole.
- **Who learns:** Torren (Lv 12), Maren (Lv 14)
- **Visual:** A brighter green-white glow with visible energy streams flowing into the target; more pronounced leaf particles.

#### 33. Resurgence
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 3
- **MP Cost:** 28
- **Target:** Single ally
- **Effect:** Spell power 55. Restores heavy HP.
- **Description:** Life pours into the target like a river breaking a dam. For a moment, the boundary between living and spirit blurs.
- **Who learns:** Torren (Lv 26), Maren (Lv 30)
- **Visual:** A pillar of bright green-white light engulfs the target; translucent spirit shapes circle them; HP visibly climbs.

#### 34. Breath of the Wilds
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 1
- **MP Cost:** 6
- **Target:** All allies
- **Effect:** Spell power 8. Restores minor HP to entire party.
- **Description:** A soft wind carries the scent of moss and rain. Every wound eases. Every breath comes easier.
- **Who learns:** Torren (Lv 6), Maren (Lv 10), Edren (Act III cross-train, +50% MP cost)
- **Visual:** A gentle breeze of green-white particles sweeps across the entire party; each member glows briefly.

#### 35. Sanctuary
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 2
- **MP Cost:** 18
- **Target:** All allies
- **Effect:** Spell power 22. Restores moderate HP to entire party.
- **Description:** The caster draws a circle of protection. Inside it, the spirit world's warmth bleeds through and mends what is broken.
- **Who learns:** Torren (Lv 18), Maren (Lv 22)
- **Visual:** A glowing green-white circle appears on the ground beneath the party; warm light rises from it.

#### 36. Lifetide
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 3
- **MP Cost:** 42
- **Target:** All allies
- **Effect:** Spell power 45. Restores heavy HP to entire party.
- **Description:** The full power of the spirit-bond floods the party. Even the dying are pulled back. Torren says it feels like drowning in sunlight.
- **Who learns:** Torren (Lv 32)
- **Visual:** A wave of brilliant green-white energy washes over the entire party; translucent spirit shapes embrace each member.

#### 37. Kindle Breath
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 1
- **MP Cost:** 6
- **Target:** Single ally
- **Effect:** Grants regeneration: restores 5% max HP per turn for 4 turns.
- **Description:** A slow-burning warmth settles into the target's chest. The body heals itself, breath by breath.
- **Who learns:** Torren (Lv 4), Maren (Lv 8), Edren (Act III cross-train, +50% MP cost)
- **Visual:** A small, warm green-white ember orbits the target character; pulses faintly each turn.

#### 38. Rekindling
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 2
- **MP Cost:** 16
- **Target:** All allies
- **Effect:** Grants regeneration: restores 5% max HP per turn for 4 turns to entire party.
- **Description:** The ember spreads. Every heartbeat brings the party closer to whole. Torren learned this watching the Wilds regrow after wildfire.
- **Who learns:** Torren (Lv 20), Maren (Act III cross-train, +50% MP cost)
- **Visual:** Small green-white embers appear orbiting each party member; they pulse in sync.

#### 39. Spirit Recall
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 2
- **MP Cost:** 20
- **Target:** Single ally (Fainted)
- **Effect:** Revives a fallen ally at 25% of max HP.
- **Description:** The caster calls the departing spirit back. It is not a command -- it is a request. Sometimes the spirit listens.
- **Who learns:** Torren (Lv 14), Maren (Lv 18)
- **Visual:** A translucent version of the fallen character rises from their body, then sinks back in; they stir and rise.

#### 40. Second Dawn
- **Element:** Ley
- **Category:** Healing
- **Tier:** 3
- **MP Cost:** 40
- **Target:** Single ally (Fainted)
- **Effect:** Revives a fallen ally at 75% of max HP.
- **Description:** Ley energy floods the body like sunrise. The dead do not stay dead when the ley lines still burn.
- **Who learns:** Maren (Lv 28)
- **Visual:** A burst of gold-white light erupts from beneath the fallen character; they are lifted briefly and set back down, restored.

#### 41. Cleansing Draught
- **Element:** Spirit
- **Category:** Healing
- **Tier:** 1
- **MP Cost:** 5
- **Target:** Single ally
- **Effect:** Removes one negative status effect (Poison, Burn, Sleep, Confusion, Silence, Blind).
- **Description:** A pulse of clean spirit-light washes through the target, burning away corruption like morning fog.
- **Who learns:** Torren (Lv 3), Maren (Lv 5), Edren (Lv 8)
- **Visual:** A bright white flash pulses outward from the target's center; dark particles scatter away.

#### 42. Purge
- **Element:** Ley
- **Category:** Healing
- **Tier:** 2
- **MP Cost:** 14
- **Target:** Single ally
- **Effect:** Removes all negative status effects from one ally (including Petrify and Slow) EXCEPT Stop (must expire naturally) and Despair (can only be removed by Hollow Mend or Hope Shard item).
- **Description:** The full cleansing power of ley-light. Every shadow, every chain, every whisper -- burned away.
- **Who learns:** Maren (Lv 16), Torren (Lv 20)
- **Visual:** Gold-white light spirals around the target rapidly; all status effect icons shatter and dissolve.

#### 43. Leydraught
- **Element:** Ley
- **Category:** Healing
- **Tier:** 3
- **MP Cost:** 0
- **HP Cost:** 15% of caster's max HP
- **Target:** Single ally
- **Effect:** Restores 20% of target's max MP.
- **Description:** The caster trades their own life-force for magical energy. A desperate bargain that Valdris court mages once swore never to teach.
- **Who learns:** Maren (Lv 24)
- **Visual:** Red energy flows from the caster (their HP bar visibly drops); gold-white energy flows into the target's MP bar.

---

## Status Effect Magic

### Offensive Status Spells

#### 44. Vilethorn
- **Element:** Earth
- **Category:** Status
- **Tier:** 1
- **MP Cost:** 5
- **Target:** Single enemy
- **Effect:** 75% chance to inflict Poison. Poisoned targets lose 8% max HP per turn.
- **Description:** A barbed thorn, slick with something foul, embeds itself in the target. The Wilds have their own venom.
- **Who learns:** Torren (Lv 3), Maren (Lv 8)
- **Visual:** A dark green thorn projectile strikes the target; purple-green poison particles bubble up from the wound.

#### 45. Slumber Mote
- **Element:** Spirit
- **Category:** Status
- **Tier:** 1
- **MP Cost:** 6
- **Target:** Single enemy
- **Effect:** 70% chance to inflict Sleep. Target cannot act; wakes on receiving damage.
- **Description:** A drifting mote of pale spirit-light settles on the target's brow. Their eyes close. The spirit world calls them to rest.
- **Who learns:** Torren (Lv 5), Maren (Lv 6)
- **Visual:** A single pale green mote drifts slowly toward the target; on contact, their sprite droops and "Zzz" particles appear.

#### 46. Befuddle
- **Element:** Ley
- **Category:** Status
- **Tier:** 1
- **MP Cost:** 7
- **Target:** Single enemy
- **Effect:** 65% chance to inflict Confusion. Target attacks random allies or enemies.
- **Description:** A flash of contradictory ley-signals scrambles the target's thoughts. Friend becomes foe. Up becomes sideways.
- **Who learns:** Maren (Lv 8), Sable (Lv 18, story event)
- **Visual:** Spiraling gold-white motes orbit the target's head rapidly; their sprite sways; question marks and stars appear.

#### 47. Seal Tongue
- **Element:** Ley
- **Category:** Status
- **Tier:** 1
- **MP Cost:** 6
- **Target:** Single enemy
- **Effect:** 70% chance to inflict Silence. Target cannot cast spells.
- **Description:** A thread of ley energy wraps around the target's throat. Words form but no sound emerges. The silence is absolute.
- **Who learns:** Maren (Lv 6), Edren (Lv 12), Lira (Act III cross-train, +50% MP cost), Torren (Act III cross-train, +50% MP cost)
- **Visual:** A thin gold thread winds around the target's neck area; a speech-bubble icon appears crossed out.

#### 48. Grey Gaze
- **Element:** Ley
- **Category:** Status
- **Tier:** 2
- **MP Cost:** 18
- **Target:** Single enemy
- **Effect:** 50% chance to inflict Petrify. Target is removed from combat until cured.
- **Description:** The caster's eyes flash with old, cold light. The target's skin hardens. Their joints lock. In time, even the heart goes still.
- **Who learns:** Maren (Lv 22)
- **Visual:** A beam of grey-gold light shines from the caster's eyes; the target's sprite desaturates and freezes in place.

#### 49. Leaden Step
- **Element:** Earth
- **Category:** Status
- **Tier:** 1
- **MP Cost:** 5
- **Target:** Single enemy
- **Effect:** 75% chance to inflict Slow. Target's ATB gauge fills at 50% speed.
- **Description:** The ground clings. Every step costs twice the effort. The deep-root does not want you to leave.
- **Who learns:** Torren (Lv 6), Maren (Lv 10)
- **Visual:** Brown-grey energy crawls up the target's legs from the ground; their movement visibly stutters.

#### 50. Stillwatch
- **Element:** Frost
- **Category:** Status
- **Tier:** 2
- **MP Cost:** 16
- **Target:** Single enemy
- **Effect:** 55% chance to inflict Stop. Target's ATB gauge is frozen for 3 seconds of active battle time (not turn-based — the target takes no turns while Stopped; in Wait mode, the countdown pauses while sub-menus are open). See [combat-formulas.md](combat-formulas.md).
- **Description:** Time thickens around the target like ice forming on still water. They are held between one heartbeat and the next.
- **Who learns:** Maren (Lv 20)
- **Visual:** A ring of pale blue frost-energy encircles the target; they freeze mid-animation; frost particles hover motionless.

#### 51. Murk Veil
- **Element:** Spirit
- **Category:** Status
- **Tier:** 1
- **MP Cost:** 4
- **Target:** Single enemy
- **Effect:** 75% chance to inflict Blind. Target's physical attack accuracy reduced by 50%.
- **Description:** A veil of shadowed spirit-light falls across the target's eyes. The world dims to smudged shapes and uncertain movement.
- **Who learns:** Torren (Lv 4), Sable (Lv 12, story event)
- **Visual:** Dark wispy particles gather over the target's eyes; their sprite is briefly overlaid with shadow.

### AoE Status Spells

#### 52. Miasma
- **Element:** Earth
- **Category:** Status
- **Tier:** 2
- **MP Cost:** 20
- **Target:** All enemies
- **Effect:** 60% chance to inflict Poison on each target.
- **Description:** A low-hanging cloud of spore and decay rolls across the field. The Wilds exhale something foul.
- **Who learns:** Torren (Lv 14)
- **Visual:** A green-purple cloud drifts across all enemies at ground level; poison bubbles appear on affected targets.

#### 53. Eventide
- **Element:** Spirit
- **Category:** Status
- **Tier:** 2
- **MP Cost:** 22
- **Target:** All enemies
- **Effect:** 55% chance to inflict Sleep on each target.
- **Description:** The caster hums an old Thornmere lullaby. The air grows heavy. Eyelids grow heavier.
- **Who learns:** Torren (Lv 16)
- **Visual:** Musical note particles drift across the battlefield; pale green motes settle on each enemy; affected targets slump.

#### 54. Bogsink
- **Element:** Earth
- **Category:** Status
- **Tier:** 2
- **MP Cost:** 20
- **Target:** All enemies
- **Effect:** 60% chance to inflict Slow on each target.
- **Description:** The ground softens to marsh. Every step sinks deeper. The wetlands do not hurry, and now neither do you.
- **Who learns:** Torren (Lv 15)
- **Visual:** The ground beneath all enemies turns dark and muddy; their sprites sink slightly; brown particles rise.

#### 55. Flashblind
- **Element:** Storm
- **Category:** Status
- **Tier:** 2
- **MP Cost:** 19
- **Target:** All enemies
- **Effect:** 60% chance to inflict Blind on each target.
- **Description:** A burst of white-violet lightning with no thunder -- all flash, no force. The afterimage burns.
- **Who learns:** Maren (Lv 14)
- **Visual:** A brilliant white-violet flash fills the screen briefly; affected enemies have dark overlays on their sprites.

---

## Buff & Debuff Magic

### Buffs (Party)

#### 56. Ironhide
- **Element:** Earth
- **Category:** Buff
- **Tier:** 1
- **MP Cost:** 6
- **Target:** Single ally
- **Effect:** Increases physical defense by 40% for 5 turns.
- **Description:** The caster calls on the deep-root's patience. Skin hardens. Muscle tightens. The body becomes its own armor.
- **Who learns:** Edren (Lv 5), Torren (Lv 8), Maren (Lv 10), Lira (Ironhaven Foundry schematic)
- **Visual:** Brown-grey energy ripples across the target's sprite; a brief stone-texture overlay appears and fades.

#### 57. Wardglass
- **Element:** Ley
- **Category:** Buff
- **Tier:** 1
- **MP Cost:** 6
- **Target:** Single ally
- **Effect:** Increases magic defense by 40% for 5 turns.
- **Description:** A pane of shimmering ley energy interposes itself between the target and the world. Spells slide off like rain on glass.
- **Who learns:** Maren (Lv 4), Edren (Lv 8), Cael (Lv 6), Lira (Ashmark Archives schematic), Torren (Act III cross-train, +50% MP cost)
- **Visual:** A translucent gold-white barrier flickers into existence around the target; faint hexagonal grid pattern.

#### 58. Quickstep
- **Element:** Storm
- **Category:** Buff
- **Tier:** 2
- **MP Cost:** 14
- **Target:** Single ally
- **Effect:** Increases ATB fill speed by 50% for 5 turns.
- **Description:** Lightning crackles along the target's nerves. Everything slows -- except them.
- **Who learns:** Maren (Lv 12), Cael (Lv 14)
- **Visual:** Yellow-white sparks crackle along the target's outline; their idle animation speeds up slightly.

#### 59. Leymirror
- **Element:** Ley
- **Category:** Buff
- **Tier:** 2
- **MP Cost:** 18
- **Target:** Single ally
- **Effect:** Grants Reflect status. The next 3 spells targeting this ally are bounced back at the caster. Does not reflect healing.
- **Description:** A mirror of pure ley energy. What is sent is returned. The old court mages called it "the debater's courtesy."
- **Who learns:** Maren (Lv 16)
- **Visual:** A spinning disc of gold-white light appears in front of the target; it occasionally flickers with reflected images.

#### 60. Rallying Cry
- **Element:** Non-elemental
- **Category:** Buff
- **Tier:** 1
- **MP Cost:** 8
- **Target:** Single ally
- **Effect:** Increases physical attack by 30% for 5 turns.
- **Description:** Edren's voice cuts through the din of battle. His words carry old authority -- the kind that makes tired arms strong again.
- **Who learns:** Edren (Lv 6)
- **Visual:** The caster raises a fist; a red-gold aura briefly flares around the target; their attack animation becomes sharper.

#### 61. Attunement
- **Element:** Ley
- **Category:** Buff
- **Tier:** 2
- **MP Cost:** 14
- **Target:** Single ally
- **Effect:** Increases magic attack by 30% for 5 turns.
- **Description:** The caster tunes the target's connection to the ley lines like tightening a lute string. Every spell rings truer.
- **Who learns:** Maren (Lv 14), Cael (Lv 16)
- **Visual:** Gold-white ley-lines trace along the target's arms and hands; they glow faintly.

#### 62. Last Breath
- **Element:** Spirit
- **Category:** Buff
- **Tier:** 3
- **MP Cost:** 35
- **Target:** Single ally
- **Effect:** Grants auto-revive. If the target is Fainted, they automatically revive with 30% HP once. Lasts until triggered or battle ends.
- **Description:** A spirit lingers at the target's shoulder -- a guardian from the other side, ready to pull them back from the edge.
- **Who learns:** Torren (Lv 28), Maren (Lv 32)
- **Visual:** A translucent pale-green figure appears briefly behind the target, then fades to a faint green glow at their feet.

#### 63. Bulwark Line
- **Element:** Earth
- **Category:** Buff
- **Tier:** 2
- **MP Cost:** 20
- **Target:** All allies
- **Effect:** Increases physical defense by 25% for 4 turns (entire party).
- **Description:** The deep-root answers for everyone. The ground trembles, and every soul standing on friendly soil feels stronger.
- **Who learns:** Edren (Lv 18), Torren (Lv 22)
- **Visual:** A ripple of brown-gold energy expands outward from the caster's feet, passing under each party member.

#### 64. Leyward
- **Element:** Ley
- **Category:** Buff
- **Tier:** 2
- **MP Cost:** 20
- **Target:** All allies
- **Effect:** Increases magic defense by 25% for 4 turns (entire party).
- **Description:** A web of ley energy stretches across the party like a golden net. Everything magical dims on the other side.
- **Who learns:** Maren (Lv 18), Edren (Lv 22)
- **Visual:** Gold-white threads briefly connect all party members in a web pattern; each member flickers with a ward-glow.

### Debuffs (Enemy)

#### 65. Sunder
- **Element:** Non-elemental
- **Category:** Debuff
- **Tier:** 1
- **MP Cost:** 7
- **Target:** Single enemy
- **Effect:** Reduces physical defense by 30% for 5 turns. 80% hit rate.
- **Description:** A pulse of raw force finds the weak point in the target's guard. Armor buckles. Stances break.
- **Who learns:** Edren (Lv 10), Maren (Lv 12)
- **Visual:** A concussive ripple strikes the target; their armor/outline flickers red briefly; a downward arrow icon appears.

#### 66. Fray
- **Element:** Non-elemental
- **Category:** Debuff
- **Tier:** 1
- **MP Cost:** 7
- **Target:** Single enemy
- **Effect:** Reduces magic defense by 30% for 5 turns. 80% hit rate.
- **Description:** The target's magical defenses unravel like old cloth. Maren learned this by studying how ley lines fray at their ends.
- **Who learns:** Maren (Lv 10)
- **Visual:** Thread-like wisps of light are pulled away from the target's outline; they dissolve in the air.

#### 67. Crumble
- **Element:** Earth
- **Category:** Debuff
- **Tier:** 2
- **MP Cost:** 12
- **Target:** Single enemy
- **Effect:** Reduces target's elemental resistance by one tier (immune -> resist -> normal -> weak) for the target's dominant element. 70% hit rate. Lasts 5 turns.
- **Description:** The deep-root finds the fault line and pulls. Everything has a crack. Everything can be opened.
- **Who learns:** Torren (Lv 16), Maren (Lv 20)
- **Visual:** Visible crack-lines spread across the target's sprite; small fragments chip away; a broken shield icon appears.

#### 68. Dispersion
- **Element:** Ley
- **Category:** Debuff
- **Tier:** 2
- **MP Cost:** 14
- **Target:** Single enemy
- **Effect:** Removes all positive status effects (buffs) from the target.
- **Description:** A surge of ley energy washes over the target and scours away every enhancement, every ward, every borrowed strength.
- **Who learns:** Maren (Lv 18)
- **Visual:** Gold-white light spirals around the target; all buff icons shatter; colored particles scatter away.

#### 69. Drag Tide
- **Element:** Storm
- **Category:** Debuff
- **Tier:** 1
- **MP Cost:** 6
- **Target:** Single enemy
- **Effect:** Reduces ATB fill speed by 30% for 5 turns. 75% hit rate.
- **Description:** The wind shifts against the target. Every motion meets resistance. The storm wants them still.
- **Who learns:** Maren (Lv 8), Torren (Lv 10)
- **Visual:** Swirling grey-violet wind particles orbit the target in reverse; their animation subtly slows.

#### 70. Dampening Field
- **Element:** Ley
- **Category:** Debuff
- **Tier:** 2
- **MP Cost:** 14
- **Target:** Single enemy
- **Effect:** Reduces magic attack by 30% for 5 turns. 75% hit rate.
- **Description:** The ley lines around the target go quiet. Their magic dims. Their incantations stutter.
- **Who learns:** Maren (Lv 16)
- **Visual:** A dark gold circle appears on the ground beneath the target; their magical glow (if any) noticeably dims.

#### 71. Mass Dispersion
- **Element:** Ley
- **Category:** Debuff
- **Tier:** 3
- **MP Cost:** 30
- **Target:** All enemies
- **Effect:** Removes all positive status effects (buffs) from all enemies.
- **Description:** The ley lines convulse. Every ward, every shield, every borrowed power across the entire battlefield shatters at once.
- **Who learns:** Maren (Lv 30)
- **Visual:** A gold-white shockwave radiates from the caster across all enemies; all buff icons on all enemies shatter.

---

## Utility & Special Magic

#### 72. Spiritsight
- **Element:** Spirit
- **Category:** Utility
- **Tier:** 1
- **MP Cost:** 3
- **Target:** Single enemy
- **Effect:** Reveals target's HP, MP, elemental weaknesses, resistances, and steal-able items.
- **Description:** The caster peers through the spirit world's lens. Every creature has a shape in that place -- and every shape has seams.
- **Who learns:** Torren (Lv 1), Maren (Lv 4), Sable (Lv 8, story event), Lira (personal upgrade, Lv 10)
- **Visual:** A translucent pale-green overlay briefly appears over the target; data text populates a scan window.

#### 73. Waymark
- **Element:** Ley
- **Category:** Utility
- **Tier:** 1
- **MP Cost:** 5
- **Target:** Self/Party (out of combat only)
- **Effect:** Instantly teleport the party to the entrance of the current dungeon. Cannot be used in boss rooms.
- **Description:** The caster marks a thread back to the nearest ley line junction. When pulled, the thread retracts -- and the party with it.
- **Who learns:** Maren (Lv 8)
- **Visual:** Gold-white thread appears at the caster's feet and streaks toward the screen edge; a brief flash; scene transition.

#### 74. Linewalk
- **Element:** Ley
- **Category:** Utility
- **Tier:** 2
- **MP Cost:** 12
- **Target:** Self/Party (out of combat, overworld only)
- **Effect:** Instantly teleport to any previously visited town. Opens a selection menu.
- **Description:** The great ley lines connect every settlement that was built upon them. Maren walks those lines like roads.
- **Who learns:** Maren (Lv 20)
- **Visual:** The party dissolves into gold-white motes that streak upward; scene transition; they reform at the destination.

#### 75. Veilstep
- **Element:** Spirit
- **Category:** Utility
- **Tier:** 2
- **MP Cost:** 12
- **Target:** Self/Party (field use)
- **Effect:** Reduces random encounter rate by 75% for 120 seconds (real time) or 200 steps.
- **Description:** The caster steps half into the spirit world. The party's presence dims. Predators look past them. The Wilds forget they were there.
- **Who learns:** Torren (Lv 10)
- **Visual:** The party sprites become slightly translucent; faint pale-green motes drift around them.

#### 76. Drift
- **Element:** Storm
- **Category:** Utility
- **Tier:** 1
- **MP Cost:** 8
- **Target:** All allies (in combat)
- **Effect:** Grants Float status to entire party. Floating characters are immune to Earth-element spells and ground-based attacks. Lasts until end of battle.
- **Description:** The wind picks the party up -- just barely. Feet hover an inch above the ground. The earth cannot reach what the sky holds.
- **Who learns:** Maren (Lv 12)
- **Visual:** Party members' sprites lift slightly off the ground; a gentle upward wind particle effect persists beneath them.

#### 77. Smokeveil
- **Element:** Non-elemental
- **Category:** Utility
- **Tier:** 1
- **MP Cost:** 4
- **Target:** Self/Party
- **Effect:** Guarantees escape from non-boss encounters. In combat, immediately ends the battle with no rewards.
- **Description:** A burst of acrid smoke -- Sable's trademark exit. By the time it clears, they are gone.
- **Who learns:** Sable (Lv 1, innate)
- **Visual:** A cloud of dark grey smoke billows outward from the party's position; screen fades to black; battle ends.

#### 78. Glintmark
- **Element:** Non-elemental
- **Category:** Utility
- **Tier:** 1
- **MP Cost:** 3
- **Target:** Single enemy
- **Effect:** Marks a target. Marked targets take 10% more damage from all sources for 3 turns. Also reveals hidden/steal-able items (like a lesser Spiritsight).
- **Description:** Sable's eye for value never rests. A flick of the wrist and the target's weak points shimmer -- along with anything worth taking.
- **Who learns:** Sable (Lv 5, story event)
- **Visual:** A glinting spark bounces off the target; a faint golden outline highlights them; small item icons may appear briefly.

#### 79. Forgeshield
- **Element:** Flame
- **Category:** Utility
- **Tier:** 2
- **MP Cost:** 12
- **Target:** Single ally
- **Effect:** Absorbs the next instance of magical damage directed at the target (up to a threshold of 150 + caster MAG). Then shatters.
- **Description:** Lira forges a barrier of condensed heat that devours incoming magic. Arcanite engineering at its finest -- one perfect shield, one use.
- **Who learns:** Lira (Lv 14)
- **Visual:** A translucent orange-red hexagonal barrier appears in front of the target; it hums with forge-heat.

---

## Void Magic (Pallor)

Void magic is the domain of the Pallor and those it has claimed. Most Void spells are enemy-only. A small number become available to the party after Cael's defeat, as bittersweet rewards.

### Enemy-Only Void Spells

#### 80. Hollow Touch
- **Element:** Void
- **Category:** Offensive (Enemy only)
- **Tier:** 2
- **MP Cost:** -- (enemies do not use MP)
- **Target:** Single party member
- **Effect:** Spell power 35. Deals Void damage and drains HP equal to 25% of damage dealt, healing the caster.
- **Description:** Grey fingers reach through the air. Where they touch, warmth drains away. The Pallor takes what it needs.
- **Visual:** A grey-static hand reaches from the enemy toward a party member; grey particles flow back to the caster.

#### 81. Ashen Whisper
- **Element:** Void
- **Category:** Status (Enemy only)
- **Tier:** 2
- **MP Cost:** --
- **Target:** Single party member
- **Effect:** 60% chance to inflict Despair (new status). Despair: ATB fill speed reduced by 25%, all damage dealt reduced by 20%. Lasts 4 turns. Cannot be stacked but can be refreshed.
- **Description:** A voice you almost recognize speaks from nowhere. It says the thing you most fear is true. Your hands go numb.
- **Visual:** Grey static coalesces near the target's ear; their sprite dims and droops; a grey down-arrow icon appears.

#### 82. Pallor Tide
- **Element:** Void
- **Category:** Offensive (Enemy only)
- **Tier:** 3
- **MP Cost:** --
- **Target:** All party members
- **Effect:** Spell power 45. Void damage to entire party.
- **Description:** The grey rolls in like fog. It is not wind. It is not cold. It is the absence of both. Everything dims.
- **Visual:** A wave of grey static rolls across the entire party from right to left; all sprites briefly desaturate.

#### 83. Silence of Ages
- **Element:** Void
- **Category:** Status (Enemy only)
- **Tier:** 3
- **MP Cost:** --
- **Target:** All party members
- **Effect:** 50% chance to inflict Silence on each party member. Additionally suppresses all active buff effects for 2 turns (buffs resume after).
- **Description:** Sound stops. The ley lines go quiet. Every ward, every blessing, every whispered prayer -- silenced.
- **Visual:** A grey pulse radiates outward; all sound effects mute briefly; all party buff icons dim and crack.

#### 84. Drinker of Days
- **Element:** Void
- **Category:** Offensive (Enemy only)
- **Tier:** 3
- **MP Cost:** --
- **Target:** Single party member
- **Effect:** Drains MP equal to 30% of target's max MP. No MP is gained by the caster (it is simply destroyed).
- **Description:** The Pallor does not steal your magic. It erases it. The ley lines you were drawing from simply... forget you exist.
- **Visual:** Gold-white motes are pulled from the target and dissolve into grey particles; the target's MP bar visibly drops.

#### 85. Unmaking
- **Element:** Void
- **Category:** Offensive (Enemy only)
- **Tier:** 4
- **MP Cost:** --
- **Target:** Single party member
- **Effect:** Spell power 85. Massive Void damage. If target HP falls below 10% from this spell, they are instantly Fainted.
- **Description:** The Pallor looks at you and decides you were never meant to exist. For a moment, you agree.
- **Visual:** The target's sprite is broken into pixel fragments that scatter outward; grey light fills the gaps; they reform (if alive) or collapse.

#### 86. Grey Horizon
- **Element:** Void
- **Category:** Status (Enemy only)
- **Tier:** 4
- **MP Cost:** --
- **Target:** All party members
- **Effect:** Inflicts Despair on all party members (45% per target) AND suppresses all healing effects by 50% for 3 turns.
- **Description:** The horizon goes grey. Not dark -- grey. There is no sunrise coming. There never was. The Pallor shows you the truth it wants you to believe.
- **Visual:** The battle background desaturates completely; grey static creeps from the edges; all party sprites dim; a cracked sun icon appears.

#### 87. The Weight
- **Element:** Void
- **Category:** Special (Enemy only -- Cael boss only)
- **Tier:** 4
- **MP Cost:** --
- **Target:** All party members
- **Effect:** Spell power 100. Massive Void damage to all. Inflicts Despair on all targets (no resistance check). Used only in Cael's final boss phase.
- **Description:** Cael stops fighting. He looks at the party -- his friends, his family -- and the Pendulum pulses. Every grief he has ever felt, every loss the party has ever suffered, crashes down at once.
- **Visual:** The screen goes grey. Cael's sprite is consumed by a towering grey silhouette. A shockwave of grey static engulfs the entire party. All color drains briefly. Slow recovery.

### Party-Learnable Void Spells (Post-Game)

#### 88. Hollow Mend
- **Element:** Void
- **Category:** Healing (unique)
- **Tier:** 3
- **MP Cost:** 30
- **Target:** Single ally
- **Effect:** Spell power 55. Restores heavy HP. Additionally removes Despair status. The only spell that can reliably remove Despair outside of items.
- **Description:** Cael's last gift. He could not save himself, but he learned how to push the grey back from someone else. The warmth it brings tastes like grief.
- **Who learns:** Maren (post-game, found in the Convergence meadow after defeating Cael). Torren (post-game, through a spirit communion at the same location).
- **Visual:** Grey-white light gathers at the target's chest; it flickers between grey and warm gold before settling on gold; HP restores.

#### 89. Pendulum's Echo
- **Element:** Void
- **Category:** Offensive
- **Tier:** 3
- **MP Cost:** 45
- **Target:** Single enemy
- **Effect:** Spell power 70. Void damage. Additionally has a 40% chance to inflict Despair on the target.
- **Description:** The Pendulum is shattered, but its echo lingers. To cast this spell is to remember what it cost. The damage it deals carries the weight of that memory.
- **Who learns:** Maren (post-game, found in the ruins of the Pendulum chamber)
- **Visual:** A ghostly image of the Pendulum swings across the screen; grey static trails behind it; on contact with the target, a grey shockwave.

---

## Spell Index by Character

### Maren (Court Mage -- Ley Line Tradition)

Maren has the largest spell list in the game. She is the party's primary offensive caster and secondary healer.

| # | Spell | Element | Category | Tier | Lv/Event |
|---|-------|---------|----------|------|----------|
| 1 | Ember Lance | Flame | Offensive | 1 | Lv 1 |
| 17 | Linebolt | Ley | Offensive | 1 | Lv 1 |
| 31 | Leybalm | Ley | Healing | 1 | Lv 1 |
| 30 | Mend | Spirit | Healing | 1 | Lv 3 |
| 5 | Rime Shard | Frost | Offensive | 1 | Lv 1 (innate) |
| 9 | Arc Snap | Storm | Offensive | 1 | Lv 3 |
| 57 | Wardglass | Ley | Buff | 1 | Lv 4 |
| 72 | Spiritsight | Spirit | Utility | 1 | Lv 4 |
| 41 | Cleansing Draught | Spirit | Healing | 1 | Lv 5 |
| 13 | Tremor Spike | Earth | Offensive | 1 | Lv 5 |
| 47 | Seal Tongue | Ley | Status | 1 | Lv 6 |
| 45 | Slumber Mote | Spirit | Status | 1 | Lv 6 |
| 37 | Kindle Breath | Spirit | Healing | 1 | Lv 8 |
| 46 | Befuddle | Ley | Status | 1 | Lv 8 |
| 69 | Drag Tide | Storm | Debuff | 1 | Lv 8 |
| 73 | Waymark | Ley | Utility | 1 | Lv 8 |
| 44 | Vilethorn | Earth | Status | 1 | Lv 8 |
| 56 | Ironhide | Earth | Buff | 1 | Lv 10 |
| 49 | Leaden Step | Earth | Status | 1 | Lv 10 |
| 34 | Breath of the Wilds | Spirit | Healing | 1 | Lv 10 |
| 66 | Fray | Non-elemental | Debuff | 1 | Lv 10 |
| 76 | Drift | Storm | Utility | 1 | Lv 12 |
| 58 | Quickstep | Storm | Buff | 2 | Lv 12 |
| 65 | Sunder | Non-elemental | Debuff | 1 | Lv 12 |
| 2 | Kindlepyre | Flame | Offensive | 2 | Lv 14 |
| 6 | Hoarfall | Frost | Offensive | 2 | Lv 14 |
| 32 | Deepmend | Spirit | Healing | 2 | Lv 14 |
| 61 | Attunement | Ley | Buff | 2 | Lv 14 |
| 55 | Flashblind | Storm | Status | 2 | Lv 14 |
| 18 | Ley Cascade | Ley | Offensive | 2 | Lv 15 |
| 42 | Purge | Ley | Healing | 2 | Lv 16 |
| 14 | Rootgrip | Earth | Offensive | 2 | Lv 16 |
| 59 | Leymirror | Ley | Buff | 2 | Lv 16 |
| 70 | Dampening Field | Ley | Debuff | 2 | Lv 16 |
| 4 | Scorch Sweep | Flame | Offensive | 2 | Lv 18 |
| 8 | Whiteout | Frost | Offensive | 2 | Lv 18 |
| 39 | Spirit Recall | Spirit | Healing | 2 | Lv 18 |
| 64 | Leyward | Ley | Buff | 2 | Lv 18 |
| 68 | Dispersion | Ley | Debuff | 2 | Lv 18 |
| 25 | Fracture | Non-elemental | Offensive | 2 | Lv 20 |
| 12 | Squall Line | Storm | Offensive | 2 | Lv 20 |
| 16 | Quake Stride | Earth | Offensive | 2 | Lv 20 |
| 50 | Stillwatch | Frost | Status | 2 | Lv 20 |
| 67 | Crumble | Earth | Debuff | 2 | Lv 20 |
| 74 | Linewalk | Ley | Utility | 2 | Lv 20 |
| 35 | Sanctuary | Spirit | Healing | 2 | Lv 22 |
| 20 | Ley Storm | Ley | Offensive | 2 | Lv 22 |
| 48 | Grey Gaze | Ley | Status | 2 | Lv 22 |
| 43 | Leydraught | Ley | Healing | 3 | Lv 24 |
| 40 | Second Dawn | Ley | Healing | 3 | Lv 28 |
| 3 | Crucible Wrath | Flame | Offensive | 3 | Lv 30 |
| 7 | Glacial Tomb | Frost | Offensive | 3 | Lv 30 |
| 33 | Resurgence | Spirit | Healing | 3 | Lv 30 |
| 71 | Mass Dispersion | Ley | Debuff | 3 | Lv 30 |
| 62 | Last Breath | Spirit | Buff | 3 | Lv 32 |
| 11 | Tempest Reign | Storm | Offensive | 3 | Lv 32 |
| 15 | Landshatter | Earth | Offensive | 3 | Lv 34 |
| 19 | Convergence Flare | Ley | Offensive | 3 | Lv 34 |
| 26 | Unraveling Bolt | Non-elemental | Offensive | 3 | Lv 36 |
| 27 | Worldfire | Flame | Offensive | 4 | Lv 42 |
| 28 | Ley Ruin | Ley | Offensive | 4 | Lv 45 + Ancient Ruins text |
| 89 | Pendulum's Echo | Void | Offensive | 3 | Post-game (Pendulum chamber) |
| 88 | Hollow Mend | Void | Healing | 3 | Post-game (Convergence meadow) |
| 38 | Rekindling | Spirit | Healing | 2 | Act III scene with Torren (cross-train, +50% MP cost) |

**Total: 64 spells** (63 base + 1 cross-trained; the most of any character by far)

### Edren (Knight-Commander -- Limited Ley Line Tradition)

Edren's spell list is narrow and focused on protection and leadership.

| # | Spell | Element | Category | Tier | Lv/Event |
|---|-------|---------|----------|------|----------|
| 31 | Leybalm | Ley | Healing | 1 | Lv 3 |
| 30 | Mend | Spirit | Healing | 1 | Lv 5 |
| 56 | Ironhide | Earth | Buff | 1 | Lv 5 |
| 60 | Rallying Cry | Non-elemental | Buff | 1 | Lv 6 |
| 5 | Rime Shard | Frost | Offensive | 1 | Lv 8 |
| 41 | Cleansing Draught | Spirit | Healing | 1 | Lv 8 |
| 57 | Wardglass | Ley | Buff | 1 | Lv 8 |
| 17 | Linebolt | Ley | Offensive | 1 | Lv 10 |
| 65 | Sunder | Non-elemental | Debuff | 1 | Lv 10 |
| 47 | Seal Tongue | Ley | Status | 1 | Lv 12 |
| 63 | Bulwark Line | Earth | Buff | 2 | Lv 18 |
| 64 | Leyward | Ley | Buff | 2 | Lv 22 |
| 37 | Kindle Breath | Spirit | Healing | 1 | Act III campfire scene (cross-train from Torren, +50% MP cost) |
| 34 | Breath of the Wilds | Spirit | Healing | 1 | Act III campfire scene (cross-train from Torren, +50% MP cost) |

**Total: 14 spells** (12 base + 2 cross-trained)

### Lira (Forgewright -- Arcanite Tradition)

Lira's spells are Flame-focused offensive and technical support. Her "Forgewright" unique command handles most of her combat utility.

| # | Spell | Element | Category | Tier | Lv/Event |
|---|-------|---------|----------|------|----------|
| 1 | Ember Lance | Flame | Offensive | 1 | Lv 5 |
| 79 | Forgeshield | Flame | Utility | 2 | Lv 14 |
| 2 | Kindlepyre | Flame | Offensive | 2 | Lv 18 |
| 4 | Scorch Sweep | Flame | Offensive | 2 | Lv 22 |
| 3 | Crucible Wrath | Flame | Offensive | 3 | Lv 35 |

**Forge-Schematic Spells** (learned from Carradan schematics found in specific locations):

| # | Spell | Element | Category | Tier | Source |
|---|-------|---------|----------|------|--------|
| 56 | Ironhide | Earth | Buff | 1 | Ironhaven Foundry schematic |
| 57 | Wardglass | Ley | Buff | 1 | Ashmark Archives schematic |

**Personal Upgrade:**

| # | Spell | Element | Category | Tier | Source |
|---|-------|---------|----------|------|--------|
| 72 | Spiritsight | Spirit | Utility | 1 | Lira's personal upgrade (Lv 10) |

**Cross-Trained Spell** (Act III, +50% MP cost):

| # | Spell | Element | Category | Tier | Source |
|---|-------|---------|----------|------|--------|
| 47 | Seal Tongue | Ley | Status | 1 | Act III scene with Maren |

**Total: 9 spells** (5 level-up + 2 schematic + 1 personal upgrade + 1 cross-trained)

### Torren (Spirit-Speaker -- Spirit Tradition)

Torren is the party's primary healer and nature-element caster. His Spirit and Earth spells are unique to him in several cases.

| # | Spell | Element | Category | Tier | Lv/Event |
|---|-------|---------|----------|------|----------|
| 21 | Thornlash | Spirit | Offensive | 1 | Lv 1 |
| 13 | Tremor Spike | Earth | Offensive | 1 | Lv 1 |
| 30 | Mend | Spirit | Healing | 1 | Lv 1 |
| 72 | Spiritsight | Spirit | Utility | 1 | Lv 1 |
| 44 | Vilethorn | Earth | Status | 1 | Lv 3 |
| 41 | Cleansing Draught | Spirit | Healing | 1 | Lv 3 |
| 51 | Murk Veil | Spirit | Status | 1 | Lv 4 |
| 37 | Kindle Breath | Spirit | Healing | 1 | Lv 4 |
| 45 | Slumber Mote | Spirit | Status | 1 | Lv 5 |
| 49 | Leaden Step | Earth | Status | 1 | Lv 6 |
| 34 | Breath of the Wilds | Spirit | Healing | 1 | Lv 6 |
| 56 | Ironhide | Earth | Buff | 1 | Lv 8 |
| 69 | Drag Tide | Storm | Debuff | 1 | Lv 10 |
| 75 | Veilstep | Spirit | Utility | 2 | Lv 10 |
| 14 | Rootgrip | Earth | Offensive | 2 | Lv 12 |
| 32 | Deepmend | Spirit | Healing | 2 | Lv 12 |
| 22 | Spiritfang | Spirit | Offensive | 2 | Lv 14 |
| 39 | Spirit Recall | Spirit | Healing | 2 | Lv 14 |
| 52 | Miasma | Earth | Status | 2 | Lv 14 |
| 54 | Bogsink | Earth | Status | 2 | Lv 15 |
| 67 | Crumble | Earth | Debuff | 2 | Lv 16 |
| 16 | Quake Stride | Earth | Offensive | 2 | Lv 16 |
| 53 | Eventide | Spirit | Status | 2 | Lv 16 |
| 24 | Wilds Chorus | Spirit | Offensive | 2 | Lv 18 |
| 35 | Sanctuary | Spirit | Healing | 2 | Lv 18 |
| 42 | Purge | Ley | Healing | 2 | Lv 20 |
| 38 | Rekindling | Spirit | Healing | 2 | Lv 20 |
| 63 | Bulwark Line | Earth | Buff | 2 | Lv 22 |
| 33 | Resurgence | Spirit | Healing | 3 | Lv 26 |
| 62 | Last Breath | Spirit | Buff | 3 | Lv 28 |
| 15 | Landshatter | Earth | Offensive | 3 | Lv 30 |
| 23 | Ancestor's Fury | Spirit | Offensive | 3 | Lv 32 + Act III spirit communion |
| 36 | Lifetide | Spirit | Healing | 3 | Lv 32 |
| 29 | Requiem of Thorns | Spirit | Offensive | 4 | Lv 40 + Pallor trial |
| 88 | Hollow Mend | Void | Healing | 3 | Post-game (Convergence meadow) |
| 57 | Wardglass | Ley | Buff | 1 | Act III scene with Maren (cross-train, +50% MP cost) |
| 47 | Seal Tongue | Ley | Status | 1 | Act III scene with Maren (cross-train, +50% MP cost) |

**Total: 37 spells** (35 base + 2 cross-trained)

### Sable (Streetwise -- Minimal Magic)

Sable is not a mage. Her 5 spells are practical tools, learned through story events and street experience.

| # | Spell | Element | Category | Tier | Lv/Event |
|---|-------|---------|----------|------|----------|
| 77 | Smokeveil | Non-elemental | Utility | 1 | Innate |
| 78 | Glintmark | Non-elemental | Utility | 1 | Lv 5, story event |
| 72 | Spiritsight | Spirit | Utility | 1 | Lv 8, story event (Torren teaches her) |
| 51 | Murk Veil | Spirit | Status | 1 | Lv 12, story event |
| 46 | Befuddle | Ley | Status | 1 | Lv 18, story event (Maren teaches her) |

**Total: 5 spells**

### Cael (Acts I-II Party Member / Later Boss)

While in the party, Cael has a solid set of Ley Line spells. After his corruption, these convert to Void-element boss abilities.

**Party version (Acts I-II):**

| # | Spell | Element | Category | Tier | Lv/Event |
|---|-------|---------|----------|------|----------|
| 1 | Ember Lance | Flame | Offensive | 1 | Lv 1 |
| 17 | Linebolt | Ley | Offensive | 1 | Lv 1 |
| 31 | Leybalm | Ley | Healing | 1 | Lv 1 |
| 5 | Rime Shard | Frost | Offensive | 1 | Lv 3 |
| 9 | Arc Snap | Storm | Offensive | 1 | Lv 5 |
| 57 | Wardglass | Ley | Buff | 1 | Lv 6 |
| 2 | Kindlepyre | Flame | Offensive | 2 | Lv 14 |
| 58 | Quickstep | Storm | Buff | 2 | Lv 14 |
| 61 | Attunement | Ley | Buff | 2 | Lv 16 |
| 6 | Hoarfall | Frost | Offensive | 2 | Lv 16 |
| 18 | Ley Cascade | Ley | Offensive | 2 | Lv 17 |
| 10 | Galeforce | Storm | Offensive | 2 | Lv 18 |

**Total: 12 spells (party version)**

**Boss version (Void-corrupted):** Cael uses enemy-only Void spells (#80-87) plus corrupted versions of his party spells. His corrupted spells use the same animations but with grey-static overlays replacing their original elemental colors.

---

## Status Effect Reference

For quick reference, here are all status effects that spells in this system can inflict or cure.

| Status | Type | Effect | Duration | Cured By* |
|--------|------|--------|----------|----------|
| Poison | Negative | Lose 8% max HP per turn | Until cured | Cleansing Draught, Purge, Antidote item |
| Burn | Negative | Lose 5% max HP per turn (Flame-typed damage) | 3 turns | Cleansing Draught, Purge, Antidote item |
| Sleep | Negative | Cannot act; wake on damage | Until cured or damaged | Cleansing Draught, Purge, Alarm Clock item |
| Confusion | Negative | Attack random targets | 3 turns or until damaged | Cleansing Draught, Purge, Smelling Salts item, Remedy item |
| Silence | Negative | Cannot cast spells | 4 turns or until cured | Cleansing Draught, Purge, Echo Drop item |
| Blind | Negative | Physical accuracy -50% | 4 turns or until cured | Cleansing Draught, Purge, Eye Drops item |
| Petrify | Negative | Removed from combat | Until cured | Purge, Soft Stone item |
| Slow | Negative | ATB speed -50% | 5 turns | Purge, Chronos Dust item |
| Stop | Negative | ATB frozen | 3 real-time seconds (not turn-based) | Wears off only |
| Paralysis | Negative | Cannot act (does not wake on damage) | 3 turns | Purge, Remedy item |
| Berserk | Negative | ATB speed +25%, auto-attack random enemy with +50% basic attack damage | Until cured | Purge only |
| Faint | Negative | Unconscious, out of combat | Until revived | Spirit Recall, Second Dawn, Phoenix Feather item, Phoenix Pinion item |
| Despair | Negative (Void) | ATB speed -25%, damage dealt -20% | 4 turns | Hollow Mend, Pallor Salve item, Hope Shard item (rare) |
| Float | Positive | Immune to Earth spells and ground attacks | Until end of battle | Dispersion / Mass Dispersion |
| Reflect | Positive | Bounces next 3 spells back at caster | Until charges expire | Dispersion / Mass Dispersion |
| Regen | Positive | Restore 5% max HP per turn | 4 turns | Dispersion / Mass Dispersion |
| Ironhide (DEF Up) | Positive | Physical DEF +40% (single) or +25% (party) | 4-5 turns | Dispersion / Mass Dispersion |
| Wardglass (MDEF Up) | Positive | Magic DEF +40% (single) or +25% (party) | 4-5 turns | Dispersion / Mass Dispersion |
| Quickstep (Haste) | Positive | ATB speed +50% | 5 turns | Dispersion / Mass Dispersion |
| Rallying Cry (ATK Up) | Positive | Physical ATK +30% | 5 turns | Dispersion / Mass Dispersion |
| Attunement (MAG Up) | Positive | Magic ATK +30% | 5 turns | Dispersion / Mass Dispersion |
| Last Breath (Reraise) | Positive | Auto-revive at 30% HP on Faint | Until triggered or battle ends | Dispersion / Mass Dispersion |
| Glintmark | Positive (on enemy) | Takes 10% more damage from all sources | 3 turns | Wears off |

*For positive statuses, "Cured By" indicates spells that can remove the buff. Dispersion and Mass Dispersion target enemies, so in practice these buffs are stripped when an enemy casts Dispersion/Mass Dispersion against the buffed party. Player-side Dispersion removes enemy buffs, not friendly ones.*

---

## Spell Count Summary

| Category | Count |
|----------|-------|
| Offensive Magic | 29 |
| Healing Magic | 14 |
| Status Effect Magic | 12 |
| Buff & Debuff Magic | 16 |
| Utility & Special Magic | 8 |
| Void Magic (Enemy-Only) | 8 |
| Void Magic (Party-Learnable) | 2 |
| **Total** | **89** |

---

## Design Notes

### Naming Conventions

- **Ley Line tradition** (Valdris): Names reference light, lines, wards, and old authority. Examples: Linebolt, Leybalm, Wardglass, Convergence Flare.
- **Forgewright vocabulary** (Carradan): Names reference heat, metal, industry, and engineering. Examples: Ember Lance, Crucible Wrath, Forgeshield, Scorch Sweep.
- **Spirit-speaker language** (Thornmere): Names reference nature, breath, communion, and the unseen. Examples: Thornlash, Spiritfang, Breath of the Wilds, Ancestor's Fury.
- **Void/Pallor spells**: Names reference absence, weight, silence, and endings. Examples: Hollow Touch, Ashen Whisper, The Weight, Unmaking.

### Spell Curve Philosophy

**Early game (Tier 1):** Cheap, reliable, always useful. Ember Lance at 4 MP will still be cast in the final dungeon when the party is low on resources. These spells are the foundation.

**Mid game (Tier 2):** The workhorses. Kindlepyre, Deepmend, Quickstep -- these are the spells that define combat strategy. AoE variants open up, status effects become relevant, and buff/debuff play begins.

**Late game (Tier 3):** Power fantasies with real costs. Resurgence heals massively but costs 28 MP. Tempest Reign devastates but demands 35 MP. Resource management becomes the constraint, not spell availability.

**Endgame (Tier 4):** Three ultimate spells. Worldfire, Ley Ruin, and Requiem of Thorns. Each costs 70-80 MP and requires specific late-game achievements to learn. They are rewards, not necessities -- the game should be beatable without them.

### Interaction with Combat System

- All spell damage uses the magic damage formula from the systems reference: `magic_damage = min(14999, max(1, (caster.mag * spell.power) / 4 - target.mdef) * element_mod * variance)` where `variance = random_int(240, 255) / 256`. See [combat-formulas.md](combat-formulas.md) for full resolution order.
- Buff/debuff percentages modify the relevant stat directly (stacking rules: same buff does not stack, different buffs do)
- Status hit rates are modified by: `effective_rate = base_rate * (caster.mag / (caster.mag + target.mdef))`
- Reflect bounces the spell back using the original caster's MAG stat against the original caster's MDEF
- Unique command effects can modify spell output with a percentage multiplier. For example, Maren's Resonance (see abilities.md) amplifies the next ally spell by +30% damage or healing, applied as a multiplier after the base calculation and elemental adjustments

### The Despair Status

Despair is this game's signature status effect. It is thematically central -- the Pallor's weapon is not destruction but surrender. Mechanically, it makes the afflicted character slower and weaker, representing the creeping apathy that the Pallor inflicts. It cannot be cured by standard Cleansing Draught or Purge -- only by Pallor Salve (Act III, expensive/scarce), Hollow Mend (post-game spell), or the rare Hope Shard item. This forces the party to endure it during the main story, making Pallor encounters feel genuinely oppressive. The inability to simply cure it is intentional: despair is not something you fix with a spell. You outlast it.
