# GAP-034: Per-biome weather/atmospheric effects and story overrides not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-034 |
| **Area** | Exploration |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | exploration |

## Summary

No weather/atmospheric overlay system exists; maps render a single static palette with no particle/lighting atmospherics.

## Current state (implementation)

Only an audio-side biome crossfade constant exists.

## Desired state (per design)

Fixed per-biome atmospheric overlays (rain/snow/fog/ley shimmer) and story-triggered overrides per overworld.md §4 and biomes.md.

## Proposed approach

Add a reusable atmospheric overlay node (particles + CanvasModulate) configured per map biome meta, with a flag-driven override hook.

## Acceptance criteria

- [ ] Biomes show distinct atmospheric overlays
- [ ] A story flag can override a biome's atmosphere
- [ ] Effect is configurable per map meta

## Design references

- docs/story/overworld.md §4
- docs/story/biomes.md §Time of Day Effects

## Code references

- game/scripts/ (only audio_manager CROSSFADE_BIOME constant)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
