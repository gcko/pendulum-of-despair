# Dawn March Opening Credits — Design Spec

**Date:** 2026-04-13
**Gap:** 4.4 Phase B2 (remaining items)
**Status:** Design
**Depends on:** 3.7 Cutscene Overlay (COMPLETE), 4.4 Phase B2 (MOSTLY COMPLETE)

## Overview

Implement the 3 remaining Phase B2 items that were blocked by gap 3.7:

1. **Opening credits visual sequence** — title card with character names
2. **Dawn March forward-only walk** — T1 Full Cutscene, all movement scripted
3. **`opening_credits_seen` flag (39)** — set on cutscene completion

Reference: FF6 Narshe opening (Terra wakes up, fully scripted sequence).
The player watches; characters move on their own; dialogue plays between
choreographed movements; title card fades in mid-sequence.

## Source Documents

- `docs/story/script/act-i.md` lines 365-435 (Scene 4: The Dawn March)
- `docs/story/events.md` flag 39 (`opening_credits_seen`)
- `docs/story/dialogue-system.md` Section 1.1 (cutscene tiers)
- `docs/plans/technical-architecture.md` Section 3 (scene architecture)

**Prerequisite flag note:** events.md says flag 39 uses `vaelith_ember_vein`
(flag 2) as prerequisite, but the actual overworld trigger (Scene4Trigger)
uses `ironmouth_escape_seen` — which is more correct because it ensures the
Ironmouth escape sequence (Scene 3) has played. The progression chain is:
`carradan_ambush_survived` (Scene 3 trigger) -> `ironmouth_escape_seen`
(Scene 3 completion) -> `opening_credits_seen` (Dawn March). events.md
should be updated to match.

## Approach

**T1 Full Cutscene** on a dedicated trail map scene. The cutscene player
drives all movement, camera, dialogue, and title card display via its
existing 10 command types. No new engine code needed for the sequencer
itself.

### Narrative Beat Summary (from act-i.md)

1. Dawn breaks. Narrow forest trail. Forward-only walk, no encounters.
2. Edren + Cael walk ahead. Lira + Sable trail behind, separate.
3. Cael and Edren discuss the miners' despair (entries 001-005).
4. Trail widens. Valley opens — Valdris Crown towers visible in distance.
5. Camera shifts to Lira + Sable trailing behind (entries 006-012).
6. Sable and Lira discuss the Pendulum, the Compact's soldiers.
7. Trail descends into deeper forest. Canopy closes overhead.
8. Fade to black. Title card: **PENDULUM OF DESPAIR**. [SFX: title_reveal]
9. Credits overlay: character names, "A game by..."
10. Flag `opening_credits_seen` (39) set. Tutorial complete.

## Deliverables

### 1. Trail Map Scene

**File:** `game/scenes/maps/cutscenes/dawn_march_trail.tscn`
**Map ID:** `cutscenes/dawn_march_trail`

A dedicated linear map that serves as the cutscene stage.

**Layout:**
- 80x15 tiles (1280x240 px), oriented left-to-right
- Reuses existing forest tileset tiles (indices 8-9: forest floor,
  bioluminescent) from Wilds Route
- Simple forest corridor: floor tiles with wall/canopy tiles along
  top and bottom edges
- No interactables, no encounters, no transitions
- No encounter_floor_id metadata (prevents random encounters)

**Entities (under Entities node):**
- 4 NPC instances of `npc.tscn`, positioned at trail start (left side):
  - `Edren` — position (80, 120), metadata `npc_id = "edren"`
  - `Cael` — position (64, 136), metadata `npc_id = "cael"`
  - `Lira` — position (32, 120), metadata `npc_id = "lira"`
  - `Sable` — position (16, 136), metadata `npc_id = "sable"`
- Use NPC instances (not PlayerCharacter) for all 4 — the player has
  no input during this cutscene. NPCs have `walk_to()`, `cancel_walk()`,
  and `play_animation()` which is everything the cutscene choreography
  needs.
