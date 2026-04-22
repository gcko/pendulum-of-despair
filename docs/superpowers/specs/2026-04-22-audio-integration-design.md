# Audio Integration Design (Gap 3.8)

> **Date:** 2026-04-22
> **Gap:** 3.8 Audio Integration
> **Scope:** System only (Approach A) — full AudioManager implementation
> with single silence placeholder. Real audio assets deferred to gap 4.9.
> **Architecture:** Dual-Track Crossfade (Approach 1)
> **Source docs:** `docs/story/audio.md`, `docs/story/music.md`,
> `docs/plans/technical-architecture.md` Section 5.3

---

## 1. AudioStreamPlayer Node Architecture

16 AudioStreamPlayer nodes created programmatically in `_ready()`:

| Pool | Count | Purpose |
|------|-------|---------|
| `_music_active` | 1 | Currently playing music track |
| `_music_fade` | 1 | Outgoing music during crossfade |
| `_ambient_active` | 1 | Currently playing ambient loop |
| `_ambient_fade` | 1 | Outgoing ambient during crossfade |
| `_sfx_pool` | 12 | SFX with priority metadata |

**Note:** The 24-channel budget from audio.md Section 3.1 is a design
guideline for sound density (how many simultaneous sounds the game
targets). The implementation uses 16 physical AudioStreamPlayers: 2
music (active + fade), 2 ambient (active + fade), and 12 SFX pool
slots. This covers the design budget — music/ambient only need 1
active channel each (the fade slot is transient), and 12 SFX slots
exceed practical simultaneous SFX needs.

### AudioBus Setup

Three buses created in `_ready()` if they don't already exist:

| Bus | Routes To | Volume Source |
|-----|-----------|---------------|
| Music | Master | `config.music_volume * mix_ratio` |
| SFX | Master | `config.sfx_volume` |
| Ambient | Master | `config.sfx_volume * mix_ratio` |

Each AudioStreamPlayer is assigned to its category's bus. Bus volumes
control master category levels; individual player `volume_db` controls
crossfade tweening.

### Pre-Battle State

Stored on `enter_battle()`, restored on `exit_battle()`:

- `_pre_battle_music: String` — track ID
- `_pre_battle_ambient: String` — ambient ID
- `_pre_battle_music_pos: float` — playback position (seconds)
- `_pre_battle_mix_context: String` — mix context name

---

## 2. SFX Pool & Priority System

### Pool Metadata

```
var _sfx_meta: Array[Dictionary]  # 12 entries
# Each: { sfx_id: String, priority: Priority, start_time: int }
```

### Play SFX Algorithm

1. Check same-ID count across pool. If >= `MAX_SAME_SFX` (2), reject.
2. Find a free slot (player not playing). Use it.
3. If no free slot, find the lowest-priority slot where
   `slot.priority < requested_priority`. Steal it (50ms fade-out via
   tween, then replace).
4. If all slots are equal or higher priority, reject (sound dropped).

### File Loading

`play_sfx()` resolves path as `res://assets/sfx/{sfx_id}.ogg`. Calls
`ResourceLoader.exists()` before `load()`. Missing files produce a
debug-gated `push_warning()` and return silently.

### Stereo Panning

`play_sfx()` accepts optional `pan: float = 0.0` (-1.0 left to 1.0
right). Battle SFX pass pan values based on source position. When
config `sound_mode == "mono"`, pan is forced to 0.0.

---

## 3. Crossfade System

All crossfades use Godot `Tween` on `volume_db`. Volume range: 0 dB
(full) to -80 dB (silent/off).

### Music Crossfade (`play_music`)

1. Kill any in-progress tweens on `_music_active` and `_music_fade`.
2. If `_music_active` is playing, swap it to `_music_fade`.
3. Tween `_music_fade` from current volume to -80 dB over
   `duration / 2`.
4. Load new track into `_music_active` at -80 dB, start playing.
5. Tween `_music_active` from -80 dB to 0 dB over `duration / 2`.
6. When `_music_fade` tween completes, call `stop()`.

### Ambient Crossfade (`play_ambient`)

Identical to music crossfade using `_ambient_active` / `_ambient_fade`.

### Hard Cut (`enter_battle`)

1. Store pre-battle state (track IDs, music playback position, mix
   context).
