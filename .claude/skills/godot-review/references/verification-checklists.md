# Godot Review Verification Checklists

Reference for all review agents. Check every applicable item.

---

## 1. GDScript Code Quality

### Static Typing
- [ ] All function parameters have type hints
- [ ] All function return types are declared (including `-> void`)
- [ ] All variable declarations use `: Type` or `:= value` inference
- [ ] No bare `var x = value` without type (use `var x: Type = value`)
- [ ] No use of `Variant` where a concrete type is known
- [ ] Scene scripts passed via constructor injection (e.g., `_init(exploration: Node2D)`) should use the concrete type if the script has `class_name`. If the script lacks `class_name`, consider adding one (non-autoload scripts only) so helpers like CutsceneHandler/CleansingSequence get full static type safety instead of `Node2D`.

### Naming Conventions (per GDScript style guide)
- [ ] Functions: snake_case (`func open_chest()`)
- [ ] Variables: snake_case (`var current_hp: int`)
- [ ] Constants: UPPER_SNAKE_CASE (`const MAX_HP: int = 14999`)
- [ ] Classes: PascalCase (`class_name PlayerCharacter`)
- [ ] Signals: snake_case, past tense (`signal chest_opened`)
- [ ] Enums: PascalCase name, UPPER_SNAKE_CASE values (`enum State { IDLE, WALKING }`)
- [ ] File names: snake_case matching class (`player_character.gd`)
- [ ] No abbreviations in public API names

