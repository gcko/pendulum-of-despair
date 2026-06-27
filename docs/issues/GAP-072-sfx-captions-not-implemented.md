# GAP-072: SFX Captions not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-072 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save |

## Summary

sfx_captions persists but has no consumer; no caption label appears for any of the 8 gameplay sound events.

## Current state (implementation)

Only reference is the menu_config setting.

## Desired state (per design)

When enabled, a lower-corner label shows the 8 event captions for 2-3s on the corresponding event.

## Proposed approach

Add a global caption CanvasLayer with a timed label; emit caption requests from the systems firing those SFX, gated on config.sfx_captions.

## Acceptance criteria

- [ ] Captions appear for the 8 events when enabled
- [ ] Captions auto-dismiss after 2-3s
- [ ] Disabled by default per config

## Design references

- docs/story/accessibility.md §6

## Code references

- game/scripts/ui/menu_config.gd:53


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu_config.gd:53 defines sfx_captions toggle. Repo-wide grep for `sfx_captions` outside menu_config.gd returns nothing — no caption CanvasLayer/label, no emitters.
- **Notes:** Confirmed missing feature. Needs a global caption layer + emit points on 8 SFX events. Not bounded. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
