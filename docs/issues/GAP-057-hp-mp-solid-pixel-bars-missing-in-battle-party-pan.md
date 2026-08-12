# GAP-057: HP/MP solid pixel bars missing in battle party panel and main menu (numeric text only)

| Field | Value |
|-------|-------|
| **ID** | GAP-057 |
| **Area** | UI |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | resolved — PR #275 |
| **GitHub Issue** | [#203](https://github.com/gcko/pendulum-of-despair/issues/203) |
| **Source domains** | ui |

## Summary

Both battle rows and the main-menu party panel render HP/MP as numeric labels with color modulation only; the design's explicitly-called-out single modern addition — solid pixel HP/MP fill bars — exists nowhere (only ATBBar is a ColorRect).

## Current state (implementation)

battle.tscn rows have NameLabel/HPLabel/MPLabel/ATBBar; menu party rows are text-only.

## Desired state (per design)

Each party row in battle and menu shows a solid pixel HP bar (green, red below 25%) and MP bar (blue) alongside the numeric value.

## Proposed approach

Add HPBar/MPBar ColorRect (bg + fill) to each battle and menu Row; compute fill_ratio and set width + color in _update_row/_update_party_row.

## Acceptance criteria

- [ ] Battle and menu rows show HP and MP fill bars
- [ ] HP bar turns red below 25%
- [ ] Numeric values remain alongside the bars

## Design references

- docs/story/ui-design.md §1.2/§2.1/§2.3/§3.3

## Code references

- game/scripts/ui/battle_party_panel.gd — `_set_fill()` (the HP/MP fill bars)
- game/scenes/core/battle.tscn
- game/scripts/ui/menu_party_panel.gd — `_set_bar_fill()` (the menu-row HP/MP fill bars; the party panel was extracted from menu_overlay.gd, which renders no HP/MP)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_party_panel.gd:46-56 renders HPLabel/MPLabel as text with modulate only; the only ColorRect in a battle row is ATBBar (battle.tscn:83,106,129,152). menu_overlay.gd:326-336 renders HP/MP as text labels with modulate. grep for ColorRect in menu.tscn/battle.tscn shows NO HP/MP fill bars (only Background, PreviewRect, CrystalScreen XPBar, and ATBBars). Design ui-design.md:8 '/One modern addition: HP/MP bars alongside numeric values', :31-32 'Bars: Solid pixel fills...HP/MP/ATB bars are rectangles', :214/:216 'HP/MP label + solid pixel bar + numeric value', :370 menu rows 'HP bar + numeric | MP bar + numeric'.
- **Notes:** Real divergence. Refined HIGH->MEDIUM: it is a cosmetic enhancement with no functional/gameplay impact in the vertical slice, though design explicitly flags it as the single intended modern addition. Not fixNow: requires adding ColorRect bg/fill nodes to 4 battle rows + 4 menu rows across two .tscn files plus fill-ratio logic in two scripts — a feature implementation, not a bounded data/doc fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._

## Resolution (PR #275, 2026-07-20)

Solid pixel HP/MP fill bars now render in battle party rows (new instanced scene `game/scenes/ui/battle_party_panel.tscn`) and main-menu party rows, alongside the retained numeric values. HP fill uses the shipped #44cc44 (doc lists "#44ff44 / #44cc44" ambiguously) and turns #ff4444 below 25% via the shipped integer-division idiom, centralized in `StatBarHelpers`.
