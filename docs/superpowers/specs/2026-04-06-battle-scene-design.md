# Battle Scene Design Spec (Gap 3.3)

> **Goal:** Implement the ATB battle system as a core state scene in
> Godot 4.6, covering all combat formulas, turn flow, battle UI, and
> victory/defeat flow. One PR, phased internally.
>
> **Canonical sources:** `combat-formulas.md`, `ui-design.md` Section 2,
> `abilities.md`, `magic.md`, `progression.md`, `difficulty-balance.md`
>
> **Depends on:** 2.3 (Enemy Prefab), 1.1 (Characters), 1.2 (Enemies),
> 1.5 (Spells & Abilities) — all COMPLETE

---

## 1. Architecture Overview

### 1.1 File Structure

```
game/scripts/combat/
├── damage_calculator.gd   — Pure static formulas (no instance state)
├── atb_system.gd          — Gauge fill rates, turn queue management
├── battle_state.gd        — Party member runtime state (HP/MP/status/row/resources)
├── battle_ai.gd           — Enemy action selection (weighted-random)
└── battle_manager.gd      — Orchestrator: encounter setup, command dispatch, flow control

game/scripts/ui/
├── battle_ui.gd               — UI controller, signal observer, damage popups, results
├── battle_party_panel.gd      — Party rows: HP/MP bars, ATB gauges, status icons
└── battle_command_menu.gd     — Command panel, sub-menus, target selection, input

game/scenes/core/
└── battle.tscn            — Scene tree with battle manager + UI nodes

game/tests/
├── test_damage_calculator.gd  — Formula verification (milestone tables)
├── test_atb_system.gd         — ATB gauge, turn order, active/wait modes
├── test_battle_state.gd       — Party state, status timers, buff tracking
└── test_battle_manager.gd     — Integration: full pipeline composition, victory/defeat
```

### 1.2 Scene Tree

```
Battle (Node2D)                          — battle_manager.gd, process_mode=PAUSABLE
├── EnemyArea (Node2D)                   — enemy sprite container
│   └── (enemy instances added at runtime)
├── BattleUI (CanvasLayer, layer=10)     — battle_ui.gd attached
│   ├── PartyPanel (PanelContainer)      — battle_party_panel.gd, bottom-left
│   │   ├── Row0 (HBoxContainer)         — name, HP bar, MP bar, ATB gauge, status icons
│   │   ├── Row1
│   │   ├── Row2
│   │   └── Row3
│   ├── CommandMenu (PanelContainer)     — battle_command_menu.gd, bottom-right
│   │   ├── CommandList (VBoxContainer)  — 6 command labels
│   │   ├── SubMenu (PanelContainer)     — magic/item/ability overlay (hidden)
│   │   └── TargetCursor (Sprite2D)      — blinking arrow
│   ├── MessageArea (PanelContainer)     — top-center, action announcements
│   │   └── MessageLabel (Label)
│   └── ResultsPanel (PanelContainer)    — victory screen (hidden by default)
└── Camera2D                             — static, centered on 320x180

**process_mode:** Battle scene uses default PAUSABLE. If GameManager
pushes a CUTSCENE overlay during battle (e.g., boss mid-fight dialogue),
the tree pauses and ATB stops — this is correct behavior. The overlay
runs in PROCESS_MODE_ALWAYS (set by GameManager.push_overlay).
```

### 1.3 Integration with GameManager

**Entry:** `GameManager.change_core_state(CoreState.BATTLE, data)` where
data contains:
```gdscript
{
    "encounter_group": Array[String],  # enemy IDs
    "enemy_act": String,               # act for DataManager lookup
    "formation_type": String,          # "normal", "back_attack", "preemptive"
    "is_boss": bool,
    "return_map_id": String,           # map to return to after battle
    "return_position": Vector2,        # player position to restore
}
```

**Exit paths:**
- Victory → `GameManager.change_core_state(CoreState.EXPLORATION, {result: "victory", ...})`
- Flee → same with `result: "flee"`
- Defeat → `GameManager.change_core_state(CoreState.EXPLORATION, {result: "faint", ...})`
  (Faint-and-Fast-Reload: loads most recent save, merges XP/gold per events.md)

---

