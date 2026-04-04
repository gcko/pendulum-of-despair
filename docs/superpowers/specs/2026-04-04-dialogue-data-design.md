# Gap 1.8: Dialogue Data — Design Spec

> **Date:** 2026-04-04
> **Gap:** 1.8 (Dialogue Data)
> **Status:** Approved
> **Source docs:** script/ (8 content files, 6,531 lines), dialogue-system.md (7-field entry format), npcs.md (NPC dialogue assignments), events.md (flag names)
> **Architecture ref:** technical-architecture.md Section 2.5

## Tech-Arch / Dialogue-System Divergences

This spec extends and corrects the skeleton schemas in technical-architecture.md Section 2.5 and diverges from dialogue-system.md in several intentional ways:

**Entry ID format:** Tech-arch uses `{scene_prefix}_{NNN}`, dialogue-system.md uses freeform. This spec standardizes on `{scene_id}_{NNN}` (e.g., `act1_ember_vein_intro_001`) for machine-verifiability. Tech-arch and dialogue-system.md should be updated to match.

**File naming:** dialogue-system.md Section 4.6 uses "one file per location" for NPCs. This spec uses one file per NPC (`npc_{npc_id}.json`) for more granular runtime loading. Supersedes dialogue-system.md Section 4.6.

**Null vs omit:** dialogue-system.md says omit optional fields. This spec uses explicit `null` for all 7 fields on every entry (consistent with all gap 1.x JSON patterns). Simplifies validation and parsing.

**Speaker field:** Uses character/NPC IDs (snake_case), not display names. Runtime resolves display names via DataManager lookup. This matches tech-arch convention (IDs everywhere) rather than dialogue-system.md (display names).

**Animation `look_around`:** Tech-arch Section 2.5 example uses `look_around` which is not in the 14-animation catalog. The valid animations are: `jump`, `shake`, `turn_away`, `head_down`, `bubble_exclaim`, `bubble_ellipsis`, `bubble_question`, `sweat_drop`, `cry`, `red_tint`, `arms_up`, `collapse`, `nod`, `step_back`, plus `clear` (control command). Tech-arch should be updated.

## Problem

Dialogue data (~960 entries across ~99 JSON files) needs to be converted from structured markdown script files to runtime JSON. The script files use a regular format with HTML comment metadata, bold speaker names, bracketed animations/SFX, parenthetical conditions, and blockquote choices — all parseable by regex.

## Approach

Build a Python parser script that reads all 9 script files and outputs dialogue JSON. Uses heuristics for animation/SFX timing (70% automated), flags low-confidence entries for manual review. Iterative improvement over multiple passes.

## Scope

- Python parser script: `tools/dialogue_parser.py`
- ~99 dialogue JSON files in `game/data/dialogue/`
- Validation report: `tools/dialogue_validation_report.md`
- Source: `docs/story/script/` (all 9 files)
- Cross-references: events.md (flag names), characters.md (speaker IDs), dialogue-system.md (animation catalog)

**Excluded:**
- Runtime dialogue rendering → gap 3.5 (Dialogue Overlay)
- Runtime condition evaluation → gap 3.5
- Runtime choice/score tracking → gap 3.5

---

## Script Format Reference

The script files use structured markdown with machine-parseable patterns:

### Scene Metadata (HTML comments)
```markdown
<!-- Scene: scene_id | Tier: 1 | Trigger: flag_name -->
<!-- Location: Location Name | Party: edren, cael -->
```

### Speaker Pattern
```markdown
**EDREN** : Dialogue text here.
```

### Stage Directions (narration)
```markdown
*(Edren kneels beside the miner. Checks for a pulse.)*
```

### Animations
```markdown
*(Cael [head_down]. He turns away.)*
```
14 animation types per dialogue-system.md.

### SFX
```markdown
*(The needle twitches. [SFX: ley_surge])*
```

### Conditions
```markdown
(If `cael_betrayal_complete` set.)
(If `party_has(lira)`.)
```

### Choices
```markdown
> **Choice: "Option text"** → `score_name` +2
> **Choice: "Other option"** → `score_name` +0
```

---

## Output Schema

Per technical-architecture.md Section 2.5, one file per scene:

```json
{
  "scene_id": "act1_ember_vein_intro",
  "entries": [
    {
      "id": "act1_ember_vein_intro_001",
      "speaker": "edren",
      "lines": ["Hold."],
      "condition": null,
      "animations": [
        {"who": "edren", "anim": "kneel", "when": "after_line_0"}
      ],
      "choice": null,
      "sfx": null
    }
  ]
}
```

