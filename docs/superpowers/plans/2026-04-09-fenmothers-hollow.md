# Fenmother's Hollow Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the second Act I dungeon — 3 floors with swamp biome, Drowned Sentinel mini-boss, 3-phase Corrupted Fenmother boss with wave defense cleansing sequence, 7 treasure chests, and overworld integration.

**Architecture:** Follows existing Ember Vein patterns — .tscn maps with TileMapLayer + Entities/Transitions groups, boss AI hardcoded in battle_ai.gd, boss flow in battle_manager.gd, cleansing wave sequence managed by exploration.gd post-battle logic.

**Tech Stack:** Godot 4.6 / GDScript, GUT test framework, existing autoload singletons (GameManager, DataManager, PartyState, EventFlags)

**Spec:** `docs/superpowers/specs/2026-04-09-fenmothers-hollow-design.md`

---

## Chunk 1: Data Verification & Dialogue Files

### Task 1: Verify enemy data exists in act_i.json

Enemy data for all 9 Fenmother enemies already exists in `game/data/enemies/act_i.json`.
This task verifies the data is correct against the bestiary.

**Files:**
- Read: `game/data/enemies/act_i.json`
- Read: `docs/story/bestiary/act-i.md`

- [ ] **Step 1: Verify all 9 enemy IDs exist**

```bash
cat game/data/enemies/act_i.json | python3 -c "
import json, sys
d = json.load(sys.stdin)
ids = [e['id'] for e in d['enemies']]
needed = ['marsh_serpent','bog_leech','drowned_bones','swamp_lurker',
          'ley_jellyfish','polluted_elemental','corrupted_spawn',
          'drowned_sentinel','corrupted_fenmother']
for n in needed:
    assert n in ids, f'MISSING: {n}'
    e = next(x for x in d['enemies'] if x['id'] == n)
    print(f'{n}: HP={e[\"hp\"]}, Lv={e[\"level\"]}, type={e[\"type\"]}')
print('All 9 enemies present')
"
```

- [ ] **Step 2: Spot-check 3 enemies against bestiary**

Verify exact stat match for marsh_serpent (HP=140, ATK=19, DEF=10),
drowned_sentinel (HP=4000, ATK=24, weak=storm),
corrupted_fenmother (HP=18000, ATK=40, weak=flame, resist=frost).

```bash
cat game/data/enemies/act_i.json | python3 -c "
import json, sys
d = json.load(sys.stdin)
checks = {
    'marsh_serpent': {'hp': 140, 'atk': 19, 'def': 10, 'level': 6},
    'drowned_sentinel': {'hp': 4000, 'atk': 24, 'level': 10},
    'corrupted_fenmother': {'hp': 18000, 'atk': 40, 'level': 12},
}
for eid, expected in checks.items():
    e = next(x for x in d['enemies'] if x['id'] == eid)
    for k, v in expected.items():
        actual = e[k]
        assert actual == v, f'{eid}.{k}: expected {v}, got {actual}'
    print(f'{eid}: PASS')
print('Spot checks passed')
"
```

### Task 2: Verify encounter table data

**Files:**
- Read: `game/data/encounters/fenmothers_hollow.json`

- [ ] **Step 1: Verify encounter JSON has correct floor entries**

```bash
cat game/data/encounters/fenmothers_hollow.json | python3 -c "
import json, sys
d = json.load(sys.stdin)
key = 'floors' if 'floors' in d else 'zones'
entries = d[key]
ids = [e.get('floor_id', e.get('zone_id', '')) for e in entries]
assert '1-2' in ids, 'Missing floor_id 1-2'
assert '3' in ids, 'Missing floor_id 3'
print(f'Floor entries: {ids}')
for e in entries:
    groups = e.get('encounter_groups', [])
    print(f'  {e.get(\"floor_id\", e.get(\"zone_id\"))}: {len(groups)} groups')
print('Encounter data OK')
"
```

### Task 3: Create dialogue JSON files

**Files:**
- Create: `game/data/dialogue/fenmother_battle.json`
- Create: `game/data/dialogue/water_of_life.json`
- Create: `game/data/dialogue/fenmother_cleansing.json`

- [ ] **Step 1: Create fenmother_battle.json**

4 entries for boss battle phases. All speakers are "narrator".
Text from `docs/story/script/act-i.md` and spec Section 6.

