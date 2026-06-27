# GAP-034: Per-biome weather/atmospheric effects and story overrides not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-034 |
| **Area** | Exploration |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#189](https://github.com/gcko/pendulum-of-despair/issues/189) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Only an audio-side biome crossfade constant exists: audio_manager.gd:35 'const CROSSFADE_BIOME: float = 3.0'. No weather/particle/CanvasModulate atmosphere system in scripts. Design overworld.md §4 and biomes.md atmospheric/time-of-day effects.
- **Notes:** Confirmed. Effort M feature (overlay nodes + per-map meta + flag override). Not fixable now.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
