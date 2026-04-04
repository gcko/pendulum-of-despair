---
name: godot-review-loop
description: Use when a Godot code PR needs multiple rounds of automated review and fix cycles. Dispatches 3 specialized agents per round targeting GDScript quality, scene architecture, and design doc compliance. Fixes issues, commits, and repeats N times. Pushes once at the end. Invoke with PR number and optional round count.
---

# Godot Review Loop

Multi-round automated review loop for Godot project PRs. Dispatches
3 specialized agents per round, fixes issues, and repeats until clean
or N rounds complete. Mirrors the story-review-loop-cope architecture
adapted for GDScript, scenes, and game data.

## Invocation

```
/godot-review-loop <PR number> <N>
```

Default N=3. Same pattern as `/story-review-loop-cope`.

## Process

```dot
digraph godot_review {
    rankdir=TB;
    node [shape=box, style=filled, fillcolor=lightblue];

    setup [label="1. SETUP\nGet changed files\nRead checklists", fillcolor="#e6f3ff"];

    subgraph cluster_agents {
        label="3 Godot Review Agents (parallel)";
        style=dashed;
        a1 [label="Agent A: CODE QUALITY\nType safety\nStyle guide\nAntipatterns\nPerformance", fillcolor="#ccffcc"];
        a2 [label="Agent B: ARCHITECTURE\nScene composition\nSignal flow\nState machine\nAutoload usage", fillcolor="#ffffcc"];
        a3 [label="Agent C: DATA + RENDERING\nPixel art settings\nJSON integrity\nDesign doc compliance\nAudio rules", fillcolor="#ffcccc"];
    }

    merge [label="Merge + deduplicate\nClassify severity", fillcolor="#fff3e6"];
    clean [label="All clean?", shape=diamond, fillcolor="#fff3e6"];
    fix [label="Fix issues\n+ propagation sweep", fillcolor="#ccffcc"];
    commit [label="Commit locally", fillcolor="#e6ffe6"];
    count [label="Round < N?", shape=diamond, fillcolor="#fff3e6"];
    push [label="Push + post summary", fillcolor="#ffe6f3"];

    setup -> a1;
    setup -> a2;
    setup -> a3;
    a1 -> merge;
    a2 -> merge;
    a3 -> merge;
    merge -> clean;
    clean -> fix [label="issues"];
    clean -> push [label="clean"];
    fix -> commit;
    commit -> count;
    count -> a1 [label="yes"];
    count -> a2 [label="yes"];
    count -> a3 [label="yes"];
    count -> push [label="no"];
}
```

## Agent Prompts

### Agent A: Code Quality + Performance

```
You are reviewing Godot 4.6 GDScript code for a pixel art JRPG.
Find every code quality issue.

Focus on:
1. **Static typing** -- every parameter, return type, and variable
   must have type hints. No bare `var x = value`.
2. **Style guide** -- 17-item script ordering, naming conventions
   (snake_case functions, PascalCase classes, UPPER_SNAKE constants).
3. **Antipatterns** -- get_parent(), uncached $Node in _process(),
   find_child() in hot paths, null where typed default works,
   monolithic scripts >300 lines.
4. **Performance** -- load() in _process(), unnecessary _process()
   on idle nodes, String concatenation in loops, entity/emitter
   counts exceeding budget (64 entities, 16 emitters).

Read the verification checklists at
.claude/skills/godot-review/references/verification-checklists.md
Section 1 (GDScript Code Quality) and Section 6 (Performance).

Changed files: [LIST]
Report every issue with file:line and specific discrepancy.
Work from: [PROJECT_ROOT]
```

### Agent B: Architecture + State Machine

```
You are reviewing Godot 4.6 scene architecture for a pixel art JRPG.
Find every architecture violation.

Focus on:
1. **Signal architecture** -- "call down, signal up". No child
   referencing parent. Signals have typed parameters.
2. **Scene composition** -- each scene has one responsibility.
   Reusable behaviors are separate instanced scenes. No scene
   depends on parent structure.
3. **State machine** -- all core transitions via
   GameManager.change_core_state(). Overlays via push_overlay()
   with return check. Only one overlay at a time. Cutscene can
   override dialogue.
4. **Autoload usage** -- data via DataManager, audio via
   AudioManager, flags via EventFlags, saves via SaveManager.
   No direct file I/O in entity scripts. No custom flag dicts.

Read the verification checklists at
.claude/skills/godot-review/references/verification-checklists.md
Section 2 (Scene Architecture) and Section 7 (Project-Specific).

Changed files: [LIST]
Report every issue with file:line and specific discrepancy.
Work from: [PROJECT_ROOT]
```

### Agent C: Data Integrity + Rendering + Design Docs

