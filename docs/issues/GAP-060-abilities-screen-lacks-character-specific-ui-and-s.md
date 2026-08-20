# GAP-060: Abilities screen lacks character-specific UI and shows hardcoded resource values

| Field | Value |
|-------|-------|
| **ID** | GAP-060 |
| **Area** | UI |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#206](https://github.com/gcko/pendulum-of-despair/issues/206) |
| **Source domains** | ui |

## Summary

The Abilities screen renders a generic name+cost list with hardcoded resource headers ('AP 0/10','AC 12/12','WG 0/100'); none of the unique elements (Edren stance highlight, Torren Favor pips, Sable cooldown pips + front-row icon, Maren Weave gauge, Lira device qty) exist.

## Current state (implementation)

RESOURCE_LABELS returns literal strings; _update_grid only formats name + cost.

## Desired state (per design)

Each character's set shows its unique UI element and live resource value per §7.3.

## Proposed approach

Add per-command rendering branches (pips/gauge/highlight) and source live values from PartyState. Depends on GAP-002 resource state.

## Acceptance criteria

- [ ] Resource headers show live values
- [ ] Per-character unique elements render
- [ ] Values update with PartyState

**Re-verified by behavior search 2026-08-12 (#413): 0 of 3 met, but the first
two criteria are now half-true and the doc should not be read as "nothing
works".** `ability_helpers.gd` `get_resource_label()` no longer returns a
literal for every character: where `RESOURCE_LABELS` maps the command to `"MP"`
— Cael's Rally, Torren's Spiritcall, Sable's Tricks — it formats
`"MP %d/%d"` from the member dictionary `menu_abilities.gd` passes in, which
comes from `PartyState`. The three non-MP commands are the ones still frozen:
Bulwark returns `"AP 0/10"`, Forgewright `"AC 12/12"` and Arcanum `"WG 0/100"`
regardless of state. So half the roster satisfies criteria 1 and 3 today and
half does not, and the criteria as written are all-or-nothing, so none is
ticked. Criterion 2 is untouched: searched `game/scripts/ui/` for stance
highlights, Favor pips, cooldown pips and a front-row icon and found none.

One of the three frozen headers has a live source that this screen simply does
not read, which is the kind of thing the cited-path method misses. PR #275
shipped Maren's Weave Gauge, but into the *battle* party panel:
`battle_party_panel.gd` `_update_weave()` draws it, `stat_bar_helpers.gd`
`shows_weave_gauge()` decides who gets one, and the value itself is battle
state, fed by `battle_state.gd` `gain_weave_gauge_for_maren()`. So the Abilities
screen's `"WG 0/100"` is stale rather than sourceless — but the gauge is
per-battle and does not persist into `PartyState`, so wiring it here is a design
question (show 0 out of battle? carry it in party state?) and not a lookup.

## Design references

- docs/story/ui-design.md §7.3

## Code references

- game/scripts/ui/menu_abilities.gd
- game/scripts/ui/ability_helpers.gd — `get_resource_label()` (the resource header the finding recorded as hardcoded; now live for the three MP commands, still literal for AP/AC/WG)
- game/scripts/ui/battle_party_panel.gd — `_update_weave()`, where the Weave Gauge is actually drawn today (the battle panel, not this screen)
- game/scripts/ui/stat_bar_helpers.gd — `shows_weave_gauge()`, which decides who gets one
- game/scripts/combat/battle_state.gd — `gain_weave_gauge_for_maren()`, the only writer of the WG value, which is per-battle and never reaches PartyState


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** ability_helpers.gd:4-11 RESOURCE_LABELS contains literal strings 'AP 0/10','AC 12/12','WG 0/100' (only the 'MP' entries are live-resolved via member current_mp/max_mp at lines 64-70). menu_abilities.gd:108-126 _update_grid only formats name + cost ('%-12s %6s'); no per-character branches for Edren stance highlight, Torren Favor pips, Sable cooldown/front-row icon, Maren Weave gauge, or Lira device qty. Design ui-design.md:7.3 table lists each character's unique UI element.
- **Notes:** Confirmed partial-impl with hardcoded headers. Depends on GAP-002 (live resource state). Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
