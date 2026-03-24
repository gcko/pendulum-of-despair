# Row/Position System Design

> Spec for Gap 2.5. Defines the front/back row system: damage modifiers,
> ranged weapon rules, default character rows, free swap action, and
> enemy positioning (none — player-only rows).

---

## 1. Core Design

The game uses a **2-row system** (Front and Back) for the player party
only. Enemies occupy a single group with no rows. This follows the
FF6 model: tactical depth comes from the player's positioning choices,
not from navigating enemy formations.

---

## 2. Physical Damage & Row

### Front Row

- Deal **100% physical damage** (full ATK applied)
- Receive **100% physical damage** from enemies

### Back Row

- Deal **50% physical damage** (ATK halved before damage calculation)
- Receive **50% physical damage** from enemies (incoming physical
  damage halved after defense)
- **Exception — Ranged weapons:** Spears (Torren's weapon type) deal
  **100% physical damage from back row**. The "back-row capable" tag
  in equipment.md marks weapons that bypass this penalty.

### Magic

- **Unaffected by row.** Magic damage dealt and received is the same
  regardless of which row the caster or target occupies.
- Healing spells work at full effect from either row.

### Items & Devices

- Consumable items (Potions, status cures, etc.) work from either row.
- Forgewright battle devices work at full effect from either row.
- Ley Crystal invocations work from either row.

---

## 3. Row Swapping

- **Free action** — no turn cost, no ATB delay
- Can be performed at any time during a character's turn (before
  selecting an action)
- The player can reposition freely every turn

**Design rationale:** The game already demands tactical decisions via
ATB timing, Ley Crystal management, Forgewright loadouts, and party
composition. Free row swaps keep the system accessible without adding
friction. The strategic weight comes from the damage tradeoff itself,
not from a swap penalty.

---

## 4. Default Row Assignments

Each character has a default row they start in at the beginning of
every battle. The player can swap immediately if desired.

| Character | Default Row | Rationale |
|-----------|------------|-----------|
| Edren | Front | Tank — highest DEF/HP, sword user (melee) |
| Cael | Front | Commander — balanced ATK/DEF, greatsword user (melee) |
| Lira | Front | Engineer — hammer user (melee), moderate DEF |
| Torren | Back | Sage — high MAG, spear user (back-row capable), benefits from 50% damage reduction |
| Sable | Front | Thief — dagger user (melee), needs front row for Steal (physical contact) |
| Maren | Back | Archmage — highest MAG, lowest DEF/HP, magic unaffected by row |

### Character Row Identity

- **Torren** is the standout: spears deal full damage from back row,
  AND he casts full-power magic. He never needs to come to front row
  under normal play. This is his identity advantage — the hybrid
  mage-fighter who excels from safety.
- **Sable** creates a tactical tension: she's fragile (low DEF/HP)
  but Steal requires front row. The player must decide when it's
  worth risking her.
- **Maren** has no reason to ever be in front row. Her physical ATK
  is negligible and she takes double physical damage compared to back.

---

## 5. Enemy Positioning

**Enemies have no rows.** All enemies occupy a single group. The row
system is exclusively player-side.

- All enemies can target any party member regardless of row
- There is no "front row enemies block back row enemies" mechanic
- Enemy AoE abilities hit all party members regardless of row
- This matches FF6's approach and keeps encounter design simple

---

## 6. AoE Targeting Rules

- **Player AoE spells/abilities:** Hit all enemies (single group)
- **Enemy AoE abilities:** Hit all party members (both rows)
- **Row-specific abilities:** Edren's Rampart guards the back row,
  absorbing 30% of all damage dealt to back-row allies (per
  abilities.md). This is the only row-specific ability currently
  defined.

---

## 7. Interaction with Existing Systems

### Equipment (equipment.md)

- Spears already tagged as "back-row capable" (line 130, 274)
- No other weapon types are currently back-row capable
- All other melee weapons (swords, greatswords, daggers, hammers,
  staves) deal 50% physical damage from back row
- **Staves note:** Maren uses staves but her physical ATK is
  negligible — the row penalty on staves is mechanically irrelevant
  since she attacks with magic

### Abilities (abilities.md)

- Edren's **Rampart** (Lv 10): "guards the entire back row, absorbing
  30% of all damage dealt to back-row allies" — already assumes rows
  exist, no changes needed
- Sable's **Steal**: requires front row (physical contact with enemy).
  If Sable is in back row, Steal is greyed out / unavailable.

### Combat Formulas (combat-formulas.md)

- Physical damage formula: `(ATK² × ability_mult) / 6 - DEF`
- Row modifier applies as a **final multiplier** after all other
  calculations:
  - Front row attacker → no modifier (×1.0)
  - Back row attacker (non-ranged weapon) → damage × 0.5
  - Back row defender → incoming physical damage × 0.5
- Row modifiers stack multiplicatively: a back-row attacker hitting a
  back-row-defended target results in 0.5 × 0.5 = 0.25 of normal
  damage. (This scenario doesn't arise since enemies have no rows,
  but the rule is defined for completeness.)
- Magic damage: no row modifier at any point in the pipeline

---

## 8. Cross-References

| Document | Relationship |
|----------|-------------|
| `docs/story/combat-formulas.md` | **Update needed:** add row modifier as final multiplier step in physical damage pipeline |
| `docs/story/equipment.md` | Already references "back-row capable" for spears. No changes needed. |
| `docs/story/abilities.md` | Already references back row in Rampart. Add note that Steal requires front row. |
| `docs/story/characters.md` | **Update needed:** add default row per character |
| `docs/story/progression.md` | No changes needed |
| `docs/analysis/game-design-gaps.md` | Gap 2.5 status → COMPLETE |

---

## 9. Files Created/Modified

| Action | File | Changes |
|--------|------|---------|
| Modify | `docs/story/combat-formulas.md` | Add Row Modifier section to physical damage pipeline |
| Modify | `docs/story/characters.md` | Add default battle row per character |
| Modify | `docs/story/abilities.md` | Add note that Steal requires front row |
| Modify | `docs/analysis/game-design-gaps.md` | Gap 2.5 status → COMPLETE |
