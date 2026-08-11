# GAP-086: inventory_helpers.gd placed in scripts/autoload/ but is a static helper, not an autoload

| Field | Value |
|-------|-------|
| **ID** | GAP-086 |
| **Area** | Code structure |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | resolved — Issue #236 |
| **GitHub Issue** | [#236](https://github.com/gcko/pendulum-of-despair/issues/236) |
| **Source domains** | arch |

## Summary

inventory_helpers.gd is a static RefCounted utility preloaded as Helpers in ~7 files but lives in scripts/autoload/ alongside the 6 real singletons, against the documented layout (scripts/util/ for utilities).

## Current state (implementation)

project.godot lists exactly 6 autoloads; the file is not registered and is consumed via preload.

## Desired state (per design)

Relocate it (and similar static helpers) to scripts/util/.

## Proposed approach

Move the file to scripts/util/ and update the ~7 preload paths and .uid references.

## Acceptance criteria

- [ ] File moved to scripts/util/
- [ ] All preload paths updated
- [ ] scripts/autoload/ contains only registered singletons

## Design references

- docs/plans/technical-architecture.md §1.1/§1.3

## Code references

- game/scripts/autoload/inventory_helpers.gd:1
- game/scripts/autoload/party_state.gd:7
- game/project.godot:18-25


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scripts/autoload/inventory_helpers.gd:1 'extends RefCounted' with static helpers ('Extracted from PartyState to keep files under 400 lines'), NOT registered in project.godot autoloads (only the 6 real singletons listed at lines 20-25). scripts/util/ already exists and holds a sibling static helper (input_util.gd), and the documented layout (technical-architecture.md:64 'util/  # Utility functions') confirms utilities belong there. Consumed via preload in 4 files: ui/save_load_display.gd, ui/menu_status.gd, ui/menu_equip.gd, autoload/party_state.gd.
- **Notes:** Real divergence, but '~7 files' is overstated — only 4 preload it. fixNow=FALSE: a Godot file move requires updating .uid references and resource paths (touches core party_state.gd) — exactly the kind of move that can disturb the 916-test suite; not a trivial bounded edit.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._

## Resolution (Issue #236, 2026-08-11)

`inventory_helpers.gd` moved to `game/scripts/util/`, so `scripts/autoload/`
now contains exactly the six scripts registered in the `[autoload]` block of
`project.godot`. All 14 `preload("res://scripts/autoload/inventory_helpers.gd")`
call sites were repointed at `res://scripts/util/inventory_helpers.gd` — 8
source files (`ui/save_load_display.gd`, `ui/menu_status.gd`, `ui/menu_items.gd`,
`ui/menu_equip.gd`, `ui/battle_command_menu.gd`, `combat/battle_state.gd`,
`autoload/save_manager.gd`, `autoload/party_state.gd`) and 6 test files. Pure
relocation: no behaviour change, and `game/tests/test_script_layout.gd` now
guards the split against regression.

Two claims above are stale. "~7 files" / the verification note's "4 files" both
undercount — Phase 1 added consumers and the real count at move time was 14.
And there were no `.uid` references to update: `*.uid` is gitignored, no
`inventory_helpers.gd.uid` existed on disk or in git, and nothing referenced the
script by `uid://` (every consumer used a `res://` path preload).