## 2. Damage Calculator (`damage_calculator.gd`)

Static utility — all functions are `static func`. No instance state.
Every formula matches combat-formulas.md exactly.

### 2.1 Physical Damage

```
static func calculate_physical(atk: int, ability_mult: float, target_def: int,
    is_crit: bool, interaction_mult: float,
    attacker_row: String, defender_row: String, weapon_bypasses_row: bool,
    reduction_sources: Array[float], is_elemental: bool, element_mod: float) -> int
```

Full pipeline (combat-formulas.md § Physical Attack Resolution):

**Note:** Hit/evasion checks (steps 1-2) are performed by the CALLER
(battle_manager.gd) BEFORE calling this function. If the attack misses
or is evaded, `calculate_physical` is never called. See Section 6.2
for the full caller composition sequence.

3. `raw = max(1, (atk * atk * ability_mult) / 6 - target_def)`
4. Floor check: `raw = max(1, raw)`
5. Critical: if `is_crit`: `raw *= 2`
6. Combat interaction modifiers: `raw *= interaction_mult`
7. Variance: `result = raw * roll_variance()`
8. Elemental modifier (if `is_elemental`): `result *= element_mod`
9. Row modifiers: `result *= attacker_row_mod * defender_row_mod`
10. Damage reduction: `result *= reduction_product(reduction_sources)`
11. `clamp(floor(result), 1, 14999)`

Special cases (checked after step 8):
- `element_mod == 0.0` → return 0 (immune, bypass floor and reduction)
- `element_mod < 0` → return `abs(result)` as healing (absorb, bypass reduction)

### 2.2 Magic Damage

```
static func calculate_magic(mag: int, spell_power: int, target_mdef: int,
    element_mod: float, interaction_mult: float, buff_mults: Array[float],
    reduction_sources: Array[float]) -> int
```

Full pipeline (combat-formulas.md § Magic Damage Resolution):

**Note:** Magic spells use the SAME Hit Rate% and Evasion% checks as
physical attacks (combat-formulas.md). The CALLER (battle_manager.gd)
must call `roll_hit()` and `roll_evasion()` before `calculate_magic()`.

1. `raw = max(1, (mag * spell_power) / 4 - target_mdef)`
2. Element modifier: `raw *= element_mod`
3. Combat interaction modifiers: `result *= interaction_mult`
4. Buff modifiers (Resonance, Glintmark): multiply sequentially
5. Variance: `result *= roll_variance()`
6. Damage reduction (only "all" and "magic only" sources)
7. `clamp(floor(result), 1, 14999)`

Same immunity/absorb branching as physical (checked after step 2).

### 2.3 Healing

```
static func calculate_healing(mag: int, spell_power: int) -> int
```

`min(14999, floor(mag * spell_power * 0.8 * variance))`

No defense, no floor-of-1, no reduction.

### 2.4 Hit/Miss Resolution

```
static func roll_hit(attacker_spd: int, target_spd: int) -> bool
```

`hit_rate = clamp(90 + (attacker_spd - target_spd) / 4, 20, 99)`
Roll `randi() % 100 < hit_rate`.

```
static func roll_evasion(target_spd: int) -> bool
```

`evasion_rate = min(50, target_spd / 4)`
Roll `randi() % 100 < evasion_rate`.

### 2.5 Critical Hit

```
static func roll_crit(attacker_lck: int) -> bool
```

`crit_rate = min(50, attacker_lck / 4)`
Physical only. Magic never crits.

### 2.6 Status Effect Accuracy

```
static func roll_status(base_rate: int, caster_mag: int, target_mdef: int,
    target_spd: int) -> bool
```

Two-stage per combat-formulas.md:
1. Guard: if `caster_mag + target_mdef == 0`, return false (0% chance)
2. `effective = base_rate * (caster_mag / float(caster_mag + target_mdef))`
3. Roll `randi() % 100 < effective`. Fail → status not applied.
4. Stage 2: `meva_pct = min(40, (target_mdef + target_spd) / 8)`
5. Roll `randi() % 100 < meva_pct`. If passed → status resisted.

Magic Evasion formula: `(MDEF + SPD) / 8, cap 40%` per combat-formulas.md.
Computed inside `roll_status` — callers pass raw stats, not derived %.