- Each NPC uses the character's placeholder sprite (16x24 colored
  rectangle: edren=blue, cael=red, lira=orange, sable=grey)
- No `initialize()` call needed — NPCs without dialogue data simply
  exist as sprites with walk capability. Set `dialogue_entries = []`
  by not calling `initialize()`.

**Why NPC instances, not PlayerCharacter?**
- PlayerCharacter processes input every frame — undesirable in a
  pure cutscene
- NPC.gd has walk_to/cancel_walk/play_animation — same choreography API
- Entity lookup registers by `npc_id` metadata, which the cutscene
  system uses for move/anim commands
- No dialogue is loaded on these NPCs — they are pure sprite actors

**Spawn marker:**
- `PlayerSpawn` Marker2D at (80, 120) — required by exploration.gd
  but the "player" will be hidden immediately (see cutscene commands)

**Special handling — no player character:**
- This map is loaded by exploration.gd which always instantiates a
  PlayerCharacter. Since all 4 party members are NPC actors on this
  map, the player character must be hidden. The cutscene's first
  command hides the player via a `hide_entity` approach.
- Simplest approach: position PlayerSpawn off-screen at (-100, -100)
  so the auto-spawned player is invisible. The NPC named "edren"
  serves as the visible Edren on screen.

### 2. Enhanced Dialogue JSON

**File:** `game/data/dialogue/dawn_march.json` (update existing)

Add `commands` arrays to entries for cutscene choreography. The
existing 12 entries retain their dialogue lines unchanged. New fields
added per the cutscene_player.gd entry format:

**Cutscene metadata (top-level fields to add):**
```json
{
  "scene_id": "dawn_march",
  "cutscene_id": "dawn_march",
  "cutscene_tier": 1,
  "entries": [...]
}
```

The `cutscene_id` and `cutscene_tier` fields are consumed by the
trigger handler in exploration.gd (see Deliverable 3) to call
`start_cutscene(cutscene_id, entries, tier)`.

**Entry-level choreography commands:**

**Command field reference:** Move commands use `"to"` (not `"target"`).
Camera commands use `"target"`. This matches `cutscene_player.gd` lines
297-309: `_cmd_move()` reads `cmd.get("to", ...)`, `_cmd_camera()`
reads `cmd.get("target", ...)`.

Entry 001 (Cael — "Those miners"):
```json
{
  "commands": [
    {"type": "move", "who": "edren", "to": [400, 120], "speed": 60, "when": "before"},
    {"type": "move", "who": "cael", "to": [384, 136], "speed": 60, "when": "before"},
    {"type": "move", "who": "lira", "to": [352, 120], "speed": 60, "when": "before"},
    {"type": "move", "who": "sable", "to": [336, 136], "speed": 60, "when": "before"},
    {"type": "camera", "target": [240, 120], "duration": 5.0, "when": "before"},
    {"type": "wait", "duration": 2.0, "when": "before"}
  ]
}
```
(All 4 characters start walking east. Camera pans ahead. Wait lets
them get into frame before dialogue starts.)

Entries 002-004 (Edren/Cael dialogue continues — no commands needed,
characters are still walking from entry 001 move commands which are
non-blocking).

Entry 005 (Cael — "I keep thinking about their faces"):
```json
{
  "commands": [
    {"type": "wait", "duration": 1.5, "when": "after"}
  ]
}
```
(Beat of silence — "Edren says nothing. He walks.")

Entry 006 (Sable — "So. That thing in the satchel"):
```json
{
  "commands": [
    {"type": "move", "who": "edren", "to": [700, 120], "speed": 60, "when": "before"},
    {"type": "move", "who": "cael", "to": [684, 136], "speed": 60, "when": "before"},
    {"type": "move", "who": "lira", "to": [652, 120], "speed": 60, "when": "before"},
    {"type": "move", "who": "sable", "to": [636, 136], "speed": 60, "when": "before"},
    {"type": "camera", "target": [620, 128], "duration": 1.5, "when": "before"},
    {"type": "wait", "duration": 1.0, "when": "before"}
  ]
}
```
(Camera shifts to Lira+Sable pair. All 4 continue walking to new
positions further along the trail.)

