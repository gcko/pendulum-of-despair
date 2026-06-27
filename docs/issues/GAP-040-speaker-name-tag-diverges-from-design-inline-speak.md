# GAP-040: Speaker name tag diverges from design — inline 'SPEAKER:' prefix instead of inset tag (SpeakerLabel dead)

| Field | Value |
|-------|-------|
| **ID** | GAP-040 |
| **Area** | Dialogue |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | S |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#224](https://github.com/gcko/pendulum-of-despair/issues/224) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** dialogue_box.gd:71-73 loads _speaker_container ($DialogueBox/SpeakerLabel) and _speaker_label, but _show_entry sets _speaker_container.visible = false (line 161) and instead prepends an uppercased inline prefix: _current_lines[0] = speaker.to_upper()+': '+_current_lines[0] (165) / [speaker.to_upper()+':'] (167), with the comment 'FF6 inline style' (159). Design dialogue-system.md §1 line 29 ('Speaker name in small inset tag at top-left corner') and ui-design.md §12.1 line 833 ('Character name label in a small inset tag at the top-left corner') both specify an inset tag. The SpeakerLabel nodes are therefore dead code and the inline prefix consumes one of the 3 visible text lines.
- **Notes:** Confirmed design-vs-code divergence. fixNow is false because resolution requires a deliberate design call (implement inset tag in code vs. canonicalize inline in two design docs and delete dead nodes) — not a unilateral safe edit, and changing DialogueBox text composition risks the GUT suite. Cheapest path is a doc reconciliation but the direction must be chosen by the maintainer.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