```
You are reviewing Godot 4.6 game data and rendering settings for
a pixel art JRPG at 320x180 resolution. Find every data error
and rendering misconfiguration.

Focus on:
1. **Pixel art rendering** -- viewport 320x180, integer scaling,
   nearest-neighbor filter, snap-to-pixel on transforms and
   vertices. No sub-pixel positions. No fractional camera zoom.
   Sprite sizes match spec (16x24 character, 16x16 tile).
2. **JSON data integrity** -- snake_case keys, values match
   canonical source docs in docs/story/. Valid JSON syntax.
   Correct data/ subdirectory per technical-architecture.md.
3. **Design doc compliance** -- combat mechanics match
   combat-formulas.md, UI matches ui-design.md, save behavior
   matches save-system.md, audio matches audio.md, accessibility
   matches accessibility.md.
4. **Audio rules** -- channel budget 24 (8/12/4), priority stack,
   mixing model per context, SFX IDs match audio.md catalog.

Read the verification checklists at
.claude/skills/godot-review/references/verification-checklists.md
Sections 3 (Pixel Art), 4 (Data), 5 (Audio), 7 (Design Docs).

Changed files: [LIST]

EXPANDING FILE CHECK: [See expanding file rule below]
Report every issue with file:line and specific discrepancy.
Work from: [PROJECT_ROOT]
```

## The Expanding File Rule (CRITICAL)

Same rule as story-review-loop-cope — adapted for Godot files.

**Never declare CLEAN without reading unexplored files.**

Each round must include at least ONE agent that reads files NO
previous round has checked. Track which files have been read.

**Round 1 agents typically check:** changed .gd files, changed
.tscn files, changed .json files, project.godot

**Round 2+ agents must EXPAND to:**
- Other .gd scripts that import/reference changed scripts
- Autoload singletons if any game logic changed
- JSON data files that feed into changed game logic
- Design docs that define the behavior being implemented
- Adjacent scenes that interact with changed scenes

**What to look for in unexplored files:**
- Signal connections that reference changed functions
- Data loading that expects fields added/removed in this PR
- Autoload methods called with wrong parameters
- Scene instancing that expects nodes added/removed in this PR

## After Each Round

1. **Merge** findings from all 3 agents. Deduplicate.
2. **Fix** all BLOCKERs and ISSUEs. Skip SUGGESTIONs unless trivial.
3. **Propagation sweep** after every fix:
   - Grep all game/ files for the changed function/variable name
   - Verify the fix is consistent everywhere
   - Check callers, signal connections, data references
4. **Post-fix re-read:** re-read the full script around each edit.
5. **Commit locally** (do NOT push until all rounds complete).

## Push and Summary

After all rounds complete (or early exit on clean round):

```bash
git push
gh pr comment <PR#> --body-file /tmp/godot-review-summary.md
```

Summary format:

```markdown
## Godot Review Loop Summary

**Rounds completed:** {rounds_run} of {N}
**Total issues fixed:** {total}
**Final status:** CLEAN / ISSUES REMAINING

### Per-Round Results
| Round | Code Quality | Architecture | Data+Rendering | Unique | Fixed |
|-------|-------------|-------------|----------------|--------|-------|
| 1 | 3 | 2 | 4 | 8 | 8 |
| 2 | 0 | 0 | 0 | 0 | 0 |

### Issues by Category
| Category | Count |
|----------|-------|
| Type Safety | N |
| Signal Architecture | N |
| Pixel Rendering | N |
| ...etc |

Generated with [Claude Code](https://claude.ai/code)
```

## Rules

- **3 agents per round.** Always dispatch all 3. Each covers different
  Godot concern domains.
- **Parallel dispatch.** Launch all 3 simultaneously.
- **Be paranoid.** Previous COPE rounds found fabricated values in
  JSON examples. Verify everything against source docs.
- **Local commits, single push.** Same as story-review-loop.
- **Propagation sweep mandatory.** GDScript changes can break callers,
  signal connections, and scene references.
- **Read verification checklists.** All agents must consult them.
- **Expanding file rule.** Never declare clean without checking
  unexplored related files.
- **Run gdlint if available.** If `gdlint` (gdtoolkit) is installed,
  run it on changed .gd files as an additional quality gate:
  `gdlint game/scripts/path/to/file.gd`
- **Test if GUT/gdUnit4 available.** If a test framework is installed,
  run related tests: `godot --headless --path game/ -s addons/gut/gut_cmdln.gd`
- **ALWAYS paginate gh API calls.** Use `--paginate` on ALL `gh api`
  calls that return lists (comments, reviews, files). Default page size
  is 30 — PRs with many Copilot comments WILL exceed this. Without
  `--paginate`, page 2+ comments are silently missed. Pattern:
  `gh api repos/OWNER/REPO/pulls/N/comments --paginate --jq '...'`
  This has caused repeated failures on PRs #108, #109, #110.
