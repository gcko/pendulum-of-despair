# Gap 3.7: Cutscene Overlay (T1 Full Cutscene + T4 Micro-Cutscene)

**Date:** 2026-04-13
**Gap:** 3.7
**Status:** Design approved, ready for implementation
**Depends On:** Gap 3.5 (Dialogue Overlay), Gap 1.8 (Dialogue Data)

## Scope

A cutscene overlay system that handles both full cinematic sequences
(T1) with letterbox bars and choreography, and brief micro-cutscenes
(T4) for short scripted moments. Both tiers share a single overlay
scene and sequencer; the `tier` parameter controls whether letterbox
bars animate.

### Files to Create

| File | Purpose |
|------|---------|
| `game/scenes/overlay/cutscene.tscn` | CanvasLayer with letterbox bars, embedded dialogue box, fade rect, title label |
| `game/scripts/core/cutscene_player.gd` | Sequencer: processes cutscene entries in order, emits choreography signals |
| `game/scripts/ui/cutscene_letterbox.gd` | Letterbox bar animation (slide in/out) |
| `game/tests/test_cutscene_player.gd` | Unit tests (~31 tests) |
| `game/tests/test_cutscene_integration.gd` | Integration tests (~17 tests) |
| `game/tests/test_cutscene_letterbox.gd` | Letterbox unit tests (~5 tests) |
| `game/tests/test_dialogue_box_embedded.gd` | Dialogue box embedded mode tests (~4 tests) |

### Files Modified

| File | Change |
|------|--------|
| `game/scripts/core/exploration.gd` | Add signal handlers for cutscene choreography; add `_entities: Dictionary` mapping character_id to Node (populated during map load in `_initialize_entities()`) |
| `game/scripts/entities/player_character.gd` | Add `walk_to()` method |
| `game/scripts/entities/npc.gd` | Add `walk_to()` and `play_animation()` methods |
| `game/scripts/ui/dialogue_box.gd` | Add `embedded_mode: bool` property. When true, `dialogue_finished` does NOT call `GameManager.pop_overlay()` — the cutscene player manages overlay lifecycle instead. |

### Not Modified

- **GameManager** -- `OverlayState.CUTSCENE` already exists in the enum;
  `push_overlay()`/`pop_overlay()` already handles it
- **DataManager** -- existing `load_json()` methods work for cutscene JSON

---

## Scene Tree (cutscene.tscn)

```
Cutscene (CanvasLayer, layer 10, PROCESS_MODE_ALWAYS, script: cutscene_player.gd)
+-- LetterboxTop (ColorRect, black, anchored top, height 0 initially)
+-- LetterboxBottom (ColorRect, black, anchored bottom, height 0 initially)
+-- DialogueBox (embedded instance of dialogue_box scene/script, embedded_mode = true)
+-- FadeRect (ColorRect, full-screen 1280x720, black, modulate.a = 0, mouse_filter IGNORE)
+-- TitleLabel (Label, centered, white text, hidden by default)
```

- **cutscene_player.gd is the root script** on the Cutscene CanvasLayer
  node. This means `GameManager.overlay_node` IS the cutscene_player,
  so exploration.gd can connect signals directly on `overlay_node`
  without traversing children.
- CanvasLayer layer 10 renders above all game content.
- LetterboxTop/Bottom sit behind DialogueBox but above the game world.
- FadeRect covers the full viewport for fade/flash effects.
- TitleLabel is used for title cards (e.g., "Dawn March").
- DialogueBox is the existing dialogue_box scene embedded with
  `embedded_mode = true` -- this suppresses `pop_overlay()` on
  `dialogue_finished` so the cutscene player controls overlay lifecycle.
  Not a separate overlay push.

---

## Cutscene Data Format

Each cutscene is an array of entries loaded via DataManager. Entries
extend the existing 7-field dialogue format with an optional `commands`
array:

