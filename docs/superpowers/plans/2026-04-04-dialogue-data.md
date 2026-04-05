# Gap 1.8: Dialogue Data — Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a Python parser that converts 8 structured markdown script files into ~99 runtime dialogue JSON files.

**Architecture:** Python parser script reads docs/story/script/*.md, extracts dialogue entries using regex patterns, applies heuristic timing for animations/SFX, outputs JSON to game/data/dialogue/. Validator cross-references speakers, flags, animations, and SFX against canonical docs.

**Tech Stack:** Python 3, regex, json stdlib. No external dependencies.

**Spec:** `docs/superpowers/specs/2026-04-04-dialogue-data-design.md`

---

## File Structure

| Action | File | Purpose |
|--------|------|---------|
| Create | `tools/dialogue_parser.py` | Main parser script |
| Create | `game/data/dialogue/*.json` | ~99 output dialogue JSON files |
| Create | `tools/dialogue_validation_report.md` | Generated validation report |
| Modify | `docs/analysis/game-dev-gaps.md` | Update gap 1.8 status |

---

## Chunk 1: Parser Core

### Task 1: Build the scene splitter and entry segmenter

**Files:**
- Create: `tools/dialogue_parser.py`
- Read: `docs/story/script/act-i.md` (test input)
- Read: `docs/superpowers/specs/2026-04-04-dialogue-data-design.md`

**Agent instructions:** Create the parser script with the core parsing pipeline. The script should be runnable standalone: `python3 tools/dialogue_parser.py`

The parser has 7 stages. This task implements stages 1-3 (scene splitting, entry segmenting, field extraction).

```python
#!/usr/bin/env python3
"""Dialogue parser: converts structured markdown scripts to JSON.

Reads docs/story/script/*.md and outputs game/data/dialogue/*.json.
Run: python3 tools/dialogue_parser.py
"""
import json
import os
import re
import sys
from pathlib import Path
```

STAGE 1 — Scene Splitter:
- Read each script file
- Split by `### ` headers (level-3 markdown headers)
- Extract metadata from `<!-- Scene: scene_id | Tier: N | Trigger: flag_name -->` HTML comments using regex
- Also extract `<!-- Location: ... | Party: ... -->` if present
- Output: list of `{scene_id, tier, trigger, location, party, raw_text}` dicts
- If no `<!-- Scene: -->` comment found, derive scene_id from the header text (slugify to snake_case)

STAGE 2 — Entry Segmenter:
- Split scene raw_text into entries by `**SPEAKER** :` pattern (regex: `\*\*([A-Z][A-Z_ ]+)\*\*\s*:`)
- Capture text between speaker markers as dialogue content
- Capture stage directions `*(text)*` between entries as narration blocks (regex: `\*\((.+?)\)\*` with DOTALL for multi-line)
- Track position of each element (speaker, dialogue, narration) for timing heuristic

STAGE 3 — Field Extractor:
For each entry extract:
- `speaker`: from `**NAME** :` → lowercase, replace spaces with underscore (e.g., `ELDER SAVANH` → `elder_savanh`)
- `lines`: text after speaker colon, split into array by paragraph breaks (double newline). Each element = one text box.
- `condition`: from `(If \`flag_name\` set.)` or `(If \`party_has(char)\`.)` appearing before the speaker line. Regex: `\(If\s+\`([^`]+)\`(?:\s+set)?\.\)`
- `animations`: from `[anim_id]` in stage directions (NOT `[SFX: ...]`). Regex: `\[([a-z_]+)\]` excluding SFX prefix. Extract `who` from nearby character name in the direction text, defaulting to current speaker.
- `sfx`: from `[SFX: sfx_id]` in stage directions. Regex: `\[SFX:\s*([a-z_]+)\]`
- `choice`: from blockquote lines `> **Choice: "text"** → \`score_name\` +N`. Regex: `>\s*\*\*Choice:\s*"(.+?)"\*\*\s*→\s*\`([^`]+)\`\s*\+(\d+)`

IMPORTANT RULES:
- Stage directions without `[bracket]` markers are narration only — they do NOT produce animation or SFX triggers
- Lines that are just stage directions (no speaker) should produce entries with `speaker: ""` (narration)
- Multi-line wrapped dialogue (no double-newline break) stays as one lines element
- Choice blocks: collect all consecutive `>` lines as one choice array

- [ ] **Step 1:** Create `tools/dialogue_parser.py` with stages 1-3
- [ ] **Step 2:** Test by running `python3 tools/dialogue_parser.py` — it should parse act-i.md and print scene count + entry count
- [ ] **Step 3:** Verify at least the first scene (Ember Vein intro) produces correct speaker/lines/condition extraction

---

### Task 2: Add timing heuristic, ID generator, and JSON writer

**Files:**
- Modify: `tools/dialogue_parser.py`

**Agent instructions:** Add stages 4-6 to the parser.

STAGE 4 — Timing Heuristic:
For each narration block between entries, assign timing:
- Narration block BEFORE a speaker entry → animations/SFX get `when: "before_line_0"` for that entry
- Narration block AFTER the last entry in a scene → animations/SFX get `when: "after_line_N"` for the preceding entry (N = last line index)
- If a narration block contains multiple animations, assign all to the same timing point
- Track confidence: HIGH if unambiguous position, LOW if multiple speakers mentioned or block is between entries with unclear ownership. Add `_low_confidence` flag to animation dict for the validator to report.

STAGE 5 — ID Generator:
- Format: `{scene_id}_{NNN}` where NNN is zero-padded 3-digit sequential
- Counter resets per scene
- Track all IDs in a global set to verify uniqueness

STAGE 6 — JSON Writer:
- Output one file per scene: `game/data/dialogue/{scene_id}.json`
- Schema per spec:
```json
{
  "scene_id": "act1_ember_vein_intro",
  "entries": [
    {
      "id": "act1_ember_vein_intro_001",
      "speaker": "edren",
      "lines": ["Hold."],
      "condition": null,
      "animations": null,
      "choice": null,
      "sfx": null
    }
  ]
}
```
- 2-space indentation, UTF-8, trailing newline
- Create output directory `game/data/dialogue/` if it doesn't exist
- All 7 fields required on every entry — use null for empty

NPC AMBIENT (Layer 2) special handling:
- Source: `npc-ambient.md`
- Split by `### NPC Name` headers
- Output: `npc_{npc_id}.json` (one file per NPC)
- Each NPC section has flag-priority entries — parse as separate entries with conditions

BATTLE DIALOGUE (Layer 3) special handling:
- Source: `battle-dialogue.md`
- Split by `### Boss/Context Name` headers
- Output: `battle_{context_id}.json`
- Simpler parsing — mostly speaker + lines + conditions

- [ ] **Step 1:** Add stages 4-6 to the parser
- [ ] **Step 2:** Run parser: `python3 tools/dialogue_parser.py`
- [ ] **Step 3:** Verify JSON output exists in `game/data/dialogue/`
- [ ] **Step 4:** Spot-check 3 files: first narrative scene, first NPC, first battle context
- [ ] **Step 5:** Verify all 7 fields present on every entry, 2-space indent, valid JSON

---

## Chunk 2: Validator and Execution

### Task 3: Build the validator

**Files:**
- Modify: `tools/dialogue_parser.py` (add validator as stage 7)

**Agent instructions:** Add the validation stage that cross-references all output against canonical docs.

STAGE 7 — Validator:
Load reference data:
- Valid character IDs from `game/data/characters/*.json` (6 files, extract `id` field)
- Valid NPC IDs from `docs/story/npcs.md` (extract NPC names, slugify to snake_case)
- Valid flag names from `docs/story/events.md` (extract all flag names)
- Valid animation IDs: hardcoded list of 15 (`jump`, `shake`, `turn_away`, `head_down`, `bubble_exclaim`, `bubble_ellipsis`, `bubble_question`, `sweat_drop`, `cry`, `red_tint`, `arms_up`, `collapse`, `nod`, `step_back`, `clear`)
- Valid SFX IDs from `docs/story/audio.md` (extract SFX catalog)

Validation checks:
1. Every `speaker` is a valid character ID or NPC ID (or `""` for narration)
2. Every flag in `condition` exists in events.md
3. Every `anim` value is in the 15-animation list
4. Every SFX `id` matches audio.md catalog
5. Every choice has 2-4 options
6. Every choice option has at least one consequence (flag_set or score_name non-null)
7. Every choice `flag_set` exists in events.md
8. Every choice `score_name` exists in events.md score variables
9. All entry IDs globally unique
10. No empty `lines` arrays
11. scene_id in filename matches scene_id in JSON

Output: `tools/dialogue_validation_report.md` with sections:
- Summary: total files, total entries, entries per layer
- Low-confidence timing flags (entries where heuristic was uncertain)
- Cross-reference failures (unknown speakers, flags, animations, SFX)
- Choice validation issues
- Statistics

- [ ] **Step 1:** Add validator stage to parser
- [ ] **Step 2:** Run full parser + validator: `python3 tools/dialogue_parser.py`
- [ ] **Step 3:** Review validation report — expect some warnings (unknown NPC IDs, unused flags)
- [ ] **Step 4:** Fix any ERRORS (broken JSON, missing required fields)

---

### Task 4: Run parser and generate all dialogue files

**Files:**
- Create: `game/data/dialogue/*.json` (~99 files)
- Create: `tools/dialogue_validation_report.md`

**Agent instructions:** Execute the parser against all 8 script files and produce the full output.

- [ ] **Step 1:** Run `python3 tools/dialogue_parser.py` from project root
- [ ] **Step 2:** Count output files: `ls game/data/dialogue/*.json | wc -l`
- [ ] **Step 3:** Count total entries across all files:
```python
import json, glob
total = sum(len(json.load(open(f))["entries"]) for f in glob.glob("game/data/dialogue/*.json"))
print(f"Total entries: {total}")
```
- [ ] **Step 4:** Review `tools/dialogue_validation_report.md` for critical issues
- [ ] **Step 5:** Fix any critical validation failures (broken cross-references that indicate parser bugs)

---

## Chunk 3: Verification and Completion

### Task 5: Adversarial verification pass

- [ ] **Step 1:** Spot-check 5 narrative scenes against source script — verify speaker names, dialogue text, conditions match exactly
- [ ] **Step 2:** Spot-check 3 NPC ambient files against npc-ambient.md — verify flag-priority ordering
- [ ] **Step 3:** Spot-check 2 battle dialogue files against battle-dialogue.md
- [ ] **Step 4:** Verify all scene_ids in filenames match scene_ids inside the JSON
- [ ] **Step 5:** Verify all entry IDs are globally unique:
```python
import json, glob
ids = []
for f in glob.glob("game/data/dialogue/*.json"):
    ids.extend(e["id"] for e in json.load(open(f))["entries"])
dupes = [x for x in ids if ids.count(x) > 1]
print(f"Total IDs: {len(ids)}, Duplicates: {len(set(dupes))}")
```

### Task 6: HARD GATE — Programmatic stale-count scan

- [ ] **Step 1:** Count actual output files and entries
- [ ] **Step 2:** Scan spec for count claims — verify matches actual
- [ ] **Step 3:** Scan plan for count claims — verify matches actual
- [ ] **Step 4:** If ANY stale count found: fix ALL instances before proceeding
- [ ] **Step 5:** Re-scan to confirm zero stale counts

### Task 7: Update gap tracker and commit

- [ ] **Step 1:** Update gap 1.8 status to COMPLETE in game-dev-gaps.md
- [ ] **Step 2:** Check off all completed items in "What's Needed" list
- [ ] **Step 3:** Note downstream gaps now unblocked:
  - 1.8 unblocks: 2.2 (NPC Prefab), 3.5 (Dialogue Overlay), 3.7 (Cutscene Overlay)
- [ ] **Step 4:** Stage and commit all files:

```bash
git add tools/dialogue_parser.py tools/dialogue_validation_report.md game/data/dialogue/ docs/analysis/game-dev-gaps.md docs/superpowers/specs/2026-04-04-dialogue-data-design.md docs/superpowers/plans/2026-04-04-dialogue-data.md
git commit -m "feat(engine): add dialogue data parser and JSON files (gap 1.8)"
```

- [ ] **Step 5:** Push and hand off to `/create-pr` → `/godot-review-loop`
