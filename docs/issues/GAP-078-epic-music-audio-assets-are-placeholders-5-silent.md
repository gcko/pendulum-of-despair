# GAP-078: EPIC: Music + audio assets are placeholders (5 silent tracks vs ~70-80 designed; ~51 SFX, 12 ambient missing)

| Field | Value |
|-------|-------|
| **ID** | GAP-078 |
| **Area** | Audio |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | audio, tracker |

## Summary

game/assets/music has 5 ~0.1s silent placeholders (Title, Overworld, Standard/Boss Battle, Ember Vein); even the Act-I slice lacks Valdris Crown, Roothollow, and Fenmother's Hollow themes; the full ~70-80 tracks plus ~51 SFX and 12 ambient loops are unproduced. AudioManager is wired and verified.

## Current state (implementation)

Tracker marks gap 3.8 COMPLETE scoped to 'major contexts'. file(1) confirms placeholders are silent.

## Desired state (per design)

~70-80 unique tracks per music.md plus the SFX/ambient set per audio.md, dropped in via the existing {id}.ogg convention.

## Proposed approach

Content-production epic: first produce the Act-I-slice subset (Valdris Crown, Roothollow, Fenmother's Hollow themes) then backfill town/dungeon/narrative/battle-tier tracks and SFX/ambient.

## Acceptance criteria

- [ ] Act-I-slice locations have real themes
- [ ] Battle/boss tiers have real tracks
- [ ] ~51 SFX and 12 ambient loops are real audio
- [ ] No engine change needed to add tracks

## Design references

- docs/story/music.md:516-528,199-366,415-441
- docs/story/audio.md (~51 SFX, 12 ambient)

## Code references

- game/assets/music/ (5 silent .ogg)
- game/assets/sfx/, game/assets/ambient/ (silent placeholders)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