- [ ] **Step 2: Create water_of_life.json**

4 entries for puzzle flavor text. Speakers: torren, lira, sable, torren.
Text from spec Section 6 (canonical from dungeons-world.md).

- [ ] **Step 3: Create fenmother_cleansing.json**

5 entries for wave transitions. Speakers: torren, narrator, torren, narrator, narrator.
Text from spec Section 6.

- [ ] **Step 4: Verify all 3 files are valid JSON**

```bash
python3 -c "
import json
for f in ['fenmother_battle','water_of_life','fenmother_cleansing']:
    path = f'game/data/dialogue/{f}.json'
    with open(path) as fh:
        d = json.load(fh)
    entries = d.get('entries', [])
    print(f'{f}: {len(entries)} entries, scene_id={d.get(\"scene_id\",\"?\")}')
"
```

- [ ] **Step 5: Commit**

```bash
git add game/data/dialogue/fenmother_battle.json game/data/dialogue/water_of_life.json game/data/dialogue/fenmother_cleansing.json
git commit -m "feat(engine): add Fenmother's Hollow dialogue data (3 files)"
```

---

## Chunk 2: Tileset Extension & Floor Scenes

### Task 4: Extend placeholder tileset with swamp tiles

**Files:**
- Modify: `game/assets/tilesets/placeholder_dungeon.png`
- Modify: `game/assets/tilesets/placeholder_dungeon.tres`

- [ ] **Step 1: Generate extended tileset PNG**

