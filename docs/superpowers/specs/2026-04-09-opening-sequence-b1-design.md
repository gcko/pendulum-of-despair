# Opening Sequence Phase B1 — Design Spec

> **Gap:** 4.4 Phase B1 (Party Assembly + Game Start Restructuring)
> **Goal:** Wire correct party assembly flow: Edren+Cael at start,
> Lira+Sable join via carradan_ambush_survived flag, Scene 2+4
> dialogue triggers on overworld, Ember Vein exit sets story flags.

---

## 1. Scope

### In Scope

- Add `carradan_ambush_survived` flag check to `_check_party_joining_flags()`
  for Lira+Sable party assembly
- Create Scene 2 dialogue data (Vaelith encounter at mine exit)
- Create Scene 4 dialogue data (Dawn March opening credits walk)
- Add overworld dialogue triggers for Scenes 2, 3 (placeholder), and 4
- Wire Ember Vein F4 exit to set `pendulum_discovered` and
  `vaelith_ember_vein` flags
- Add overworld Ironmouth placeholder trigger (Scene 3 stub) that sets
  `carradan_ambush_survived` and adds Lira+Sable
- Add starting equipment entries for Lira and Sable in STARTING_EQUIPMENT
- Update all tests for the new party assembly flow
- Update gap tracker with B1 complete + B2 remaining

### Not In Scope (Deferred to Phase B2)

| Item | Reason | Deferred To |
|------|--------|-------------|
| Ironmouth outpost map (.tscn) | Needs new tileset + NPC placements | 4.4 Phase B2 |
| Ember Vein F3 (Ancient Ruin) | Complex floor with puzzles/key items | 4.4 Phase B2 |
| Scene 1 full tutorial dialogue | Needs F3 + tutorial combat design | 4.4 Phase B2 |
| Scene 3 escape combat sequence | Needs Ironmouth map + soldier enemies | 4.4 Phase B2 |
| Opening credits camera walk | Needs cutscene system (gap 3.7) | 4.4 Phase B2 |
| Dawn March forward-only walk | Needs special exploration mode | 4.4 Phase B2 |
| Arcanite gear preview | Complex equipment mechanic | 4.4 Phase B2 |
| Cael hidden stat spike | Needs Act II flag system | 4.5 |
| Change new game start to Ember Vein | Needs F1-F4 fully playable | 4.4 Phase B2 |

---

## 2. Party Assembly Flow (After B1)

```
New Game → Overworld (Edren + Cael)
  ↓ Walk to Ember Vein → Complete dungeon → Exit sets pendulum_discovered
  ↓ Return to overworld → Scene 2 trigger (Vaelith, after vaelith_ember_vein)
  ↓ Walk toward Ironmouth area → Scene 3 stub trigger
    → Sets carradan_ambush_survived → Lira + Sable join
  ↓ Continue walking → Scene 4 trigger (Dawn March dialogue)
    → Sets opening_credits_seen
  ↓ Walk to Roothollow → Scene 5 trigger → Torren joins
  ↓ Walk to Maren's Refuge → Scene 6 trigger → Maren joins
  ↓ Walk to Valdris Crown → Continue story
```

---

## 3. Exploration Changes

### _check_party_joining_flags() — Add Lira + Sable

```gdscript
func _check_party_joining_flags() -> void:
    if EventFlags.get_flag("carradan_ambush_survived") and not PartyState.has_member("lira"):
        PartyState.add_member("lira", _get_party_avg_level())
        flash_location_name("Lira joined the party!")
    if EventFlags.get_flag("carradan_ambush_survived") and not PartyState.has_member("sable"):
        PartyState.add_member("sable", _get_party_avg_level())
        flash_location_name("Sable joined the party!")
    if EventFlags.get_flag("torren_joined") and not PartyState.has_member("torren"):
        PartyState.add_member("torren", _get_party_avg_level())
        flash_location_name("Torren joined the party!")
    if EventFlags.get_flag("maren_warning") and not PartyState.has_member("maren"):
        PartyState.add_member("maren", _get_party_avg_level())
        flash_location_name("Maren joined the party!")
```

Both Lira and Sable join on the same flag (`carradan_ambush_survived`).

### Ember Vein Exit Flag

In `game/scenes/maps/dungeons/ember_vein_f4.tscn`, the exit transition
(ExitToOverworld) needs a dialogue trigger that sets `pendulum_discovered`
and `vaelith_ember_vein` flags after the boss is defeated.

Since the Vein Guardian boss fight already sets `vaelith_ember_vein` via
an existing boss trigger zone, we just need to verify the flag is set
and add `pendulum_discovered` to the boss completion flow.

---

## 4. Overworld Triggers

### Scene 2: Vaelith Encounter

Add a dialogue trigger near the Ember Vein entrance on the overworld:
- Position: near from_ember_vein marker (~848, 528)
- `required_flag = "vaelith_ember_vein"`
- `flag = "vaelith_scene_complete"` (one-shot)
- `dialogue_scene_id = "scene_2_vaelith_encounter"`

