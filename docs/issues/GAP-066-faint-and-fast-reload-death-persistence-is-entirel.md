# GAP-066: Faint-and-Fast-Reload death-persistence is entirely stubbed (XP/level-ups/restore/flags are no-ops)

| Field | Value |
|-------|-------|
| **ID** | GAP-066 |
| **Area** | Save |
| **Severity** | HIGH |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