### Script Organization (17-item ordering)
- [ ] `@tool` (if applicable)
- [ ] `class_name`
- [ ] `extends`
- [ ] Doc comment (##)
- [ ] Signals
- [ ] Enums
- [ ] Constants
- [ ] `@export` variables
- [ ] Public variables
- [ ] Private variables (prefixed `_`)
- [ ] `@onready` variables
- [ ] Built-in virtual methods (`_ready`, `_process`, etc.)
- [ ] Public methods
- [ ] Private methods (prefixed `_`)
- [ ] Signal callbacks (prefixed `_on_`)
- [ ] Static methods
- [ ] Inner classes

### Common GDScript Antipatterns
- [ ] No `get_parent()` calls (use signals — "call down, signal up")
- [ ] No `get_node("../../sibling")` path traversal (fragile, breaks on restructure)
- [ ] No uncached `$NodePath` in `_process()` (cache in `@onready`)
- [ ] No `find_child()` in hot paths
- [ ] No `null` where a typed default works (use `""`, `0`, `[]`)
- [ ] No monolithic scripts (>300 lines = consider splitting)
- [ ] No direct singleton state mutation from deep children (signal up instead)

### Defensive Coding (from Copilot gap analysis, PR #105)
- [ ] Dictionary key access guarded before write (`data.get()` or `has()` before `data["key"] = value`)
- [ ] `load()` / `preload()` results checked for null before calling `.instantiate()`
- [ ] `ResourceLoader.exists(path)` checked before `change_scene_to_file(path)` or `load(path)`
- [ ] Public API parameters validated for range (e.g., slot 0-3, not arbitrary int). Verify range matches ALL callers including tests and internal cleanup — not just UI-facing use (PR #119 batch 3: delete_slot restricted to 1-3 but tests needed 0)
- [ ] `assert(false)` NOT used as the sole error handler — asserts are disabled in release builds. Use `push_error()` + `get_tree().quit(1)` for truly fatal errors.
- [ ] Stub/placeholder methods that return empty data (`{}`, `[]`, `0`) don't cause downstream failures (e.g., save_game writing empty dict that fails validation on load)
- [ ] Docstrings match actual return behavior (if func returns error dicts AND empty dicts, document both)
- [ ] Docstrings and specs for stubbed methods describe behavior as "when implemented" or "stubbed" — not as if currently functional
- [ ] `print()` debug statements gated behind `OS.is_debug_build()` or use `print_debug()` — never bare `print()` in autoload methods called frequently
- [ ] Migration/upgrade functions fail explicitly on missing steps rather than silently skipping
- [ ] `save_game()` or similar write methods must use the ACTUAL data being written, not rebuild from scratch (FFR merged data bug)
- [ ] JSON parse result (`json.data`) must be type-checked before typed assignment (`is Dictionary`)
- [ ] Migration/upgrade error paths must NOT set the version to current — return error instead
- [ ] State/signal emission must happen AFTER validation, not before (observers see invalid state)
- [ ] Enum parameters must be validated against the lookup table (OverlayState.NONE has no scene)
- [ ] `load()` result must be type-checked (`is PackedScene`) before calling `.instantiate()`
- [ ] Autoload scripts should NOT use `class_name` — access via autoload name, not class name
- [ ] Nested dictionary access validates each level's type (`data["a"]["b"]` requires `data["a"] is Dictionary` check)
- [ ] Scene transition return values checked (`change_scene_to_file()` returns `Error` — verify `OK` before mutating state)
- [ ] When signal-before-validation is deferred as design choice, verify error/revert paths emit compensating signals
- [ ] All functions returning `Error` or `bool` status must have return values checked — not just scene transitions (DirAccess, FileAccess, write helpers)
- [ ] State set before deferred calls (e.g., `change_scene_to_file`) must be REVERTED on failure, not omitted — new scene `_ready()` reads state immediately
- [ ] GDScript falsy checks (`if data`) fail for empty `[]`/`{}`/`0` — use explicit `!= null` when checking for null returns
- [ ] `dict.get(key, default)` returns `null` (not default) when key EXISTS with null value — use `dict.get(key)` then check `!= null`, or cast explicitly: `int(val) if val != null else 0` (PRs #126, #127: power:null, cooldown:null from JSON)
- [ ] JSON gating fields (e.g., `available_act`, `story_gated`, `restock_event`) must be enforced at the UI/display layer, not just stored in data — grep for every gating field and verify it's checked before showing the item (PR #125: shop showed Act II items in Act I)
- [ ] Grid/list label collection order must match cursor navigation math — if cursor uses `index % cols` for column, labels must be in row-major order (left0, right0, left1, right1...), not column-major (PR #126: spell grid had column-major labels with row-major cursor)
- [ ] After adding/modifying methods on a class, check for unused `@onready` variables and stale dict keys that should be cleaned up (PR #128: unused _title_label, stale formation.reserve)

### Semantic Correctness (from Copilot PR #122 gap analysis)
- [ ] Data field values used in COMPUTATION, not just existence checks — if a field is `restore_percent: 25`, the code must multiply by 0.25, not treat it as a boolean flag
- [ ] Configurable values in data (e.g., revive HP fraction) must flow through to the formula — hardcoded fallbacks (e.g., always `max_hp / 4`) bypass the data
- [ ] For every item/skill effect: trace the data value from JSON -> code -> actual game effect. If the value doesn't change the output, it's a semantic bug
- [ ] Side effects (resource spend, gauge gain, message emission) must happen AFTER target/condition validation, not before. If a function can return false/re-prompt, verify no irreversible side effects occurred before the validation point. (PR #147: _do_magic gained Weave Gauge before validating KO target, enabling gauge farming)
- [ ] Every consumable use function must CONSUME the item from inventory after successful application. Verify: validation -> effect -> consumption -> return true. If the item is never deducted, it is infinite. (PR #147: _do_item applied effects but never called consume_item)

### Callable Initialization (from Copilot PR #147 gap analysis)
- [ ] Every `Callable` variable declaration must be initialized to `Callable()` — uninitialized Callables crash on `.is_valid()` if cleanup/disconnect runs before the callable is ever assigned. (PR #147: _pending_callable and _caden_dialogue_callable crashed on early cleanup)
- [ ] After adding `call_deferred()` that triggers scene transition, verify the guard flag (e.g., `_load_in_progress`) stays true until the deferred call runs — clearing it immediately allows double-fire from rapid input. (PR #147: save_load.gd _load_in_progress cleared before deferred change_core_state)

### Effect Handler Completeness (from Copilot PR #147 gap analysis)
- [ ] Every `effect` value in consumables.json must have a matching handler in BOTH `InventoryHelpers.apply_item_effect()` (field use) and `BattleManager._do_item()` (battle use, if `usable_in_battle: true`). Grep for all unique effect values and verify each has a handler. (PR #147: buff_atk, buff_mag, light_source had no handlers)
- [ ] Every boolean modifier field on a consumable (e.g., `clears_status`, `can_revive`) must be checked in ALL effect branches that the item could use, not just one. (PR #147: clears_status only checked in restore_hp_mp, not restore_hp — starbloom_tea silently skipped status clearing)

### Constraint Propagation (from Copilot PR #122 gap analysis)
- [ ] Every constraint in JSON data (e.g., `requires_save_point`, `usable_in_battle`, `target_type`) must be enforced at ALL layers: backend logic, selection/confirmation UI, and display (greying/hiding)
- [ ] After adding a new data constraint field, grep for every call site that reads the parent entity and verify the constraint is checked
- [ ] Constraints must be tested from the USER perspective (can I select the item? can I confirm it? does it execute?) — not just backend validation

### Cross-Session State Cleanup (from Copilot PR #122 gap analysis)
- [ ] Singleton state (EventFlags, GameManager flags like `is_at_save_point`) must be cleared on NEW GAME start — not just test `before_each()`
- [ ] Singleton state must be RESTORED from save data on LOAD GAME — if EventFlags are saved, they must be loaded back
- [ ] Audit every singleton for session-scoped state: anything set during gameplay that would be wrong if carried into a new/loaded game

### Runtime Instance ID Uniqueness (from Copilot PR #122 gap analysis)
- [ ] Equipment instances, inventory slots, or any runtime-generated IDs must be globally unique (use incrementing counter or UUID, not index-based)
- [ ] Methods that transfer ownership (equip, unequip, trade) must validate the entity OWNS the item before allowing the operation
- [ ] Duplicate ID detection: after any add/create operation, assert the new ID does not already exist in the collection

### Empty Collection Guards (from Copilot PR #122 gap analysis)
- [ ] Any division by collection size (e.g., `party.size()`) must guard against zero — empty party, empty inventory, empty enemy list
- [ ] Array index access must check `size() > 0` before `[0]` or similar — empty arrays cause index-out-of-bounds
- [ ] UI that displays collection items (character select, item list) must handle the empty case with a message or disabled state, not crash

### State Toggle Symmetry (from Copilot PR #122 gap analysis)
- [ ] Every state modification that has an ENABLE path must have a corresponding DISABLE/RESTORE path — if Patience mode slows animations, disabling Patience must restore original speeds
- [ ] Cascading state changes (setting X also changes Y and Z) must cascade in BOTH directions — toggling X off must also undo Y and Z
- [ ] For every accessibility/config toggle, trace: enable -> what changes? disable -> are ALL changes reverted? If not, the toggle is one-way (permanent)

### Numeric Conversion Accuracy (from Copilot PR #122 gap analysis)
- [ ] Bit-depth conversions (e.g., 5-bit 0-31 to float 0.0-1.0) must use correct formula: `value / 31.0` not `value / 32.0` — verify boundary values (0 maps to 0.0, max maps to 1.0)
- [ ] Percentage calculations must produce the correct range — verify at 0%, 50%, 100% boundary inputs
- [ ] Any formula ported from a reference (SNES color format, damage formula) must be verified against known input/output pairs from the source
- [ ] GDScript `/` operator yields float, not int. When integer division is intended in a function returning `-> int`, wrap with `int()` or use explicit `floori()`. (PR #130: `total / members.size()` returned float, caused implicit truncation warning)

### JSON Save Data Type Coercion (from Copilot PR #134 gap analysis)
- [ ] Formation indices from JSON saves are parsed as `float`, not `int`. Any code iterating formation active/reserve arrays must accept both: `if not (idx is int or idx is float): continue` then `int(idx)`. Checking only `is int` silently skips all members after a save/load cycle.
- [ ] Dictionary keys from `ley_crystals`, `event_flags`, or any user-persisted dict have **unstable iteration order**. If UI display order matters, sort the keys before returning (e.g., `result.sort()`).
- [ ] `data.get("key", {})` returns the stored value even if it's the wrong type (e.g., Array instead of Dictionary). Always type-check: `var val: Variant = data.get("key", {}); var d: Dictionary = val as Dictionary if val is Dictionary else {}`.

### Scene File Format (from Copilot PR #134 gap analysis)
- [ ] `ext_resource` ids in .tscn files must be numeric strings ("1", "2", ...) matching the existing pattern. Alphanumeric ids (e.g., "menu_ley_crystal") risk parse failures in some Godot versions. Use the next sequential numeric id.

### GDScript Runtime Safety (from PR #120 manual testing)
- [ ] `get_viewport()` returns null after `change_scene_to_file()` queues current scene for deletion. NEVER call `get_viewport().set_input_as_handled()` after any method that may trigger a scene swap (`change_core_state`, `change_scene_to_file`). Remove or guard with null check.
- [ ] Any code that runs AFTER a scene transition call (`change_core_state`, `pop_overlay`) may execute on a freed/freeing node. Move transition calls to the END of the function, never follow with member access.
- [ ] `get_tree()` can also return null in edge cases during scene teardown. Guard autoload calls (`GameManager.X`, `SaveManager.X`) that use `get_tree()` internally.
- [ ] Test ALL input handlers by pressing every key on every screen in the Godot editor — `_unhandled_input` bugs only surface at runtime, not in static review.
- [ ] After writing any `_unhandled_input` or `_input` handler, trace: "what happens if the action I take here destroys this node?" If the answer is "yes it can", move the destructive call to the last line and put nothing after it.

### Documentation Accuracy
- [ ] CLI commands in AGENTS.md/CLAUDE.md actually work in the current project state
- [ ] If `run/main_scene` is empty, don't claim the game can be "run" — say "open in editor"
- [ ] Spec status fields updated when spec is implemented (e.g., "pending" -> "Implemented (PR #N)")
- [ ] Spec setting descriptions match actual project.godot values and format
- [ ] Review reference doc headings/counts match actual content (e.g., "10 categories" vs actual 12)
- [ ] Code comments in migration/versioning logic match actual constants and scheme
- [ ] Gap tracker "Notes" section claims only match actual implementation (no claiming gold border if using modulate, no claiming copy-from if no UI path)

### Scene Rendering (from Copilot PR #119 gap analysis)
- [ ] NinePatchRect nodes MUST have a texture assigned — otherwise invisible. Prefer PanelContainer + StyleBoxFlat for UI windows without art assets.
- [ ] Sprite2D nodes MUST have a texture assigned — otherwise invisible even when set to visible. Assign a placeholder if no art exists.
- [ ] UI panel colors (bg_color, border_color) must match ui-design.md Section 1.4 palette hex values
- [ ] Full-viewport Control nodes (ColorRect, Label) that are hidden via `modulate.a = 0` MUST set `mouse_filter = IGNORE` (2) — otherwise they consume mouse/touch events while invisible, blocking input to nodes beneath. (PR #142: TitleLabel blocked clicks to embedded DialogueBox)
- [ ] Controls as direct children of CanvasLayer must use anchors + explicit offsets (or explicit `size`) for layout. `custom_minimum_size` alone does NOT set the actual rendered size for free-standing Controls. (PR #142: letterbox/fade/title Controls had zero size under CanvasLayer)
- [ ] For Control sizing animation outside a Container, tween `size:y` or offset properties — NOT `custom_minimum_size:y`, which only sets minimum without propagating to actual size on non-Container children. (PR #142: letterbox bars invisible because `custom_minimum_size:y` tween didn't affect rendered size)
- [ ] Instanced sub-scenes that should start hidden (e.g., DialogueBox in cutscene.tscn) must set `visible = false` in the parent scene override — relying on the script to hide later can show a flash of the default-visible panel on first frames. (PR #142: dialogue panel visible during command-only cutscenes)

### Test Hygiene (from Copilot PR #119 gap analysis)
- [ ] Tests that create persistent state (save files, config files) must have `after_each()` cleanup
- [ ] Tests that inject fake data must not call methods that overwrite it (e.g., `_refresh` calling `SaveManager.get_slot_previews()`)
- [ ] Tests that depend on state absence (no saves) must ensure cleanup runs even across test files
- [ ] Destructive test operations (delete) must assert preconditions (file exists) before testing deletion
- [ ] Tests must use BOTH `before_each()` AND `after_each()` cleanup — after_each alone doesn't protect against pre-existing state from previous test runs
- [ ] After gdformat runs, re-read the output for `(obj\n. method(...))` line continuations — extract inline data into helpers to keep calls on one line
- [ ] Every helper function in a test file must be called by at least one test — unused helpers are dead code. Run `grep -n "func _" <file>` then verify each is referenced.
- [ ] Every local variable declared in a test must be used — `var x = ...` with no subsequent reference is dead code.
- [ ] Tests that call `call_deferred()` indirectly (via `load_map` which schedules deferred calls) must flush the deferred queue with `await get_tree().process_frame` before test ends, or the deferred call leaks into cleanup/next test.
- [ ] RefCounted helper fields stored on the owning class should use the concrete type (e.g., `var _handler: MyHandler`), not `RefCounted`, to preserve static type safety.
- [ ] Test before_each/after_each must use lifecycle methods (e.g., `GameManager.pop_overlay()`) instead of directly assigning singleton fields (e.g., `current_overlay = NONE`) — direct assignment skips cleanup logic (freeing overlay_node, unpausing tree).
- [ ] `FileAccess` handles opened in test helpers must be closed before return (`file.close()`). GDScript does not auto-close on scope exit — unclosed handles leak file descriptors across the test suite. (PR #146: 3 `_read_file` helpers leaked)
- [ ] NPC dialogue `condition` strings must use syntax supported by `npc.gd:_evaluate_condition`: bare flag names, `flag == 0` comparisons, `AND` conjunctions, `party_has(id)`. The `!` negation prefix is NOT supported — use `flag == 0` instead. (PR #146: `!scene_7c_cordwyn` silently failed)
- [ ] Test assertions must use the method that matches test intent — `has_flag()` to prove a flag was never stored, `get_flag()` to check value. Using the wrong method can produce false passes (e.g., `get_flag("")` returns `false` default even when the key exists with a falsey value).
- [ ] Test BODY setup that needs overlay state (e.g., simulating CUTSCENE) should use `GameManager.push_overlay()` / `pop_overlay()` rather than directly assigning `GameManager.current_overlay`. Direct assignment bypasses overlay lifecycle (pause state, overlay_node creation/free, overlay_state_changed signal), making tests diverge from production behavior. If push_overlay has unwanted side effects for a unit test, create a test helper that wraps the setup/teardown pattern.
- [ ] Tests that re-implement internal logic (e.g., comma-splitting flag strings, damage formulas) instead of calling the actual handler code paths can pass even when the real handlers regress. Prefer exercising the real code path (e.g., creating an Area2D with metadata and calling the handler) over duplicating the logic inline. (PR #147: required_flags tests duplicated split logic instead of calling _on_dialogue_trigger_entered)
- [ ] `DirAccess.list_dir_begin()` yields "." and ".." entries. Any recursive directory scan MUST filter these out before recursing, or the function will stack overflow by recursing into the same directory infinitely. Use `if file_name == "." or file_name == "..": continue`. (PR #147: _scan_for_bare_viewport_calls lacked this filter)
- [ ] Doc comments (`##`) must be placed directly above the function they describe. When inserting new functions above existing documented functions, verify the doc comment still precedes the correct function. (PR #147: _consume_input inserted above _close, stealing its doc comment)

### Behavioral State Trace (from Copilot PRs #119-#120 — the #1 gap category)

**HOW TO USE:** For each item, write the file:line and your answer. Do NOT
skip items. Do NOT write "PASS" without a specific code reference. If you
cannot point to the exact line that handles the case, it's a bug.

- [ ] **Repeatability:** For every entity used in maps — can it happen twice? Doors/transitions MUST be repeatable (use Area2D, NOT one-shot TriggerZone). Story triggers are one-shot.
- [ ] **Input ownership:** Grep for each input action (ui_accept, ui_cancel, etc.) across ALL .gd files. Exactly ONE handler per action per active scene. Two handlers = double-fire bug.
- [ ] **Initialization chain:** For every entity in a .tscn map — trace: metadata set -> exploration reads metadata -> calls initialize(). If any link is missing, entity silently does nothing.
- [ ] **Viewport dimensions:** Every ColorRect, background, panel size must match the effective game world (320x180 at 4x camera zoom within 1280x720 viewport). Every tile position must align to 16x16 grid. Every sprite must match spec sizes.
- [ ] **Global state cleanup:** Every test file must clear ALL singletons in before_each: GameManager.transition_data, EventFlags.clear_all(), SaveManager.delete_slot(0-3).
- [ ] **Spec-implementation sync:** After implementation, grep spec for EVERY changed concept name. Update ALL occurrences, not just the first one you find.
- [ ] **Return path completeness:** After every overlay push or sub-state change, trace the cancel/return path. Are panels shown/hidden correctly? Is cursor visible/hidden correctly?
- [ ] **Actor filtering:** For every Area2D signal (body_entered, area_entered) — WHO can trigger it? Filter to the intended actor (e.g., `if body != _player: return`). Without this, any physics body triggers the action.
- [ ] **Failure chain:** For every operation that can fail (load_map, push_overlay, ResourceLoader) — trace what happens to ALL in-flight state: tweens, flags, visibility, freed nodes. Kill tweens, reset flags, restore visibility. One failure check is not enough — trace the FULL chain.
- [ ] **Ordering:** For every function that destroys-then-creates — validate the NEW thing BEFORE destroying the OLD thing. If validation fails, the old state must survive intact.
- [ ] **State persistence after save/load:** For every entity whose visibility or state is set during gameplay (e.g., NPC shown after quest), verify the state is restored on map load. Use `visible_when_flag` metadata or explicit EventFlags checks in `_initialize_entities`. (PR #135: CadenPostEvent hidden after save/load)
- [ ] **In-flight tween cleanup:** For every tween created during gameplay (auto-walk, animations), verify it is stored and killed when a transition or state change occurs. Orphaned tweens continue running during map swaps and can move freed nodes. (PR #135: auto-walk tween continued during fade)
- [ ] **Input gating during cinematics:** For every `_unhandled_input` handler, verify that input actions are gated when the player is in a cinematic/auto-walk state. `_input_enabled = false` on the player does not automatically block exploration-level input handlers. (PR #135: ui_accept fired during auto-walk)
- [ ] **Encapsulation:** Never access underscore-prefixed private fields from outside the owning class. Use or add a public getter (e.g., `is_input_enabled()` instead of `_input_enabled`). (PR #135: exploration.gd accessed _player._input_enabled directly)
- [ ] **Ritual/sequence state persistence:** For any multi-battle sequence with persistent UI state (ritual meter, combo counter), verify the state value is stored in transition_data before battle and restored after. Scene recreation destroys all local state. (PR #135: ritual meter lost across cleansing waves)
- [ ] **Interaction resolution for composite entities:** When an entity uses a child Area2D for interaction detection (e.g., StaticBody2D with child InteractionArea), verify that the interaction system resolves to the parent entity that has `interact()`. The player stores the overlapping Area2D, not the parent. (PR #135: SpiritPlant InteractionArea had no interact())
- [ ] **Zone behavior semantics:** For every zone type (block/reveal), verify the visibility+collision combination makes physical sense. Block zones: visible+blocking when active, invisible+passable when inactive. Reveal zones: visible+passable when active, invisible+passable when inactive. Never invisible+blocking (invisible wall). (PR #135: WaterZone reveal type had invisible walls)

### Tween Pause Mode (from Copilot PR #142 gap analysis)
- [ ] **Tween pause behavior during overlays:** For every tween created on a PAUSABLE node (exploration entities, player, NPCs) that runs during an overlay (CUTSCENE, DIALOGUE), verify `set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)` is called. GameManager.push_overlay sets `get_tree().paused = true`, which freezes all PAUSABLE tweens. Cutscene choreography tweens (camera, shake, walk_to) must use TWEEN_PAUSE_PROCESS to animate while paused. (PR #142: camera/shake/walk_to tweens were frozen during cutscenes)
- [ ] **Signal connect-before-start ordering:** For every test helper that starts an async operation and awaits a completion signal, connect the signal BEFORE starting the operation. Synchronous signal emissions (e.g., skip-flag early exit) fire before the await point, causing the signal to be missed and the test to timeout. (PR #142: _start_and_await connected after start_cutscene, missed synchronous cutscene_finished)

### Cutscene Choreography Safety (from Copilot PR #142 batch 3 gap analysis)
- [ ] **Physics trigger gating during cutscenes:** For every `body_entered` / `area_entered` signal handler in exploration.gd (boss triggers, map transitions, pitfalls, dialogue triggers), verify the handler checks `_in_cutscene` before processing. Cutscene `move` commands walk the player's CharacterBody2D, which triggers Area2D overlaps. `_unhandled_input` gating is NOT sufficient — physics signals bypass input handlers. (PR #142: boss/transition/pitfall handlers lacked _in_cutscene guard)
- [ ] **Tween duration budget accuracy:** For every tween that builds a sequence of steps (shake, typewriter, multi-phase animation), verify the total tween duration equals the requested duration. Extra reset/cleanup steps at the end can overshoot. Budget the reset within the requested duration by reducing steps or computing remaining time. (PR #142: shake reset step added +50ms beyond requested duration)

### Transition Exit Gating (from Copilot PR #141 gap analysis)
- [ ] **Exit transition gating:** For every map with a scripted sequence (boss fight, story event), verify the exit transition has `required_flag` gating. Without it, the player can walk out before completing the sequence. Check BOTH map exits AND teleport/warp transitions. (PR #141: Ironmouth ExitToOverworld had no required_flag)
- [ ] **Dead flag detection:** For every `metadata/flag` on transitions, verify the transition handler actually reads and sets that flag. `exploration.gd:_on_transition_body_entered` only checks `required_flag`, NOT `flag`. If a transition has `metadata/flag` set, it is dead metadata — either add flag handling to the transition handler or remove it. (PR #141: ironmouth_entered flag on overworld transition was never set)
- [ ] **Repeated side-effect guard:** For every callback that fires on a recurring event (dialogue closed, overlay popped), verify that one-shot side effects (break equipment, add party member, set permanent state) have a flag guard preventing re-execution. `CONNECT_ONE_SHOT` only prevents one re-fire — the callback is re-connected on the next dialogue. (PR #141: break_arcanite_gear fired every dialogue close)
- [ ] **Test transition_data accuracy:** For every test that sets `GameManager.transition_data`, verify the keys match what exploration.gd's init branches actually read. Dead keys in test data mask integration bugs. (PR #141: test_room tests used map_id key that exploration ignores)
- [ ] **Equipment removal completeness:** For every method that removes equipped items (break, destroy, consume), verify it ALSO removes matching items from `owned_equipment`. If player unequips before the removal event, items migrate to owned_equipment and bypass the equipped-slot check. (PR #141: break_arcanite_gear didn't purge owned_equipment)

### State Transition Visibility (from Copilot PR #119 batch 4)
- [ ] When switching sub-states (e.g., save_point_menu -> rest_menu), hide the previous panel AND show the next one. Verify BOTH directions (entering AND returning).
- [ ] When refresh/update methods rewrite display text, preserve prefixes or labels that distinguish node types (e.g., "AUTO" prefix on auto-save slot)
- [ ] `has_X()` / `is_X_available()` checks must validate the same criteria as the corresponding `load_X()` / `get_X()` — file existence alone is not validity (corrupted files)

---

## 2. Scene Architecture

### Scene Composition
- [ ] Each scene has one clear responsibility
- [ ] Reusable behaviors are separate scenes instanced as children
- [ ] No scene depends on its parent's structure (portable)
- [ ] Scene tree reflects logical relationship, not spatial layout

### Signal Architecture
- [ ] "Call down, signal up" — parents call children, children emit signals
- [ ] No child directly references parent (`get_parent()`)
- [ ] Signal connections documented (either in `_ready()` or editor)
- [ ] Custom signals have typed parameters where possible

### Node Usage
- [ ] Correct node type for purpose (CharacterBody2D for movement, Area2D for triggers, etc.)
- [ ] Unused nodes removed (no leftover test nodes)
- [ ] `process_mode` set correctly (PROCESS_MODE_ALWAYS for overlay scenes)
- [ ] Visibility and collision layers used correctly

---

## 3. Pixel Art Specific (1280x720 Viewport, 4x Camera Zoom)

### Viewport Configuration
- [ ] Viewport size is 1280x720
- [ ] Stretch mode is "viewport"
- [ ] Stretch aspect is "keep"
- [ ] Scale mode is `"integer"` (Godot 4.x string format in project.godot)
- [ ] Default texture filter is Nearest (0)

### Snap to Pixel
- [ ] `2d/snap/snap_2d_transforms_to_pixel` is true
- [ ] `2d/snap/snap_2d_vertices_to_pixel` is true
- [ ] Camera2D has smoothing disabled or uses pixel-snapped smoothing
- [ ] Camera zoom is whole numbers only (1x, 2x, 3x — no 1.5x)
- [ ] No sprite positions with decimal values in scene files
- [ ] No tween/animation targets with sub-pixel positions

### Import Settings
- [ ] All sprite/tileset imports use Filter = Nearest
- [ ] No mipmaps enabled on pixel art
- [ ] No compression that could blur pixels
- [ ] Texture atlas packing preserves pixel boundaries

### Sprite Sizes
- [ ] Character sprites: 16x24 (per technical-architecture.md)
- [ ] Battle sprites: 32x32 to 64x64
- [ ] Tiles: 16x16
- [ ] Status icons: 8x8
- [ ] UI elements match ui-design.md specifications

---

## 4. Data & Persistence

### JSON Data Files
- [ ] All keys use snake_case (not camelCase)
- [ ] File in correct `data/` subdirectory per technical-architecture.md
- [ ] Values match canonical source docs (bestiary, items.md, equipment.md, etc.)
- [ ] No trailing commas (invalid JSON)
- [ ] Proper array/object nesting

### JSON Data Gap Work (from Copilot gap analysis, PRs #108 + #109)
- [ ] **HARD GATE: After ANY data count change, run programmatic scan of ALL spec/plan/gap/PR docs for stale counts BEFORE committing.** No commit until scan returns zero stale references. Check: scope totals, file structure tables, section totals, subcategory breakdowns, plan task instructions, plan validation steps, PR description.
- [ ] **Cross-file ID uniqueness:** Run programmatic sweep across ALL item + equipment + enemy data files. IDs must be globally unique (single shared `item_id` namespace). Within-file checks are insufficient.
- [ ] **source_category verification:** Every material's `source_category` must match the items.md section header AND the source type annotation (e.g., "Beast (rare)" means `beast`, not `humanoid`, even if listed in the Humanoid/Flavor section).
- [ ] **Non-standard schema field documentation:** Every field in JSON data that isn't in the base schema (e.g., `auto_sell`, `ac_restorable`, `battle_usable`, `gold_value_by_act`, `boss_group`, `phase_hp_thresholds`) must be documented in the spec's Special Cases section before commit.
- [ ] **Full-doc re-read after fixing drift:** After fixing one instance of documentation drift (stale count, wrong category, etc.), re-read the ENTIRE spec and plan for any other instance of the same error type. Don't just fix the specific line — Copilot will find the others you missed.

### Save System
- [ ] Save files write to `user://saves/` (not `res://`)
- [ ] Global config separate from save slots (`user://config.json`)
- [ ] Save data includes `meta.version` for migration
- [ ] `_validate()` checks all 9 required top-level keys
- [ ] Auto-save triggers match save-system.md Section 6

### Event Flags
- [ ] Flag names match events.md (58 numbered + boss_cutscene_seen_*)
- [ ] Flag types correct (bool for most, int for council_result, string for reunion_order)
- [ ] Boss cutscene flags use parameterized pattern: `boss_cutscene_seen_{boss_id}`

---

## 5. Audio Integration

### Channel Budget
- [ ] Total channels <= 24 (8 music + 12 SFX + 4 ambient)
- [ ] Music never drops below 4 channels under pressure

### Priority Stack
- [ ] Cutscene SFX > Battle jingles > Boss onset > Battle SFX > UI SFX > Exploration SFX > Music > Ambient
- [ ] Same SFX ID limited to 2 simultaneous instances

### Mixing Model
- [ ] Overworld: music 100%, ambient 30-40%
- [ ] Dungeons: music 50-60%, ambient 80-100%
- [ ] Narrative dungeons (Siege, Convergence, Axis Tower): music 100%, ambient 30-40%
- [ ] Pallor Wastes: music 0% (drone on ambient channels), ambient 40%
- [ ] Battle: music 100%, ambient 0%

### Asset Format
- [ ] OGG Vorbis format
- [ ] 44.1 kHz sample rate
- [ ] 16-bit depth
- [ ] Naming: `{category}/{name}.ogg` (e.g., `sfx/hit_physical.ogg`)

---

## 6. Performance

### Budgets
- [ ] Frame rate: 60 fps target
- [ ] Max entities per exploration scene: 64
- [ ] Max enemies per battle: 6
- [ ] Max simultaneous particle emitters: 16
- [ ] Max tilemap layers: 4
- [ ] Scene load time: <1 second
- [ ] Save file size: <256 KB

### Common Performance Issues
- [ ] No `_process()` on nodes that don't need per-frame updates (use `_physics_process()` or timers)
- [ ] No `load()` calls in `_process()` (preload or cache)
- [ ] No `String` concatenation in hot loops (use `StringName`)
- [ ] Particle emitters disabled when off-screen
- [ ] TileMap layers minimized (only what's needed)

---

## 7. Project-Specific (Pendulum of Despair)

### State Machine (GameManager)
- [ ] Core state transitions use `change_core_state()` (not direct `change_scene_to_file()`)
- [ ] Overlay pushes use `push_overlay()` and check return value
- [ ] Only one overlay active at a time
- [ ] Cutscene can override dialogue (the one exception)
- [ ] Transition data passed via `GameManager.transition_data`

### Autoload Usage
- [ ] Game state accessed via `GameManager`, not direct scene tree traversal
- [ ] Data loaded via `DataManager`, not direct `FileAccess` in entity scripts
- [ ] Audio played via `AudioManager`, not direct `AudioStreamPlayer` creation
- [ ] Flags accessed via `EventFlags`, not custom dictionaries
- [ ] Save/load via `SaveManager`, not direct file operations

### Design Doc Compliance
- [ ] Numeric values match canonical docs (bestiary, items.md, equipment.md, etc.)
- [ ] Game mechanics match combat-formulas.md
- [ ] UI layout matches ui-design.md
- [ ] Audio behavior matches audio.md
- [ ] Save behavior matches save-system.md

---

## 8. Defensive Coding (from Copilot gap analyses PRs #105-116)

### Input Validation
- [ ] Damage/heal methods clamp `amount` to >= 0 (prevent negative inputs reversing behavior)
- [ ] Methods that accept indices validate bounds before access
- [ ] Enum parameters validated against known values (not just any string)
- [ ] Resource paths validated with `ResourceLoader.exists()` before `load()`
- [ ] **Every public method guards against uninitialized state** (check if initialize() was called — ID fields empty, data dicts empty)
- [ ] **Every initialize() validates its inputs** (empty strings, null values) with push_error + return
- [ ] **Every interact/action method returns early if entity not ready** (not just checking "is_opened" but also "was I configured?")

### Test Branch Coverage
- [ ] **Every `if` branch in the code has a corresponding test** (not just happy path)
- [ ] **Every signal emission path has a signal-watching test**
- [ ] **Every early-return guard has a test proving it blocks** (uninitialized, already-fired, immune)
- [ ] Tests use constructed data to exercise specific branches (not relying on JSON that may lack the needed values)

### Mirror Staleness Prevention (MANDATORY after every code change)
- [ ] After changing ANY value: `grep -r "old_value" docs/` and fix every hit
- [ ] After adding/removing tests: remove hardcoded test counts from docs (use descriptive text)
- [ ] After changing method behavior: update spec's method description
- [ ] After changing scene config: update spec's collision/config tables
- [ ] After renaming or removing a function/variable/file: `grep -r "old_name"` across ALL files including specs, plans, tests, and comments. Dead @onready vars and stale doc references are the #1 Copilot finding on PR #131 (7% catch rate).
- [ ] After removing UI elements (sprites, labels): verify no @onready references remain and no .visible toggles reference the removed node
- [ ] Verify filenames in spec/plan file maps match actual filenames in the repo (PR #131: menu_equipment.gd vs menu_equip.gd caused 5 Copilot comments)
- [ ] Test assertions must be specific enough to not false-positive on unrelated content (PR #131: 'text = "Config"' matched CommandPanel label too)
- [ ] After changing item/consumable effects, descriptions, or cure lists: grep ALL city docs (`docs/story/city-*.md`) for shop tables that list item effects. City shop tables duplicate items.md data and become stale when the canonical source changes. (PR #147: Smelling Salts cure list in city-valdris.md diverged from consumables.json)
- [ ] After changing item availability (shop inventory, available_act, restock_event): grep ALL city docs AND items.md availability columns for stale references. (PR #147: Waystone availability text in items.md didn't match actual shop data)
- [ ] After adding/removing tests during review rounds: update the PR description test count AND gap tracker count. Both surfaces can go stale independently. (PR #148: PR body said 17 tests, actual count was 28 after review iterations)

### Overlay Push Failure Recovery (from Copilot PR #147 gap analysis)
- [ ] Every `push_overlay()` call that is preceded by a silent `pop_overlay(true)` must handle the case where `push_overlay` returns `false`. A failed push after silent pop leaves the tree paused with `current_overlay = NONE` and no signal, soft-locking input. Restore a usable state: unpause, re-push the prior overlay, or avoid the silent pop pattern. (PR #147: menu_overlay._open_save() used silent pop + push without failure handling)

### Default State Safety
- [ ] Boolean state vars (`is_alive`, `is_ready`, etc.) default to the SAFE state (false/inactive), not the active state
- [ ] Uninitialized entities return empty/safe values from getters (not defaults that look valid)
- [ ] `initialize()` methods reset ALL mutable state before loading (safe for re-init)
- [ ] `@onready` vars guarded with null checks when accessed from methods that may run before `_ready()`
- [ ] String vars used as enum-like selectors (context names, mode strings) must default to a VALID value from their lookup table, not empty string. Empty string causes lookup misses and silent fallback behavior. (PR #148: _current_mix_context defaulted to "" causing bus volumes to use fallback instead of intended overworld context)
- [ ] Collection counting loops must check the CURRENT state of each element (e.g., `player.playing`), not just stored metadata. Metadata persists after the condition it describes has ended. (PR #148: SFX same-ID count included stopped players because meta wasn't cleared on stop)
- [ ] Generator/tool scripts that write files should guard against overwriting non-placeholder content. Use `--force` flag or check file size/content before overwriting. (PR #148: placeholder generator overwrote all files unconditionally)
- [ ] Pre-transition snapshot fields (e.g., `_pre_battle_mix_context`) must guard against double-entry: only store the snapshot when NOT already in the target state. Second entry without exit permanently loses the original state. (PR #148: double enter_battle overwrote pre-battle snapshot)
- [ ] Failure paths in state transitions must leave ALL channels in the target state, not just some. If battle music file is missing, both music AND ambient must be silenced — not just ambient. (PR #148: enter_battle failure path silenced ambient but left exploration music playing)
- [ ] `stop_music()`/`stop_ambient()` default fade duration should match spec (typically 1.0s), not biome crossfade (3.0s). Using biome crossfade as default makes all non-parameterized stops 3x slower than intended. (PR #148: stop_music defaulted to CROSSFADE_BIOME=3.0 instead of 1.0)
- [ ] Tool/generator scripts that produce media files must use the codec/format specified in the design docs. Verify ffmpeg/sox flags match audio.md Section 3.6 (OGG Vorbis, 44.1kHz, 16-bit). Docstrings must match actual flags (mono vs stereo, codec name). (PR #148: generator used libopus instead of vorbis, docstring said mono but flags said stereo)

### Signal Safety
- [ ] State-transition signals emit only ONCE per transition (guard against double-fire)
- [ ] Signals not emitted on uninitialized or dead entities
- [ ] Signal emission happens AFTER state mutation (not before)

### Node Reference Safety
- [ ] Use `get_node_or_null()` instead of `get_node()` for fallback paths
- [ ] `@onready` fallbacks use `get_node_or_null()` not `get_node()` (prevents crash if node missing)

---

## 9. JSON Data Gap Work (from PRs #108-113)

### HARD GATES (mandatory before every data commit)
- [ ] Programmatic stale-count scan: all count claims in spec/plan/gap docs match actual file/entry counts
- [ ] Cross-file ID uniqueness: no duplicate IDs within namespace (items, enemies, equipment, dialogue)
- [ ] All enemy_ids in encounter files exist in gap 1.2 enemy data
- [ ] All material/equipment IDs in crafting files exist in gap 1.3 data
- [ ] All JSON files use 2-space indent per .editorconfig (no tabs)

### Mirror Staleness Prevention
- [ ] After changing ANY value in data files, grep ALL spec/plan/gap docs for the old value
- [ ] After changing act values, propagate to spec file structure tables AND plan dungeon lists
- [ ] After changing entry counts (adding/removing entries), update ALL docs that reference the count
- [ ] After removing an item/entry during review: `grep -r "removed_item_id" docs/` to find ALL spec/plan/gap references to the removed item and update them (PR #130: despair_ward removed from herbalist but 5 doc references remained)
- [ ] When fixing a pattern-based issue, grep ALL files for the same pattern (not just flagged instances)

### Scene Naming Consistency
- [ ] metadata/map_id must match the scene's relative path under scenes/maps/ (e.g., "towns/roothollow" not "roothollow"). Check all new .tscn files against existing naming pattern. (PR #130: bare map_ids caused Copilot comments)
- [ ] Test function names must match what they actually assert (e.g., "test_excludes_X" not "test_no_equipment" if only checking one item)

### Source Doc Verification
- [ ] Every value traces to a canonical doc in docs/story/
- [ ] Bonus_effect text matches equipment.md/crafting.md VERBATIM (no paraphrasing)
- [ ] Speaker IDs match characters.md or npcs.md
- [ ] Flag names match events.md
- [ ] Animation IDs match dialogue-system.md catalog (14 animations + clear)
- [ ] Accessibility features match accessibility.md