### Scene 3: Ironmouth Escape (Placeholder)

Add a dialogue trigger between Ember Vein and the main overworld:
- Position: ~(700, 500) — south of Ember Vein
- `required_flag = "vaelith_scene_complete"`
- `flag = "carradan_ambush_survived"`
- `dialogue_scene_id = "scene_3_ironmouth_escape"`
- This is a STUB — full Scene 3 with Ironmouth map is Phase B2

### Scene 4: Dawn March

Add a dialogue trigger between Ironmouth and Roothollow:
- Position: ~(600, 480) — midway on the overworld
- `required_flag = "carradan_ambush_survived"`
- `flag = "opening_credits_seen"`
- `dialogue_scene_id = "scene_4_dawn_march"`

---

## 5. Dialogue Data Files

### scene_2_vaelith_encounter.json (NEW)

Canonical text from script/act-i.md Scene 2. Key lines:
- Vaelith: "If I wanted to stop you, I wouldn't have waited up here"
- Vaelith: "What a fragile little thing it is to build hope around"
- Vaelith calls Cael by name without introduction
- Vaelith: "Do take care of yourself, Cael"

### scene_3_ironmouth_escape.json (NEW — STUB)

Abbreviated version of Scene 3 for B1. Key lines:
- Lira: "Patrol passes in forty seconds. You came from the mine?"
- Sable: "I was definitely not looting supplies"
- Narrator: "Lira and Sable have joined the party"

Full Scene 3 with Ironmouth map combat deferred to B2.

### scene_4_dawn_march.json (NEW)

Canonical text from script/act-i.md Scene 4. Key lines:
- Cael: "Those miners... they just stopped"
- Sable: "That thing in the satchel"
- Lira: "Don't ask"
- Title card reference (text only — visual credits deferred to B2)

---

## 6. Starting Equipment

Add Lira and Sable to STARTING_EQUIPMENT in party_state.gd:

```gdscript
const STARTING_EQUIPMENT: Dictionary = {
    "edren": {"weapon": "training_sword", "head": "", "body": "", "accessory": "", "crystal": ""},
    "cael": {"weapon": "recruits_claymore", "head": "", "body": "", "accessory": "", "crystal": ""},
    "lira": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
    "sable": {"weapon": "", "head": "", "body": "", "accessory": "", "crystal": ""},
}
```

Lira and Sable join without weapons (player equips them from inventory).

---

## 7. Test Plan

### New tests (test_opening_sequence.gd)

- `test_new_game_starts_with_two_members` — PartyState after new game has exactly Edren+Cael
- `test_lira_joins_on_carradan_flag` — Setting carradan_ambush_survived adds Lira
- `test_sable_joins_on_carradan_flag` — Same flag adds Sable
- `test_lira_sable_join_together` — Both join on same flag, neither duplicated
- `test_full_party_assembly_order` — Set all 4 flags in order, verify 6 members
- `test_scene_2_dialogue_exists` — Dialogue file loads
- `test_scene_3_dialogue_exists` — Dialogue file loads
- `test_scene_4_dialogue_exists` — Dialogue file loads

### Updated tests

- `test_party_state.gd` — Verify Lira/Sable in STARTING_EQUIPMENT
- `test_wilds_route.gd` — No changes needed (Torren/Maren flow unchanged)

---

## 8. File Map

| File | Action | What Changes |
|------|--------|-------------|
| `game/scripts/core/exploration.gd` | MODIFY | Add Lira+Sable to _check_party_joining_flags |
| `game/scripts/autoload/party_state.gd` | MODIFY | Add Lira+Sable to STARTING_EQUIPMENT |
| `game/scenes/maps/overworld.tscn` | MODIFY | Add Scene 2, 3, 4 dialogue triggers |
| `game/data/dialogue/scene_2_vaelith_encounter.json` | CREATE | Vaelith encounter dialogue |
| `game/data/dialogue/scene_3_ironmouth_escape.json` | CREATE | Ironmouth escape stub dialogue |
| `game/data/dialogue/scene_4_dawn_march.json` | CREATE | Dawn March dialogue |
| `game/tests/test_opening_sequence.gd` | CREATE | Party assembly + dialogue tests |
| `docs/analysis/game-dev-gaps.md` | MODIFY | Update gap 4.4 Phase B |

---

## 9. Remaining After B1 (Phase B2)

Explicitly tracked for future work:

- [ ] Ironmouth outpost map (.tscn with NPCs, Forgewright crates)
- [ ] Ember Vein F3 (Ancient Ruin floor with geometric puzzles)
- [ ] Full Scene 1 tutorial dialogue (all 1a-1e beats with combat)
- [ ] Full Scene 3 Ironmouth escape (combat sequence with soldiers)
- [ ] Opening credits visual sequence (title card, character names)
- [ ] Dawn March forward-only walk mechanics
- [ ] Arcanite gear preview (Edren's enhanced equipment that breaks)
- [ ] Change new game start location from overworld to Ember Vein F1
- [ ] Cael hidden stat spike (Pallor's first touch)
