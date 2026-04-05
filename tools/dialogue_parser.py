#!/usr/bin/env python3
"""Dialogue parser: converts structured markdown scripts to JSON.

Reads docs/story/script/*.md and outputs game/data/dialogue/*.json.
Run: python3 tools/dialogue_parser.py
"""
import json
import re
from pathlib import Path

# Project root (one level up from tools/)
PROJECT_ROOT = Path(__file__).resolve().parent.parent
SCRIPT_DIR = PROJECT_ROOT / "docs" / "story" / "script"
OUTPUT_DIR = PROJECT_ROOT / "game" / "data" / "dialogue"
CHARACTERS_DIR = PROJECT_ROOT / "game" / "data" / "characters"
EVENTS_FILE = PROJECT_ROOT / "docs" / "story" / "events.md"
NPCS_FILE = PROJECT_ROOT / "docs" / "story" / "npcs.md"
AUDIO_FILE = PROJECT_ROOT / "docs" / "story" / "audio.md"

# Narrative spine files (Layer 1)
NARRATIVE_FILES = [
    "act-i.md",
    "act-ii-part-1.md",
    "act-ii-part-2.md",
    "interlude.md",
    "act-iii.md",
    "act-iv-epilogue.md",
]

# Layer 2
NPC_AMBIENT_FILE = "npc-ambient.md"

# Layer 3
BATTLE_FILE = "battle-dialogue.md"

# Valid animation IDs (14 + 1 control)
VALID_ANIMATIONS = {
    "jump", "shake", "turn_away", "head_down",
    "bubble_exclaim", "bubble_ellipsis", "bubble_question",
    "sweat_drop", "cry", "red_tint", "arms_up",
    "collapse", "nod", "step_back", "clear",
}

# Tracking
all_entry_ids = set()
all_warnings = []
stats = {"files": 0, "entries": 0, "warnings": 0, "layer1": 0, "layer2": 0, "layer3": 0}


def slugify(text):
    """Convert text to snake_case ID."""
    text = text.strip().lower()
    # Remove parenthetical content
    text = re.sub(r'\(.*?\)', '', text)
    # Remove special characters except spaces and hyphens
    text = re.sub(r'[^a-z0-9\s\-]', '', text)
    # Replace spaces and hyphens with underscores
    text = re.sub(r'[\s\-]+', '_', text)
    # Strip trailing/leading underscores
    text = text.strip('_')
    return text


def speaker_to_id(name):
    """Convert SPEAKER NAME to snake_case id."""
    name = name.strip().lower()
    name = re.sub(r"[''']", "", name)
    name = re.sub(r'\s+', '_', name)
    return name


# ─────────────────────────────────────────────────────────────
# STAGE 1: Scene Splitter
# ─────────────────────────────────────────────────────────────

def split_scenes_narrative(filepath):
    """Split a narrative script file into scenes by ## Scene headers.

    Each ## Scene header (with its <!-- Scene: --> metadata) becomes one
    output file.  All ### sub-scene text is concatenated under its parent
    ## Scene.  If a ## header has no <!-- Scene: --> comment we still
    collect its content — the scene_id is derived from the header text.
    """
    text = filepath.read_text(encoding="utf-8")
    scenes = []

    # --- pass 1: split file into ## blocks --------------------------------
    lines = text.split('\n')
    h2_blocks = []          # list of (header_line, body_lines)
    current_header = None
    current_body = []

    for line in lines:
        if re.match(r'^## ', line) and not re.match(r'^### ', line):
            if current_header is not None:
                h2_blocks.append((current_header, '\n'.join(current_body)))
            current_header = line
            current_body = []
        else:
            current_body.append(line)

    if current_header is not None:
        h2_blocks.append((current_header, '\n'.join(current_body)))

    # --- pass 2: for each ## block, extract metadata & build scene --------
    for header_line, body in h2_blocks:
        header_text = header_line.replace('## ', '').strip()

        # Skip decorative headers (e.g., ## **PENDULUM OF DESPAIR**)
        if header_text.startswith('**'):
            continue

        # Combine header preamble + all ### sub-scene text as one raw_text
        # The body already contains everything between this ## and the next
        raw_text = body

        # Extract metadata from preamble (before first ###)
        meta = extract_scene_metadata(raw_text)
        scene_id = meta.get("scene_id")
        if not scene_id:
            scene_id = slugify(header_text)

        # Must have some dialogue or narration content
        if not re.search(r'\*\*[A-Z]', raw_text) and not re.search(r'\*\(', raw_text):
            continue

        scenes.append({
            "scene_id": scene_id,
            "tier": meta.get("tier"),
            "trigger": meta.get("trigger"),
            "location": meta.get("location"),
            "party": meta.get("party"),
            "raw_text": raw_text,
            "header": header_text,
        })

    return scenes


def extract_scene_metadata(text):
    """Extract metadata from HTML comments in text."""
    meta = {"scene_id": None, "tier": None, "trigger": None, "location": None, "party": None}

    # <!-- Scene: scene_id | Tier: N | Trigger: flag_name -->
    scene_match = re.search(
        r'<!--\s*Scene:\s*(\S+)\s*\|\s*Tier:\s*(\d+)\s*\|\s*Trigger:\s*(.+?)\s*-->',
        text
    )
    if scene_match:
        meta["scene_id"] = scene_match.group(1).strip()
        meta["tier"] = int(scene_match.group(2))
        meta["trigger"] = scene_match.group(3).strip()

    # <!-- Location: ... | Party: ... -->
    loc_match = re.search(
        r'<!--\s*Location:\s*(.+?)\s*\|\s*Party:\s*(.+?)\s*-->',
        text
    )
    if loc_match:
        meta["location"] = loc_match.group(1).strip()
        meta["party"] = loc_match.group(2).strip()

    return meta


def split_scenes_npc(filepath):
    """Split NPC ambient file into per-NPC scenes."""
    text = filepath.read_text(encoding="utf-8")
    scenes = []

    # Split by ### headers
    lines = text.split('\n')
    current_header = None
    current_text = []
    current_location = None

    for line in lines:
        if line.startswith('## ') and not line.startswith('### '):
            # Location header
            current_location = line.replace('## ', '').strip()
            # Skip special headers
            if current_location.startswith('---'):
                current_location = None
            continue
        if line.startswith('### '):
            # Save previous NPC
            if current_header is not None and current_text:
                raw = '\n'.join(current_text)
                if re.search(r'\*\*[A-Z]', raw):
                    npc_name, npc_info = parse_npc_header(current_header)
                    npc_id = slugify(npc_name)
                    scenes.append({
                        "scene_id": f"npc_{npc_id}",
                        "npc_name": npc_name,
                        "npc_info": npc_info,
                        "location": current_location,
                        "raw_text": raw,
                        "header": current_header.replace('### ', '').strip(),
                    })
            current_header = line
            current_text = []
        elif current_header is not None:
            current_text.append(line)

    # Save last NPC
    if current_header is not None and current_text:
        raw = '\n'.join(current_text)
        if re.search(r'\*\*[A-Z]', raw):
            npc_name, npc_info = parse_npc_header(current_header)
            npc_id = slugify(npc_name)
            scenes.append({
                "scene_id": f"npc_{npc_id}",
                "npc_name": npc_name,
                "npc_info": npc_info,
                "location": current_location,
                "raw_text": raw,
                "header": current_header.replace('### ', '').strip(),
            })

    return scenes


