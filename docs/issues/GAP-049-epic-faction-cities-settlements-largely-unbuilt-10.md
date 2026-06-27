# GAP-049: EPIC: Faction cities/settlements largely unbuilt (10 Carradan, Highcairn, Greyvale, 5 Thornmere settlements, full Duskfen)

| Field | Value |
|-------|-------|
| **ID** | GAP-049 |
| **Area** | World |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | XL |
| **Epic** | Yes |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | world |

## Summary

Built towns cover only Valdris Crown districts plus partial Roothollow/Maren's Refuge and the Ironmouth escape stub; all other faction settlements (~24) are unbuilt.

## Current state (implementation)

Tracker's 4.5 '4+ towns' phrasing severely undercounts the remaining settlements across Carradan/Valdris/Thornmere.

## Desired state (per design)

All designed settlements built per the three city docs (10 Carradan, Highcairn/Thornwatch/Greyvale/Aelhart, Ashgrove/Canopy Reach/Greywood Camp/Stillwater Hollow/Sunstone Ridge, full Duskfen).

## Proposed approach

Single cities epic; enumerate settlements by faction in the tracker so the ~24 remaining are visible.

## Acceptance criteria

- [ ] Tracker enumerates remaining settlements by faction
- [ ] Settlements build act-by-act with shops/NPCs
- [ ] Each has the designed building directory

## Design references

- docs/story/city-carradan.md
- docs/story/city-valdris.md:660,877,1061
- docs/story/city-thornmere.md

## Code references

- game/scenes/maps/towns/ (only Valdris Crown districts + roothollow + marens_refuge + ironmouth stub)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