### 2.7 Flee

```
static func calculate_flee_chance(party_avg_spd: float, enemy_avg_spd: float) -> int
```

`clamp(50 + int((party_avg_spd - enemy_avg_spd) * 2), 10, 90)`

### 2.8 Variance Helper

```
static func roll_variance() -> float
```

`(randi() % 16 + 240) / 256.0`

Range: 0.9375 to 0.99609375

---

## 3. ATB System (`atb_system.gd`)

### 3.1 Constants

```gdscript
const GAUGE_MAX: int = 16000
const TICK_RATE: int = 60  # updates per second (matches _process at 60fps)
const SPEED_FACTORS: Dictionary = {
    1: 6.0, 2: 5.0, 3: 3.0, 4: 2.0, 5: 1.5, 6: 1.0,
}
```

### 3.2 Gauge Ownership

atb_system.gd owns ALL ATB gauges — party AND enemy — in a single
unified dictionary indexed by combatant ID (e.g., "party_0",
"enemy_2"). battle_state.gd does NOT store `atb_gauge`.

```gdscript
var _gauges: Dictionary = {}  # {combatant_id: int}
```

This avoids bidirectional coupling between atb_system and battle_state.
battle_manager.gd queries atb_system for gauge values when needed.

### 3.3 Fill Rate

Per combat-formulas.md § ATB Gauge System:
```
effective_spd = floor(base_spd * crystal_modifier)  # crystal_modifier = 1.0 until gap 3.4
fill_rate = floor((effective_spd + 25) * battle_speed_factor * status_modifier_product)
```

Status modifiers (multiplicative):
- Haste: 1.5
- Slow: 0.5
- Despair: 0.75
- Grounded: 0.75
- Berserk: 1.25
- Stop/Sleep/Petrify: gauge frozen (0 fill)

### 3.4 Turn Queue

Each tick (`_process` call):
1. For each combatant with unfrozen gauge: `gauge += fill_rate`
2. If `gauge >= GAUGE_MAX`: add to ready queue
3. Ready queue sorted by: effective SPD (desc) → party before enemies → slot index (asc)
4. On act: gauge resets to 0, overflow discarded

### 3.4 Active/Wait Mode

- **Active:** All gauges fill continuously
- **Wait:** Gauges pause for ALL combatants while a sub-menu is open
  (magic/item/ability list, target selection). Top-level command menu
  still runs in real-time.
- **Patience Mode:** Wait + Battle Speed 6 + top-level command menu
  also pauses all gauges. Real-time status timers also pause.

### 3.5 Formation Start State

Per combat-formulas.md § Battle Formations:
- Normal: all gauges start at 0
- Back Attack: enemy gauges start at `GAUGE_MAX / 2`, party rows reversed for round 1
- Preemptive: party gauges start at `GAUGE_MAX`, enemy gauges at 0

---

## 4. Battle State (`battle_state.gd`)

### 4.1 Party Member State

