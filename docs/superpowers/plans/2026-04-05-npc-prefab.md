# Gap 2.2: NPC Prefab — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the last Tier 2 entity — an NPC prefab with flag-gated dialogue priority stack resolution.

**Architecture:** Area2D on collision layer 3. Loads dialogue from DataManager, resolves priority stack via condition evaluation, emits signal with resolved dialogue data. Signal-only response — exploration scene handles overlay. Condition evaluator supports binary flags, numeric comparisons, party_has() (stubbed), and AND combinations.

**Tech Stack:** Godot 4.6, GDScript, GUT 9.3.0, gdlint 4.5.0

**Spec:** `docs/superpowers/specs/2026-04-05-npc-prefab-design.md`

---

## File Structure

| Action | File | Purpose |
|--------|------|---------|
| Create | `game/scripts/entities/npc.gd` | NPC entity with priority stack |
| Create | `game/scenes/entities/npc.tscn` | Scene with Area2D + animations |
| Create | `game/assets/sprites/npcs/placeholder_npc.png` | 16x24 green placeholder |
| Create | `game/tests/test_npc.gd` | Unit tests |
| Modify | `docs/analysis/game-dev-gaps.md` | Update gap 2.2 status |

---

## Chunk 1: Script + Scene

### Task 1: Create placeholder sprite

Generate a 16x24 PNG: #44AA88 fill, #228866 border.

- [ ] **Step 1:** Create `game/assets/sprites/npcs/` directory
- [ ] **Step 2:** Generate placeholder_npc.png
- [ ] **Step 3:** Verify file exists and is 16x24

---

### Task 2: Create npc.gd

**Agent instructions:** Write the NPC entity script following established patterns from player_character.gd and treasure_chest.gd. Apply the MANDATORY dual-pass self-review before declaring done.

Key components:

**Signal:** `npc_interacted(npc_id: String, dialogue_data: Dictionary)`

**initialize(p_npc_id):**
- Guard empty string with push_error + return
- Store npc_id
- Load dialogue via `DataManager.load_dialogue("npc_%s" % npc_id)`
- Extract entries array from loaded data
- Load placeholder sprite

**interact():**
- Guard uninitialized (npc_id == "") with return
- Call get_current_dialogue() to resolve priority stack
- If result is empty dict, return (no dialogue)
- Emit npc_interacted(npc_id, dialogue_entry)

**get_current_dialogue() -> Dictionary:**
- Walk dialogue_entries top-to-bottom
- For each entry: if condition is null/empty, return it (default)
- If condition evaluates true via _evaluate_condition(), return it
- Return {} if nothing matches

**_evaluate_condition(condition) -> bool:**
- null or "" → return true
- Contains " AND " → split and recursively evaluate all parts
- Starts with "party_has(" → return false (stub)
- Contains operator (>=, <=, ==, !=, >, <) → parse flag name + value, compare via EventFlags
- Otherwise → treat as binary flag: `EventFlags.get_flag(condition)`
- Wrap get_flag result in bool() for type safety

**_load_placeholder_sprite():**
- Same pattern as other entities: ResourceLoader.exists() guard, get_node_or_null fallback

**DUAL-PASS SELF-REVIEW BEFORE DONE:**
Mechanical: Every public method guarded against uninitialized state? Empty input validated? Double-call safe? Every if-branch will have a test?
Narrative: Matches spec? Signal flow correct? Collision config right?

- [ ] **Step 1:** Write npc.gd
- [ ] **Step 2:** Run gdformat + gdlint — must pass
- [ ] **Step 3:** Dual-pass self-review (mechanical + narrative)

---

### Task 3: Create npc.tscn

Scene file with:
- Root: Area2D named "NPC", collision_layer=4, collision_mask=0, monitoring=false, monitorable=true
- Sprite2D: placeholder_npc.png
- CollisionShape2D: RectangleShape2D half-extents 6x6
- AnimationPlayer: 15 stub animations (idle + 14 emotions)
- Script: res://scripts/entities/npc.gd

**CRITICAL: Count ext_resource + sub_resource BEFORE setting load_steps.**
- ext_resource: 2 (script + sprite)
- sub_resource: 1 (RectangleShape2D) + 15 (animations) + 1 (AnimationLibrary) = 17
- load_steps = 2 + 17 = 19

- [ ] **Step 1:** Write npc.tscn
- [ ] **Step 2:** Verify load_steps = ext_resource count + sub_resource count

---

## Chunk 2: Tests + Completion

### Task 4: Write GUT tests

12 tests following established patterns (untyped vars, after_each cleanup, signal watching):

**Initialization:**
1. test_initialize_loads_dialogue — init "bren", verify npc_id set, entries populated
2. test_initialize_empty_id_blocked — empty string rejected

**Interaction:**
3. test_interact_emits_signal — after init, interact() emits npc_interacted
4. test_interact_before_init_blocked — uninitialized NPC doesn't emit
5. test_interact_signal_carries_data — verify signal has npc_id and dialogue dict

**Priority Stack:**
6. test_get_current_dialogue_default — no flags set, returns entry with null condition
7. test_get_current_dialogue_with_flag — set flag, verify higher-priority entry

**Condition Evaluation:**
8. test_evaluate_condition_null — null returns true
9. test_evaluate_condition_empty — empty string returns true
10. test_evaluate_condition_flag_set — set flag, returns true
11. test_evaluate_condition_flag_unset — unset flag, returns false
12. test_evaluate_condition_and — compound AND with one part true, one false → false

Use `after_each()` with `EventFlags.clear_all()`.

- [ ] **Step 1:** Write test_npc.gd
- [ ] **Step 2:** Run gdformat + gdlint — must pass
- [ ] **Step 3:** Verify every if-branch in npc.gd has a corresponding test

---

### Task 5: Update gap tracker and commit

- [ ] **Step 1:** Update gap 2.2 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 2:** Check off all "What's Needed" items (note deferred items with strikethrough)
- [ ] **Step 3:** Note: this completes ALL Tier 2. Exploration scene (3.2) is now fully unblocked.
- [ ] **Step 4:** Run lint on ALL new files + verify load_steps
- [ ] **Step 5:** Mirror check: `grep -r` docs for any stale references
- [ ] **Step 6:** Commit and push:
  ```bash
  git add game/scenes/entities/npc.tscn game/scripts/entities/npc.gd game/assets/sprites/npcs/ game/tests/test_npc.gd docs/analysis/game-dev-gaps.md
  git commit -m "feat(engine): add NPC prefab with priority stack dialogue (gap 2.2)"
  ```
- [ ] **Step 7:** Hand off to `/create-pr` → `/godot-review-loop`
