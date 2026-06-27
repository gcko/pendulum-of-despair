# GAP-088: Resolution/accessibility doc divergence: impl on 1280x720 native + 4x zoom, docs still assume 320x180 integer scaling

| Field | Value |
|-------|-------|
| **ID** | GAP-088 |
| **Area** | Docs |
| **Severity** | LOW |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | tracker |

## Summary

The accessibility High-Res-Text and integer-scaling rationale rests on a 320x180 base, but the implementation moved to 1280x720 native with 4x camera zoom (2026-04-08); the design-gaps 4.4 entry was never reconciled.

## Current state (implementation)

design-gaps:703 still cites 320x180 as the accessibility foundation; the change is documented only in the dev tracker.

## Desired state (per design)

accessibility.md, visual-style.md, and design-gaps 4.4 describe the 1280x720/4x-zoom model; confirm whether High-Res Text is still meaningful.

## Proposed approach

Reconcile the resolution model across the docs and re-justify or drop the High-Res Text toggle.

## Acceptance criteria

- [ ] Docs describe the 1280x720/4x model
- [ ] High-Res Text relevance decided
- [ ] design-gaps 4.4 updated

## Design references

- docs/analysis/game-design-gaps.md:703
- docs/analysis/game-dev-gaps.md:11
- docs/story/accessibility.md

## Code references

- game/project.godot (1280x720 viewport, 4x zoom)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