```json
{
  "id": "scene_7_throne_01",
  "speaker": "Edren",
  "lines": ["The throne room stretches before us..."],
  "animations": [{"who": "edren", "anim": "nod", "when": "after_line_0"}],
  "sfx": [{"line": 0, "id": "door_heavy"}],
  "flag_set": "",
  "commands": [
    {"type": "fade", "direction": "in", "duration": 0.5, "when": "before"},
    {"type": "move", "who": "edren", "to": [160, 90], "speed": 60, "when": "before"},
    {"type": "camera", "target": [160, 90], "duration": 1.0, "when": "before"},
    {"type": "wait", "duration": 0.5, "when": "after"},
    {"type": "shake", "intensity": 2, "duration": 0.3, "when": "after"}
  ]
}
```

Command-only entries (no dialogue) use `"speaker": ""` and
`"lines": []`.

### `when` Field

- `"before"` -- runs before dialogue text is shown
- `"after"` -- runs after the player advances past this entry

Commands with the same `when` value run in parallel (signals emitted
sequentially but without awaiting), except `wait` which always blocks
(inserts a timer delay).

### Command Types

| Type | Fields | Description |
|------|--------|-------------|
| `fade` | `direction` ("in"/"out"), `duration` (float), `color` (optional, default "black") | Tweens FadeRect alpha. "out" = screen goes dark, "in" = screen becomes visible |
| `move` | `who` (character_id), `to` ([x, y]), `speed` (px/sec) | Emits `cutscene_move_requested` signal |
| `camera` | `target` ([x, y]), `duration` (float) | Emits `cutscene_camera_requested` signal |
| `wait` | `duration` (float) | Pauses sequencer for N seconds |
| `shake` | `intensity` (int, pixels), `duration` (float) | Emits `cutscene_shake_requested`. Respects Reduce Motion config (skips if enabled). |
| `flash` | `color` ("white"/"red"), `duration` (float) | Brief FadeRect flash. Respects Flash Intensity config. |
| `title` | `text` (string), `duration` (float), `fade_in` (float), `fade_out` (float) | Shows TitleLabel with fade timing |
| `music` | `track_id` (string), `action` ("play"/"stop"/"crossfade") | Emits `cutscene_music_requested` signal (AudioManager integration future) |
| `hide_dialogue` | (none) | Hides embedded DialogueBox |
| `show_dialogue` | (none) | Shows embedded DialogueBox |

---

## cutscene_player.gd

No `class_name` -- attached directly to the root CanvasLayer node of
cutscene.tscn. This means `GameManager.overlay_node` references the
cutscene_player script instance, so all signals are accessible directly.

### Signals

```gdscript
signal cutscene_move_requested(who: String, target: Vector2, speed: float)
signal cutscene_anim_requested(who: String, anim: String)
signal cutscene_camera_requested(target: Vector2, duration: float)
signal cutscene_shake_requested(intensity: int, duration: float)
signal cutscene_music_requested(track_id: String, action: String)
signal cutscene_finished
signal flag_set_requested(flag_name: String, value: Variant)
signal sfx_requested(sfx_id: String)
```

### Public API

```gdscript
func start_cutscene(cutscene_id: String, entries: Array, tier: int = 1) -> void
func skip_cutscene() -> void  # Debug/accessibility: jump to end, set all flags
```

### Internal State

```gdscript
var _cutscene_id: String = ""
var _entries: Array = []
var _current_index: int = 0
var _tier: int = 1
var _is_playing: bool = false
var _letterbox: CutsceneLetterbox
var _dialogue_box: Node
var _fade_rect: ColorRect
var _title_label: Label
```

### Sequencer Flow

```
start_cutscene(id, entries, tier):
  1. Build skip flag: "cutscene_seen_{id}"
     If EventFlags.get_flag(skip_flag) is truthy:
       emit cutscene_finished, call GameManager.pop_overlay(), return

  2. If tier == 1: animate letterbox bars in (await completion)

  3. For each entry in entries:
     a. Collect commands where when == "before", execute them
        (parallel except wait)
     b. Process entry animations where when starts with "before_line"
        (emit cutscene_anim_requested)
     c. If entry has lines:
        - Pass single entry to embedded dialogue_box.show_dialogue([entry])
        - Await dialogue_box.dialogue_finished (in embedded_mode,
          dialogue_box does NOT call pop_overlay -- just emits the signal)
        - During dialogue: dialogue_box emits animation_requested /
          sfx_requested per its existing logic. cutscene_player forwards
          these by connecting dialogue_box.animation_requested to
          cutscene_anim_requested and dialogue_box.sfx_requested to
          sfx_requested (connected once in _ready).
     d. Process entry animations where when starts with "after_line"
        (emit cutscene_anim_requested)
     e. Collect commands where when == "after", execute them
     f. If entry has flag_set (non-empty):
        emit flag_set_requested(flag_set, true)

  4. If tier == 1: animate letterbox bars out (await completion)

  5. Set EventFlags: "cutscene_seen_{id}" = true

  6. Emit cutscene_finished

  7. Call GameManager.pop_overlay()
```

