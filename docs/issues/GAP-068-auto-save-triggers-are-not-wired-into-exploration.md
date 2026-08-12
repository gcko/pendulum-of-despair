# GAP-068: Auto-save triggers are not wired into exploration

| Field | Value |
|-------|-------|
| **ID** | GAP-068 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#209](https://github.com/gcko/pendulum-of-despair/issues/209) |
| **Source domains** | save, tracker |

## Summary

SaveManager.auto_save() exists but has zero callers; none of the four designed triggers (dungeon-floor entry, boss zone, town entry, sidequest complete) invoke it.

## Current state (implementation)

Tracker confirms auto-save triggers deferred until exploration is stable.

## Desired state (per design)

Exploration/scene-transition and quest systems call auto_save() at the four trigger points, suppressing mid-floor and boss-rush.

## Proposed approach

Hook auto-save at flagged floor/town transitions, at boss trigger zones before fight start, and on quest-complete; guard suppression cases.

## Acceptance criteria

- [ ] Auto-save fires on floor/town/boss/quest triggers
- [ ] Mid-floor and boss-rush are suppressed
- [ ] Writes to the auto slot

## Design references

- docs/story/save-system.md §6
- docs/story/difficulty-balance.md (anti-frustration)

## Code references

- game/scripts/autoload/save_manager.gd — `auto_save()` (zero callers)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** save_manager.gd:97-99 defines auto_save(); repo-wide grep for `auto_save` across scripts/ and scenes/ returns ONLY the definition — zero callers. save-system.md §6 (referenced) defines floor/town/boss/quest triggers.
- **Notes:** Confirmed no callers. Wiring into scene transitions + quest completion with mid-floor/boss-rush suppression is new cross-system logic needing tests. Not bounded. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383); write what the file does hold instead. Always verify against current code before acting._
