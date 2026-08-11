# GAP-045: NPC act-state dialogue variants unreachable: conditions on flags never set anywhere

| Field | Value |
|-------|-------|
| **ID** | GAP-045 |
| **Area** | Story |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#194](https://github.com/gcko/pendulum-of-despair/issues/194) |
| **Source domains** | story |

## Summary

NPC JSONs ship later-act conditioned entries gated on flags never produced (cael_betrayal_complete in 14 files / set in 0; interlude_begins in 23 / set in 0), so all Act-II+ variants for placed NPCs are dead; conversely the impl sets several flags (fenmother_cleansed, *_seen, *_defeated) not enumerated in events.md.

## Current state (implementation)

Even some Act-I conditions never fire (npc_old_harren keys off vaelith_tavern_encounter). The events.md flag catalog and runtime flags have drifted.

## Desired state (per design)

Act-state flags are set as acts are built (turning the data live), and events.md enumerates the implementation ordering/scene flags; a data-lint catches permanently-dead conditions.

## Proposed approach

Add flag setters when each act is built; extend events.md with the *_seen/*_defeated/*_cleansed convention; add CI checking that dialogue-condition flags are set by at least one map/script/cutscene.

## Acceptance criteria

- [ ] events.md documents the implementation ordering flags
- [ ] A lint flags dialogue conditions whose flags are never set
- [ ] fenmother_cleansed vs fenmother_boss_defeated is clarified

## Design references

- docs/story/events.md flags 17/19/20/38; §3

## Code references

- game/data/dialogue/npc_bren.json|npc_dame_cordwyn.json|npc_scholar_aldis.json
- game/scripts/entities/npc.gd
- game/scripts/core/cleansing_sequence.gd — `_complete()` (sets fenmother_cleansed, one of the flags absent from events.md)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** cael_betrayal_complete appears in 14 dialogue JSON files but has 0 set_flag callers in game/scripts or game/scenes. interlude_begins appears in 23 dialogue files, 0 setters. So all Act-II+ conditioned variants for placed NPCs are dead. Conversely the impl sets flags absent from the events.md catalog: cleansing_sequence.gd:80 set_flag('fenmother_boss_defeated') and :206 set_flag('fenmother_cleansed') — both exist (battle_manager.gd:471 uses fenmother_boss_defeated; fenmothers_hollow_f3.tscn:44/:91 too) yet events.md does not enumerate either; events.md:286 confirms vaelith_tavern_encounter is flag 13 (also unset in code).
- **Notes:** Confirmed flag drift. Overlaps GAP-047 (dead Act-II+ variants are dead because those acts aren't built). Not a clean bounded fix: acceptance bundles a CI lint, events.md convention additions, and per-act flag setters. Severity MEDIUM appropriate (partial-impl, dead ambient variants).

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