def parse_npc_header(header_line):
    """Parse '### NPC Name (Location, Role)' or '### NPC Name — Description'."""
    text = header_line.replace('### ', '').strip()
    # Try: Name (Info)
    m = re.match(r'^([^(—–\-]+?)(?:\s*[\(](.+?)[\)])?(?:\s*[—–\-]\s*(.+))?$', text)
    if m:
        name = m.group(1).strip()
        info = m.group(2) or m.group(3) or ""
        return name, info.strip()
    return text, ""


def split_scenes_battle(filepath):
    """Split battle dialogue file into per-boss/context scenes."""
    text = filepath.read_text(encoding="utf-8")
    scenes = []

    lines = text.split('\n')
    current_h3_header = None
    current_h4_header = None
    current_text = []
    h3_texts = []

    # Battle file uses ### for boss categories and #### for phases
    # We want one output file per #### subsection OR per ### if no ####
    # Actually, looking at the structure: ### for top-level boss names, #### for phases
    # We want one file per ### (boss context) with all #### phases as entries

    for line in lines:
        if line.startswith('### ') and not line.startswith('#### '):
            # Save previous
            if current_h3_header is not None and current_text:
                h3_texts.append((current_h3_header, '\n'.join(current_text)))
            current_h3_header = line
            current_text = []
        elif current_h3_header is not None:
            current_text.append(line)

    # Save last
    if current_h3_header is not None and current_text:
        h3_texts.append((current_h3_header, '\n'.join(current_text)))

    for header, raw_text in h3_texts:
        header_text = header.replace('### ', '').strip()

        # Skip pure section headers like "Act I Bosses"
        if re.match(r'^Act\s+[IVX]+\s+', header_text) and 'Boss' in header_text:
            # This is a category header, not a boss
            # But it may contain #### sub-bosses — split them out
            h4_parts = re.split(r'^(#### .+)$', raw_text, flags=re.MULTILINE)
            i = 1
            while i < len(h4_parts):
                h4_header = h4_parts[i].replace('#### ', '').strip()
                h4_text = h4_parts[i + 1] if i + 1 < len(h4_parts) else ""
                boss_id = slugify(h4_header)
                scenes.append({
                    "scene_id": f"battle_{boss_id}",
                    "raw_text": h4_text,
                    "header": h4_header,
                })
                i += 2
            continue

        # Check for #### subheaders — if present, this is a multi-phase boss
        # Combine all content under one scene
        boss_id = slugify(header_text)
        if not raw_text.strip():
            continue

        scenes.append({
            "scene_id": f"battle_{boss_id}",
            "raw_text": raw_text,
            "header": header_text,
        })

    return scenes


# ─────────────────────────────────────────────────────────────
# STAGE 2: Entry Segmenter
# ─────────────────────────────────────────────────────────────

def segment_entries(raw_text):
    """Split scene text into dialogue entries and stage directions."""
    elements = []
    lines = raw_text.split('\n')
    i = 0

    while i < len(lines):
        line = lines[i]

        # Skip HTML comments, blank lines, ---
        if re.match(r'^\s*<!--', line) or re.match(r'^\s*$', line) or re.match(r'^\s*---\s*$', line):
            i += 1
            continue

        # BUG 1 FIX: Skip script navigation markers (e.g., *Continue: [link](file)*)
        if re.match(r'^\s*\*Continue:', line) or re.match(r'^\s*\*Dialogue script continues', line):
            i += 1
            continue
        # Skip markdown navigation link blocks (e.g., [README](README.md) | [NPC Ambient]...)
        if re.match(r'^\s*\[.+?\]\(.+?\.md\)', line):
            i += 1
            continue
        # Skip lines containing doc references (e.g., "See [accessibility.md](...)")
        if re.search(r'\[.+?\.md\]\(.+?\)', line):
            i += 1
            continue
        # Skip pure italic markdown links: *[text](file.md)*
        if re.match(r'^\s*\*\[.+?\]\(.+?\)\*\s*$', line):
            i += 1
            continue

        # Skip cross-ref comments that span multiple lines
        if '<!--' in line and '-->' not in line:
            while i < len(lines) and '-->' not in lines[i]:
                i += 1
            i += 1
            continue

        # Choice block
        if re.match(r'^\s*>\s*\*\*Choice:', line):
            choice_lines = []
            while i < len(lines) and (re.match(r'^\s*>', lines[i]) or re.match(r'^\s*$', lines[i])):
                if lines[i].strip():
                    choice_lines.append(lines[i])
                i += 1
            elements.append({"type": "choice", "text": '\n'.join(choice_lines)})
            continue

        # "If spoken to again/third time" pattern — MUST be checked before
        # generic stage direction, since both match ^\s*\*\(
        if re.match(r'^\s*\*\(If spoken to', line):
            elements.append({"type": "repeat_marker", "text": line.strip()})
            i += 1
            continue

        # Stage direction: *(text)*
        if re.match(r'^\s*\*\(', line):
            direction_text = line
            # Multi-line stage direction
            while not direction_text.rstrip().endswith(')*') and i + 1 < len(lines):
                i += 1
                direction_text += '\n' + lines[i]
            elements.append({"type": "direction", "text": direction_text})
            i += 1
            continue

        # Condition line: (If `flag` set.) or (If `flag` NOT set.)
        condition_match = re.match(r'^\s*\(If\s+[`\']([^`\']+)[`\']\s*(NOT\s+)?(?:set)?\.?\)\s*$', line)
        if condition_match:
            flag = condition_match.group(1)
            negated = condition_match.group(2) is not None
            cond_text = f"{flag}_not_set" if negated else flag
            elements.append({"type": "condition", "text": cond_text})
            i += 1
            continue

        # Condition line with numeric comparison: (If `var` >= 2.) etc.
        score_cond_match = re.match(
            r'^\s*\(If\s+`([^`]+)`\s*(>=|<=|==|!=|>|<)\s*(\d+)\.\)\s*$', line
        )
        if score_cond_match:
            var_name = score_cond_match.group(1)
            operator = score_cond_match.group(2)
            value = score_cond_match.group(3)
            elements.append({"type": "condition", "text": f"{var_name} {operator} {value}"})
            i += 1
            continue

        # Branch annotation: (If CHARACTER verb phrase.) → slugified condition
        branch_annot_match = re.match(
            r'^\s*\((?:If\s+)?(.+?)\s*\.?\)\s*$', line
        )
        if branch_annot_match and re.match(r'^\s*\(If\s+[A-Z]', line) and not re.match(r'^\s*\(If\s+`', line) and not re.match(r'^\s*\(If\s+player\s+', line):
            # e.g., "(If Edren reaches him first.)" → "edren_reaches_first"
            # "(Default — Edren and party arrive together.)" handled below
            inner = branch_annot_match.group(1).strip()
            # Strip leading "If "
            inner = re.sub(r'^If\s+', '', inner)
            cond_slug = slugify(inner)
            if cond_slug:
                elements.append({"type": "condition", "text": cond_slug})
                i += 1
                continue

        # Default branch annotation: (Default — description)
        default_annot_match = re.match(r'^\s*\(Default\b', line)
        if default_annot_match:
            elements.append({"type": "condition", "text": "default_arrival"})
            i += 1
            continue

        # Condition-like lines: (If player chose option N.)
        if re.match(r'^\s*\(If\s+player\s+', line):
            elements.append({"type": "meta_condition", "text": line.strip()})
            i += 1
            continue

        # Speaker line: **NAME** : text
        speaker_match = re.match(r'^\s*\*\*([A-Z][A-Z_ \']+?)\*\*\s*:\s*(.*)', line)
        if speaker_match:
            speaker = speaker_match.group(1).strip()
            dialogue_text = speaker_match.group(2).strip()

            # Collect continuation lines
            while i + 1 < len(lines):
                next_line = lines[i + 1]
                # Stop at: new speaker, direction, choice, condition, blank line before speaker/direction, ---
                if (re.match(r'^\s*\*\*[A-Z]', next_line) or
                    re.match(r'^\s*\*\(', next_line) or
                    re.match(r'^\s*>\s*\*\*Choice:', next_line) or
                    re.match(r'^\s*\(If\s+', next_line) or
                    re.match(r'^\s*---', next_line) or
                    re.match(r'^\s*##', next_line) or
                    re.match(r'^\s*$', next_line)):
                    break
                i += 1
                dialogue_text += '\n' + next_line.strip()

            elements.append({"type": "speaker", "speaker": speaker, "text": dialogue_text})
            i += 1
            continue

        # Narration without stage direction markers (battle dialogue has plain text narration)
        if line.strip() and not line.startswith('#') and not line.startswith('>'):
            narration_text = line
            while i + 1 < len(lines):
                next_line = lines[i + 1]
                if (re.match(r'^\s*\*\*[A-Z]', next_line) or
                    re.match(r'^\s*\*\(', next_line) or
                    re.match(r'^\s*>', next_line) or
                    re.match(r'^\s*\(If\s+', next_line) or
                    re.match(r'^\s*---', next_line) or
                    re.match(r'^\s*##', next_line) or
                    re.match(r'^\s*$', next_line)):
                    break
                i += 1
                narration_text += '\n' + next_line.strip()
            elements.append({"type": "narration", "text": narration_text.strip()})
            i += 1
            continue

        i += 1

    return elements


