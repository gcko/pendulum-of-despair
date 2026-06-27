# GAP-080: EPIC: Character Leitmotif System and motif-layering rules have no engine or asset support

| Field | Value |
|-------|-------|
| **ID** | GAP-080 |
| **Area** | Audio |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | audio |

## Summary

No data model for character leitmotifs and no engine logic to layer a character's motif into a scene by narrative role; no motif stems exist. AudioManager plays whole pre-baked tracks only.

## Current state (implementation)

grep motif/leitmotif returns nothing; marquee beats (Sable reunion stacking, Final Battle six-motif unison, Vaelith progression) require runtime motif assembly.

## Desired state (per design)

When a character is narratively relevant their motif layers into the current track per the role->treatment matrix.

## Proposed approach

Composition + adaptive-audio epic: author per-character motif stems and a layering controller mixing stems on dedicated sub-channels keyed by active party/scene. Mostly Act II+.

## Acceptance criteria

- [ ] Per-character motif stems exist
- [ ] A layering controller mixes motifs by narrative role
- [ ] Sable's reunion order drives layering sequence

## Design references

- docs/story/music.md:116-183,340-350,434

## Code references

- game/scripts/autoload/audio_manager.gd (no motif/layering)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** grep -i for 'motif|leitmotif' across game/scripts returns nothing. AudioManager plays whole pre-baked .ogg tracks via play_music; no motif stems exist in game/assets/music (only the 5 full-track placeholders). No layering controller or per-character motif data model.
- **Notes:** Confirmed. XL adaptive-audio + composition epic, mostly Act II+. Not a bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
