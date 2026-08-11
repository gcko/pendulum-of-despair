# Tech Stack Reference -- Pendulum of Despair

## Architecture

A **single Godot 4.7 project** rooted at `game/`. There is no monorepo, no
bundler, no backend server, and no database. The game is a locally-run desktop
application written entirely in **GDScript**.

| Item | Value |
|------|-------|
| Engine | Godot 4.7 |
| Renderer | GL Compatibility |
| `config_version` | 5 |
| Language | GDScript only |
| Main scene | `res://scenes/core/title.tscn` |
| Viewport | 1280x720 at 4x camera zoom -> 320x180 effective, integer-scaled |
| Game name | "Pendulum of Despair" |

Open the `game/` directory in the Godot 4.7+ editor.

---

## Autoload Singletons

Six autoloads are registered in `project.godot` and live in
`game/scripts/autoload/`:

| Autoload | Script | Responsibility |
|----------|--------|----------------|
| `GameManager` | `game_manager.gd` | Top-level game state, scene flow, run lifecycle |
| `DataManager` | `data_manager.gd` | Loads and serves JSON game data from `game/data/` |
| `AudioManager` | `audio_manager.gd` | Music + SFX playback via Godot audio buses |
| `SaveManager` | `save_manager.gd` | Local save/load of game state (no backend) |
| `EventFlags` | `event_flags.gd` | Story flags and world-state booleans |
| `PartyState` | `party_state.gd` | Active party, characters, inventory state |

`scripts/autoload/` holds these six scripts and nothing else. Helpers that are
*not* registered as autoloads split on who reaches them, not on how many screens
use them. A helper reached from outside `scripts/ui/` lives in `scripts/util/`;
a helper whose only consumers are UI scripts stays in `scripts/ui/` next to
those screens, even when several screens share it — `ui/stat_bar_helpers.gd` is
used by the battle party panel, the main menu and the status screen, and
`ui/spell_helpers.gd` by the battle command menu and the magic menu, while
`ui/ability_helpers.gd`, `ui/save_load_display.gd`, `ui/crystal_display.gd` and
`ui/menu_party_panel.gd` each serve one screen.

Do not read `scripts/util/` as an enumerable list — GAP-087 grew it from four
scripts to sixteen. It holds two kinds of thing:

- **Cross-cutting static helpers.** All-`static` `RefCounted` files with no
  instance state: `inventory_helpers.gd` (preloaded from `autoload/`, `combat/`
  and `ui/`), `InputUtil` (`ui/`, `core/`), `DialogueCondition` (`ui/`, `core/`,
  `entities/`), `DialogueConsequences` (`core/`), plus the helper sets split out
  of the big files — `formation_helpers.gd`, `progression_helpers.gd`,
  `save_data_helpers.gd`, `audio_crossfade.gd`, `audio_mix_context.gd`,
  `audio_sfx_policy.gd`.
- **Per-owner facets.** Instantiated `RefCounted` collaborators that take their
  owner in `_init(owner)` and hold a back-reference to it, so a single oversized
  owner can be split without moving its state: `party_crystals.gd`,
  `party_roster.gd`, `party_vitals.gd`, `party_inventory.gd`,
  `party_equipment.gd` and `party_persistence.gd` are all facets of `PartyState`.
  A new facet goes next to its siblings and its owner names it in a class doc.

Neither kind is a UI controller, and a global `class_name` does not mark the
split either way — `StatBarHelpers` and `SaveLoadDisplay` are `class_name`
globals in `scripts/ui/`, and `inventory_helpers.gd` in `scripts/util/` has no
`class_name` at all. The facet pattern is not confined to `util/`: an owner
whose consumers are all UI keeps its facets in `ui/` (`ui/menu_party_panel.gd`,
`ui/save_load_display.gd`), and `core/` and `combat/` hold their own
(`core/exploration_*.gd`, `combat/battle_*.gd`).

`game/tests/test_script_layout.gd` enforces only the `autoload/` half: every
`.gd` in `scripts/autoload/` must appear in the `[autoload]` block, no script in
`scripts/util/` may be a registered singleton, and `inventory_helpers.gd` must
live in `scripts/util/`. The util-vs-ui placement above is a convention the
suite does not check.

---

## GDScript Directory Layout

All gameplay code lives under `game/scripts/`:

```
game/scripts/
  autoload/    # The 6 autoload singletons registered in project.godot
  combat/      # ATB battle logic, command handling, damage resolution
  core/        # Core game-flow controllers (scene management, run state)
  entities/    # Player, NPCs, enemies, interactables, trigger zones
  ui/          # UI controllers (menus, HUD, dialogue) + their local helpers
  util/        # Cross-cutting helpers, not registered as autoloads
```

Scenes live under `game/scenes/`:

```
game/scenes/
  core/        # title.tscn, exploration.tscn, battle.tscn
  overlay/     # dialogue.tscn, cutscene.tscn, menu.tscn, shop_overlay.tscn, save_load.tscn
  entities/    # player_character.tscn, npc.tscn, enemy.tscn, save_point.tscn, trigger/zones, etc.
  maps/        # overworld + towns/ + dungeons/ + cutscenes/ (.tscn maps)
  ui/          # ritual_meter.tscn and other reusable UI scenes
```

Art and audio assets live under `game/assets/` (`sprites/`, `tilesets/`,
`music/`, `sfx/`, `ambient/`).

---

## Game Data Format

All game content is stored as **JSON files** under `game/data/`, loaded at
runtime by the `DataManager` autoload. Current layout (directories of JSON,
not flat files):

```
game/data/
  abilities/
  characters/      # cael.json, edren.json, lira.json, maren.json, sable.json, torren.json
  config/
  crafting/
  dialogue/        # act_i.json, act_ii.json, act_iii.json, ...
  encounters/
  enemies/
  equipment/
  items/
  shops/
  spells/
  ley_crystals.json
```

### JSON conventions

- Data files include a `"_comment"` key describing structure where helpful.
- IDs are strings (e.g. `"enemy_001"`) for readability.
- JSON is validated by the pre-commit hook (`python3 -c "import json..."`).
- Data integrity (ID uniqueness, stale counts, scene refs) is scanned by the
  pre-push hook.

---

## Testing: GUT 9.7.0

GUT (Godot Unit Test) 9.7.0 lives in `game/addons/gut/`. Test files
(`test_*.gd`) live in `game/tests/`.

Resolve the Godot binary as `godot` on PATH, else
`/Applications/Godot.app/Contents/MacOS/Godot`.

```bash
# Import assets first (must pass before tests run)
<godot> --headless --path game/ --import

# Full suite
<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd

# Single file
<godot> --headless --path game/ -s addons/gut/gut_cmdln.gd \
  -gtest=res://tests/<file>.gd -gexit
```

### GUT gotchas (do not get burned)

- Godot 4.7 / GUT 9.7.0 **silently skip** test files that have parse errors --
  a green run can hide them. Always check the **Scripts / Tests** counts in the
  summary, not just the pass/fail line.
- The assertion helpers are `assert_lte` / `assert_gte` (NOT `assert_le` /
  `assert_ge`).
- Nodes that must be unit-testable via `.new()` should use
  `get_node_or_null("Child")`, not `$Child` (`$` emits a "node not found ->
  nullptr" engine error that GUT counts as a failure).
- On macOS, Godot `--import` can wedge in an uninterruptible U-state (0% CPU);
  a reboot clears it. A wedged pre-push hook means the GUT suite did NOT run --
  never equate "other gates pass" with "tests green."

---

## Lint & Format

- **Lint:** `gdlint <files>` (gdtoolkit)
- **Format check:** `gdformat --check <files>`; auto-fix with `gdformat <file>`

These are the verification gates for code -- there is no eslint/prettier/tsc.

---

## Package Tooling (pnpm -- husky + commitlint ONLY)

`pnpm` exists in this repo solely to install and run **husky** (git hooks) and
**commitlint**. It does not build, bundle, or test the game.

- `pnpm install` -- installs git hooks; recovery for broken `core.hooksPath`.
- Do **not** use `npm`, `yarn`, or standalone `npx`.

### Git hooks (Husky v9)

Dispatch chain: `core.hooksPath=.husky/_` -> thin shim -> dispatcher ->
`.husky/<hook>` (user hook). **Never edit `.husky/_/`** -- it is regenerated by
`pnpm install`.

| Hook | What it runs |
|------|--------------|
| `commit-msg` | commitlint (Conventional Commits 1.0.0) |
| `pre-commit` | branch protection + gdlint + JSON validation + `gdformat --check` |
| `pre-push` | data-integrity scans + Godot `--import` + full GUT suite |

**Never use `--no-verify`.** Fix the root cause (or remove the offending test)
instead.

#### Conventional Commits

- **Types:** feat, fix, docs, style, refactor, test, chore, build, perf,
  revert, ci
- **Scopes:** engine, story, assets, ci, deps
- Example: `git commit -m "feat(engine): add ATB gauge to battle manager"`

---

## Recommended MCP

The Godot MCP server
([tugcantopaloglu/godot-mcp](https://github.com/tugcantopaloglu/godot-mcp))
provides live editor and scene-tree access -- inspecting nodes, reading scene
structure, and driving the editor. It is being added to the project so future
sessions can work against real `.tscn` scenes directly instead of editing them
blind.

---

## Out of Scope

- Multiplayer or co-op
- Web/browser builds (this is a desktop Godot app)
- Any backend, REST API, auth server, or database
- Procedurally generated content -- hand-crafted maps and story only
- 3D rendering of any kind
- Microtransactions or monetization
