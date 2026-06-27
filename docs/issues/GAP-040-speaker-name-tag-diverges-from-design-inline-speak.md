# GAP-040: Speaker name tag diverges from design — inline 'SPEAKER:' prefix instead of inset tag (SpeakerLabel dead)

| Field | Value |
|-------|-------|
| **ID** | GAP-040 |
| **Area** | Dialogue |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | dialogue |

## Summary

DialogueBox hides the SpeakerLabel inset and renders an uppercased inline 'SPEAKER: text' prefix (consuming one of three text lines), contradicting dialogue-system.md §1 and ui-design.md §12.

## Current state (implementation)

SpeakerLabel nodes are loaded but never shown; the inline prefix is the actual behavior. Tracker calls it 'FF6 inline speaker' but the doc still specifies an inset tag.

## Desired state (per design)

A single source of truth: implement the inset name tag, OR canonicalize the inline decision in the doc and delete the dead SpeakerLabel.

## Proposed approach

Make a design call and reconcile dialogue-system.md §1 and ui-design.md §12; remove dead nodes if inline is kept.

## Acceptance criteria

- [ ] Code and docs agree on speaker rendering
- [ ] Dead SpeakerLabel removed or used
- [ ] Doc reconciliation recorded

## Design references

- docs/story/dialogue-system.md §1/§4.5

## Code references

- game/scripts/ui/dialogue_box.gd:160-167,71-73

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