# ─────────────────────────────────────────────────────────────
# STAGE 3: Field Extractor
# ─────────────────────────────────────────────────────────────

def extract_animations_from_direction(text, default_speaker=""):
    """Extract [anim_id] from stage direction text (not [SFX:...])."""
    animations = []
    # Find character names mentioned in direction
    # Pattern: Name [anim]
    # e.g., "Cael [head_down]", "Edren [bubble_exclaim]"

    # Find all animation references
    anim_pattern = re.finditer(r'\[([a-z_]+)\]', text)
    for m in anim_pattern:
        anim_id = m.group(1)
        # Skip SFX references (they start with [SFX:)
        before = text[:m.start()]
        if before.rstrip().endswith('SFX:') or 'SFX:' in text[max(0, m.start()-5):m.start()]:
            continue

        if anim_id not in VALID_ANIMATIONS and anim_id.upper() != anim_id:
            # Skip non-animation brackets
            continue

        # Try to find who performs the animation
        # Look for a capitalized name before the bracket
        who_match = re.search(r'([A-Z][a-z]+)\s*\[' + re.escape(anim_id) + r'\]', text)
        if who_match:
            who = speaker_to_id(who_match.group(1))
        else:
            who = default_speaker

        animations.append({"who": who, "anim": anim_id, "when": None})

    return animations


def extract_sfx_from_direction(text):
    """Extract [SFX: sfx_id] from stage direction text."""
    sfx_list = []
    for m in re.finditer(r'\[SFX:\s*([a-z_]+)\]', text):
        sfx_list.append({"line": 0, "id": m.group(1)})
    return sfx_list


def extract_choices(text):
    """Extract choice options from choice block text."""
    choices = []
    # Pattern: > **Choice: "text"** -> `score_name` +N
    # Some choices span multiple lines; the → may be on the next > line
    # Allow \n> between ** and → to handle line wrapping
    choice_pattern = re.finditer(
        r'>\s*\*\*Choice:\s*"(.+?)"\*\*\s*(?:\n>\s*)?(?:→|->)\s*`([^`]+)`\s*\+(\d+)'
        r'(?:\s*\(([^)]+)\))?',
        text, re.DOTALL
    )
    for m in choice_pattern:
        label = m.group(1).strip()
        # Clean up multi-line labels
        label = re.sub(r'\s*\n>\s*', ' ', label)
        score_name = m.group(2).strip()
        score_delta = int(m.group(3))
        extra = m.group(4)

        choice = {
            "label": label,
            "score_name": score_name,
            "score_delta": score_delta,
            "flag_set": None,
        }
        if extra and 'bonus' not in extra.lower():
            choice["flag_set"] = extra.strip()

        choices.append(choice)

    return choices if choices else None