### Field Definitions — Dialogue Entry

| Field | Type | Notes |
|-------|------|-------|
| `id` | string | `{scene_id}_{NNN}` sequential. Unique across all files |
| `speaker` | string | Character ID (snake_case) or `""` for narration-only |
| `lines` | string[] | Array of text boxes. Each element = one text box (max 3 rendered lines per box) |
| `condition` | string/null | Flag expression: `"flag_name"`, `"score >= N"`, `"party_has(char)"`, AND combos. null = always shown |
| `animations` | array/null | `[{who, anim, when}]`. `when` = `before_line_N` or `after_line_N`. null = no animations |
| `choice` | array/null | `[{label, score_name, score_delta, flag_set}]`. null = no choice |
| `sfx` | array/null | `[{line, id}]`. `line` = index into lines array. null = no SFX |

### Field Definitions — Animation

| Field | Type | Notes |
|-------|------|-------|
| `who` | string | Character ID performing the animation |
| `anim` | string | One of 14 animation types from dialogue-system.md |
| `when` | string | `before_line_N` or `after_line_N` where N is index into lines array |

### Field Definitions — Choice Option

| Field | Type | Notes |
|-------|------|-------|
| `label` | string | Player-visible choice text |
| `score_name` | string/null | Score variable to modify. null for flag-only choices |
| `score_delta` | int | Score change (+2, +1, +0). 0 for neutral |
| `flag_set` | string/null | Binary flag to set on selection. null if no flag set |

### Field Definitions — SFX Trigger

| Field | Type | Notes |
|-------|------|-------|
| `line` | int | Index into lines array (0-based). SFX plays when this line begins rendering. |
| `id` | string | SFX ID from audio.md catalog |

---

## Parser Design

### Location

`tools/dialogue_parser.py` — Build tool, not shipped with game.

### Pipeline

```
script/*.md → Scene Splitter → Entry Segmenter → Field Extractor → Timing Heuristic → ID Generator → JSON Writer → Validator
```

### Stage 1: Scene Splitter

Split each script file by `### ` headers. Extract metadata from `<!-- Scene: ... -->` comments:
- `scene_id` from Scene field
- `tier` from Tier field
- `trigger` from Trigger field
- `location` from Location field
- `party` from Party field

Output: list of `{scene_id, metadata, raw_text}` objects.

### Stage 2: Entry Segmenter

Split scene raw_text into dialogue entries by `**SPEAKER** :` pattern:
- Each `**NAME** :` starts a new entry
- Text between speaker markers is captured as dialogue
- Stage directions `*(text)*` between entries are captured as narration/animation/SFX sources
- Blank lines and `---` dividers mark section boundaries

### Stage 3: Field Extractor

For each entry:
- **speaker**: Extract from `**NAME** :` → lowercase snake_case
- **lines**: Capture text after speaker marker until next marker/direction. Split into text boxes by paragraph breaks.
- **condition**: Extract from `(If `flag_name` set.)` or `(If `party_has(char)`.)` preceding the speaker line
- **animations**: Extract `[anim_id]` from stage directions. Identify `who` from context (speaker name in same direction, or current speaker)
- **sfx**: Extract `[SFX: sfx_id]` from stage directions
- **choice**: Extract `> **Choice: "text"** → `score_name` +N` blocks. Capture label, score_name, score_delta.

### Stage 4: Timing Heuristic

Animation/SFX timing assignment:
1. Stage direction **before** a speaker line → `before_line_0` for that entry
2. Stage direction **after** the last line of an entry (before next speaker) → `after_line_N` where N is last line index
3. Stage direction **between** two lines of the same entry → `after_line_N` of the preceding line
4. If ambiguous, default to `before_line_0` and flag for review

**Confidence levels:**
- HIGH: Animation in direction immediately before speaker → `before_line_0`
- HIGH: SFX in direction immediately after last speaker line → `after_line_N`
- MEDIUM: Animation mentions a different character than current speaker
- LOW: Multiple animations in one direction block → flag for review

### Stage 5: ID Generator

Format: `{scene_id}_{NNN}` where NNN is 3-digit zero-padded sequential number.
- `act1_ember_vein_intro_001`, `act1_ember_vein_intro_002`, etc.
- IDs must be globally unique across all output files.

### Stage 6: JSON Writer

