# Common Godot Issues Taxonomy

Classification reference for review agents. Maps to verification
checklists.

---

## 12 Issue Categories

### 1. Type Safety
Missing or incorrect static typing. Catches errors at parse time
instead of runtime. Benchmarks show 28-59% speedup with typed code.
- Missing parameter type hints
- Missing return type declarations
- Bare `var` without type annotation
- `Variant` used where concrete type is known

### 2. Signal Architecture
Violations of "call down, signal up" principle.
- Child references parent via `get_parent()`
- Deep node path traversal (`../../sibling`)
- Direct singleton mutation from deep children
- Untyped signal parameters

### 3. Scene Composition
Scene organization and portability issues.
- Monolithic scenes (too many responsibilities)
- Scene depends on parent structure (not portable)
- Duplicate logic that should be a shared scene
- Wrong node type for purpose

### 4. Pixel Art Rendering
320x180 viewport, nearest-neighbor, snap-to-pixel violations.
- Sub-pixel sprite positions
- Non-integer camera zoom
- Wrong texture filter (linear instead of nearest)
- Mipmaps or compression on pixel art
- Import settings missing nearest-neighbor

### 5. Performance
Frame budget or resource usage violations.
- Uncached node lookups in `_process()`
- `load()` calls in hot paths
- Unnecessary `_process()` on idle nodes
- String concatenation in loops
- Exceeding entity/emitter/channel budgets

### 6. Data Integrity
JSON data file errors and design doc mismatches.
- Values don't match canonical source docs
- Wrong JSON key naming (camelCase instead of snake_case)
- Missing required fields in data schemas
- Save schema missing required groups

### 7. State Machine
GameManager state machine violations.
- Direct `change_scene_to_file()` bypassing GameManager
- Overlay push without checking return value
- Multiple overlays active simultaneously
- Transition data not passed through `GameManager.transition_data`

### 8. Autoload Misuse
Singleton usage violations.
- Direct file I/O instead of using DataManager/SaveManager
- Direct AudioStreamPlayer creation instead of AudioManager
- Custom flag dictionaries instead of EventFlags
- Game state stored in non-autoload scripts

### 9. Naming & Style
GDScript style guide violations.
- Wrong case convention (PascalCase function, snake_case class)
- Script member ordering doesn't follow 17-item convention
- File name doesn't match class_name
- Abbreviations in public API

### 10. Design Doc Compliance
Implementation doesn't match the game design documents.
- Mechanic doesn't match combat-formulas.md
- UI doesn't match ui-design.md
- Audio behavior doesn't match audio.md
- Save behavior doesn't match save-system.md
- Values don't match bestiary/items/equipment source tables

### 11. Defensive Coding (from Copilot gap analysis, PR #105)
Runtime safety issues that cause crashes or silent failures.
- Dictionary key access without checking key exists first
- load()/preload() result not checked for null before instantiate()
- Scene path not verified with ResourceLoader.exists() before change_scene
- Public API parameters not validated for range (out-of-bounds slot numbers)
- assert(false) used as only error handler (disabled in release builds)
- Stub methods return invalid data that breaks downstream consumers
- Docstrings don't match actual return behavior (inconsistent API contract)
- Migration functions silently skip missing steps instead of failing
- Bare print() in frequently-called autoload methods (log flooding)

### 12. Documentation Accuracy
Context files and specs don't match current project state.
- CLI commands in AGENTS.md/CLAUDE.md that can't work yet (no main scene)
- Claims about runnability when project is editor-open-only
- Spec status fields stale after implementation
- Spec notation doesn't match actual Godot project settings format
- Review reference doc headings/counts inconsistent with content

---

## Severity Levels

**BLOCKER:** Crashes, data loss, broken core systems, pixel rendering
broken. Must fix before merge.

**ISSUE:** Incorrect behavior, design doc mismatch, type safety gap,
style violation. Should fix before merge.

**SUGGESTION:** Improvement opportunity, minor style preference,
performance optimization for non-hot path. Fix if trivial.
