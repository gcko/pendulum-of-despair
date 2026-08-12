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

- game/scripts/autoload/save_manager.gd — `faint_and_fast_reload()` and the stubs it calls: `_merge_xp()`, `_process_level_ups()`, `_full_restore()`


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** HIGH
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** save_manager.gd:309-336: _capture_party_xp returns {} (311), _capture_boss_cutscene_flags returns {} (320), _merge_xp/_merge_flags/_process_level_ups/_full_restore are all bare `pass` with TODOs (324,328,332,336). Only gold is preserved (_capture_gold at 314-315 + line 155). save-system.md:421-436 specifies XP preservation, level-up derivation, HP/MP to 100%, ailment clears, boss_cutscene_seen_* flags, and write-back.
- **Notes:** Real partial-impl. Control flow wired (faint_and_fast_reload 133-175) but all substance stubbed. Implementing requires reading per-character XP, deriving levels, restoring HP/MP, clearing ailments + new GUT tests — a feature, not bounded. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
