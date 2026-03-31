# Pendulum of Despair

> *Echoes of a Forgotten Age* -- A JRPG inspired by the golden age of 16-bit RPGs (Final Fantasy IV/VI, Chrono Trigger, Secret of Mana).

---

## Overview

Pendulum of Despair is a single-player JRPG built with **Godot Engine**. The game features ATB combat, a 6-character party, Ley Crystal progression, Arcanite Forging crafting, and a branching narrative across 4 acts plus epilogue and post-game content.

**Status:** Game design is complete (25 design gaps closed across 4 tiers). Engine implementation has not yet begun.

---

## Repository Structure

```
pendulum-of-despair/
├── docs/
│   ├── story/              # Canonical game design documents (35+ files)
│   │   ├── save-system.md  # Save/load, rest, death recovery
│   │   ├── combat-formulas.md
│   │   ├── bestiary/       # Enemy stat tables by act
│   │   ├── script/         # Full dialogue script (6,300+ lines)
│   │   └── ...
│   ├── analysis/           # Gap analysis and audit docs
│   ├── references/         # SNES-era reference data (FF4/FF6/CT/SoM)
│   ├── plans/              # Architecture decisions
│   └── superpowers/        # Design specs and implementation plans
├── .beads/                 # Issue tracking database (bd)
├── .github/                # CI workflows (Claude review, SAST)
├── .husky/                 # Git hooks (conventional commits, branch protection)
├── package.json            # Commitlint + Husky tooling only
└── commitlint.config.ts    # Conventional commit rules
```

> **Note:** The Godot project structure (`project.godot`, scenes, scripts, assets) will be created in a future issue. This repo currently contains only game design documentation and project tooling.

---

## Getting Started

### Prerequisites

- **pnpm** -- for commitlint/husky tooling: `corepack enable`
- **Godot Engine 4.x** -- for game development (when project is initialized)

### Setup

```bash
pnpm install    # Install commitlint + husky (git hooks)
```

---

## Game Design Documents

All mechanical game design is complete and lives in `docs/story/`. Key documents:

| Document | Content |
|----------|---------|
| `combat-formulas.md` | Damage, hit/miss, critical, ATB gauge, encounter rates |
| `characters.md` | 6 party members, stat growth, Ley Crystal system |
| `bestiary/` | 198 enemies + 30 bosses with full AI scripts |
| `items.md` | 32 consumables, 13 devices, 67 materials, 23 key items |
| `equipment.md` | 56 weapons, 49 armor, 38 accessories |
| `economy.md` | Shop inventories, inn prices, gold pacing |
| `save-system.md` | Save slots, auto-save, rest items, death recovery |
| `script/` | Full dialogue script (8 files, 6,300+ lines) |
| `ui-design.md` | Battle screen, menus, dialogue, save/load UI |
| `difficulty-balance.md` | FF6 Accessible philosophy, balance methodology |

See `docs/analysis/game-design-gaps.md` for the full gap tracker.

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

Issue tracking uses **bd** (beads): `bd ready` to find available work, `bd show <id>` for details.
