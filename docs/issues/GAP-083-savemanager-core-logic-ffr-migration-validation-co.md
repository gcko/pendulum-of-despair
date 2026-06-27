# GAP-083: SaveManager core logic (FFR, migration, validation, corrupt-load) has no unit tests

| Field | Value |
|-------|-------|
| **ID** | GAP-083 |
| **Area** | Tests |
| **Severity** | MEDIUM |
| **Type** | test-gap |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#218](https://github.com/gcko/pendulum-of-despair/issues/218) |
| **Source domains** | arch |

## Summary

The only save test drives the overlay UI; there are no tests for _migrate, _validate rejection, the corrupted/invalid/cannot_open load branches, or faint_and_fast_reload (grep 'faint' in tests returns nothing).

## Current state (implementation)

test_save_load.gd covers only overlay UI functions.

## Desired state (per design)

Dedicated SaveManager unit tests covering migration, per-key validation rejection, load error branches, and FFR persistence (after GAP-066).

## Proposed approach

Add game/tests/test_save_manager.gd with GUT cases for _migrate, _validate, load errors, and FFR.

## Acceptance criteria

- [ ] Migration chain tested
- [ ] _validate rejects each malformed key
- [ ] Load error branches tested
- [ ] FFR persistence tested once implemented

## Design references

- docs/plans/technical-architecture.md §6.3/§6.5

## Code references

- game/scripts/autoload/save_manager.gd:60-92,191-237,133-176
- game/tests/test_save_load.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/tests/test_save_load.gd (232 lines) only has overlay-UI and happy-path tests (test_save_load_scene_loads, test_save_writes_file, test_copy_slot, test_load_defers_state_change, etc.). grep across tests/ for _migrate/_validate/cannot_open/"invalid"/faint_and_fast returns ZERO save-related matches (the 'corrupted' hits are enemy data in test_fenmothers_hollow.gd). save_manager.gd has untested logic: error branches load_game (cannot_open:70, corrupted:78, invalid:82,90), _migrate:191, _validate:214, faint_and_fast_reload:133.
- **Notes:** Core claim accurate: no unit tests for _migrate, _validate rejection, load error branches, or FFR. faint_and_fast_reload IS already implemented (line 133) so it is testable now, contrary to the 'once implemented' caveat. fixNow=FALSE: this is net-new test authoring (a full new GUT file), not a bounded one-line fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
