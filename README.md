# Pendulum of Despair

> *Echoes of a Forgotten Age* -- A JRPG inspired by the golden age of 16-bit RPGs (Final Fantasy IV/VI, Chrono Trigger, Secret of Mana).

---

## Overview

Pendulum of Despair is a single-player JRPG built with **Godot Engine**. The game features ATB combat, a 6-character party, Ley Crystal progression, Arcanite Forging crafting, and a branching narrative across 4 acts plus epilogue and post-game content.

**Status:** Game design is complete (25 design gaps closed across 4 tiers). The game is being built in `game/`, a Godot 4.8 project with a GUT test suite. Implementation is tracked against the design in `docs/analysis/game-dev-gaps.md` and `docs/issues/`.

---

## Repository Structure

```
pendulum-of-despair/
├── game/                   # Godot 4.8 project root (open this in the editor)
│   ├── project.godot
│   ├── scripts/            # GDScript game logic; autoload/ holds the 6 singletons
│   ├── scenes/             # Scene files (.tscn): core, overlay, entities, maps
│   ├── data/               # JSON game data (enemies, items, equipment, shops, ...)
│   ├── assets/             # Sprites, tilesets, music, SFX, ambient audio
│   ├── tests/              # GUT test suite
│   └── addons/             # Vendored addons (GUT)
├── docs/
│   ├── story/              # Canonical game design documents
│   │   ├── bestiary/       # Enemy stat tables, type rules, families
│   │   ├── script/         # Full dialogue script
│   │   └── ...
│   ├── analysis/           # Gap trackers: design (game-design-gaps.md) and implementation (game-dev-gaps.md)
│   ├── issues/             # Per-gap implementation issue files (GAP-NNN), indexed by README.md
│   ├── decisions/          # Decision records
│   ├── references/         # Reference data (SNES, audio, graphics)
│   ├── plans/              # Architecture decisions and implementation plans
│   └── superpowers/        # Design specs and implementation plans
├── scripts/
│   ├── gates.sh            # Run the quality gates locally
│   └── quality-gates/      # Gate scripts, their self-tests, and the GUT count floors
├── tools/                  # Hand-run developer scripts (see tools/README.md)
├── .github/                # CI: gut-tests, quality-gates, static-gates; Claude review, SAST
├── .husky/                 # Git hooks (conventional commits, branch protection, quality gates)
├── package.json            # Commitlint + Husky tooling only
└── commitlint.config.ts    # Conventional commit rules
```

See the Repository Layout table in `AGENTS.md` for where each kind of change goes.

---

## Getting Started

### Prerequisites

- **pnpm** -- for commitlint/husky tooling: `corepack enable`
- **Godot Engine 4.8** -- open `game/` as the project directory; the pre-push hook needs it to run the GUT suite
- **gdtoolkit** (gdlint + gdformat) -- at the version in `scripts/quality-gates/gdtoolkit-version.txt`: `pip install "gdtoolkit==$(tr -d '[:space:]' < scripts/quality-gates/gdtoolkit-version.txt)"`. The pre-commit hook fails when `.gd` files are staged and either tool is missing or at a version other than that pin

### Setup

```bash
pnpm install    # Install commitlint + husky and enable the git hooks
```

Run `pnpm install` once per clone, and again in every new `git worktree`: the
hook shims live in the gitignored `.husky/_/`, which each checkout generates
for itself, and `scripts/gates.sh` refuses to run until they exist.

### Running the game

Open the `game/` directory as a project in the Godot 4.8 editor and press
**Run Project** (F5). The main scene is `res://scenes/core/title.tscn`.

### Running the quality gates

```bash
bash scripts/gates.sh
```

This runs the hooks' quality gates (gdformat, gdlint, JSON validation, the
Python data and doc gates and their self-tests, then Godot import and the GUT
suite when the change can affect them) against your branch and any uncommitted
work. On a stacked branch, pass `GATES_BASE=<parent>`. The GUT suite is held
to the count floors in `scripts/quality-gates/gut-baseline.txt`. The hooks
still run on every commit and push; the script is for checking work they cannot
see yet.

---

## Game Design Documents

All mechanical game design is complete and lives in `docs/story/`. Key documents:

| Document | Content |
|----------|---------|
| `combat-formulas.md` | Damage, hit/miss, critical, ATB gauge, encounter rates |
| `characters.md` | 6 party members, stat growth, Ley Crystal system |
| `bestiary/` | Regular enemies and bosses, with full AI scripts |
| `items.md` | Consumables, devices, crafting materials, key items |
| `equipment.md` | Weapons, armor, accessories |
| `economy.md` | Shop inventories, inn prices, gold pacing |
| `save-system.md` | Save slots, auto-save, rest items, death recovery |
| `script/` | Full dialogue script: acts, interlude, battle and NPC ambient dialogue |
| `ui-design.md` | Battle screen, menus, dialogue, save/load UI |
| `difficulty-balance.md` | FF6 Accessible philosophy, balance methodology |

Gap trackers: `docs/analysis/game-design-gaps.md` (design), `docs/analysis/game-dev-gaps.md` (implementation against the design), and the per-gap issue files in `docs/issues/`.

---

## Design Inspirations

| Feature | Inspired by |
|---------|-------------|
| ATB gauge combat | Final Fantasy VI |
| Character-driven narrative | Final Fantasy IV |
| Ley Crystal system | FF6 Espers + Chrono Trigger |
| Arcanite Forging | Secret of Mana (Watts blacksmith) |
| Dark pixel UI | Final Fantasy VI |
| Tile-based overworld | Chrono Trigger |
| Party-aware dialogue | Chrono Trigger |

---

## Contributing

This project uses **conventional commits** enforced by commitlint:

```
feat(scope): add new feature
fix(scope): fix a bug
docs(scope): documentation changes
```

All commits require a PR targeting `main`. Direct commits to main are blocked by a pre-commit hook.

Issue tracking uses **GitHub Issues**: `gh issue list` to find available work, `gh issue view <number>` for details.
