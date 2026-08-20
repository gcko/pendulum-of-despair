# Enemy Ability Conventions

> **Status:** canonical reference (GAP-024). This document fills a deliberate
> gap in the design corpus: `palette-families.md` assigns every Act I enemy an
> ability **kit by name** (e.g. *Venom Spit (Poison)*, *Pack Howl (ATK up for
> all wolves)*, *Shard Burst (AoE on death)*) but is **silent on the numbers** —
> ability power, status hit-rates, and buff magnitudes/durations. Rather than
> invent values, every convention below is **derived from an already-documented
> canon value** (a player spell, a combat formula, a status-table entry) and
> cites its source as a `<file>.md § Heading` anchor, which survives edits to
> the cited document. Enemy ability data in `game/data/enemies/`
> references a rule here for each value it sets.

This document defines (1) the JSON ability schema, and (2) the
canon-derived defaults that resolve each silent value.

---

## 1. Ability JSON schema

Each enemy entry in `game/data/enemies/<act>.json` MAY carry an `abilities`
array, slotted alongside `weaknesses` / `resistances` / `status_immunities`.
Each element is a dictionary:

| Field | Type | Default | Meaning |
|-------|------|---------|---------|
| `id` | String | — (required) | Stable ability id (snake_case). |
| `name` | String | `id` | Display name. |
| `type` | String | `"attack"` | `"attack"` (physical formula), `"magic"` (magic formula), or `"buff"`. |
| `element` | String | `""` | Damage element; `""` = non-elemental. |
| `ability_mult` | float | `1.0` | Physical power multiplier (`type:"attack"`). |
| `spell_power` | int | `0` | Magic spell power (`type:"magic"`). |
| `target` | String | `"single"` | `"single"`, `"all"` (party-wide AoE), or `"self"`. |
| `selector` | String | `""` | Single-target pick. `"back"` (a back-row member, e.g. Lunge) and `"random"` (e.g. Drift) are honored by **both** regular enemies and bosses; `"highest_threat"`/`"lowest_hp"` are **boss-only** (resolved by BossAI against BattleState). Default (empty) is the front-biased physical pick. |
| `status` | String | `""` | Status inflicted on hit (e.g. `"poison"`). |
| `status_rate` | int | `0` | Base hit-rate fed to the two-stage roll. |
| `status_duration` | Variant | `null` | Explicit duration override; `null` = canonical (`StatusEffects.resolve_duration`). |
| `hits` | int | `1` | Multi-hit count. |
| `aoe_on_death` | bool | `false` | If true, the ability fires against the party when the bearer dies. |
| `buff` | Dictionary | `{}` | `{stat, mult, duration, scope}` for `type:"buff"` (see §2.4). |

Every damage/roll value resolves through the existing combat code — there is
**no** new damage math. `type:"attack"` → `DamageCalc.calculate_physical`
(`ability_mult` is the power knob); `type:"magic"` →
`DamageCalc.calculate_magic` (`spell_power` is the power knob); `status` →
`DamageCalc.roll_status` two-stage accuracy; `buff` → enemy stat multiplier.

---

## 2. Canon-derived defaults for silent values

### 2.1 Damaging physical abilities — `ability_mult: 1.0`

Basic strikes whose power is unspecified (Bite, Claw, Slash, Scratch, Pinch,
Fang Strike, Heavy Swing, Gore, Pounce, Tail Swipe, Lunge, …) use
`ability_mult 1.0` — i.e. a normal basic attack through the physical formula
`(atk² · ability_mult)/6 − def` (combat-formulas.md § Physical Attack
Resolution). Descriptor words like *Heavy* or *high ATK* (Gore) are **not**
bumped above 1.0, because no doc supplies a multiplier — the enemy's own ATK
stat already encodes its role (a Boar's high ATK makes Gore hit hard at
`ability_mult 1.0`).

### 2.2 Single-target elemental/magic abilities — `spell_power: 14`

Magic-typed single-target enemy abilities (Flicker = Flame, Spark = Ley,
Shadow Touch = magic) use `spell_power 14`, the documented **Tier 1
single-target spell power floor** for player attack spells: Ember Lance
`magic.md § Ember Lance > 'Spell power 14'` and Rime Shard
`magic.md § Rime Shard > 'Spell power 14'`. Tier 1
matches the Act I regular-enemy band (`palette-families.md` Tier 1 kits).

