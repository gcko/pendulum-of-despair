# GAP-070: Playtime is never incremented during gameplay

| Field | Value |
|-------|-------|
| **ID** | GAP-070 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | bug |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save |

## Summary

PartyState.playtime is set to 0 on new game, loaded from save, and written back, but nothing advances it during play, so every slot displays 0:00 for a fresh playthrough.

## Current state (implementation)

No _process/timer accumulates elapsed seconds; grep finds only assignment and reset.

## Desired state (per design)

A running clock accumulates real played seconds (excluding paused menus) into playtime.

## Proposed approach

Add a _process(delta) accumulator in PartyState/GameManager that increments while in non-paused gameplay and folds into playtime on save.

## Acceptance criteria

- [ ] Playtime advances during gameplay
- [ ] Paused menus are excluded
- [ ] Saved/displayed playtime is accurate

## Design references

- docs/story/save-system.md §3.10/§5

## Code references

- game/scripts/autoload/party_state.gd:44,77,128
- game/scripts/autoload/save_manager.gd:305-306
- game/scripts/ui/save_load_display.gd:159-165


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** party_state.gd:44 `var playtime: int = 0`; reset to 0 at 77; loaded from save at 128; written via save_manager.gd:305-306. Repo-wide grep finds NO `playtime +=` and no _process accumulator in party_state.gd or game_manager.gd. menu_overlay.gd:362 and save_load_display.gd:159-165 only read/format it.
- **Notes:** Confirmed never incremented. A _process accumulator needs gameplay-vs-paused state gating + tests (excluding paused menus). Small but introduces runtime state logic; not a trivially safe doc/data change. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
