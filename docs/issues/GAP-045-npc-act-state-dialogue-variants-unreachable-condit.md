# GAP-045: NPC act-state dialogue variants unreachable: conditions on flags never set anywhere

| Field | Value |
|-------|-------|
| **ID** | GAP-045 |
| **Area** | Story |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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
- game/scripts/entities/npc.gd:81-118
- game/scripts/core/cleansing_sequence.gd:80,206

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
