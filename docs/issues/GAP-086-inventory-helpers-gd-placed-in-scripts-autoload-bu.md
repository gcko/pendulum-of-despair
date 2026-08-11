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

Two notes on the claims above.

The body's "~7 files" was accurate when this doc was generated — at the last
commit before 2026-06-28, `git grep -l autoload/inventory_helpers -- game/`
returns 7 files (party_state.gd, menu_equip.gd, menu_status.gd,
save_load_display.gd, and the test_battle_rewards / test_issue_fixes /
test_mechanical_tweaks tests). Phase 1 then doubled it to 14. The verification
note's "4 files" was wrong even at authoring: it counted only source consumers
and dropped the three test files.

The "update the .uid references" step was a no-op, but not because sidecars do
not exist — every script in `game/scripts/` has one on disk. It was a no-op
because nothing pointed at this script by UID: `*.uid` is gitignored
(`.gitignore:7`), no `inventory_helpers.gd.uid` is tracked in git, and grepping
the repo for the UIDs held by the old and new sidecars returns no hits. Every
consumer preloads a `res://` path, so the untracked sidecar was free to be
regenerated at the new location.