def build_entries_from_elements(elements, scene_id, layer="narrative"):
    """Convert segmented elements into dialogue entries."""
    entries = []
    pending_condition = None
    parent_flag_condition = None  # Tracks the current flag block for NPC ambient
    pending_animations = []
    pending_sfx = []
    pending_direction_before = True  # Track if direction is before next speaker

    i = 0
    while i < len(elements):
        elem = elements[i]

        if elem["type"] == "condition":
            pending_condition = elem["text"]
            # Update parent flag condition — new flag block replaces the old one
            parent_flag_condition = elem["text"]
            i += 1
            continue

        if elem["type"] == "meta_condition":
            # BUG 2 FIX: Translate meta-conditions to flag-based strings
            raw = elem["text"]
            # "(If player chose option N.)" → "choice_N_selected"
            opt_match = re.search(r'chose\s+option\s+(\d+)', raw)
            if opt_match:
                pending_condition = f"choice_{opt_match.group(1)}_selected"
            else:
                # "(If player consulted X ...)" → "consulted_x_slug"
                consult_match = re.search(r'consulted\s+(.+?)(?:\s+before|\s*[.)]\s*$)', raw)
                if consult_match:
                    pending_condition = "consulted_" + slugify(consult_match.group(1))
                else:
                    # Fallback: slugify the whole condition
                    pending_condition = slugify(raw)
            parent_flag_condition = pending_condition
            i += 1
            continue

        if elem["type"] == "repeat_marker":
            # "*(If spoken to again.)*" inherits the parent flag condition.
            # It means "same condition block, repeat visit" — NOT a new condition.
            pending_condition = parent_flag_condition
            i += 1
            continue

        if elem["type"] == "direction":
            # Extract animations and SFX from the direction
            anims = extract_animations_from_direction(elem["text"])
            sfx = extract_sfx_from_direction(elem["text"])

            if anims or sfx:
                # Look ahead: if next element is a speaker, these are "before_line_0"
                # If previous element was a speaker, these are "after_line_N"
                next_is_speaker = (i + 1 < len(elements) and elements[i + 1]["type"] == "speaker")

                if next_is_speaker:
                    pending_animations.extend(anims)
                    pending_sfx.extend(sfx)
                elif entries:
                    # Attach to last entry as after_line_N
                    last_entry = entries[-1]
                    last_line_idx = max(0, len(last_entry["lines"]) - 1)
                    for a in anims:
                        a["when"] = f"after_line_{last_line_idx}"
                    if last_entry["animations"] is None:
                        last_entry["animations"] = []
                    last_entry["animations"].extend(anims)
                    for s in sfx:
                        s["line"] = last_line_idx
                    if last_entry["sfx"] is None:
                        last_entry["sfx"] = []
                    last_entry["sfx"].extend(sfx)
                else:
                    pending_animations.extend(anims)
                    pending_sfx.extend(sfx)
            i += 1
            continue

        if elem["type"] == "narration":
            # Plain narration (common in battle dialogue)
            # Create a narration entry
            text = elem["text"].strip()
            if text:
                entry = {
                    "id": None,  # Assigned later
                    "speaker": "",
                    "lines": [text],
                    "condition": pending_condition,
                    "animations": None,
                    "choice": None,
                    "sfx": None,
                }
                entries.append(entry)
                # For NPC layer, persist the parent flag condition so all
                # entries within a flag block inherit it. For other layers,
                # conditions apply only to the immediately following entry.
                if layer == "npc":
                    pending_condition = parent_flag_condition
                else:
                    pending_condition = None
            i += 1
            continue

        if elem["type"] == "speaker":
            speaker = speaker_to_id(elem["speaker"])
            text = elem["text"].strip()

            # Split text into lines (paragraph breaks = double newline)
            if '\n\n' in text:
                lines = [l.strip() for l in text.split('\n\n') if l.strip()]
            else:
                lines = [text] if text else []

            # Build entry
            entry = {
                "id": None,  # Assigned later
                "speaker": speaker,
                "lines": lines,
                "condition": pending_condition,
                "animations": None,
                "choice": None,
                "sfx": None,
            }

            # Apply pending animations (before_line_0)
            if pending_animations:
                for a in pending_animations:
                    a["when"] = "before_line_0"
                    if not a["who"]:
                        a["who"] = speaker
                entry["animations"] = list(pending_animations)
                pending_animations = []

            # Apply pending SFX
            if pending_sfx:
                for s in pending_sfx:
                    s["line"] = 0
                entry["sfx"] = list(pending_sfx)
                pending_sfx = []

            entries.append(entry)
            # For NPC layer, persist the parent flag condition so all
            # entries within a flag block inherit it. For other layers,
            # conditions apply only to the immediately following entry.
            if layer == "npc":
                pending_condition = parent_flag_condition
            else:
                pending_condition = None
            i += 1
            continue

        if elem["type"] == "choice":
            choices = extract_choices(elem["text"])
            if choices and entries:
                # Attach choices to the last speaker entry
                entries[-1]["choice"] = choices
            i += 1
            continue

        i += 1

    # Post-processing pass: catch score-comparison conditions embedded in dialogue lines.
    # These appear as lines like "(If `council_result` >= 2.)" that were not on their
    # own line and thus got absorbed into a speaker's text or narration.
    _score_cond_re = re.compile(r'\(If\s+`([^`]+)`\s*(>=|<=|==|!=|>|<)\s*(\d+)\.\)')
    _flag_cond_re = re.compile(r'\(If\s+`([^`]+)`\s*(NOT\s+)?(?:set)?\.?\)')
    cleaned_entries = []
    for entry in entries:
        new_lines = []
        extracted_condition = None
        for line_text in entry["lines"]:
            # Check if the entire line is a score condition
            score_m = _score_cond_re.fullmatch(line_text.strip())
            if score_m:
                extracted_condition = f"{score_m.group(1)} {score_m.group(2)} {score_m.group(3)}"
                continue
            # Check if the entire line is a flag condition
            flag_m = _flag_cond_re.fullmatch(line_text.strip())
            if flag_m:
                flag = flag_m.group(1)
                negated = flag_m.group(2) is not None
                extracted_condition = f"{flag}_not_set" if negated else flag
                continue
            # Check for inline condition at start/end of line and strip it
            cleaned = _score_cond_re.sub('', line_text).strip()
            cleaned = _flag_cond_re.sub('', cleaned).strip()
            if cleaned:
                new_lines.append(cleaned)
            elif line_text.strip():
                # Line was entirely a condition pattern — extract it
                score_m2 = _score_cond_re.search(line_text)
                if score_m2:
                    extracted_condition = f"{score_m2.group(1)} {score_m2.group(2)} {score_m2.group(3)}"
                else:
                    flag_m2 = _flag_cond_re.search(line_text)
                    if flag_m2:
                        flag = flag_m2.group(1)
                        negated = flag_m2.group(2) is not None
                        extracted_condition = f"{flag}_not_set" if negated else flag
        if extracted_condition:
            # Apply the extracted condition to the NEXT entry (or current if it has no condition)
            if new_lines:
                # Condition was mixed into this entry's lines — keep the cleaned lines
                entry["lines"] = new_lines
                # The condition applies to the next entry; stash it
                cleaned_entries.append(entry)
                # Create a synthetic condition carrier for the next entry
                cleaned_entries.append({"_pending_condition": extracted_condition})
            else:
                # All lines were the condition — this entry IS the condition for the next one
                cleaned_entries.append({"_pending_condition": extracted_condition})
        else:
            if new_lines:
                entry["lines"] = new_lines
            cleaned_entries.append(entry)

    # Rebuild entries applying any pending conditions
    final_entries = []
    pending_cond_from_post = None
    for item in cleaned_entries:
        if "_pending_condition" in item:
            pending_cond_from_post = item["_pending_condition"]
            continue
        if pending_cond_from_post and not item.get("condition"):
            item["condition"] = pending_cond_from_post
        pending_cond_from_post = None
        final_entries.append(item)
    entries = final_entries

    # Apply any remaining pending animations/sfx to last entry
    if (pending_animations or pending_sfx) and entries:
        last_entry = entries[-1]
        last_line_idx = max(0, len(last_entry["lines"]) - 1) if last_entry["lines"] else 0
        for a in pending_animations:
            a["when"] = f"after_line_{last_line_idx}"
        if pending_animations:
            if last_entry["animations"] is None:
                last_entry["animations"] = []
            last_entry["animations"].extend(pending_animations)
        for s in pending_sfx:
            s["line"] = last_line_idx
        if pending_sfx:
            if last_entry["sfx"] is None:
                last_entry["sfx"] = []
            last_entry["sfx"].extend(pending_sfx)

    return entries


# ─────────────────────────────────────────────────────────────
# STAGE 4: Timing Heuristic (handled inline in Stage 3)
# ─────────────────────────────────────────────────────────────
# Timing is assigned during build_entries_from_elements:
# - Directions before speakers → before_line_0
# - Directions after speakers → after_line_N


# ─────────────────────────────────────────────────────────────
# STAGE 5: ID Generator
# ─────────────────────────────────────────────────────────────

def assign_ids(entries, scene_id):
    """Assign unique IDs to entries: {scene_id}_{NNN}."""
    global all_entry_ids
    # BUG 5 FIX: Clear any stale IDs from a prior pass with the same scene_id
    # (e.g., NPC appearing twice in the ambient file — second write overwrites first)
    prefix = f"{scene_id}_"
    all_entry_ids = {eid for eid in all_entry_ids if not eid.startswith(prefix)}
    counter = 1
    for entry in entries:
        entry_id = f"{scene_id}_{counter:03d}"
        # Ensure global uniqueness
        while entry_id in all_entry_ids:
            counter += 1
            entry_id = f"{scene_id}_{counter:03d}"
        all_entry_ids.add(entry_id)
        entry["id"] = entry_id
        counter += 1


# ─────────────────────────────────────────────────────────────
# STAGE 6: JSON Writer
# ─────────────────────────────────────────────────────────────