Write one JSON file per scene to `game/data/dialogue/{scene_id}.json`.
- 2-space indentation per .editorconfig
- UTF-8 encoding
- Trailing newline

### Stage 7: Validator

Cross-reference checks:
1. Every speaker ID matches a valid character from characters.md or npcs.md
2. Every flag name in conditions matches events.md flag list
3. Every animation ID matches dialogue-system.md 14-animation catalog
4. Every SFX ID matches audio.md SFX catalog
5. Every choice has 2-4 options
6. Every choice option has at least one consequence (flag_set or score_name/score_delta non-null)
7. Every choice `flag_set` value matches events.md flag list
8. Every choice `score_name` value matches events.md score variables
9. All entry IDs unique globally
10. No empty lines arrays
11. `clear` accepted as valid animation value (control command)

Output: `tools/dialogue_validation_report.md` with:
- Total entries parsed
- Entries flagged for review (low-confidence timing)
- Cross-reference failures (unknown speakers, flags, animations, SFX)
- Statistics per layer (narrative, ambient, battle)

---

## Three Layers

### Layer 1: Narrative Spine (6 script files)

Source: `act-i.md`, `act-ii-part-1.md`, `act-ii-part-2.md`, `interlude.md`, `act-iii.md`, `act-iv-epilogue.md`

~44 scenes → ~44 JSON files, ~660 entries.

Features: Full complexity — choices, conditions, animations, SFX, branching, party-aware dialogue.

### Layer 2: NPC Ambient (1 script file)

Source: `npc-ambient.md`

~30 NPCs → ~30 JSON files (one per NPC), ~200 entries.

Features: Flag-priority stacks (latest flag wins), repeat interaction variants, no choices. Simpler parsing — each NPC section is independent.

File naming: `npc_{npc_id}.json` (e.g., `npc_bren.json`, `npc_aldis.json`)

### Layer 3: Battle Dialogue (1 script file)

Source: `battle-dialogue.md`

~25 boss/system contexts → ~25 JSON files, ~100 entries.

Features: Boss barks, phase transitions, system text (tutorials, prompts). Minimal branching. Trigger conditions tied to battle events.

File naming: `battle_{context_id}.json` (e.g., `battle_vein_guardian.json`, `battle_tutorial.json`)

---

## File Structure

| Category | Directory | Files | Naming |
|----------|-----------|-------|--------|
| Narrative scenes | `game/data/dialogue/` | ~44 | `{scene_id}.json` |
| NPC ambient | `game/data/dialogue/` | ~30 | `npc_{npc_id}.json` |
| Battle/system | `game/data/dialogue/` | ~25 | `battle_{context_id}.json` |
| Parser tool | `tools/` | 1 | `dialogue_parser.py` |
| Validation report | `tools/` | 1 | `dialogue_validation_report.md` |

---

## Cross-File Consistency Rules

1. Every `speaker` must be a valid character ID or NPC ID
2. Every flag in `condition` must exist in events.md
3. Every `anim` must be one of 14 types from dialogue-system.md
4. Every SFX `id` must match audio.md catalog
5. All entry `id` values globally unique
6. All entries have ALL 7 required fields (use null for inapplicable)
7. Choice arrays have 2-4 options each
8. scene_id in filename matches scene_id in JSON
9. 2-space JSON indentation per .editorconfig

## Verification Checklist

- [ ] Parser processes all 9 script files without errors
- [ ] Every scene in script files has a corresponding JSON file
- [ ] All ~960 entries have all 7 required fields
- [ ] All speaker IDs valid (characters.md + npcs.md)
- [ ] All flag names valid (events.md)
- [ ] All animation IDs valid (dialogue-system.md)
- [ ] All entry IDs globally unique
- [ ] Validation report generated with flagged items
- [ ] JSON files use 2-space indentation
- [ ] HARD GATE: Programmatic stale-count scan passes before commit

## DataManager Compatibility

`DataManager.load_dialogue(scene_id)` at line 96 of data_manager.gd loads `res://data/dialogue/{scene_id}.json`. Returns a Dictionary. The scene_id parameter matches the filename without .json extension.

## Iterative Improvement

- **Pass 1:** Parser generates all JSON with heuristic timing. Validation report flags low-confidence items.
- **Pass 2+:** Review flagged entries, improve timing, fill flag_set data. Re-run parser with manual overrides if needed.
- Parser is idempotent — same input produces same output.
- Future passes can refine timing heuristics based on patterns found during review.
