# GAP-074: Multiple config toggles persist but have no runtime consumers (High-Res Text, Mono Audio, Transition Style, Screen Shake, always-on cues)

| Field | Value |
|-------|-------|
| **ID** | GAP-074 |
| **Area** | Save |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save |

## Summary

high_res_text, sound_mode (mono), transition_style, and screen_shake persist with no consumers; cutscene shake is gated only by reduce_motion (so Screen Shake off alone does nothing); and the always-on cues (HP-bar crack below 25%, corruption texture, particle-type shift) are absent.

## Current state (implementation)

These settings are referenced only in menu_config; no second viewport, mono down-mix, transition branch, independent shake check, or HP-bar shape cue exists.

## Desired state (per design)

Each toggle drives its runtime behavior: High-Res Text viewport, mono bus, transition_style branch, independent screen_shake check, and always-on HP-crack/corruption/particle cues.

## Proposed approach

Wire each consumer: read screen_shake in shake emitters; branch transitions on transition_style; force pan=0/mono bus when sound_mode=='mono'; add a high-res UI SubViewport; add HP-bar shape cue <25%. Defer High-Res Text if single-resolution UI is acceptable.

## Acceptance criteria

- [ ] Screen Shake off disables shake independent of Reduce Motion
- [ ] Mono collapses stereo to center
- [ ] Transition Style selects simple vs classic
- [ ] HP bars show a crack/segment cue below 25%

## Design references

- docs/story/accessibility.md §1/§2/§5
- docs/story/save-system.md §2

## Code references

- game/scripts/ui/menu_config.gd:24,27,39,48-52
- game/scripts/autoload/audio_manager.gd:651-674
- game/scripts/core/cutscene_player.gd:353-359

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