def split_lines_on_newlines(lines):
    """Split any lines element containing embedded newlines into separate elements.

    Per dialogue-system.md Section 4.1, each element in "lines" should be
    ONE text box. Multi-paragraph text must be split into separate elements.
    """
    result = []
    for line in lines:
        parts = line.split('\n')
        for part in parts:
            stripped = part.strip()
            if stripped:
                result.append(stripped)
    return result if result else [""]


def deduplicate_animations(animations):
    """Remove exact duplicate animation entries (same who/anim/when)."""
    if not animations:
        return animations
    seen = set()
    result = []
    for a in animations:
        key = (a.get("who", ""), a.get("anim", ""), a.get("when", ""))
        if key not in seen:
            seen.add(key)
            result.append(a)
    return result if result else None


def normalize_condition(condition):
    """Normalize condition strings.

    - Convert 'X_is_in_the_party' → 'party_has(x)'
    - Decompose compound placeholders with '_and_' into AND conditions
    - Normalize battle ability triggers to shorter snake_case
    """
    if not condition:
        return condition

    # Battle ability trigger normalization (FIX 10-13)
    battle_ability_map = {
        "edren_uses_steadfast_resolve_during_the_fight": "battle_edren_steadfast_resolve",
        "lira_uses_a_healing_ability_on_the_party": "battle_lira_heal",
        "torren_uses_rootsong": "battle_torren_rootsong",
        "maren_uses_pallor_sight": "battle_maren_pallor_sight",
    }
    if condition in battle_ability_map:
        return battle_ability_map[condition]

    # FIX 6: Convert 'X_is_in_the_party' → 'party_has(x)'
    party_match = re.match(r'^([a-z_]+)_is_in_the_party$', condition)
    if party_match:
        char_name = party_match.group(1)
        return f"party_has({char_name})"

    # FIX 7-9: Decompose compound placeholders with '_and_'
    # Pattern: X_is_not_first_reunion_and_Yfound_set
    compound_match = re.match(
        r'^([a-z]+)_is_not_first_reunion_and_([a-z]+)found_set$', condition
    )
    if compound_match:
        char = compound_match.group(1)
        other = compound_match.group(2)
        return f"{char}_not_first_reunion AND {other}_found"

    return condition


def clean_entry(entry):
    """Ensure all 7 fields present, clean up internal tracking."""
    raw_lines = entry["lines"] if entry["lines"] else [""]
    # Normalize condition (FIX 6, 7-9, 10-13)
    condition = normalize_condition(entry.get("condition"))
    # Deduplicate animations (FIX 4-5)
    animations = deduplicate_animations(entry.get("animations")) if entry.get("animations") else None
    return {
        "id": entry["id"],
        "speaker": entry["speaker"],
        "lines": split_lines_on_newlines(raw_lines),
        "condition": condition,
        "animations": animations,
        "choice": entry.get("choice") if entry.get("choice") else None,
        "sfx": entry.get("sfx") if entry.get("sfx") else None,
    }


def clean_animation(anim):
    """Remove internal tracking from animation dict."""
    return {
        "who": anim["who"],
        "anim": anim["anim"],
        "when": anim["when"] or "before_line_0",
    }


def write_scene_json(scene_id, entries):
    """Write one JSON file per scene."""
    global stats

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    cleaned_entries = []
    for entry in entries:
        ce = clean_entry(entry)
        if ce["animations"]:
            ce["animations"] = [clean_animation(a) for a in ce["animations"]]
        cleaned_entries.append(ce)

    data = {
        "scene_id": scene_id,
        "entries": cleaned_entries,
    }

    filepath = OUTPUT_DIR / f"{scene_id}.json"
    filepath.write_text(
        json.dumps(data, indent=2, ensure_ascii=False) + '\n',
        encoding="utf-8",
    )

    stats["files"] += 1
    stats["entries"] += len(cleaned_entries)
    return len(cleaned_entries)


# ─────────────────────────────────────────────────────────────
# STAGE 7: Validator
# ─────────────────────────────────────────────────────────────

def load_valid_character_ids():
    """Load character IDs from game/data/characters/*.json."""
    ids = set()
    if CHARACTERS_DIR.exists():
        for f in CHARACTERS_DIR.glob("*.json"):
            try:
                data = json.loads(f.read_text(encoding="utf-8"))
                if "id" in data:
                    ids.add(data["id"])
            except Exception:
                pass
    return ids


def load_valid_npc_ids():
    """Load NPC names from docs/story/npcs.md and slugify."""
    ids = set()
    if NPCS_FILE.exists():
        text = NPCS_FILE.read_text(encoding="utf-8")
        for m in re.finditer(r'^### (.+?)$', text, re.MULTILINE):
            name = m.group(1).strip()
            # Remove parenthetical
            name = re.sub(r'\s*\(.*?\)', '', name)
            # Remove trailing description after dash
            name = re.sub(r'\s*[—–\-].+', '', name)
            npc_id = slugify(name)
            ids.add(npc_id)
    return ids


def load_valid_flags():
    """Load flag names from docs/story/events.md."""
    flags = set()
    if EVENTS_FILE.exists():
        text = EVENTS_FILE.read_text(encoding="utf-8")
        for m in re.finditer(r'`([a-z][a-z0-9_]*)`', text):
            flags.add(m.group(1))
    return flags


def load_valid_sfx_ids():
    """Load SFX IDs from docs/story/audio.md."""
    ids = set()
    if AUDIO_FILE.exists():
        text = AUDIO_FILE.read_text(encoding="utf-8")
        # Look for SFX IDs in backtick format
        for m in re.finditer(r'`([a-z_]+)`', text):
            ids.add(m.group(1))
    return ids