2. Kill all active tweens on music/ambient players.
3. Immediately set ambient players to -80 dB, call `stop()`.
4. Immediately stop music, load battle track at 0 dB, play.
5. Call `set_mix_context("battle")`.

### Battle Exit (`exit_battle`)

1. Tween battle music to -80 dB over `CROSSFADE_BATTLE_EXIT` (1s).
2. Load pre-battle music at stored position, tween from -80 dB to 0 dB.
3. Load pre-battle ambient, tween from -80 dB to 0 dB.
4. Restore pre-battle mix context.

### Tween Safety

Every crossfade kills any in-progress tween on the target player before
creating a new one. Prevents overlapping tweens from rapid calls.

---

## 4. Mixing Model

`set_mix_context(context)` applies volume ratios to AudioBuses.

### Algorithm

1. Look up `MIX_*` dictionary by context string: "overworld", "town",
   "dungeon", "narrative_dungeon", "pallor", "battle".
2. Read player config: `music_volume` (0-10), `sfx_volume` (0-10).
3. Convert: `linear_to_db(config_value / 10.0 * mix_ratio)`.
4. Apply to "Music" and "Ambient" bus volumes via
   `AudioServer.set_bus_volume_db()`.

### Context Strings to Constants

| Context String | Constant |
|---------------|----------|
| `"overworld"` | `MIX_OVERWORLD` |
| `"town"` | `MIX_TOWN` |
| `"dungeon"` | `MIX_DUNGEON` |
| `"narrative_dungeon"` | `MIX_NARRATIVE_DUNGEON` |
| `"pallor"` | `MIX_PALLOR` |
| `"battle"` | `MIX_BATTLE` |

### Runtime Config Updates

`update_volumes()` re-applies the current mix context with fresh config
values. Called by config screen when volume sliders change.

Tracked as `_current_mix_context: String`.

---

## 5. Public API

### Existing Methods (implement stubs)

| Method | Signature |
|--------|-----------|
| `play_music` | `(track_id: String, crossfade_duration: float = CROSSFADE_BIOME) -> void` |
| `play_sfx` | `(sfx_id: String, priority: Priority = Priority.UI_SFX, pan: float = 0.0) -> void` |
| `play_ambient` | `(ambient_id: String, crossfade_duration: float = CROSSFADE_BIOME) -> void` |
| `silence_all` | `() -> void` |
| `set_mix_context` | `(context: String) -> void` |
| `enter_battle` | `(battle_track: String) -> void` |
| `exit_battle` | `(music_track: String, ambient_track: String) -> void` |

### New Methods

| Method | Signature | Purpose |
|--------|-----------|---------|
| `update_volumes` | `() -> void` | Re-apply mix context with current config |
| `stop_music` | `(fade_duration: float = 1.0) -> void` | Fade music to silence (Pallor Wastes 0% music) |
| `get_current_music` | `() -> String` | Returns `_current_music` |
| `get_current_ambient` | `() -> String` | Returns `_current_ambient` |

### API Change

`play_sfx` gains optional third parameter `pan: float = 0.0`. Existing
caller (`exploration.gd:327`) is unaffected (uses default).

---

## 6. Wiring Existing Callers

Three touch points in existing code:

### cutscene_handler.gd

Line ~172: `_on_cutscene_music` stub becomes:
```gdscript
func _on_cutscene_music(track_id: String, action: String) -> void:
    if action == "play":
        AudioManager.play_music(track_id)
    elif action == "stop":
        AudioManager.stop_music()
```

Line ~175: `_on_cutscene_sfx` stub becomes:
```gdscript
func _on_cutscene_sfx(sfx_id: String) -> void:
    AudioManager.play_sfx(sfx_id, AudioManager.Priority.CUTSCENE_SFX)
```

### exploration.gd

Line 327: Change `"save_point_proximity"` to `"save_point_chime"` per
audio.md Section 1.3 catalog.

### Not Wired (deferred)

Battle music triggers, exploration map-change music/ambient, shop SFX,
menu SFX — callers don't exist yet or are content-gap concerns. The
system is ready; callers will be added when those features are built.

---

## 7. Placeholder Audio Files

### Generation

Python script `tools/generate_placeholder_audio.py` creates a minimal
valid 0.1-second silent .ogg file and copies it to every expected path.

