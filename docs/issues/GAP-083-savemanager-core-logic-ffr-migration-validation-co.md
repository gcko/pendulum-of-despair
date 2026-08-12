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

- game/scripts/autoload/save_manager.gd — `_migrate()`, `_validate()`, `faint_and_fast_reload()` (the untested branches)
- game/tests/test_save_load.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/tests/test_save_load.gd (232 lines) only has overlay-UI and happy-path tests (test_save_load_scene_loads, test_save_writes_file, test_copy_slot, test_load_defers_state_change, etc.). grep across tests/ for _migrate/_validate/cannot_open/"invalid"/faint_and_fast returns ZERO save-related matches (the 'corrupted' hits are enemy data in test_fenmothers_hollow.gd). save_manager.gd has untested logic: error branches load_game (cannot_open:70, corrupted:78, invalid:82,90), _migrate:191, _validate:214, faint_and_fast_reload:133.
- **Notes:** Core claim accurate: no unit tests for _migrate, _validate rejection, load error branches, or FFR. faint_and_fast_reload IS already implemented (line 133) so it is testable now, contrary to the 'once implemented' caveat. fixNow=FALSE: this is net-new test authoring (a full new GUT file), not a bounded one-line fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