Entries 007-011 (Sable/Lira dialogue continues — no commands needed,
characters still walking from entry 006 move commands).

Entry 012 (Lira — "I know. That's why I came."):
```json
{
  "commands": [
    {"type": "fade", "direction": "out", "duration": 1.5, "when": "after"},
    {"type": "wait", "duration": 0.5, "when": "after"}
  ],
  "flag_set": "opening_credits_seen"
}
```
(Fade to black after final line. Flag 39 set.)

**Note on double flag-set:** The trigger handler (Deliverable 3) sets
`opening_credits_seen` immediately to prevent re-entry if the player
somehow re-triggers the zone. The `flag_set` on entry 012 is the
canonical story-progression set point. Both are intentional — the
trigger guard is defensive, the entry flag is narrative.

**Title card entry (new entry 013, after entry 012):**
```json
{
  "id": "dawn_march_013",
  "speaker": "",
  "lines": [],
  "condition": null,
  "animations": null,
  "choice": null,
  "sfx": "title_reveal",
  "commands": [
    {"type": "title", "text": "PENDULUM OF DESPAIR", "fade_in": 1.0, "duration": 3.0, "fade_out": 1.0, "when": "before"},
    {"type": "wait", "duration": 5.0, "when": "before"}
  ]
}
```

No speaker, no lines — this is a pure command entry. Title text
appears over the black screen (fade-out already happened in entry 012).
The `wait` holds for the full title display (fade_in 1.0 + duration
3.0 + fade_out 1.0 = 5.0s). SFX `title_reveal` emits via signal
(AudioManager wiring deferred to gap 3.8).

**Credits entries (new entries 014-016):**

Additional title-command entries for credits text. These appear
sequentially over the black screen:

```json
{
  "id": "dawn_march_014",
  "speaker": "",
  "lines": [],
  "condition": null,
  "animations": null,
  "choice": null,
  "sfx": null,
  "commands": [
    {"type": "title", "text": "Edren  -  Cael  -  Maren", "fade_in": 0.5, "duration": 2.0, "fade_out": 0.5, "when": "before"},
    {"type": "wait", "duration": 3.0, "when": "before"}
  ]
},
{
  "id": "dawn_march_015",
  "speaker": "",
  "lines": [],
  "condition": null,
  "animations": null,
  "choice": null,
  "sfx": null,
  "commands": [
    {"type": "title", "text": "Sable  -  Lira  -  Torren", "fade_in": 0.5, "duration": 2.0, "fade_out": 0.5, "when": "before"},
    {"type": "wait", "duration": 3.0, "when": "before"}
  ]
},
{
  "id": "dawn_march_016",
  "speaker": "",
  "lines": [],
  "condition": null,
  "animations": null,
  "choice": null,
  "sfx": null,
  "commands": [
    {"type": "fade", "direction": "in", "duration": 1.0, "when": "before"}
  ]
}
```

Entry 016 fades back from black briefly before the cutscene ends
and letterbox bars retract. This gives the player a moment to see the
trail scene before transitioning back to the overworld.

### 3. Trigger Mechanism

**Change:** Convert the existing Scene4Trigger on the overworld map
from a dialogue trigger to a cutscene trigger.

**Current state** (overworld.tscn line 185-196):
```
[node name="Scene4Trigger" type="Area2D"]
metadata/flag = "opening_credits_seen"
metadata/required_flag = "ironmouth_escape_seen"
metadata/dialogue_scene_id = "dawn_march"
```

This fires `_on_dialogue_trigger_entered`, which pushes a DIALOGUE
overlay and calls `show_dialogue()`. That is wrong for a T1 cutscene.

**New approach — cutscene trigger metadata:**

