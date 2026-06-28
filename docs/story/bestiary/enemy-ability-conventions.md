# Enemy Ability Conventions

> **Status:** canonical reference (GAP-024). This document fills a deliberate
> gap in the design corpus: `palette-families.md` assigns every Act I enemy an
> ability **kit by name** (e.g. *Venom Spit (Poison)*, *Pack Howl (ATK up for
> all wolves)*, *Shard Burst (AoE on death)*) but is **silent on the numbers** —
> ability power, status hit-rates, and buff magnitudes/durations. Rather than
> invent values, every convention below is **derived from an already-documented
> canon value** (a player spell, a combat formula, a status-table entry) and
> cites its source to `file:line`. Enemy ability data in `game/data/enemies/`
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
single-target spell power floor** for player attack spells (Ember Lance
`magic.md:152`, Rime Shard `magic.md:198` — both *Spell power 14*). Tier 1
matches the Act I regular-enemy band (`palette-families.md` Tier 1 kits).

### 2.3 AoE elemental abilities — `spell_power: 9`

Party-wide elemental abilities (Frost Burst) use `spell_power 9`.
`magic.md:101` states *"AoE spell power uses approximately 60–70% of the
single-target ranges."* Applying 65% to the Tier 1 single-target floor of 14
(§2.2) gives `round(14 × 0.65) = 9`. There is **no damage splitting** — each
party member takes the full AoE hit (combat-formulas.md:633). (Shard Burst is a
*non-elemental* AoE-on-death — see §2.6 — but uses this same AoE power.)

### 2.4 Stat buffs — reuse the player-analog magnitude & duration

No enemy buff magnitude is documented, so each maps to the player buff spell
with the same effect (its magnitude and duration are canon):

| Enemy ability | Buffs | Mult | Duration | Player analog (source) |
|---------------|-------|------|----------|------------------------|
| Pack Howl | ATK | ×1.30 | 5 turns | Rallying Cry +30% ATK / 5t (`magic.md:834`) |
| Guard Stance | DEF | ×1.40 | 5 turns | Ironhide +40% DEF / 5t (`magic.md:790`) |
| Coil | SPD | ×1.50 | 5 turns | Quickstep +50% / 5t (`magic.md:812`) |
| Elemental Shield | MDEF | ×1.40 | 5 turns | Wardglass +40% MDEF / 5t (`magic.md:801`) |

`scope` is `"self"` (buffs only the caster) or `"pack"` (buffs every living
enemy sharing the caster's **`id`** — its own kind, e.g. Pack Howl across all
Wayward Wolves in the encounter, per `palette-families.md:435` *"ATK up for all
wolves"*). Matching by `id` rather than `type` avoids buffing unrelated
same-type enemies (a Pack Howl should not strengthen the boars and serpents
sharing a Beast-type encounter).

### 2.5 Offensive status hit-rate — `status_rate: 70`

Enemy status base-rates are unspecified. `magic.md:107` documents the player
band: *"Status spells have a base hit rate of 60–80%."* Enemy offensive
statuses use **70** (band midpoint), then run the same two-stage accuracy roll
as player status spells (`DamageCalc.roll_status`, combat-formulas.md:478–484):
Stage 1 `effective = base_rate · MAG/(MAG+MDEF)`, Stage 2 magic-evasion
`(MDEF+SPD)/8` capped at 40%. The status's **effect** (e.g. Poison = 8% max-HP
per turn until cured, `magic.md:1392`) is already canon in
`status_effects.gd` / `StatusEffects.resolve_duration`.

### 2.6 AoE-on-death (Shard Burst) — non-elemental, `spell_power: 9`

`palette-families.md:90` gives only *"Shard Burst (AoE on death)"* — element,
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

## 3. Out of scope (tracked separately)

These Act I kit items reference mechanics the docs do not yet define; they are
**deferred** and filed as issues rather than guessed at here:

- **Paralysis** (Ley Jellyfish *Ley Sting*) — referenced by
  `palette-families.md:275` and `act-i.md:106` but **absent** from the
  `magic.md` Status Effect Reference. A status definition is required before it
  can be implemented.
- **Bespoke effects** with no defined magnitude: HP drain (Latch), self-destruct
  (Bloat), first-strike (Ambush), knockback (Charge), reactive counter (Thorn
  Counter), gold theft (Steal Gold), flee (Flee), random-target (Drift).
- **The full Act I roster.** GAP-024's first pass populates a representative
  subset proving each mechanic end-to-end; the remaining family kits are
  populated in a follow-up using the conventions above.