### Command Execution Details

- **fade:** Sets `FadeRect.color` to the specified color (default black)
  then tweens `FadeRect.modulate.a` (0 to 1 for "out", 1 to 0 for "in")
  over `duration`. Awaits tween completion.
- **move:** Emits `cutscene_move_requested(who, Vector2(to[0], to[1]),
  speed)`. Non-blocking. Pair with `wait` if blocking is needed.
- **camera:** Emits `cutscene_camera_requested(Vector2(target[0],
  target[1]), duration)`. Non-blocking.
- **wait:** Creates a timer, awaits timeout. Always sequential/blocking.
- **shake:** Checks DataManager.load_json("res://data/config/defaults.json") for `reduce_motion`. If
  enabled, skip. Otherwise emits `cutscene_shake_requested(intensity,
  duration)`.
- **flash:** Checks DataManager.load_json("res://data/config/defaults.json") for `flash_intensity`. If
  "off", skip. If "reduced", halve duration. Tweens FadeRect to color
  then back to transparent.
- **title:** Sets `TitleLabel.text`, tweens alpha in over `fade_in`
  seconds, holds for `duration`, tweens out over `fade_out` seconds.
  Awaits full sequence.
- **music:** Emits `cutscene_music_requested(track_id, action)`.
  Non-blocking. Actual playback deferred to gap 3.8.
- **hide_dialogue / show_dialogue:** Toggle DialogueBox visibility.

### Parallel Execution

All non-wait commands with the same `when` value fire simultaneously
(signals emitted in sequence but without awaiting). `wait` is the
mechanism to create blocking points within a command group.

---

## cutscene_letterbox.gd

Controls LetterboxTop and LetterboxBottom ColorRects.

```gdscript
signal letterbox_in_complete
signal letterbox_out_complete

const BAR_HEIGHT: int = 90  # ~12.5% of 720px, standard letterbox ratio

@export var top_bar: ColorRect
@export var bottom_bar: ColorRect

func animate_in(duration: float = 0.5) -> void
func animate_out(duration: float = 0.5) -> void
func set_instant(visible: bool) -> void  # Snap bars without animation (for skip)
```

Uses Tween on `custom_minimum_size.y` (top bar) and `position.y` +
`custom_minimum_size.y` (bottom bar).

---

## T1 vs T4 Behavior

| Behavior | T1 (Full Cutscene) | T4 (Micro-Cutscene) |
|----------|---------------------|----------------------|
| Letterbox | animate_in / animate_out | None (bars stay at 0) |
| Input lock | Full (overlay pauses tree) | Full (overlay pauses tree) |
| Duration limit | Unlimited | Design convention <10s (not enforced) |
| Skip flag prefix | `cutscene_seen_` | `cutscene_seen_` (same) |
| Fade support | Yes | Yes (allowed, no restriction) |
| Title cards | Yes | No (convention, not enforced) |

Both tiers push the same `CUTSCENE` overlay. The `tier` parameter only
controls letterbox animation.

---

## Skip Logic

1. Build skip flag: `"cutscene_seen_%s" % cutscene_id`
2. If `EventFlags.get_flag(skip_flag)` is truthy: emit
   `cutscene_finished`, call `GameManager.pop_overlay()`, return
   immediately
3. On normal completion: `EventFlags.set_flag(skip_flag, true)`

This supports faint-and-fast-reload: boss cutscene skip flags persist
across death (per events.md Section 2c).

### skip_cutscene() Behavior

Debug/accessibility shortcut. Jumps to end of the sequence:

1. Iterate remaining entries, collect all `flag_set` values
2. Set each flag via `EventFlags.set_flag(flag, true)`
3. If tier == 1, remove letterbox bars instantly via `set_instant(false)`
4. Set the `cutscene_seen_{id}` flag
5. Emit `cutscene_finished`
6. Call `GameManager.pop_overlay()`

---

## Exploration Integration

When the cutscene overlay is pushed, `exploration.gd` connects to its
signals:

```gdscript
func _on_cutscene_overlay_pushed() -> void:
    var cutscene := GameManager.overlay_node as Node
    cutscene.cutscene_move_requested.connect(_on_cutscene_move)
    cutscene.cutscene_anim_requested.connect(_on_cutscene_anim)
    cutscene.cutscene_camera_requested.connect(_on_cutscene_camera)
    cutscene.cutscene_shake_requested.connect(_on_cutscene_shake)
    cutscene.flag_set_requested.connect(_on_cutscene_flag_set)
    cutscene.sfx_requested.connect(_on_cutscene_sfx)
```

### Signal Handler Routing

| Signal | Handler Action |
|--------|---------------|
| `cutscene_move_requested` | Find entity by character_id in `_entities` dict, call `walk_to(target, speed)` |
| `cutscene_anim_requested` | Find entity by character_id, call `play_animation(anim)` |
| `cutscene_camera_requested` | Tween `Camera2D.position` to target over duration |
| `cutscene_shake_requested` | Apply camera shake offset tween |
| `flag_set_requested` | `EventFlags.set_flag(flag, value)` |
| `sfx_requested` | Stub (future AudioManager, gap 3.8) |

### Entity Lookup

Exploration adds a new `_entities: Dictionary` mapping `character_id` to
`Node` reference. Populated in `_initialize_entities()` during map load
by iterating entity children and reading their `character_id` or `npc_id`
metadata. Cutscene signal handlers look up entities from this dict.
If a `character_id` is not found, log a warning and skip the command
(do not crash).

### Note on `cutscene_music_requested`

This signal is intentionally NOT connected in exploration.gd. It will
be wired to AudioManager when gap 3.8 (Audio Integration) is implemented.

---

## PlayerCharacter / NPC Additions

Both entities need a `walk_to()` method for cutscene choreography.
NPC also needs a `play_animation(anim: String) -> void` method (wraps
`$AnimationPlayer.play(anim)`) -- PlayerCharacter already has this.

```gdscript
signal walk_complete

func walk_to(target: Vector2, speed: float) -> void
```

Behavior:
- Disables player input (already disabled via tree pause, but explicit
  flag for safety)
- Tweens position toward target at given speed
- Plays walk animation in the appropriate direction
- Emits `walk_complete` signal when arrived

---

## Test Plan

### Unit Tests -- test_cutscene_player.gd (~25+ tests)

Sequencer logic (mock dialogue_box, no real scenes needed):

1. `start_cutscene` with empty entries emits `cutscene_finished` immediately
2. `start_cutscene` processes entries in order (index tracking)
3. "before" commands emit signals before `dialogue_box.show_dialogue` called
4. "after" commands emit signals after `dialogue_finished` received
5. Command-only entry (empty lines) skips dialogue, runs commands only
6. Multiple "before" commands emit in parallel (all signals fire, no await between them)
7. `wait` command creates delay (verify timer-based pause)
8. `fade` "out" command tweens FadeRect alpha from 0 to 1
9. `fade` "in" command tweens FadeRect alpha from 1 to 0
10. `shake` command emits `cutscene_shake_requested` with correct args
11. `shake` command skipped when `reduce_motion` config is true
12. `flash` command respects `flash_intensity` config ("off" skips, "reduced" halves duration)
13. `title` command sets TitleLabel text and tweens visibility
14. `move` command emits `cutscene_move_requested` with correct Vector2 and speed
15. `camera` command emits `cutscene_camera_requested` with correct args
16. `music` command emits `cutscene_music_requested` with correct args
17. `hide_dialogue` / `show_dialogue` toggle DialogueBox visibility
18. T1 tier shows letterbox (`animate_in` called)
19. T4 tier does NOT show letterbox
20. Skip flag checked on start -- cutscene skips if flag already set
21. Skip flag set to true on normal completion
22. `cutscene_finished` signal emitted on completion (both normal and skip)
23. `flag_set_requested` emitted for entries with non-empty `flag_set` field
24. `sfx_requested` forwarded from embedded dialogue_box for entries with `sfx` array
25. `cutscene_anim_requested` forwarded from embedded dialogue_box `animation_requested` signal
26. `skip_cutscene()` jumps to end, sets all flags from remaining entries, emits `cutscene_finished`
27. `GameManager.pop_overlay()` called on completion
28. `fade` command sets FadeRect.color before tweening alpha (non-black color)
29. `cutscene_move_requested` with unknown character_id does not crash (exploration logs warning)
30. Embedded dialogue_box has `embedded_mode = true` and does NOT call `pop_overlay()` on finish
31. `dialogue_box.dialogue_finished` signal still emitted in embedded mode (sequencer advances)