Replace `dialogue_scene_id` with `cutscene_scene_id`:
```
metadata/flag = "opening_credits_seen"
metadata/required_flag = "ironmouth_escape_seen"
metadata/cutscene_scene_id = "dawn_march"
metadata/cutscene_map_id = "cutscenes/dawn_march_trail"
metadata/cutscene_return_map = "overworld"
metadata/cutscene_return_spawn = "Scene4Return"
```

**New metadata fields:**
- `cutscene_scene_id` — dialogue JSON scene_id to load entries from
- `cutscene_map_id` — map to transition to before starting cutscene
- `cutscene_return_map` — map to transition back to after cutscene
- `cutscene_return_spawn` — spawn marker on return map

**exploration.gd changes:**

**New state variables:**
```gdscript
## Pending cutscene data (set by trigger, consumed after map load).
var _pending_cutscene: Dictionary = {}
## Return destination after a cutscene map finishes.
var _cutscene_return: Dictionary = {}
```

1. **Entity signal wiring** (in `_connect_entity_signals`, the block
   that iterates Area2D children): Add a third branch for
   `cutscene_scene_id` metadata, before the dialogue branch:

   ```gdscript
   elif (
       child is Area2D
       and child.has_meta("cutscene_scene_id")
   ):
       child.body_entered.connect(
           _on_cutscene_trigger_entered.bind(child)
       )
   ```

   This must come BEFORE the `dialogue_scene_id` check since an
   Area2D should only wire to one handler.

2. **New handler** `_on_cutscene_trigger_entered(body, area)`:

   ```gdscript
   func _on_cutscene_trigger_entered(
       body: Node2D, area: Area2D
   ) -> void:
       if body != _player or _transitioning or _in_cutscene:
           return
       var flag: String = area.get_meta("flag", "")
       if not flag.is_empty() and EventFlags.get_flag(flag):
           return
       var required: String = area.get_meta("required_flag", "")
       if not required.is_empty() and not EventFlags.get_flag(required):
           return
       # Set one-shot flag immediately (prevents re-trigger)
       if not flag.is_empty():
           EventFlags.set_flag(flag, true)
       var scene_id: String = area.get_meta("cutscene_scene_id", "")
       var map_id: String = area.get_meta("cutscene_map_id", "")
       var return_map: String = area.get_meta("cutscene_return_map", "")
       var return_spawn: String = area.get_meta("cutscene_return_spawn", "")
       # Load cutscene data from dialogue JSON
       var scene_data: Dictionary = DataManager.load_dialogue(scene_id)
       var entries: Array = scene_data.get("entries", [])
       var cutscene_id: String = scene_data.get("cutscene_id", scene_id)
       var tier: int = scene_data.get("cutscene_tier", 1)
       if entries.is_empty():
           return
       # Store return info (survives map swap)
       _cutscene_return = {
           "map": return_map, "spawn": return_spawn
       }
       if map_id != "":
           # Transition to cutscene map, then start cutscene
           _pending_cutscene = {
               "id": cutscene_id, "entries": entries, "tier": tier
           }
           _transition_to_map(map_id, "PlayerSpawn")
       else:
           # Start cutscene on current map
           _start_pending_cutscene(cutscene_id, entries, tier)
   ```

3. **Cutscene launch helper:**

   ```gdscript
   func _start_pending_cutscene(
       cutscene_id: String, entries: Array, tier: int
   ) -> void:
       if GameManager.push_overlay(GameManager.OverlayState.CUTSCENE):
           GameManager.overlay_node.start_cutscene(
               cutscene_id, entries, tier
           )
   ```

4. **Map load hook** — in `load_map()`, after `_initialize_entities()`
   completes, add a deferred check (follows the existing `auto_sequence`
   pattern at line 191):

   ```gdscript
   if not _pending_cutscene.is_empty():
       var pc: Dictionary = _pending_cutscene
       _pending_cutscene = {}
       call_deferred(
           "_start_pending_cutscene",
           pc.get("id", ""), pc.get("entries", []), pc.get("tier", 1)
       )
   ```

   Uses `call_deferred` so the map is fully loaded and entities are
   registered before the cutscene starts (entity lookup must be
   populated for move commands to find the NPC actors).