### 2.3 AoE elemental abilities — `spell_power: 9`

Party-wide elemental abilities (Frost Burst) use `spell_power 9`.
`magic.md § MP Cost by Tier > 'AoE spell power'` states *"AoE spell power
uses approximately 60–70% of the single-target ranges above ... at Tiers 1-3
only"* (Tier 4 is exempt — magic.md
§ Tier 4 AoE Exemption; §2.3 only ever applies the rule at Tier 1-2, so the
scoping does not change any value here). Applying 65% to the Tier 1 single-target floor of 14
(§2.2) gives `round(14 × 0.65) = 9`. There is **no damage splitting** — each
party member takes the full AoE hit (combat-formulas.md § AoE Damage Rules). (Shard Burst is a
*non-elemental* AoE-on-death — see §2.6 — but uses this same AoE power.)

### 2.4 Stat buffs — reuse the player-analog magnitude & duration

No enemy buff magnitude is documented, so each maps to the player buff spell
with the same effect (its magnitude and duration are canon):

| Enemy ability | Buffs | Mult | Duration | Player analog (source) |
|---------------|-------|------|----------|------------------------|
| Pack Howl | ATK | ×1.30 | 5 turns | Rallying Cry +30% ATK / 5t (`magic.md § Rallying Cry`) |
| Guard Stance | DEF | ×1.40 | 5 turns | Ironhide +40% DEF / 5t (`magic.md § Ironhide`) |
| Coil | SPD | ×1.50 | 5 turns | Quickstep +50% / 5t (`magic.md § Quickstep`) |
| Elemental Shield | MDEF | ×1.40 | 5 turns | Wardglass +40% MDEF / 5t (`magic.md § Wardglass`) |

`scope` is `"self"` (buffs only the caster) or `"pack"` (buffs every living
enemy sharing the caster's **`id`** — its own kind, e.g. Pack Howl across all
Wayward Wolves in the encounter, per
`palette-families.md § Wolf Family > 'ATK up for all wolves'`). Matching by `id` rather than `type` avoids buffing unrelated
same-type enemies (a Pack Howl should not strengthen the boars and serpents
sharing a Beast-type encounter).

### 2.5 Offensive status hit-rate — `status_rate: 70`

Enemy status base-rates are unspecified.
`magic.md § Balance Rules > 'base hit rate'` documents the player
*standard* band: *"Status spells have a base hit rate of 60–80%."* (magic.md
§ Derived Rules adds a severe 45-59% band for combat-removal statuses; enemy
offensive statuses here are all standard-band.) Enemy offensive
statuses use **70** (band midpoint), then run the same two-stage accuracy roll
as player status spells (`DamageCalc.roll_status`, combat-formulas.md
§ Status Spell Resolution):
Stage 1 `effective = base_rate · MAG/(MAG+MDEF)`, Stage 2 magic-evasion
`(MDEF+SPD)/8` capped at 40%. The status's **effect** (e.g. Poison = 8% max-HP
per turn until cured, `magic.md § Status Effect Reference > 'Poison'`) is
already canon in
`status_effects.gd` / `StatusEffects.resolve_duration`.

### 2.6 AoE-on-death (Shard Burst) — non-elemental, `spell_power: 9`

`palette-families.md § Crystal Family > 'Shard Burst'` gives only
*"Shard Burst (AoE on death)"* — element,
power, and status all silent. It resolves as a `target:"all"`, `type:"magic"`,
`aoe_on_death:true` ability at the §2.3 AoE power (`spell_power 9`), element
**non-elemental** (`""`). Non-elemental is chosen because the burst's element
is undefined and non-elemental avoids inventing a party-resistance interaction
the docs never specify. It deals no status.

### 2.7 Multi-hit — `hits`

`hits` repeats the ability's damage step N times (each hit rolls its own
hit/evasion/crit). **No Act I regular enemy is documented with a multi-hit
ability** — the first is the Act II Cave Vermin's *Rabid Frenzy* (2-hit). The
engine therefore *supports* `hits > 1` (covered by tests) but no Act I
production entry sets it above 1.

---

### 2.8 Enemies with no tabled kit — inherit the family, not an invention

