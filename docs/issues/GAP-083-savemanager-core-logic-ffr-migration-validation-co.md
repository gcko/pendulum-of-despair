# GAP-083: SaveManager core logic (FFR, migration, validation, corrupt-load) has no unit tests

| Field | Value |
|-------|-------|
| **ID** | GAP-083 |
| **Area** | Tests |
| **Severity** | MEDIUM |
| **Type** | test-gap |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