5. **Cutscene finish hook** — in `_on_cutscene_finished()`, after
   existing cleanup, add return transition:

   ```gdscript
   if not _cutscene_return.is_empty():
       var ret: Dictionary = _cutscene_return
       _cutscene_return = {}
       var ret_map: String = ret.get("map", "")
       var ret_spawn: String = ret.get("spawn", "PlayerSpawn")
       if ret_map != "":
           _transition_to_map(ret_map, ret_spawn)
   ```

**Return spawn:** Add a `Scene4Return` Marker2D on the overworld map
near the Scene4Trigger position (576, 480). When the cutscene finishes,
the player spawns here and continues exploring toward Thornmere Wilds.

### 4. Overworld Map Updates

**File:** `game/scenes/maps/overworld.tscn`

- Replace `dialogue_scene_id` with cutscene metadata on Scene4Trigger
- Add `Scene4Return` Marker2D near (576, 480)
- Existing `flag = "opening_credits_seen"` stays (prevents re-trigger)

## Testing Strategy

**Manual testing (Godot editor):**
- Start new game, progress through Ironmouth escape
- Walk into Scene4Trigger zone on overworld
- Verify: fade to trail map, letterbox in, characters walk and talk,
  camera shifts from front pair to back pair, fade to black, title
  card appears, credits roll, fade back, letterbox out, return to
  overworld
- Verify: `opening_credits_seen` flag is set
- Verify: re-entering trigger zone does nothing (flag gate)
- Verify: skip (ui_cancel) fast-forwards, sets all flags, returns to
  overworld

**GUT tests:**
- Test cutscene trigger detection in exploration (mock Area2D with
  cutscene metadata)
- Test dawn_march.json loads and has valid structure (16 entries,
  commands arrays, flag_set on entry 012)
- Test `_pending_cutscene` state machine (set on trigger, cleared on
  map load, return on finish)

## File Summary

| File | Action | Description |
|------|--------|-------------|
| `game/scenes/maps/cutscenes/dawn_march_trail.tscn` | NEW | Linear trail map (cutscene stage) |
| `game/data/dialogue/dawn_march.json` | UPDATE | Add commands, title entries, flag_set |
| `game/scripts/core/exploration.gd` | UPDATE | Add cutscene trigger handler + pending state |
| `game/scenes/maps/overworld.tscn` | UPDATE | Convert trigger metadata, add return spawn |
| `game/tests/test_dawn_march.gd` | NEW | GUT tests for trigger + data validation |

## Coordinates and Timing

All positions are in pixels at 1280x720 viewport with 4x camera zoom
(effective 320x180 game world). Character sprites are 16x24.

**Trail map layout (80x15 tiles = 1280x240 px):**
- Walkable corridor: y=96 to y=160 (4 tiles high)
- Start positions (left): x=16 to x=80
- End positions (right): x=1100 to x=1200
- Camera visible area: 320x180 px window

**Walk timing:**
- Characters walk at 60 px/sec (slightly slower than normal 80 for
  reflective mood)
- Total walk distance: ~1100 px / 60 = ~18s of walking
- Dialogue interleaves with walking (commands are parallel with lines)

**Title card timing:**
- "PENDULUM OF DESPAIR": fade_in 1.0s, hold 3.0s, fade_out 1.0s
- Character names (2 entries): fade_in 0.5s, hold 2.0s, fade_out 0.5s
- Total credits: ~11s over black screen

## What This Does NOT Include

- Audio/music (gap 3.8 — signals emit, no sound yet)
- Real character sprites (gap 4.8 — uses colored rectangles)
- Weather/atmospheric effects (deferred)
- "A game by..." credit line (add when real credits are defined)