`palette-families.md` names a kit for every *family tier*, but three Act I
records sit outside a tier row and so had no kit at all (#257). Rather than
invent one, each takes the kit of the family it demonstrably belongs to:

| Enemy | Family evidence | Kit assigned |
|-------|-----------------|--------------|
| The Flickering (Lv 6, Spirit, Dangerous, Ember Vein F3 unique) | Shares Mine Shade's entire profile — Spirit type, Ley weakness, Ether Wisp (75%) / Spirit Essence (25%) loot, Poison + Petrify immunities (`act-i.md § Ember Vein`) | Shadow Touch (Tier 1 base) + Darkness (`palette-families.md § Shade Family`) |
| Compact Patrol (Lv 5, Humanoid, Low) | `act-i.md § Ironmouth Docks` states both are **early deployments of the Soldier / Compact family** (base: Compact Soldier Lv 18) | Sword Strike (`palette-families.md § Soldier Family > 'Compact Soldier'`) |
| Compact Scout (Lv 6, Humanoid, Low) | as above | Sword Strike |

Two rules govern which of the family's abilities a non-tier record gets:

1. **Take the base tier's kit.** A record below the family's base level gets
   the Tier 1 row and nothing more. Compact Patrol and Compact Scout are
   therefore *identical* in kit and differ only in stats — Patrol is the
   180 HP / 16 ATK wall, Scout the 140 HP / 14 SPD skirmisher. That is the
   documented difference between them, and inventing a Scout-only recon move
   to make them feel distinct would be exactly the kind of guess §2 exists to
   prevent.
2. **A record whose threat outranks the base may take the family's next
   documented ability — never a new one.** The Flickering is the only
   *Dangerous* regular enemy in Act I (the other two Dangerous records are
   mini-bosses driven by `boss_ai`), so a single-ability kit would make it
   weaker than Bone Warden. It therefore adds the Shade family's next tabled
   ability, **Darkness** (Blind, single target — `palette-families.md § Shade
   Family > 'Crypt Shade'`), at §2.2's spell power and §2.5's status rate.
   This gives it two abilities, matching every other 2-ability Act I record
   (Bone Warden, Marsh Serpent, Wayward Wolf).

**Cover is deferred, not assigned.** The Soldier family's other Tier 1 move,
*Cover (protects adjacent ally)*, is a targeting-redirect mechanic with no
defined magnitude and no battle-layer support. It joins the §4 deferred list
rather than being approximated by a DEF buff.

---

## 3. Boss-AI conventions (GAP-009)

The data-driven boss interpreter (`boss_ai.gd`) reads a `boss_ai` object on each
boss enemy entry: an ordered `phases` array plus a `moves` table. `bosses.md`
fully specifies each boss's *behavior* (mode → priority list → ability) but, as
with regular enemies, is **silent on damage numbers** and never defines a
**threat metric**. These conventions fill those two gaps from canon.

### 3.1 Boss-tier damage mapping

Act I bosses are Lv 8–12, which the `magic.md § MP Cost by Tier` table places
in **Tier 1**
(Lv 1–12). A boss, however, should hit harder than a same-level regular enemy, so
their offensive magic takes a deliberate **one-tier premium**: it uses the
documented **Tier 2** player spell powers rather than the Tier 1 floor (the §2.2
floor of 14 used for regular enemies):

- **Single-target magic** → `spell_power 32` (Tier 2 single-target, e.g.
  Kindlepyre `magic.md § Kindlepyre > 'Spell power 32'`).
- **AoE magic** → `spell_power 24` (Tier 2 AoE ≈ 65–70% of single, e.g. Scorch
  Sweep `magic.md § Scorch Sweep > 'Spell power 24'`; rule
  `magic.md § MP Cost by Tier > 'AoE spell power'`).
- **Physical** (`crystal_slam`, `stone_slam`, `pounce`, `tail_swipe`,
  `tail_sweep`) → `ability_mult 1.0`. Bosses already carry high ATK (~40), so
  a "heavy physical" reads as heavy at 1.0 — consistent with §2.1 (descriptors
  are not bumped above 1.0).
- **Explicit non-damage values are canon and used as-stated:** Vein Guardian
  Reconstruct **+300 HP** (`bosses.md § Vein Guardian > 'Reconstruct'`),
  Drowned Sentinel Barnacle Shield
  **DEF +100% for 2 turns**
  (`bosses.md § Drowned Sentinel > 'Barnacle Shield'`; `buff {stat:def,
  mult:2.0,
  duration:2}`), Corrupted Fenmother add cap **2**.
- **Element remap:** Corrupted Fenmother's Water Jet is "water magic"
  (`bosses.md § Corrupted Fenmother > 'Water Jet'`), but the canonical element
  wheel has no Water (—, Flame,
  Frost, Storm, Earth, Ley, Spirit, Void). It maps to **Frost** — the closest
  fit for her ice/water theme and her own Frost resistance
  (`bosses.md § Corrupted Fenmother > 'Frost'`).

### 3.2 Threat (highest-threat targeting)

`bosses.md § Conditional Priority Lists > 'highest threat'` lists
`highest threat` as a target selector but never defines
how threat is measured. Convention: **threat = cumulative damage a party member
has dealt to enemies this battle** (tracked in `BattleState.threat_dealt`,
incremented on every landed player hit). `highest_threat` selects the living
member with the most accumulated damage; ties (including the all-zero opening)
break to the lowest slot. This is the genre-standard reading and makes the
boss hunt the party's damage dealer.

### 3.3 Charge / telegraph

A move with a `telegraph` string is a **two-turn** ability. On the **charge
turn** the boss emits the telegraph message and deals **no damage** (recorded in
`enemy.ai_state.charging`); on the **next turn** it resolves and deals damage.
Per `bosses.md § Ember Drake > '1-turn charge'` and
`bosses.md § Vein Guardian > '1-turn telegraph'` the telegraph is
informational only — the boss
is not untargetable or more vulnerable during the charge; the player mitigates
via the free row-swap. Act I 1-turn telegraphs are **not interruptible**
(interrupt windows first appear on later 2–3-turn charges).

Telegraphed moves are currently supported only in **non-modal** phases (no Act I
boss combines a `modes` phase with a telegraphed move — Vein Guardian and Ember
Drake telegraph but have no modes; Corrupted Fenmother has modes but no
telegraphs). A future modal boss that also telegraphs would need the resolve-turn
short-circuit in `boss_ai.gd` to re-sync mode/untargetable state.

### 3.4 Condition keys

Phase rules are evaluated first-match (FF6-style) using a **fixed declarative
key set** (no expression evaluation): `every_n` (turn_counter % N == 0),
`hp_below` (handled by phase `hp_above` bands), `adds_below` (living adds <
N), `last_move`, `position` (a living member is in that row), `once` (a named
one-time gate stored in `ai_state`), and `default` (always matches). This
covers every condition the documented format uses
(`bosses.md § Conditional Priority Lists > 'Condition types'`).

---

## 4. Out of scope (tracked separately)

These Act I kit items reference mechanics the docs do not yet define; they are
**deferred** and filed as issues rather than guessed at here:

- **Bespoke effects** with no defined magnitude: HP drain (Latch), self-destruct
  (Bloat), first-strike (Ambush), knockback (Charge), reactive counter (Thorn
  Counter), gold theft (Steal Gold), flee (Flee), **ally protection (Cover —
  Soldier family Tier 1; needs a targeting-redirect mechanic the battle layer
  does not have)**.

> **Now defined (#248):** **Paralysis** — *cannot act for 3 turns, does not wake
> on damage* — is in the `magic.md` Status Effect Reference and `status_effects.gd`
> (`incapacitates`); the battle layer auto-skips a *paralyzed* member's ready
> turn so the gauge clock counts the duration down (gauge-frozen statuses are
> passed over instead — see `combat-formulas.md` § Status Effect ATB
> Interactions). Ley Jellyfish (Ley Sting +
> Drift via the `random` selector) is fully populated.
- **The full Act I roster.** GAP-024's first pass populated a representative
  subset proving each mechanic end-to-end; the remaining family kits followed.
  As of #257 the Act I roster is complete except **Bog Leech**, whose only
  documented move is *Latch* (HP drain, deferred above). The four Act I
  bosses and mini-bosses carry no `abilities` array by design — their moves
  live in `boss_ai.moves` (§3).