def validate_all():
    """Run validation on all generated JSON files."""
    global all_warnings

    valid_chars = load_valid_character_ids()
    valid_npcs = load_valid_npc_ids()
    valid_flags = load_valid_flags()
    valid_sfx = load_valid_sfx_ids()
    all_speakers = valid_chars | valid_npcs

    # Add first-name and short-name variants from NPC full names
    npc_short_names = set()
    for npc_id in valid_npcs:
        parts = npc_id.split('_')
        # Add each part as a potential short name (e.g., "brant" from "commissar_aldric_brant")
        for part in parts:
            if len(part) > 2:  # skip very short tokens
                npc_short_names.add(part)
        # Also add last-two tokens (e.g., "elyn_drayce")
        if len(parts) >= 2:
            npc_short_names.add('_'.join(parts[-2:]))

    all_speakers |= npc_short_names

    # Also add common speaker aliases used in scripts
    speaker_aliases = {
        "king_aldren", "elder_savanh", "grandmother_seyth",
        "dame_cordwyn", "scholar_aldis", "lord_chancellor_haren",
        "captain_isen", "sergeant_marek", "spirit_speaker_caden",
        "forgemaster_elyn_drayce", "lieutenant_ansa_veld",
        "commissar_brant", "general_vassar_kole",
        # Short NPC names used as speakers
        "caden", "elder_thessa",
        # Battle-specific speakers (bosses, trial entities)
        "machine", "perfect_machine", "last_voice", "index",
        "crowned_hollow", "iron_warden", "crystal_queen",
        "rootking", "first_scholar", "caels_echo", "shadow",
        # Generic/role speakers
        "villager", "shopkeeper", "innkeeper", "herbalist",
        "gate_guard", "forgewright", "oasis_vendor", "nessa",
        "younger_maren", "archivist",
    }
    all_speakers |= speaker_aliases

    unknown_speakers = set()
    unknown_flags = set()
    placeholder_flags = set()  # Parser-generated placeholders
    battle_trigger_flags = set()  # Battle-event triggers (gap 3.3)
    unknown_anims = set()
    unknown_sfx = set()
    empty_lines = []
    duplicate_ids = []
    choice_issues = []
    id_set = set()

    report_lines = ["# Dialogue Validation Report\n"]
    report_lines.append(f"Generated by dialogue_parser.py\n")
    report_lines.append("---\n")

    files = sorted(OUTPUT_DIR.glob("*.json"))
    total_entries = 0
    layer1_entries = 0
    layer2_entries = 0
    layer3_entries = 0

    for filepath in files:
        try:
            data = json.loads(filepath.read_text(encoding="utf-8"))
        except Exception as e:
            all_warnings.append(f"ERROR: Cannot parse {filepath.name}: {e}")
            continue

        scene_id = data.get("scene_id", "")
        entries = data.get("entries", [])
        total_entries += len(entries)

        # Categorize by layer
        if filepath.name.startswith("npc_"):
            layer2_entries += len(entries)
        elif filepath.name.startswith("battle_"):
            layer3_entries += len(entries)
        else:
            layer1_entries += len(entries)

        # Check scene_id matches filename
        expected_name = f"{scene_id}.json"
        if filepath.name != expected_name:
            all_warnings.append(f"WARNING: Filename {filepath.name} != scene_id {scene_id}")

        for entry in entries:
            eid = entry.get("id", "")
            speaker = entry.get("speaker", "")
            lines_arr = entry.get("lines", [])
            condition = entry.get("condition")
            animations = entry.get("animations")
            choice = entry.get("choice")
            sfx = entry.get("sfx")

            # Check ID uniqueness
            if eid in id_set:
                duplicate_ids.append(eid)
            id_set.add(eid)

            # Check speaker
            if speaker and speaker not in all_speakers:
                unknown_speakers.add(speaker)

            # Check empty lines
            if not lines_arr or all(not l.strip() for l in lines_arr):
                empty_lines.append(eid)

            # Check condition flags
            if condition and condition not in ("spoken_to_again",):
                skip_words = {
                    "set", "if", "player", "chose", "option",
                    "consulted", "grandmother", "seyth", "before",
                    "this", "meeting", "spoken", "to", "again",
                    "a", "third", "time", "has", "party",
                    # Boolean/comparison operators
                    "not", "and", "or", "not_set",
                }
                # Known battle-event trigger prefixes (gap 3.3)
                battle_triggers = {
                    "battle_edren_steadfast_resolve",
                    "battle_lira_heal",
                    "battle_torren_rootsong",
                    "battle_maren_pallor_sight",
                }
                # Known parser-generated placeholders
                placeholder_prefixes = (
                    "choice_", "default_", "consulted_",
                )
                # Suffixes that indicate parser-generated branch conditions
                placeholder_suffixes = (
                    "_reaches_him_first", "_reaches_her_first",
                    "_not_found", "_not_set", "_not_first_reunion",
                )
                # Skip meta-conditions (player choice references, etc.)
                if condition.startswith("(If player") or condition.startswith("If player"):
                    pass
                # Numeric comparison conditions (e.g., "council_result >= 2")
                # Validate the variable name portion, skip comparison syntax
                elif re.match(r'^[a-z][a-z0-9_]*\s*(>=|<=|==|!=|>|<)\s*\w+$', condition):
                    var_name = re.match(r'^([a-z][a-z0-9_]*)', condition).group(1)
                    if var_name not in valid_flags and var_name not in skip_words:
                        if any(var_name.startswith(p) for p in placeholder_prefixes):
                            placeholder_flags.add(var_name)
                        elif var_name.startswith("battle_"):
                            battle_trigger_flags.add(var_name)
                        else:
                            unknown_flags.add(var_name)
                else:
                    # Extract actual flag names — handle party_has(X) as a
                    # known function, not a flag
                    cond_clean = re.sub(r'party_has\([^)]+\)', '', condition)
                    flag_names = re.findall(r'[a-z][a-z0-9_]+', cond_clean)
                    # Compound conditions use AND — check each part
                    if " AND " in condition:
                        parts = condition.split(" AND ")
                        for part in parts:
                            part = part.strip()
                            # reunion_order != X is a compound placeholder
                            if part.startswith("reunion_order"):
                                placeholder_flags.add(part)
                            else:
                                part_flags = re.findall(r'[a-z][a-z0-9_]+', part)
                                for fn in part_flags:
                                    if fn not in valid_flags and fn not in skip_words:
                                        placeholder_flags.add(fn)
                    elif condition in battle_triggers:
                        battle_trigger_flags.add(condition)
                    else:
                        for fn in flag_names:
                            if fn not in valid_flags and fn not in skip_words:
                                if any(fn.startswith(p) for p in placeholder_prefixes):
                                    placeholder_flags.add(fn)
                                elif any(fn.endswith(s) for s in placeholder_suffixes):
                                    placeholder_flags.add(fn)
                                elif fn.startswith("battle_"):
                                    battle_trigger_flags.add(fn)
                                else:
                                    unknown_flags.add(fn)

            # Check animations
            if animations:
                for anim in animations:
                    if anim.get("anim") not in VALID_ANIMATIONS:
                        unknown_anims.add(anim.get("anim", "?"))
                    who = anim.get("who", "")
                    if who and who not in valid_speakers and who != "":
                        unknown_speakers.add(who)

            # Check SFX
            if sfx:
                for s in sfx:
                    if s.get("id") and s["id"] not in valid_sfx:
                        unknown_sfx.add(s["id"])

            # Check choices
            if choice:
                # BUG 4 FIX: Single-option choices are valid (bonus/conditional)
                if len(choice) < 1 or len(choice) > 4:
                    choice_issues.append(f"{eid}: {len(choice)} options (need 1-4)")

    # Build report
    report_lines.append("## Summary\n")
    report_lines.append(f"- **Total files:** {len(files)}")
    report_lines.append(f"- **Total entries:** {total_entries}")
    report_lines.append(f"- **Layer 1 (Narrative):** {layer1_entries} entries")
    report_lines.append(f"- **Layer 2 (NPC Ambient):** {layer2_entries} entries")
    report_lines.append(f"- **Layer 3 (Battle):** {layer3_entries} entries")
    report_lines.append("")

    report_lines.append("## Cross-Reference Issues\n")

    if unknown_speakers:
        report_lines.append(f"### Unknown Speakers ({len(unknown_speakers)})\n")
        for s in sorted(unknown_speakers):
            report_lines.append(f"- `{s}`")
        report_lines.append("")

    if unknown_flags:
        report_lines.append(f"### Unknown Flags ({len(unknown_flags)})\n")
        for f in sorted(unknown_flags):
            report_lines.append(f"- `{f}`")
        report_lines.append("")

    if placeholder_flags:
        report_lines.append(f"### Parser-Generated Placeholders ({len(placeholder_flags)})\n")
        report_lines.append("These conditions are auto-generated by the parser and require")
        report_lines.append("runtime implementation (choice branching, reunion ordering, etc.).\n")
        for f in sorted(placeholder_flags):
            report_lines.append(f"- `{f}`")
        report_lines.append("")

    if battle_trigger_flags:
        report_lines.append(f"### Battle-Event Triggers ({len(battle_trigger_flags)})\n")
        report_lines.append("These conditions are intentional battle-event triggers documented")
        report_lines.append("in battle-dialogue.md. They will be set by the battle system (gap 3.3).\n")
        for f in sorted(battle_trigger_flags):
            report_lines.append(f"- `{f}`")
        report_lines.append("")

    if unknown_anims:
        report_lines.append(f"### Unknown Animations ({len(unknown_anims)})\n")
        for a in sorted(unknown_anims):
            report_lines.append(f"- `{a}`")
        report_lines.append("")

    if unknown_sfx:
        report_lines.append(f"### Unknown SFX ({len(unknown_sfx)})\n")
        for s in sorted(unknown_sfx):
            report_lines.append(f"- `{s}`")
        report_lines.append("")

    report_lines.append("## Structural Issues\n")

    if duplicate_ids:
        report_lines.append(f"### Duplicate IDs ({len(duplicate_ids)})\n")
        for d in duplicate_ids:
            report_lines.append(f"- `{d}`")
        report_lines.append("")

    if empty_lines:
        report_lines.append(f"### Empty Lines Arrays ({len(empty_lines)})\n")
        for e in empty_lines:
            report_lines.append(f"- `{e}`")
        report_lines.append("")

    if choice_issues:
        report_lines.append(f"### Choice Issues ({len(choice_issues)})\n")
        for c in choice_issues:
            report_lines.append(f"- {c}")
        report_lines.append("")

    if all_warnings:
        report_lines.append("## Warnings\n")
        for w in all_warnings:
            report_lines.append(f"- {w}")
        report_lines.append("")

    if not unknown_speakers and not unknown_flags and not unknown_anims and not unknown_sfx and not duplicate_ids and not empty_lines and not choice_issues:
        if placeholder_flags or battle_trigger_flags:
            report_lines.append("No critical issues found. Parser-generated placeholders and battle-event triggers listed above require runtime implementation.\n")
        else:
            report_lines.append("No critical issues found.\n")

    report_path = PROJECT_ROOT / "tools" / "dialogue_validation_report.md"
    report_path.write_text('\n'.join(report_lines) + '\n', encoding="utf-8")

    return {
        "total_files": len(files),
        "total_entries": total_entries,
        "layer1": layer1_entries,
        "layer2": layer2_entries,
        "layer3": layer3_entries,
        "unknown_speakers": len(unknown_speakers),
        "unknown_flags": len(unknown_flags),
        "unknown_anims": len(unknown_anims),
        "unknown_sfx": len(unknown_sfx),
        "duplicate_ids": len(duplicate_ids),
        "choice_issues": len(choice_issues),
    }


