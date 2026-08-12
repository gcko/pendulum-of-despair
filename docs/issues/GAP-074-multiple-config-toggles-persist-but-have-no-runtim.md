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

**Re-verified by behavior search 2026-08-12 (#413): 0 of 4 met, and the first
criterion has moved in the wrong direction.** Searched `game/scripts/` and
`game/tests/` for each key. `screen_shake` and `transition_style` now have a
second consumer, but it is `menu_config.gd` again: turning Reduce Motion on
saves the prior values, forces `screen_shake` to `false` and `transition_style`
to `"simple"` through `PartyState.set_config()`, and turning it off restores
them. That couples the settings more tightly rather than separating them —
`cutscene_commands.gd` `_shake()` still returns early on `reduce_motion` alone
and never reads `screen_shake`, so switching Screen Shake off by itself still
changes nothing. `sound_mode` and `high_res_text` have no consumer outside
`menu_config.gd` at all: `audio_manager.gd` never mentions `sound_mode`, so
there is no down-mix. And there is no HP-bar cue — `stat_bar_helpers.gd` and
`battle_party_panel.gd`, which own the bars PR #275 shipped, contain no
`crack`, no segment logic and no 25% threshold.

## Design references

- docs/story/accessibility.md §1/§2/§5
- docs/story/save-system.md §2

## Code references

- game/scripts/ui/menu_config.gd — `_apply_cascades()` (the Reduce Motion cascade that forces `screen_shake` false and `transition_style` "simple", and restores them) and `_is_setting_disabled()` (which greys both out while Reduce Motion is on)
- game/scripts/autoload/audio_manager.gd — no `sound_mode` reader; the Mono criterion has no implementation to point at, so re-check this one by hand rather than trusting a green path check
- game/scripts/ui/stat_bar_helpers.gd — the bar renderer PR #275 shipped, which is where the below-25% HP cue would go and currently has no threshold logic
- game/scripts/core/cutscene_commands.gd — `_shake()` (the shake emitter, gated on reduce_motion alone; it never reads screen_shake, which outside menu_config.gd has no consumer at all. PR #357 moved this out of cutscene_player.gd, where it was `_cmd_shake`)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Grep across scripts/ (excluding menu_config.gd) for high_res_text, sound_mode, transition_style, screen_shake all return nothing. cutscene_player.gd:353-359 (_cmd_shake) gates ONLY on reduce_motion (354) with no screen_shake check, confirming Screen Shake off alone has no effect. audio_manager.gd:651-678 (_apply_bus_volumes) has no mono/pan down-mix. No high-res SubViewport, no transition_style branch, no HP-bar shape cue.
- **Notes:** Confirmed: all listed toggles persist (menu_config.gd:24,27,39,48-52) with no consumers. Multiple separate runtime wirings — feature work. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
