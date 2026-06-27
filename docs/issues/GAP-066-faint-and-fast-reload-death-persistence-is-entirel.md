# GAP-066: Faint-and-Fast-Reload death-persistence is entirely stubbed (XP/level-ups/restore/flags are no-ops)

| Field | Value |
|-------|-------|
| **ID** | GAP-066 |
| **Area** | Save |
| **Severity** | HIGH |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#174](https://github.com/gcko/pendulum-of-despair/issues/174) |
| **Source domains** | save, arch |

## Summary

FFR control flow is wired but the substance is stubbed: _capture_party_xp/_capture_boss_cutscene_flags return {} and _merge_xp/_merge_flags/_process_level_ups/_full_restore are bare pass; only gold is preserved, so XP, level-ups, HP/MP=100%, and ailment clears are lost on a wipe.

## Current state (implementation)

design-gaps.md:850 marks Save System COMPLETE with 'durable XP/gold write-back' (false-completion); dev-gaps acknowledges the merge logic deferred.

## Desired state (per design)

Per §7: preserve per-character XP and boss_cutscene_seen_* flags, merge into the loaded save, process level-ups, set HP/MP to 100%, clear ailments, write back.

## Proposed approach

Implement capture/merge against PartyState XP and EventFlags boss_cutscene_seen_* keys; derive levels from XP; reset hp/mp to max; clear ailments; reuse _write_data_to_slot. Add unit tests.

## Acceptance criteria

- [ ] XP accrued before death survives the reload
- [ ] Level-ups from accumulated XP are processed
- [ ] HP/MP reset to 100% and ailments cleared
- [ ] Tests cover merge + restore

## Design references

- docs/story/save-system.md §7
- docs/plans/technical-architecture.md §6.5

## Code references

- game/scripts/autoload/save_manager.gd:133-176,309-337


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** save_manager.gd:309-336: _capture_party_xp returns {} (311), _capture_boss_cutscene_flags returns {} (320), _merge_xp/_merge_flags/_process_level_ups/_full_restore are all bare `pass` with TODOs (324,328,332,336). Only gold is preserved (_capture_gold at 314-315 + line 155). save-system.md:421-436 specifies XP preservation, level-up derivation, HP/MP to 100%, ailment clears, boss_cutscene_seen_* flags, and write-back.
- **Notes:** Real partial-impl. Control flow wired (faint_and_fast_reload 133-175) but all substance stubbed. Implementing requires reading per-character XP, deriving levels, restoring HP/MP, clearing ailments + new GUT tests — a feature, not bounded. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