# ─────────────────────────────────────────────────────────────
# MAIN: Pipeline orchestration
# ─────────────────────────────────────────────────────────────

def process_narrative_files():
    """Process Layer 1: Narrative spine files."""
    total_scenes = 0
    total_entries = 0

    for filename in NARRATIVE_FILES:
        filepath = SCRIPT_DIR / filename
        if not filepath.exists():
            print(f"  WARNING: {filename} not found, skipping")
            all_warnings.append(f"File not found: {filename}")
            continue

        scenes = split_scenes_narrative(filepath)
        print(f"  Processing {filename}... {len(scenes)} scenes found")

        for scene in scenes:
            elements = segment_entries(scene["raw_text"])
            entries = build_entries_from_elements(elements, scene["scene_id"], "narrative")

            if not entries:
                continue

            assign_ids(entries, scene["scene_id"])
            n = write_scene_json(scene["scene_id"], entries)
            total_entries += n
            stats["layer1"] += n

        total_scenes += len(scenes)

    return total_scenes, total_entries


def process_npc_file():
    """Process Layer 2: NPC Ambient dialogue."""
    filepath = SCRIPT_DIR / NPC_AMBIENT_FILE
    if not filepath.exists():
        print(f"  WARNING: {NPC_AMBIENT_FILE} not found, skipping")
        all_warnings.append(f"File not found: {NPC_AMBIENT_FILE}")
        return 0, 0

    scenes = split_scenes_npc(filepath)
    print(f"  Processing {NPC_AMBIENT_FILE}... {len(scenes)} NPCs found")

    total_entries = 0
    for scene in scenes:
        elements = segment_entries(scene["raw_text"])
        entries = build_entries_from_elements(elements, scene["scene_id"], "npc")

        if not entries:
            continue

        assign_ids(entries, scene["scene_id"])
        n = write_scene_json(scene["scene_id"], entries)
        total_entries += n
        stats["layer2"] += n

    return len(scenes), total_entries


def process_battle_file():
    """Process Layer 3: Battle dialogue."""
    filepath = SCRIPT_DIR / BATTLE_FILE
    if not filepath.exists():
        print(f"  WARNING: {BATTLE_FILE} not found, skipping")
        all_warnings.append(f"File not found: {BATTLE_FILE}")
        return 0, 0

    scenes = split_scenes_battle(filepath)
    print(f"  Processing {BATTLE_FILE}... {len(scenes)} contexts found")

    total_entries = 0
    for scene in scenes:
        elements = segment_entries(scene["raw_text"])
        entries = build_entries_from_elements(elements, scene["scene_id"], "battle")

        if not entries:
            continue

        assign_ids(entries, scene["scene_id"])
        n = write_scene_json(scene["scene_id"], entries)
        total_entries += n
        stats["layer3"] += n

    return len(scenes), total_entries