### Integration Tests -- test_cutscene_integration.gd (~15+ tests)

Full overlay lifecycle with exploration scene:

1. Push CUTSCENE overlay from exploration -- tree pauses, overlay node exists
2. Cutscene overlay has `PROCESS_MODE_ALWAYS` (runs while paused)
3. CUTSCENE force-closes active DIALOGUE overlay (`push_overlay` priority)
4. `cutscene_move_requested` signal received by exploration signal handler
5. `cutscene_anim_requested` signal received by exploration signal handler
6. `cutscene_camera_requested` signal received by exploration signal handler
7. `cutscene_shake_requested` signal received by exploration signal handler
8. `flag_set_requested` signal sets EventFlags correctly
9. Cutscene completes -- overlay pops -- tree unpauses -- exploration resumes input
10. Player input blocked during cutscene (`ui_accept` does not trigger player movement)
11. Full T1 sequence: push -- letterbox in -- entries with commands -- letterbox out -- pop
12. Full T4 sequence: push -- entries (no letterbox) -- pop
13. Skip flag persists: play cutscene once, replay same ID -- skips immediately
14. Sequential cutscenes: first finishes, push second -- both play correctly
15. Entity lookup: `cutscene_move_requested` with valid character_id routes to correct entity
16. Entity lookup: `cutscene_move_requested` with unknown character_id logs warning, does not crash
17. `cutscene_music_requested` signal not connected in exploration (no error if emitted)

### Dialogue Box Embedded Mode Tests -- test_dialogue_box_embedded.gd (~4 tests)

1. `embedded_mode = false` (default): `dialogue_finished` calls `GameManager.pop_overlay()`
2. `embedded_mode = true`: `dialogue_finished` does NOT call `GameManager.pop_overlay()`
3. `embedded_mode = true`: `dialogue_finished` signal still emitted normally
4. `embedded_mode = true`: `animation_requested` and `sfx_requested` signals still emitted

### Letterbox Tests -- test_cutscene_letterbox.gd (~5 tests)

1. `animate_in` tweens bars from 0 to BAR_HEIGHT (90px)
2. `animate_out` tweens bars from BAR_HEIGHT to 0
3. `set_instant(true)` snaps bars to BAR_HEIGHT immediately
4. `set_instant(false)` snaps bars to 0 immediately
5. `letterbox_in_complete` / `letterbox_out_complete` signals emitted after animation

---

## Dependencies

- **Requires (complete):** Gap 3.5 (Dialogue Overlay -- reuses
  dialogue_box.gd), Gap 1.8 (Dialogue Data)
- **Modifies:** exploration.gd, player_character.gd, npc.gd
- **Does NOT modify:** GameManager, DataManager, dialogue_box.gd

---

## What This Does NOT Include

- **T2 Walk-and-Talk** -- exploration-mode behavior, not an overlay
- **T3 Playable Scene** -- exploration-mode behavior, not an overlay
- **Audio playback** -- gap 3.8; signals emitted but not consumed
- **Complex camera work** -- Mode 7 rotation, zoom deferred
- **Ley Line Rupture montage** -- Interlude Scene 20, requires
  multi-location rendering; deferred to gap 4.5
- **Boss-integrated cutscenes** -- dialogue at HP thresholds handled by
  battle_manager.gd, not this overlay
- **Cael grey border flicker** -- Act IV specific, deferred to gap 4.5
- **Real sprite animations** -- uses existing AnimationPlayer stubs;
  real art in gap 4.8
