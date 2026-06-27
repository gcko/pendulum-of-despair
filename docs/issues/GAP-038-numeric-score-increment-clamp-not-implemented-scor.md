# GAP-038: Numeric score increment + clamp not implemented — score choices overwrite instead of accumulate

| Field | Value |
|-------|-------|
| **ID** | GAP-038 |
| **Area** | Dialogue |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | dialogue |

## Summary

DialogueBox emits the score delta and the only handler calls EventFlags.set_flag (overwrite); EventFlags has no increment/clamp, so multi-question approval scores (council_*_approval 0-3) never accumulate or clamp.

## Current state (implementation)

thornmere_council.json scores across questions 005/011/013/016 depend on accumulation; setting the flag to the delta loses prior totals.

## Desired state (per design)

Score deltas are added to the existing value and clamped to range per §3.3.

## Proposed approach

Add EventFlags.increment_score(name, delta, min, max) with clamp and a distinct score path; source min/max from events.md; add accumulation+clamp tests.

## Acceptance criteria

- [ ] Score choices accumulate across questions
- [ ] Scores clamp to their documented range
- [ ] Tests cover accumulation and clamp

## Design references

- docs/story/dialogue-system.md §3.3/§3.4

## Code references

- game/scripts/ui/dialogue_box.gd:278-281
- game/scripts/core/cutscene_handler.gd:164-169
- game/scripts/autoload/event_flags.gd:18-24

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