def postprocess_system_text_files():
    """Post-process battle system text files that need manual splitting.

    The source markdown has bullet-list blobs that the parser treats as single
    narration entries. These need to be split into individual entries for the
    game runtime.
    """
    # battle_save_system: split markdown blob into individual system messages
    save_sys_path = OUTPUT_DIR / "battle_save_system.json"
    if save_sys_path.exists():
        save_messages = [
            "Rest / Rest & Save / Save",
            "No rest items. Recover 25% MP.",
            "Overwrite existing save?",
            "Saved.",
            "\u2014 Empty \u2014",
            "Select a save file.",
            "Copy to which slot?",
            "Delete this save?",
        ]
        entries = []
        for idx, msg in enumerate(save_messages, 1):
            entries.append({
                "id": f"battle_save_system_{idx:03d}",
                "speaker": "",
                "lines": [msg],
                "condition": None,
                "animations": None,
                "choice": None,
                "sfx": None,
            })
        data = {"scene_id": "battle_save_system", "entries": entries}
        save_sys_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + '\n',
            encoding="utf-8",
        )

    # battle_status_effect_notifications: split into individual notifications
    status_path = OUTPUT_DIR / "battle_status_effect_notifications.json"
    if status_path.exists():
        notifications = [
            "[Character] is Poisoned!",
            "[Character] is Silenced!",
            "[Character] is Frozen!",
            "[Character] fell Asleep!",
            "[Character] is Confused!",
            "[Character] is Blinded!",
            "[Character] is Slowed!",
            "[Character] is Burning!",
            "[Character] is afflicted with Despair!",
            "[Character] is Berserk!",
            "[Character] is Stopped!",
            "[Character] is Grounded!",
            "Poison wears off.",
            "Silence wears off.",
            "[Character] woke up!",
            "[Status] was cured!",
        ]
        entries = []
        for idx, msg in enumerate(notifications, 1):
            entries.append({
                "id": f"battle_status_effect_notifications_{idx:03d}",
                "speaker": "",
                "lines": [msg],
                "condition": None,
                "animations": None,
                "choice": None,
                "sfx": None,
            })
        data = {"scene_id": "battle_status_effect_notifications", "entries": entries}
        status_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + '\n',
            encoding="utf-8",
        )

    # battle_transport_prompts: clean markdown formatting to player-facing text
    transport_path = OUTPUT_DIR / "battle_transport_prompts.json"
    if transport_path.exists():
        entries = [{
            "id": "battle_transport_prompts_001",
            "speaker": "",
            "lines": [
                "[Destination] — [Cost]g",
                "Bellhaven — Ashport: 200g",
            ],
            "condition": None,
            "animations": None,
            "choice": None,
            "sfx": None,
        }]
        data = {"scene_id": "battle_transport_prompts", "entries": entries}
        transport_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + '\n',
            encoding="utf-8",
        )

    # battle_shop_prompts: clean markdown formatting to player-facing text
    shop_path = OUTPUT_DIR / "battle_shop_prompts.json"
    if shop_path.exists():
        entries = [{
            "id": "battle_shop_prompts_001",
            "speaker": "",
            "lines": [
                "Buy | Sell | Exit",
                "[E]",
            ],
            "condition": None,
            "animations": None,
            "choice": None,
            "sfx": None,
        }]
        data = {"scene_id": "battle_shop_prompts", "entries": entries}
        shop_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + '\n',
            encoding="utf-8",
        )

    # battle_element_notifications: clean markdown formatting to player-facing text
    elem_path = OUTPUT_DIR / "battle_element_notifications.json"
    if elem_path.exists():
        entries = [{
            "id": "battle_element_notifications_001",
            "speaker": "",
            "lines": [
                "Weakness!",
                "Resist!",
                "Immune!",
                "Absorb!",
            ],
            "condition": None,
            "animations": None,
            "choice": None,
            "sfx": None,
        }]
        data = {"scene_id": "battle_element_notifications", "entries": entries}
        elem_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + '\n',
            encoding="utf-8",
        )

    # battle_escape: clean markdown formatting to player-facing text
    escape_path = OUTPUT_DIR / "battle_escape.json"
    if escape_path.exists():
        entries = [{
            "id": "battle_escape_001",
            "speaker": "",
            "lines": [
                "Escaped!",
                "Can't escape!",
            ],
            "condition": None,
            "animations": None,
            "choice": None,
            "sfx": None,
        }]
        data = {"scene_id": "battle_escape", "entries": entries}
        escape_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + '\n',
            encoding="utf-8",
        )

    # battle_party_wipe: clean markdown formatting to player-facing text
    wipe_path = OUTPUT_DIR / "battle_party_wipe.json"
    if wipe_path.exists():
        entries = [{
            "id": "battle_party_wipe_001",
            "speaker": "",
            "lines": [
                "The world grows quiet.",
            ],
            "condition": None,
            "animations": None,
            "choice": None,
            "sfx": None,
        }]
        data = {"scene_id": "battle_party_wipe", "entries": entries}
        wipe_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + '\n',
            encoding="utf-8",
        )

    # battle_sfx_captions: clean content and ensure contiguous IDs
    sfx_path = OUTPUT_DIR / "battle_sfx_captions.json"
    if sfx_path.exists():
        sfx_entries = [
            {
                "id": "battle_sfx_captions_001",
                "speaker": "",
                "lines": [
                    "When SFX Captions are enabled in Config, these text labels appear",
                    "briefly in the lower corner of the screen.",
                ],
                "condition": None,
                "animations": None,
                "choice": None,
                "sfx": None,
            },
            {
                "id": "battle_sfx_captions_002",
                "speaker": "",
                "lines": [
                    "[Save Point]",
                    "[Encounter]",
                    "[Level Up]",
                    "[Victory]",
                    "[Item]",
                    "[Quest Complete]",
                    "[Phase Change]",
                    "[Alert]",
                ],
                "condition": None,
                "animations": None,
                "choice": None,
                "sfx": None,
            },
            {
                "id": "battle_sfx_captions_003",
                "speaker": "",
                "lines": [
                    "The battle speaks through its voices — bosses who believe in",
                    "what they're doing, a party that refuses to stop, and a world",
                    "that communicates through status notifications and the quiet",
                    "rhythm of \"Saved.\"",
                ],
                "condition": None,
                "animations": None,
                "choice": None,
                "sfx": None,
            },
        ]
        data = {"scene_id": "battle_sfx_captions", "entries": sfx_entries}
        sfx_path.write_text(
            json.dumps(data, indent=2, ensure_ascii=False) + '\n',
            encoding="utf-8",
        )


if __name__ == "__main__":
    print("=" * 60)
    print("Dialogue Parser — Pendulum of Despair")
    print("=" * 60)
    print()

    # Reset global mutable state
    all_entry_ids.clear()
    all_warnings.clear()
    stats.clear()
    stats.update({"files": 0, "entries": 0, "warnings": 0, "layer1": 0, "layer2": 0, "layer3": 0})

    # Ensure output directory exists
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Clean output directory to prevent stale files from previous runs
    for old_file in OUTPUT_DIR.glob("*.json"):
        old_file.unlink()


    # Layer 1: Narrative
    print("[Layer 1] Narrative Spine")
    n_scenes, n_entries = process_narrative_files()
    print(f"  → {n_scenes} scenes, {n_entries} entries\n")

    # Layer 2: NPC Ambient
    print("[Layer 2] NPC Ambient Dialogue")
    n_npcs, n_npc_entries = process_npc_file()
    print(f"  → {n_npcs} NPCs, {n_npc_entries} entries\n")

    # Layer 3: Battle
    print("[Layer 3] Battle Dialogue")
    n_battles, n_battle_entries = process_battle_file()
    print(f"  → {n_battles} contexts, {n_battle_entries} entries\n")

    # Post-process system text files (split blobs, fix IDs)
    print("[Post-process] Fixing system text files...")
    postprocess_system_text_files()
    print("  → Done\n")

    # Validation
    print("[Validation] Cross-referencing all output...")
    v = validate_all()
    print(f"  → Validated {v['total_files']} files, {v['total_entries']} entries")
    if v["unknown_speakers"]:
        print(f"  → {v['unknown_speakers']} unknown speakers")
    if v["unknown_flags"]:
        print(f"  → {v['unknown_flags']} unknown flags")
    if v["unknown_anims"]:
        print(f"  → {v['unknown_anims']} unknown animations")
    if v["duplicate_ids"]:
        print(f"  → {v['duplicate_ids']} duplicate IDs")
    print(f"  → Report: tools/dialogue_validation_report.md")
    print()

    # Summary
    print("=" * 60)
    total_files = stats["files"]
    total_entries = stats["entries"]
    total_warnings = len(all_warnings)
    print(f"Total: {total_files} files, {total_entries} entries, {total_warnings} warnings")
    print(f"  Layer 1 (Narrative): {stats['layer1']} entries")
    print(f"  Layer 2 (NPC):       {stats['layer2']} entries")
    print(f"  Layer 3 (Battle):    {stats['layer3']} entries")
    print("=" * 60)
