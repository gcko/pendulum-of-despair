# Gap 2.2: NPC Prefab — Design Spec

> **Date:** 2026-04-05
> **Gap:** 2.2 (NPC Prefab)
> **Status:** Approved
> **Source docs:** dialogue-system.md (interaction model, priority stack, 14 emotions), npcs.md (NPC list), technical-architecture.md Section 4.2 (scene tree)
> **Architecture ref:** technical-architecture.md Section 4.2

## Problem

The exploration scene needs NPC entities that display on maps, respond to player interaction, resolve flag-gated dialogue via a priority stack, and emit interaction signals. This is the last Tier 2 entity prefab and the sole blocker for the exploration scene (gap 3.2).

## Scope

- 1 scene file + 1 script file
- 1 placeholder sprite
- 1 test file
- Signal-only response (consumer handles dialogue overlay)

**Excluded (deferred):**
- Dialogue overlay rendering → gap 3.5
- Emotion animation playback during dialogue → gap 3.5
- Choice consequence handling → gap 3.5
- `party_has()` runtime check → implemented via PartyState.has_member()

---

## Scene Tree

```
NPC (Area2D)
├── Sprite2D              — 16x24 placeholder
├── CollisionShape2D      — RectangleShape2D 12x12
├── AnimationPlayer       — idle + 14 emotion stubs
└── npc.gd
```

### Node Configuration

| Node | Property | Value | Notes |
|------|----------|-------|-------|
| NPC | collision_layer | 4 (layer 3) | Detected by PlayerCharacter InteractionArea |
| NPC | collision_mask | 0 | Doesn't detect anything |
| NPC | monitoring | false | Not needed |
| NPC | monitorable | true | Player detects it |

---

## GDScript API

### Signals

```gdscript
## Emitted when the player interacts. Carries resolved dialogue data.
signal npc_interacted(npc_id: String, dialogue_data: Dictionary)
```

### Properties

```gdscript
## NPC identifier used for dialogue lookup.
var npc_id: String = ""

## All dialogue entries loaded from DataManager.
var dialogue_entries: Array = []

## Child node references.
@onready var _sprite: Sprite2D = $Sprite2D
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
```

### Public Methods

```gdscript
## Initialize the NPC with an ID. Loads dialogue from DataManager.
func initialize(p_npc_id: String) -> void

## Called by exploration scene when player interacts.
## Resolves current dialogue via priority stack, emits npc_interacted.
func interact() -> void

## Get the current dialogue entry based on priority stack resolution.
## Two-pass: first checks conditioned entries (skips null), then falls
## back to the last null-condition entry. Handles data where defaults
## appear before conditioned entries in the JSON array.
func get_current_dialogue() -> Dictionary
```

### Private Methods

```gdscript
## Evaluate a condition expression string against current game state.
## Supports: binary flags, numeric comparisons (>=, <, ==),
## party_has(character), AND combinations, null (always true).
func _evaluate_condition(condition) -> bool

## Load placeholder sprite for this NPC.
func _load_placeholder_sprite() -> void
```

---

## Priority Stack Resolution

`get_current_dialogue()` walks `dialogue_entries` top-to-bottom and returns the first entry whose condition evaluates true:

```
for entry in dialogue_entries:
    if entry.condition is null or entry.condition == "":
        return entry  # default/fallback
    if _evaluate_condition(entry.condition):
        return entry
return {}  # no match (should never happen with a default entry)
```

Note: entries with `condition: null` are fallback entries. They should be at the END of the array so higher-priority conditioned entries are checked first. If a null-condition entry appears before conditioned entries, it will always match first (first-match-wins).

### Condition Evaluation

```gdscript
func _evaluate_condition(condition) -> bool:
    if condition == null or condition == "":
        return true

    # AND combinations
    if " AND " in condition:
        var parts = condition.split(" AND ")
        for part in parts:
            if not _evaluate_condition(part.strip_edges()):
                return false
        return true

    # party_has(character)
    if condition.begins_with("party_has("):
        # Stub: return false until GameManager.party exists
        return false

    # Numeric comparison (score >= N, score < N, score == N)
    for op in [">=", "<=", "==", "!=", ">", "<"]:
        if op in condition:
            var split = condition.split(op)
            var flag_name = split[0].strip_edges()
            var value = split[1].strip_edges()
            var flag_val = EventFlags.get_flag(flag_name)
            # Compare based on operator...
            return _compare(flag_val, op, value)

    # Binary flag (simplest case)
    return EventFlags.get_flag(condition)
```

---

## Placeholder Sprite

| File | Size | Color | Notes |
|------|------|-------|-------|
| `placeholder_npc.png` | 16x24 | #44AA88 fill, #228866 border | Green-tinted person |

Location: `game/assets/sprites/npcs/`

---

## AnimationPlayer

15 stub animations (idle + 14 emotions):

| Animation | Length | Loop |
|-----------|--------|------|
| idle | 2.0s | Yes |
| jump | 0.4s | No |
| shake | 0.5s | No |
| turn_away | 0.3s | No |
| head_down | 0.4s | No |
| bubble_exclaim | 1.0s | No |
| bubble_ellipsis | 1.5s | No |
| bubble_question | 1.0s | No |
| sweat_drop | 0.8s | No |
| cry | 1.0s | Yes |
| red_tint | 0.5s | No |
| arms_up | 0.5s | No |
| collapse | 0.6s | No |
| nod | 0.4s | No |
| step_back | 0.3s | No |

All stubs — no tracks. Real animation tracks added when art assets exist.

---

## Tests

`game/tests/test_npc.gd`:

1. **test_initialize_loads_dialogue** — init with "bren", verify npc_id set, dialogue_entries populated
2. **test_initialize_empty_id_blocked** — empty string rejected with push_error
3. **test_interact_emits_signal** — after init, interact() emits npc_interacted
4. **test_interact_before_init_blocked** — uninitialized NPC doesn't emit
5. **test_interact_signal_carries_data** — verify signal has npc_id and dialogue dict
6. **test_get_current_dialogue_default** — no flags set, returns last entry (default)
7. **test_get_current_dialogue_with_flag** — set a flag, verify higher-priority entry returned
8. **test_evaluate_condition_null** — null condition returns true
9. **test_evaluate_condition_empty** — empty string returns true
10. **test_evaluate_condition_flag_set** — set flag, returns true
11. **test_evaluate_condition_flag_unset** — unset flag, returns false
12. **test_evaluate_condition_and** — compound AND condition

Tests use `after_each()` with `EventFlags.clear_all()` per PR #117 pattern.

---

## Verification Checklist

- [ ] Scene loads in Godot editor without errors
- [ ] Area2D on collision layer 3 (bitmask 4), monitorable=true
- [ ] Sprite2D displays 16x24 placeholder
- [ ] AnimationPlayer has all 15 animations (idle + 14 emotions)
- [ ] initialize() loads dialogue from DataManager
- [ ] initialize() rejects empty npc_id with push_error
- [ ] interact() emits npc_interacted with resolved dialogue
- [ ] interact() returns early if uninitialized
- [ ] get_current_dialogue() resolves priority stack correctly
- [ ] _evaluate_condition() handles null, empty, binary flag, AND
- [ ] party_has() implemented via PartyState.has_member()
- [ ] All code passes gdlint + gdformat
- [ ] load_steps in .tscn matches ext_resource + sub_resource count
- [ ] Tests cover every if-branch (dual-pass verified)
- [ ] No stale mirrors in docs after implementation
