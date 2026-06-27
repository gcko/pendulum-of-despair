# GAP-057: HP/MP solid pixel bars missing in battle party panel and main menu (numeric text only)

| Field | Value |
|-------|-------|
| **ID** | GAP-057 |
| **Area** | UI |
| **Severity** | HIGH (verified: MEDIUM) |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
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

- game/scripts/ui/battle_party_panel.gd:46-56
- game/scenes/core/battle.tscn:73-78
- game/scripts/ui/menu_overlay.gd:326-336


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_party_panel.gd:46-56 renders HPLabel/MPLabel as text with modulate only; the only ColorRect in a battle row is ATBBar (battle.tscn:83,106,129,152). menu_overlay.gd:326-336 renders HP/MP as text labels with modulate. grep for ColorRect in menu.tscn/battle.tscn shows NO HP/MP fill bars (only Background, PreviewRect, CrystalScreen XPBar, and ATBBars). Design ui-design.md:8 '/One modern addition: HP/MP bars alongside numeric values', :31-32 'Bars: Solid pixel fills...HP/MP/ATB bars are rectangles', :214/:216 'HP/MP label + solid pixel bar + numeric value', :370 menu rows 'HP bar + numeric | MP bar + numeric'.
- **Notes:** Real divergence. Refined HIGH->MEDIUM: it is a cosmetic enhancement with no functional/gameplay impact in the vertical slice, though design explicitly flags it as the single intended modern addition. Not fixNow: requires adding ColorRect bg/fill nodes to 4 battle rows + 4 menu rows across two .tscn files plus fill-ratio logic in two scripts — a feature implementation, not a bounded data/doc fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