Per-member dictionary tracked in an array (up to 4 active slots;
may be fewer during story segments like Edren alone in Prologue or
Sable's solo Interlude section — empty slots are null):

```gdscript
{
    "character_id": String,
    "character_data": Dictionary,  # from DataManager
    "current_hp": int,
    "max_hp": int,
    "current_mp": int,
    "max_mp": int,
    "row": String,  # "front" or "back"
    "active_statuses": Array[Dictionary],  # see 4.2 Status Timer Model
    "is_alive": bool,
    "is_defending": bool,  # cleared when character's ATB next fills (see 4.4)
    # Ability resources
    "ap": int,        # Edren: Aegis Points (0-10)
    "ac": int,        # Lira: Arcanite Charges (0-12)
    "wg": int,        # Maren: Weave Gauge (0-100)
    "favor": Dictionary,  # Torren: {spirit_id: int(0-3)}
    "stolen_goods": Array[String],  # Sable: up to 3 item IDs
    "active_rally": Dictionary,  # Cael: current rally buff
    "active_stance": String,  # Edren: current Bulwark stance
}
```

**Note:** ATB gauge is NOT stored here — it lives in atb_system.gd
(see Section 3.2 Gauge Ownership).

### 4.2 Status Timer Model

Status effects use TWO duration types:

```gdscript
# Turn-based status (most statuses)
{"name": "haste", "duration_type": "turns", "remaining_turns": 5}

# Real-time status (Stop only)
{"name": "stop", "duration_type": "realtime", "remaining_seconds": 3.0}
```

Turn-based: decremented by `tick_statuses()` at END of the affected
combatant's turn.

Real-time: decremented by delta in `_process()`. In Wait mode, the
timer pauses when sub-menus are open. In Patience mode, the timer
also pauses during top-level command selection.

### 4.3 Buff/Debuff Tracking

Stat buffs modify the effective stat before it enters formulas.
Tracked per-combatant:
```gdscript
{
    "atk_mult": float,   # default 1.0
    "def_mult": float,
    "mag_mult": float,
    "mdef_mult": float,
    "spd_mult": float,
    "damage_taken_mult": float,  # Glintmark etc.
}
```

`get_effective_stat(member, stat_name)` applies buff multipliers.
**No clamping in battle** — buffs can push stats past 255 temporarily
per progression.md. This is the pathway for mages to reach the
damage cap.

### 4.4 Defend Flag Lifetime

`is_defending` is set to `true` when the Defend command is chosen.
It is cleared when the character's ATB gauge next fills to GAUGE_MAX
(i.e., their next turn begins). battle_manager.gd clears this flag
in the ATB ready callback before presenting the command menu.

Defend grants +50% DEF (applied via `def_mult` in buff tracking).

### 4.5 Enemy State

Enemy instances use existing `enemy.gd` — already has HP/MP/status
tracking, elemental profiles, steal/drop resolution. ATB gauge
tracked in atb_system.gd (unified gauge storage, see Section 3.2).

---

## 5. Battle AI (`battle_ai.gd`)

### 5.1 Weighted-Random Selection

Regular enemies select actions from a weighted pool:
```gdscript
static func select_action(enemy: Node, party: Array) -> Dictionary
```

Default behavior (no AI script):
- 70% basic attack (random party member)
- 20% ability (if enemy has abilities — from enemy data)
- 10% do nothing / defend

Target selection:
- Physical attacks prefer front-row party members (75% front, 25% back)
- Magic attacks target randomly (magic ignores rows)
- Healing targets lowest-HP ally enemy

### 5.2 Boss AI Stub

Boss enemies will have scripted AI in future content gaps. For now:
```gdscript
static func select_boss_action(enemy: Node, party: Array, phase: int) -> Dictionary
```

Returns basic attack. Phase tracking based on HP thresholds from
enemy data (`enemy_data.get("phases", [])`).

---

## 6. Battle Manager (`battle_manager.gd`)

### 6.0 Signal Architecture

battle_manager.gd emits signals that battle_ui.gd observes. No direct
method calls from manager to UI. This keeps the rendering layer
decoupled from game logic.

```gdscript
signal battle_started(party: Array, enemies: Array)
signal turn_ready(combatant_id: String, is_party: bool)
signal action_executed(action: Dictionary)  # {type, actor, target, result}
signal damage_dealt(target_id: String, amount: int, damage_type: String)  # "physical"/"magic"/"heal"/"miss"/"immune"
signal status_changed(target_id: String, status_name: String, applied: bool)
signal combatant_died(combatant_id: String)
signal victory(rewards: Dictionary)
signal defeat
signal flee_result(success: bool)
signal message(text: String)  # action announcements
```

battle_ui.gd connects to these signals in `_ready()` and updates
the display accordingly. Input from the UI (command selection, target
selection) calls back to battle_manager via direct method calls
(UI calls down to manager, manager signals up to UI).

### 6.1 Battle Flow

```
_ready():
  1. Read GameManager.transition_data (cache return_map_id and return_position locally)
  2. Guard: if encounter_group is empty, push_error and return to exploration
  3. Setup encounter (instantiate enemies, load party state)
  4. Apply formation (row reversal, ATB pre-fill)
  5. Emit battle_started signal
  6. Start ATB ticking

Main loop (_process):
  1. Tick ATB gauges via atb_system (if not paused)
  2. Tick real-time status timers (Stop countdown) if battle time running
  3. Check ready queue
  4. If enemy ready: execute AI action
  5. If party member ready: show command menu, wait for input
  6. Execute chosen command
  7. Check victory/defeat conditions
  8. If all enemies dead: victory flow
  9. If all party KO'd: defeat flow
```

### 6.2 Command Dispatch

**Full physical attack resolution sequence** (caller composes pipeline):
```
1. roll_hit(attacker_spd, target_spd) → miss? emit damage_dealt("miss"), return
2. roll_evasion(target_spd) → dodged? emit damage_dealt("miss"), return
3. roll_crit(attacker_lck) → is_crit
4. calculate_physical(atk, mult, def, is_crit, ...) → damage
5. target.take_damage(damage)
6. emit damage_dealt(target_id, damage, "physical")
```

Magic follows the same hit/evasion → calculate_magic → apply pattern.

When a party member's ATB fills:
1. Clear `is_defending` flag (Section 4.4)
2. Highlight their name in yellow
3. Show command panel (6 options)
4. Player selects command → dispatch:

| Command | Action |
|---------|--------|
| Attack | Target selection → full physical pipeline above |
| Magic | Sub-menu (spell list) → target → hit/evasion → `calculate_magic()` |
| Ability | Sub-menu (character-specific) → target → ability-specific dispatch |
| Item | Sub-menu (battle items) → target → item effect application |
| Defend | Immediate: set `is_defending = true`, +50% DEF via `def_mult` |
| Flee | Immediate: roll flee chance, success → exit, fail → lose turn |

### 6.3 Victory Flow

When all enemies are dead:
1. Stop ATB
2. Calculate rewards:
   - XP: sum of all enemy XP values. Full to active, 50% to absent, 0 to KO.
   - Gold: sum of all enemy gold values.
   - Drops: roll each dead enemy's drop table.
3. Check level-ups (per progression.md formula)
4. Show results screen
5. On confirm: `GameManager.change_core_state(CoreState.EXPLORATION, ...)`

### 6.4 Defeat Flow (Faint-and-Fast-Reload)

When all party members are KO'd:
1. Stop ATB
2. Play last faint animation
3. Fade to black (2s)
4. Build merge dict: `{earned_xp: int, earned_gold: int}`
5. Call `SaveManager.load_most_recent()` → get save data
6. Add merge XP to each character's XP in save data; recompute levels
   (level-ups restore HP/MP per progression.md)
7. Add merge gold to save gold
8. Write merged state back to the save slot
9. `GameManager.change_core_state(CoreState.EXPLORATION, {result: "faint", save_data: merged})`

**Interface contract:** battle_manager builds the merge data and
applies it to the loaded save dictionary before transitioning. No
new SaveManager methods needed — use existing `load_most_recent()`
and `save_game(slot, data)`.

### 6.5 Flee

Per combat-formulas.md:
- Disabled in boss battles (Flee greyed out in command menu)
- Roll `calculate_flee_chance(party_avg_spd, enemy_avg_spd)`
- Success: exit battle, no rewards
- Failure: acting character loses their turn
- Smoke Bomb / Smokeveil: 100% flee (non-boss)

---

## 7. Battle UI (split into focused scripts)

To avoid a god-object, battle UI is split into 3 scripts:
- `battle_ui.gd` — main controller, connects to battle_manager signals,
  coordinates child UI scripts (~120 lines)
- `battle_party_panel.gd` — party rows, HP/MP bars, ATB gauges,
  status icons (~120 lines)
- `battle_command_menu.gd` — command panel, sub-menus, target selection,
  input handling (~150 lines)

Damage number popups and the results screen are managed by battle_ui.gd
directly (small enough to not warrant separate scripts).

### 7.1 Layout

Per ui-design.md Section 2.1:
- Upper ~65%: enemy sprite area (center-to-right)
- Bottom-left ~65%: party panel (4 rows, fewer if party < 4)
- Bottom-right ~35%: command panel (6 commands)

Viewport: 320x180. All positions pixel-aligned.

### 7.2 Party Panel

Each row (per ui-design.md Section 2.3):
- Status icons: 8x8, up to 4 visible, scroll on 2s timer
- Name: white, active character highlighted yellow `#ffff88`
- HP: green label + pixel bar + "current/max". Bar turns red < 25%
- MP: blue label + pixel bar + "current/max"
- ATB gauge: gold fill `#ffcc00` on dark `#222222`. 2-frame flash when full.

### 7.3 Command Panel

Per ui-design.md Section 2.4:
- 6 vertical items: Attack, Magic, [ability_name], Item, Defend, Flee
- Pixel-art hand cursor (2-frame idle animation)
- Selected: yellow `#ffff88`, others: pale blue `#ccddff`
- Flee greyed out in boss battles
- Third slot shows character-specific ability name from abilities.md

### 7.4 Sub-Menus

Overlay left side (over party panel):

**Magic:** two-column (name + MP cost). Unaffordable greyed `#666688`.
**Item:** single-column (icon + name + qty). Non-battle items hidden.
**Ability:** varies by character (stance list / device list / spirit list / technique list / weave list / buff list).

Cancel returns to command panel.

### 7.5 Target Selection

Per ui-design.md Section 2.6:
- Blinking arrow above enemies (offensive) / below party (support)
- Left/right cycles enemies, up/down cycles party
- Multi-target: all highlighted, "All" text
- Confirm executes, cancel returns

### 7.6 Damage Numbers

Per ui-design.md Section 2.2:
- Pop above sprite, float upward ~0.5s
- White (damage), green (heal), grey (miss)
- Pixel font 12px

### 7.7 Message Area

Per ui-design.md Section 2.5:
- Top-center, pale yellow on dark navy
- Action announcements, auto-fade 1.5s

### 7.8 Results Screen

Per ui-design.md Section 2.8:
- XP gained (white), gold gained (gold), items obtained (icon + name)
- Level-up: name flashes, "reached Level N!", new stats shown
- Confirm advances through sections

---

## 8. Row System

Per combat-formulas.md § Row Modifier:

| Condition | Modifier |
|-----------|----------|
| Front row attacker (melee) | 1.0 |
| Back row attacker (melee) | 0.5 |
| Back row attacker (spear) | 1.0 (bypasses penalty) |
| Front row defender (physical) | 1.0 |
| Back row defender (physical) | 0.5 |
| Magic | No row modifiers |

Row swap is a free action (no turn/ATB cost). Enemies have no rows.

Back Attack formation reverses party rows for round 1.

---

## 9. Elemental System

Per combat-formulas.md § Elemental System:

| Interaction | Multiplier |
|-------------|-----------|
| Weakness | 1.5 |
| Neutral | 1.0 |
| Disadvantage | 0.75 |
| Same-element | 0.5 |
| Immune | 0.0 (bypass floor, show "Immune") |
| Absorb | -1.0 (heal target, bypass reduction) |

Element wheel:
- Flame > Frost > Storm > Earth > Flame
- Ley > Void > Spirit > Ley
- Non-elemental: 1.0 to all

---

## 10. Status Effects in Battle

### 10.1 ATB Interactions

Per combat-formulas.md § Status Effect ATB Interactions:

| Status | Gauge Effect | Duration |
|--------|-------------|----------|
| Haste | ×1.5 fill | 5 turns |
| Slow | ×0.5 fill | 5 turns |
| Stop | Frozen | 3 real-time seconds |
| Sleep | Frozen | Until cured/damaged |
| Confusion | ×1.0, auto-attack random | 3 turns or damaged |
| Berserk | ×1.25, auto-attack enemy (+50% ATK) | Until cured |
| Despair | ×0.75, -20% damage dealt | 4 turns |
| Petrify | Frozen (0), removed from battle | Until cured |

### 10.2 Party-Side Tracking

Same structure as enemy.gd: `[{name: String, remaining_turns: int}]`
with `apply_status()`, `remove_status()`, `tick_statuses()`, `has_status()`.

Status immunity for party: none by default. Equipment-granted immunities
deferred to gap 3.4 (Menu/Equipment).

---

## 11. Character Ability Resources

Per abilities.md, each character has a unique resource tracked in
battle_state.gd:

| Character | Resource | Max | Start | Gain |
|-----------|----------|-----|-------|------|
| Edren | Aegis Points (AP) | 10 | 0 | 1/hit absorbed, +1 if hit > 10% max HP |
| Cael | (MP-based Rally) | — | — | Rally costs MP, one active at a time |
| Lira | Arcanite Charges (AC) | 12 | Current pool | Restored on rest |
| Torren | Spirit Favor | 3/spirit | Persistent | +1 on "in harmony" use |
| Sable | Stolen Goods | 3 items | Empty | Via Filch/Ransack |
| Maren | Weave Gauge (WG) | 100 | 0 | +10 ally cast, +5 self, +15 enemy cast |

For this gap, ability commands will **dispatch to the correct formula**
based on ability data JSON fields (cost_type, cost, target, effect_type).
Complex ability-specific logic (Edren's stance absorption, Torren's
favor leveling, Sable's stolen goods usage) will have basic
implementations that can be refined in content gaps.

---

## 12. Encounter Setup

Per combat-formulas.md § Encounter System:

### 12.1 Formation Types

| Type | Party | Enemies |
|------|-------|---------|
| Normal | Rows as assigned, ATB 0 | ATB 0 |
| Back Attack | Rows reversed round 1, ATB 0 | ATB GAUGE_MAX/2 |
| Preemptive | ATB GAUGE_MAX | ATB 0 |

### 12.2 Enemy Instantiation

From `transition_data.encounter_group` (Array of enemy IDs):
1. For each ID: instantiate `enemy.tscn`
2. Call `enemy.initialize(id, transition_data.enemy_act)`
3. Position in enemy area (flexible grid, up to 6)
4. Create ATB entry in atb_system

---

## 13. What's Deferred

| Feature | Deferred To | Reason |
|---------|------------|--------|
| Mosaic dissolve transition | Visual polish gap | Not in core battle flow |
| Battle music | Gap 3.8 (Audio) | AudioManager stubs exist |
| Combat interactions (Frozen Shatter, etc.) | Gap 4.1+ content | Hooks placed, not implemented |
| Boss scripted AI | Gap 4.1+ content | Basic weighted-random for now |
| Maren's WG bar in party panel | UI polish | Tracked in state, visual deferred |
| Equipment stat modifiers | Gap 3.4 (Menu) | Base stats only for now |
| Ley Crystal bonuses | Gap 3.4 (Menu) | crystal_modifier = 1.0 for now |
| Danger counter / encounter trigger | Gap 3.2 expansion | Battles entered via transition_data |
| Battle Cursor (Reset/Memory) config | Gap 3.4 (Config) | Always resets for now |
| Screen shake config | Gap 3.4 (Config) | Always on for now |

---

## 14. Test Strategy

### 14.1 Unit Tests (GUT)

**test_damage_calculator.gd:**
- Physical damage matches combat-formulas.md milestone table (Edren Lv1 vs tutorial mob → ~49)
- Magic damage matches milestone table (Maren Lv1 Ember Lance → ~69)
- Healing formula (no defense subtraction)
- Damage floor of 1 (high DEF vs low ATK)
- Damage cap of 14999
- Elemental immunity returns 0
- Elemental absorb returns positive (healing amount)
- Critical doubles raw damage
- Row modifiers apply correctly (back row → 0.5)
- Damage reduction stacks multiplicatively
- Variance in range [0.9375, 0.996]

**test_atb_system.gd:**
- Fill rate formula matches combat-formulas.md
- Gauge caps at GAUGE_MAX
- Turn order: higher SPD first, party before enemies on tie
- Active mode: gauges fill during sub-menu
- Wait mode: gauges pause during sub-menu
- Status modifiers (Haste 1.5×, Slow 0.5×)
- Frozen gauge (Stop, Sleep) retains value
- Preemptive: party starts full
- Back Attack: enemies start at 50%

**test_battle_state.gd:**
- Party member initialization from character data
- HP/MP modification with clamping
- Status apply/remove/tick
- Buff multiplier application
- Row assignment
- Death detection (HP → 0)

**test_battle_manager.gd:**
- Encounter setup from transition_data
- Victory condition (all enemies dead)
- Defeat condition (all party KO)
- XP distribution (full/absent/KO per progression.md)
- Flee chance calculation
- Boss flee disabled
- Formation type application

### 14.2 Verification Against Design Docs

Every damage formula test case uses exact values from
combat-formulas.md milestone tables. If a test value doesn't
match the doc, the code is wrong — not the test.