Use Python to extend the PNG from 160x16 to 224x16, adding 4 solid-color
16x16 tiles at indices 10-13:
- 10: Marsh floor (#2d4a2e)
- 11: Shallow water (#1a3a3a)
- 12: Stone wall (#3a3a2e)
- 13: Crystal root (#4a2a5a)

```bash
python3 -c "
from PIL import Image
img = Image.open('game/assets/tilesets/placeholder_dungeon.png')
new_img = Image.new('RGBA', (224, 16), (0, 0, 0, 0))
new_img.paste(img, (0, 0))
colors = [(0x2d,0x4a,0x2e), (0x1a,0x3a,0x3a), (0x3a,0x3a,0x2e), (0x4a,0x2a,0x5a)]
for i, c in enumerate(colors):
    for y in range(16):
        for x in range(16):
            new_img.putpixel((160 + i*16 + x, y), (*c, 255))
new_img.save('game/assets/tilesets/placeholder_dungeon.png')
print('Tileset extended to 224x16 (14 tiles)')
"
```

If PIL is not available, use a manual approach with raw RGBA bytes.

- [ ] **Step 2: Update placeholder_dungeon.tres**

Add atlas coords for tiles 10-13. Add physics collision to tile 12 (stone wall).

Read the current .tres, add lines after the last tile registration:
```
10:0/0 = 0
11:0/0 = 0
12:0/0 = 0
13:0/0 = 0
12:0/0/physics_layer_0/linear_velocity = Vector2(0, 0)
12:0/0/physics_layer_0/polygon_0/points = PackedVector2Array(-8, -8, 8, -8, 8, 8, -8, 8)
```

Also update `load_steps` if needed.

- [ ] **Step 3: Verify tileset loads**

```bash
# Tileset file should now reference 14 tiles
grep -c "0/0 = 0" game/assets/tilesets/placeholder_dungeon.tres
# Expected: 14 (or more if some tiles have multiple properties)
```

- [ ] **Step 4: Commit**

```bash
git add game/assets/tilesets/placeholder_dungeon.png game/assets/tilesets/placeholder_dungeon.tres
git commit -m "feat(engine): extend placeholder tileset with 4 swamp tiles (indices 10-13)"
```

### Task 5: Create Floor 1 scene (Flooded Entry)

**Files:**
- Create: `game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn`

Follow the exact pattern from `ember_vein_f1.tscn`:
- TileMapLayer using placeholder_dungeon.tres with swamp tiles (10=floor, 11=water, 12=wall, 13=crystal)
- 45x30 tile map: walls around perimeter, marsh floor interior, water patches, crystal roots
- Entities group: SavePoint, 2 Chests, 1 DialogueTrigger
- Transitions group: 1 transition to F2
- PlayerSpawn marker
- Metadata: map_id, dungeon_id, floor_id "1-2", location_name

- [ ] **Step 1: Create the .tscn file**

Build the scene programmatically following ember_vein_f1.tscn structure.
Key details from spec Section 4:
- SavePoint "fenmothers_hollow_f1_save" at (~64, ~48)
- Chest chest_id="fenmothers_hollow_marsh_cloak" item_id="marsh_cloak" at (~640, ~96)
- Chest chest_id="fenmothers_hollow_spirit_tonic" item_id="spirit_tonic" at (~320, ~400)
- DialogueTrigger at (~192, ~256) with dialogue_scene_id="water_of_life", flag="fenmothers_hollow_wheel_seen"
- Transition to F2 at (~352, ~448)
- PlayerSpawn at (~48, ~48)

- [ ] **Step 2: Verify scene structure**

```bash
grep "metadata/map_id" game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn
grep "metadata/floor_id" game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn
grep "chest_id" game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn
grep "save_point_id" game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn
```

- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/dungeons/fenmothers_hollow_f1.tscn
git commit -m "feat(engine): add Fenmother's Hollow F1 (Flooded Entry) scene"
```

### Task 6: Create Floor 2 scene (Submerged Temple)

**Files:**
- Create: `game/scenes/maps/dungeons/fenmothers_hollow_f2.tscn`

50x35 tiles. Entities: SavePoint, 3 Chests, DialogueTrigger, BossTrigger (Drowned Sentinel).
Transitions: back to F1, forward to F3 (with required_flag "drowned_sentinel_defeated").

- [ ] **Step 1: Create the .tscn file**

Key details from spec:
- SavePoint "fenmothers_hollow_f2_save" at (~400, ~272)
- Chest fenmothers_hollow_fenmothers_scale / fenmothers_scale at (~96, ~320)
- Chest fenmothers_hollow_spirit_bound_spear / spirit_bound_spear at (~640, ~192)
- Chest fenmothers_hollow_ancient_totem / ancient_totem at (~96, ~64)
- DialogueTrigger at (~544, ~160) with dialogue_scene_id="water_of_life", flag="fenmothers_hollow_plant_seen"
- BossTrigger at (~544, ~320): boss_id="drowned_sentinel", flag="drowned_sentinel_defeated", enemy_ids=["drowned_sentinel"]
- Transition to F1 at (~352, ~48)
- Transition to F3 at (~544, ~528) with required_flag="drowned_sentinel_defeated"
- PlayerSpawn "from_f1" at (~352, ~48)

- [ ] **Step 2: Verify**
- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/dungeons/fenmothers_hollow_f2.tscn
git commit -m "feat(engine): add Fenmother's Hollow F2 (Submerged Temple) scene"
```

### Task 7: Create Floor 3 scene (Fenmother's Sanctum)

**Files:**
- Create: `game/scenes/maps/dungeons/fenmothers_hollow_f3.tscn`

35x25 tiles. Circular boss arena. Entities: SavePoint, BossTrigger (Corrupted Fenmother),
flag-gated Chest. Transitions: back to F2, exit to overworld.

- [ ] **Step 1: Create the .tscn file**

Key details:
- SavePoint "fenmothers_hollow_f3_save" at (~272, ~96)
- BossTrigger at (~272, ~208): boss_id="corrupted_fenmother", flag="fenmother_boss_defeated", enemy_ids=["corrupted_fenmother"]
- Chest fenmothers_hollow_blessing / fenmothers_blessing at (~272, ~304) with required_flag="fenmother_cleansed"
- Transition to F2 at (~272, ~48)
- Transition to overworld at (~272, ~368) target_map="overworld" target_spawn="from_fenmothers_hollow"
- PlayerSpawn "from_f2" at (~272, ~48)

- [ ] **Step 2: Verify**
- [ ] **Step 3: Commit**

```bash
git add game/scenes/maps/dungeons/fenmothers_hollow_f3.tscn
git commit -m "feat(engine): add Fenmother's Hollow F3 (Sanctum) scene"
```

---

## Chunk 3: Exploration Changes

### Task 8: Add flag-gated transition support

**Files:**
- Modify: `game/scripts/core/exploration.gd` (around line 417-422, `_on_transition_body_entered`)

- [ ] **Step 1: Read current transition handler**

```gdscript
# Current code at line 417:
func _on_transition_body_entered(body: Node2D, area: Area2D) -> void:
    if _transitioning or body != _player:
        return
    var tgt: String = area.get_meta("target_map", "")
    if tgt != "":
        _transition_to_map(tgt, area.get_meta("target_spawn", ""))
```

- [ ] **Step 2: Add required_flag check**

Add after the `_transitioning` check, before the target_map read:

```gdscript
    var req_flag: String = area.get_meta("required_flag", "")
    if not req_flag.is_empty() and not EventFlags.get_flag(req_flag):
        return
```

- [ ] **Step 3: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): support required_flag on map transitions"
```

### Task 9: Add flag-gated chest support

**Files:**
- Modify: `game/scenes/entities/treasure_chest.gd` (or wherever chest interact logic lives)

- [ ] **Step 1: Find the chest interact method**

Search for the chest script that handles interaction. Check `game/scripts/entities/treasure_chest.gd`
or similar. Look for the `interact()` method.

- [ ] **Step 2: Add required_flag guard at top of interact()**

```gdscript
    var req: String = get_meta("required_flag", "")
    if not req.is_empty() and not EventFlags.get_flag(req):
        return
```

- [ ] **Step 3: Commit**

```bash
git add game/scripts/entities/treasure_chest.gd
git commit -m "feat(engine): support required_flag on treasure chests"
```

### Task 10: Add cleansing wave sequence support

**Files:**
- Modify: `game/scripts/core/exploration.gd` (`_initialize_from_transition_data`)

This is the most complex change. When battle returns with
`result: "fenmother_cleansing"`, exploration must:
1. Distribute battle rewards (XP/gold)
2. Play dialogue between waves
3. Move Torren to reserve
4. Start next wave battle
5. After Wave 4: restore Torren, set flag, load F3

- [ ] **Step 1: Add "fenmother_cleansing" result handler**

In `_initialize_from_transition_data`, after the `elif r == "faint"` block
(around line 208), add a new elif for the initial cleansing trigger:

```gdscript
        elif r == "fenmother_cleansing":
            var rewards: Dictionary = {
                "xp": data.get("earned_xp", 0),
                "gold": data.get("earned_gold", 0),
                "drops": data.get("earned_drops", [])
            }
            PartyState.distribute_battle_rewards(rewards)
            _danger_counter = 0
            load_map(data.get("map_id", "dungeons/fenmothers_hollow_f3"))
            if _player != null:
                _player.position = data.get("position", Vector2(272, 208))
            _start_cleansing_sequence(data)
```

- [ ] **Step 2: Add wave continuation handler**

After the "victory" result handler, check for wave_num in transition_data
to detect wave battle returns:

```gdscript
        # Inside the "victory" result block, after distributing rewards:
        # Check if this was a cleansing wave battle
        var wave_num: int = data.get("wave_num", -1)
        if wave_num >= 0:
            _continue_cleansing_sequence(data)
            return
```

- [ ] **Step 3: Implement _start_cleansing_sequence**

```gdscript
func _start_cleansing_sequence(data: Dictionary) -> void:
    # Move Torren from active to reserve
    _move_torren_to_reserve()
    # Show pre-wave dialogue
    var dialogue: Dictionary = DataManager.load_dialogue("fenmother_cleansing")
    var entries: Array = dialogue.get("entries", [])
    if not entries.is_empty():
        if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
            GameManager.overlay_node.show_dialogue([entries[0]])
            GameManager.overlay_state_changed.connect(
                _on_cleansing_dialogue_closed.bind(0, data), CONNECT_ONE_SHOT
            )
```

- [ ] **Step 4: Implement _continue_cleansing_sequence**

```gdscript
func _continue_cleansing_sequence(data: Dictionary) -> void:
    var wave_num: int = data.get("wave_num", 0)
    # Revive fallen party members at 25% HP between waves
    _revive_fallen_at_quarter_hp()
    if wave_num >= 3:
        _complete_cleansing(data)
        return
    var next_wave: int = wave_num + 1
    # Show inter-wave dialogue
    var dialogue: Dictionary = DataManager.load_dialogue("fenmother_cleansing")
    var entries: Array = dialogue.get("entries", [])
    var entry_idx: int = mini(next_wave, entries.size() - 1)
    if entry_idx < entries.size():
        if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
            GameManager.overlay_node.show_dialogue([entries[entry_idx]])
            GameManager.overlay_state_changed.connect(
                _on_cleansing_dialogue_closed.bind(next_wave, data), CONNECT_ONE_SHOT
            )
```

- [ ] **Step 5: Implement wave battle launcher and completion**

```gdscript
const CLEANSING_WAVES: Array = [
    ["marsh_serpent","marsh_serpent","marsh_serpent","marsh_serpent","polluted_elemental","polluted_elemental"],
    ["ley_jellyfish","ley_jellyfish","ley_jellyfish","drowned_bones","drowned_bones","drowned_bones","polluted_elemental"],
    ["polluted_elemental","polluted_elemental","marsh_serpent","marsh_serpent","marsh_serpent","marsh_serpent","ley_jellyfish","ley_jellyfish"],
    ["corrupted_spawn","corrupted_spawn","corrupted_spawn"],
]

func _on_cleansing_dialogue_closed(state: GameManager.OverlayState, wave_num: int, data: Dictionary) -> void:
    if state != GameManager.OverlayState.NONE:
        return
    _launch_cleansing_wave(wave_num, data)

func _launch_cleansing_wave(wave_num: int, data: Dictionary) -> void:
    var transition: Dictionary = {
        "encounter_group": CLEANSING_WAVES[wave_num],
        "formation_type": "normal",
        "return_map_id": data.get("map_id", "dungeons/fenmothers_hollow_f3"),
        "return_position": data.get("position", Vector2(272, 208)),
        "enemy_act": "act_i",
        "encounter_source": "cleansing_wave",
        "wave_num": wave_num,
    }
    GameManager.change_core_state(GameManager.CoreState.BATTLE, transition)

func _complete_cleansing(data: Dictionary) -> void:
    _restore_torren_to_active()
    EventFlags.set_flag("fenmother_cleansed", true)
    # Show final dialogue
    var dialogue: Dictionary = DataManager.load_dialogue("fenmother_cleansing")
    var entries: Array = dialogue.get("entries", [])
    if entries.size() > 4:
        if GameManager.push_overlay(GameManager.OverlayState.DIALOGUE):
            GameManager.overlay_node.show_dialogue([entries[4]])
    load_map("dungeons/fenmothers_hollow_f3")
    if _player != null:
        _player.position = data.get("position", Vector2(272, 208))
    flash_location_name("The Fenmother has been cleansed!")

func _move_torren_to_reserve() -> void:
    var active: Array = PartyState.formation.get("active", [])
    var reserve: Array = PartyState.formation.get("reserve", [])
    for i: int in range(active.size()):
        var idx: int = active[i]
        if idx < PartyState.members.size():
            var m: Dictionary = PartyState.members[idx]
            if m.get("character_id", "") == "torren":
                active.remove_at(i)
                reserve.append(idx)
                break
    PartyState.formation["active"] = active
    PartyState.formation["reserve"] = reserve

func _restore_torren_to_active() -> void:
    var active: Array = PartyState.formation.get("active", [])
    var reserve: Array = PartyState.formation.get("reserve", [])
    for i: int in range(reserve.size()):
        var idx: int = reserve[i]
        if idx < PartyState.members.size():
            var m: Dictionary = PartyState.members[idx]
            if m.get("character_id", "") == "torren":
                reserve.remove_at(i)
                if active.size() < 4:
                    active.append(idx)
                break
    PartyState.formation["active"] = active
    PartyState.formation["reserve"] = reserve

func _revive_fallen_at_quarter_hp() -> void:
    for m: Dictionary in PartyState.members:
        if m.get("current_hp", 0) <= 0:
            var quarter: int = maxi(1, m.get("max_hp", 1) / 4)
            m["current_hp"] = quarter
```

- [ ] **Step 6: Commit**

```bash
git add game/scripts/core/exploration.gd
git commit -m "feat(engine): add Fenmother cleansing wave sequence in exploration"
```

---

## Chunk 4: Battle Manager Changes

### Task 11: Add Drowned Sentinel boss AI

**Files:**
- Modify: `game/scripts/combat/battle_ai.gd`
- Modify: `game/scripts/combat/battle_manager.gd`

- [ ] **Step 1: Add Drowned Sentinel AI function to battle_ai.gd**

Add after `get_vein_guardian_action`:

```gdscript
## Drowned Sentinel scripted AI (hardcoded, tech debt).
## Every 4th turn: Barnacle Shield (DEF buff). Every 3rd turn: Frost Wave (AoE).
## Default: Stone Slam (physical, highest threat target).
static func get_drowned_sentinel_action(
    state: Node, turn: int
) -> Dictionary:
    if turn % 4 == 0:
        return {
            "type": "ability", "id": "barnacle_shield",
            "target": "self", "element": ""
        }
    if turn % 3 == 0:
        return {
            "type": "ability", "id": "frost_wave",
            "target": "all", "element": "frost", "power": 20
        }
    return {
        "type": "attack", "id": "stone_slam",
        "target_slot": pick_alive_target(state)
    }
```

- [ ] **Step 2: Add Corrupted Fenmother AI function to battle_ai.gd**

```gdscript
## Corrupted Fenmother scripted AI (hardcoded, tech debt).
## Dive/surface cycle: 3 surface turns, 2 dive turns.
## Phase 1 (>50% HP): turn_counter priority (Tail Sweep, Water Jet).
## Phase 2 (<=50% HP): spawn adds, more aggressive surface attacks.
static func get_corrupted_fenmother_action(
    state: Node, turn: int, hp_ratio: float,
    surface_count: int, is_diving: bool,
    spawned_adds: bool, active_adds: int
) -> Dictionary:
    # Phase 2 transition: spawn adds
    if not spawned_adds and hp_ratio <= 0.5:
        return {"type": "spawn", "id": "spawn_adds",
                "enemies": ["corrupted_spawn", "corrupted_spawn"]}

    # Dive phase: skip turn
    if is_diving:
        return {"type": "skip", "id": "dive"}

    # About to dive (after 3 surface turns)
    if surface_count >= 3:
        return {"type": "skip", "id": "start_dive"}

    # Phase 2 surface: re-spawn adds if needed
    if hp_ratio <= 0.5 and active_adds < 2 and turn % 3 == 0:
        return {"type": "spawn", "id": "spawn_adds",
                "enemies": ["corrupted_spawn", "corrupted_spawn"]}

    # Surface actions (per bosses.md priority)
    if hp_ratio > 0.5:
        # Phase 1
        if turn % 4 == 0:
            return {"type": "ability", "id": "tail_sweep",
                    "target": "all", "element": "", "power": 0}
        if turn % 3 == 0:
            var tgt: int = _pick_lowest_hp_target(state)
            return {"type": "ability", "id": "water_jet",
                    "target_slot": tgt, "element": "frost", "power": 25}
        return {"type": "ability", "id": "tail_sweep",
                "target": "all", "element": "", "power": 0}
    else:
        # Phase 2: more aggressive
        if turn % 3 == 0:
            var tgt: int = _pick_lowest_hp_target(state)
            return {"type": "ability", "id": "water_jet",
                    "target_slot": tgt, "element": "frost", "power": 25}
        if turn % 2 == 0:
            return {"type": "ability", "id": "tail_sweep",
                    "target": "all", "element": "", "power": 0}
        var tgt: int = _pick_lowest_hp_target(state)
        return {"type": "ability", "id": "water_jet",
                "target_slot": tgt, "element": "frost", "power": 25}


static func _pick_lowest_hp_target(state: Node) -> int:
    var lowest_hp: int = 99999
    var lowest_slot: int = 0
    for i: int in range(4):
        var m: Dictionary = state.get_member(i)
        if m.get("is_alive", false):
            var hp: int = m.get("current_hp", 99999)
            if hp < lowest_hp:
                lowest_hp = hp
                lowest_slot = i
    return lowest_slot
```

- [ ] **Step 3: Wire Drowned Sentinel in battle_manager.gd _execute_enemy_turn**

Add after the Vein Guardian check (around line 292):

```gdscript
    elif _is_boss and enemy.enemy_data.get("id", "") == "drowned_sentinel":
        action = BattleAI.get_drowned_sentinel_action(_state, _turn_counter)
```

- [ ] **Step 4: Wire Corrupted Fenmother in battle_manager.gd**

Add state variables at class level:
```gdscript
var _fm_surface_count: int = 0
var _fm_diving: bool = false
var _fm_spawned_adds: bool = false
```

Add in _execute_enemy_turn after drowned_sentinel:
```gdscript
    elif _is_boss and enemy.enemy_data.get("id", "") == "corrupted_fenmother":
        var hp_ratio: float = float(enemy.current_hp) / float(enemy.enemy_data.get("hp", 1))
        var active_adds: int = _enemies.filter(
            func(e: Node) -> bool: return e.is_alive and e.enemy_data.get("id", "") == "corrupted_spawn"
        ).size()
        action = BattleAI.get_corrupted_fenmother_action(
            _state, _turn_counter, hp_ratio,
            _fm_surface_count, _fm_diving, _fm_spawned_adds, active_adds
        )
        # Handle state transitions
        if action.get("id", "") == "spawn_adds":
            _fm_spawned_adds = true
        elif action.get("id", "") == "start_dive":
            _fm_diving = true
            _fm_surface_count = 0
        elif action.get("id", "") == "dive":
            _fm_surface_count += 1
            if _fm_surface_count >= 2:
                _fm_diving = false
                _fm_surface_count = 0
        else:
            _fm_surface_count += 1
```

- [ ] **Step 5: Handle spawn action type in _execute_enemy_turn**

Add handling for the "spawn" action type to create add enemies:
```gdscript
    if action.get("type", "") == "spawn":
        var spawn_ids: Array = action.get("enemies", [])
        for sid: String in spawn_ids:
            # Similar to _setup_enemies but adding to existing _enemies
            var enemy_data: Dictionary = DataManager.load_enemy(sid, "act_i")
            if not enemy_data.is_empty():
                var new_enemy: Node = ENEMY_SCENE.instantiate()
                _enemy_area.add_child(new_enemy)
                new_enemy.initialize(enemy_data)
                _enemies.append(new_enemy)
                var eid: String = "enemy_%d" % (_enemies.size() - 1)
                _atb.add_combatant(eid, enemy_data.get("spd", 10))
        message.emit("Corrupted Spawn emerge from the depths!")
        return  # spawn takes the full turn
```

- [ ] **Step 6: Intercept victory for Fenmother cleansing**

In `_check_end_conditions`, before the current victory logic:

```gdscript
func _check_end_conditions() -> void:
    if _enemies.all(func(e: Node) -> bool: return not e.is_alive):
        _battle_active = false
        _awaiting_input_for = ""
        _earned_drops = []
        for e: Node in _enemies:
            _earned_xp += e.enemy_data.get("exp", e.enemy_data.get("xp", 0))
            _earned_gold += e.enemy_data.get("gold", 0)
            var d: Dictionary = e.roll_drop()
            if d.get("success", false):
                _earned_drops.append({"item_id": d.get("item_id", "")})
        # Intercept: Fenmother boss triggers cleansing instead of victory
        if _boss_flag == "fenmother_boss_defeated":
            _exit_battle("fenmother_cleansing")
            return
        var r: Dictionary = {"xp": _earned_xp, "gold": _earned_gold, "drops": _earned_drops}
        victory.emit(r)
    elif _state.is_party_wiped():
        defeat.emit()
        _exit_battle("faint")
```

- [ ] **Step 7: Handle dive/skip actions (untargetable)**

The "skip" action type needs the enemy to be untargetable. Add at the
top of the action execution in `_execute_enemy_turn`:

```gdscript
    if action.get("type", "") == "skip":
        if action.get("id", "") == "start_dive":
            message.emit("The Fenmother dives beneath the surface!")
            enemy.set_meta("untargetable", true)
        elif action.get("id", "") == "dive" and not _fm_diving:
            message.emit("The Fenmother resurfaces!")
            enemy.set_meta("untargetable", false)
        return
```

Also need to check untargetable in attack targeting — add guard in
`_do_attack` and magic targeting to skip untargetable enemies.

- [ ] **Step 8: Commit**

```bash
git add game/scripts/combat/battle_ai.gd game/scripts/combat/battle_manager.gd
git commit -m "feat(engine): add Drowned Sentinel + Corrupted Fenmother boss AI"
```

---

## Chunk 5: Overworld, Tests, Gap Tracker

### Task 12: Add overworld entry point

**Files:**
- Modify: `game/scenes/maps/overworld.tscn`

- [ ] **Step 1: Add FenmothersHollow transition + label + spawn marker**

Add to Transitions group:
- Area2D "FenmothersHollow" at position (~336, ~528)
- target_map: "dungeons/fenmothers_hollow_f1"
- target_spawn: "from_overworld" (Note: F1's PlayerSpawn serves this)
- collision_layer=0, collision_mask=2, monitoring=true, monitorable=false
- CollisionShape2D with RectangleShape2D size 48x48

Add Label "LabelFenmothersHollow" with text "Fenmother's Hollow".

Add Marker2D "from_fenmothers_hollow" near the transition position.

- [ ] **Step 2: Commit**

```bash
git add game/scenes/maps/overworld.tscn
git commit -m "feat(engine): add Fenmother's Hollow overworld entry point"
```

### Task 13: Write integration tests

**Files:**
- Create: `game/tests/test_fenmothers_hollow.gd`

- [ ] **Step 1: Write all ~35 tests**

Follow the pattern from `test_opening_sequence.gd`: use scene instantiation
for .tscn validation, DataManager for JSON, direct const access for data.

Tests organized by category per spec Section 11:
- Tileset/assets (3): PNG exists, .tres exists, swamp tile coords registered
- Enemy data (9): each enemy loads with correct HP from act_i.json
- Encounter data (2): exists, has floor_id "1-2" and "3"
- Dialogue data (3): all 3 files load with correct entry counts
- Floor metadata (3): each .tscn has correct map_id/dungeon_id/floor_id/location_name
- Tileset reference (3): each floor's TileMapLayer uses placeholder_dungeon
- Chests (3): F1 has 2, F2 has 3, F3 has 1 with required_flag
- Save points (3): each floor has save point
- Boss triggers (2): Sentinel on F2, Fenmother on F3
- Transitions (3): F1→F2, F2→F3 (flag-gated), F3→overworld
- Overworld (2): transition exists, spawn marker exists
- Flag-gated transition (1): exploration.gd contains required_flag check

- [ ] **Step 2: Run gdlint + gdformat on test file**

```bash
gdlint game/tests/test_fenmothers_hollow.gd
gdformat --check game/tests/test_fenmothers_hollow.gd
```

- [ ] **Step 3: Commit**

```bash
git add game/tests/test_fenmothers_hollow.gd
git commit -m "test(engine): add Fenmother's Hollow integration tests (~35 tests)"
```

### Task 14: Update gap tracker

**Files:**
- Modify: `docs/analysis/game-dev-gaps.md`

- [ ] **Step 1: Update Phase A2 status**

Change from "NOT STARTED" to "MOSTLY COMPLETE" (puzzle mechanics deferred):
- Mark all combat-focused items as done
- Add Phase A2b section for deferred puzzle work
- Add notes about what was built
- Add design spec reference

- [ ] **Step 2: Add progress tracking entry**

Add row to the progress table at the bottom of the file.

- [ ] **Step 3: Commit**

```bash
git add docs/analysis/game-dev-gaps.md
git commit -m "docs(engine): update gap 4.4 Phase A2 — Fenmother's Hollow mostly complete"
```

### Task 15: Final verification

- [ ] **Step 1: Run all quality gates**

```bash
gdlint game/scripts/core/exploration.gd game/scripts/combat/battle_ai.gd game/scripts/combat/battle_manager.gd game/tests/test_fenmothers_hollow.gd
gdformat --check game/scripts/core/exploration.gd game/scripts/combat/battle_ai.gd game/scripts/combat/battle_manager.gd game/tests/test_fenmothers_hollow.gd
```

- [ ] **Step 2: Verify all new files exist**

```bash
ls -la game/data/dialogue/fenmother_battle.json game/data/dialogue/water_of_life.json game/data/dialogue/fenmother_cleansing.json
ls -la game/scenes/maps/dungeons/fenmothers_hollow_f*.tscn
ls -la game/tests/test_fenmothers_hollow.gd
```

- [ ] **Step 3: Mirror staleness check**

```bash
grep -r "fenmother" docs/ --include="*.md" -l
# Verify spec, gap tracker, and events.md are consistent
```

- [ ] **Step 4: Commit any final fixes, then hand off**

Next steps:
1. `/create-pr` — open PR targeting main
2. `/godot-review-loop <PR#> 2` — multi-round hardening
