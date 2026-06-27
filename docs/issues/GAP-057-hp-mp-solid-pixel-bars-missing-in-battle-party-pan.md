# GAP-057: HP/MP solid pixel bars missing in battle party panel and main menu (numeric text only)

| Field | Value |
|-------|-------|
| **ID** | GAP-057 |
| **Area** | UI |
| **Severity** | HIGH |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
