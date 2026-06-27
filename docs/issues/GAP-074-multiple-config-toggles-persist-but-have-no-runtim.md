# GAP-074: Multiple config toggles persist but have no runtime consumers (High-Res Text, Mono Audio, Transition Style, Screen Shake, always-on cues)

| Field | Value |
|-------|-------|
| **ID** | GAP-074 |
| **Area** | Save |
| **Severity** | LOW |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#230](https://github.com/gcko/pendulum-of-despair/issues/230) |
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


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Grep across scripts/ (excluding menu_config.gd) for high_res_text, sound_mode, transition_style, screen_shake all return nothing. cutscene_player.gd:353-359 (_cmd_shake) gates ONLY on reduce_motion (354) with no screen_shake check, confirming Screen Shake off alone has no effect. audio_manager.gd:651-678 (_apply_bus_volumes) has no mono/pan down-mix. No high-res SubViewport, no transition_style branch, no HP-bar shape cue.
- **Notes:** Confirmed: all listed toggles persist (menu_config.gd:24,27,39,48-52) with no consumers. Multiple separate runtime wirings — feature work. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