### File Inventory

| Category | Count | Path Pattern |
|----------|-------|-------------|
| SFX | 51 | `game/assets/sfx/{sfx_id}.ogg` |
| Ambient | 12 | `game/assets/ambient/{ambient_id}.ogg` |
| Music | 5 | `game/assets/music/{track_id}.ogg` |
| **Total** | **68** | ~4KB each |

### SFX IDs (51 from audio.md)

**Combat (19):** hit_physical, hit_magic, miss, critical, guard, heal,
status_apply, status_remove, ko_party, ko_beast, ko_undead,
ko_construct, ko_spirit, flee, victory_fanfare, level_up,
battle_onset_boss, battle_onset_superboss, phase_change

**UI (8):** cursor_move, confirm, cancel, menu_open, menu_close,
equip_change, error_buzz, save_confirm

**Exploration (8):** door_open, chest_open, save_point_chime,
encounter_trigger, ley_crystal_obtain, item_pickup, rest_complete,
quest_complete

**Environmental (16):** ley_surge, ley_rupture, pallor_surge,
pallor_surge_final, pallor_transform, pallor_ambience, alarm_bells,
wall_breach, door_breach, sword_draw, weapon_forge, machine_activate,
wind_quiet, pendulum_shatter, title_reveal, drums_war

### Ambient IDs (12 from audio.md Section 2.1)

valdris_highlands, carradan_industrial, thornmere_forest,
thornmere_marsh, mountain_windshear, coastal, underground_cave,
ley_line_depths, factory_interior, pallor_wastes, town_generic,
sacred_sites

### Music IDs (5 — contexts that exist in-game today)

title_theme, overworld_act_i, battle_standard, battle_boss, ember_vein

---

## 8. Testing Strategy

GUT tests in `game/tests/test_audio_manager.gd`:

| # | Test | Verifies |
|---|------|----------|
| 1 | Node creation | 16 AudioStreamPlayer children after `_ready()` |
| 2 | Bus setup | "Music", "SFX", "Ambient" buses in AudioServer |
| 3 | SFX pool full | 12 SFX fill pool; 13th rejected or steals |
| 4 | Same-ID limit | 3rd instance of same SFX rejected |
| 5 | Priority steal | High-priority SFX steals from low-priority |
| 6 | Music crossfade state | `play_music("b")` after "a": current is "b", fade has "a" |
| 7 | Battle enter/exit | Pre-battle state stored/restored, ambient silenced |
| 8 | Mix context | Bus volumes match `MIX_BATTLE` after `set_mix_context("battle")` |
| 9 | Silence all | All players stopped, IDs cleared |
| 10 | Missing file | `play_sfx("nonexistent")` — no crash, warning printed |
| 11 | Pan / mono | Pan applied to player; forced 0.0 in mono mode |

### Not Tested (manual verification)

Actual audible output, crossfade timing smoothness, tween precision —
verified by running in Godot editor.

### Integration

Verify cutscene_handler stubs wired. Verify exploration.gd SFX ID
corrected.

---

## 9. File Manifest

| File | Action |
|------|--------|
| `game/scripts/autoload/audio_manager.gd` | Rewrite |
| `game/scripts/core/cutscene_handler.gd` | Edit (2 stubs) |
| `game/scripts/core/exploration.gd` | Edit (1 SFX ID) |
| `tools/generate_placeholder_audio.py` | New |
| `game/assets/sfx/*.ogg` (51 files) | New (generated) |
| `game/assets/ambient/*.ogg` (12 files) | New (generated) |
| `game/assets/music/*.ogg` (5 files) | New (generated) |
| `game/tests/test_audio_manager.gd` | New |
| `docs/analysis/game-dev-gaps.md` | Update (3.8 → COMPLETE) |

---

## 10. Out of Scope

- Real audio assets (gap 4.9)
- Battle music triggers in battle_manager.gd (content gap)
- Exploration map-change music/ambient (content gap)
- Shop/menu SFX calls (content gap)
- Corruption stage audio effects (gap 4.5 — Acts II-IV)
- Music-as-mechanic (Torren Spiritcall — gap 4.5)
- Narrative true silence moments (gap 4.5)
- SFX captions (gap 4.7 — Accessibility)
- Ley Nexus additive layering (gap 4.5)
