# GAP-053: Maren's Refuge missing its basement library and lore layer

| Field | Value |
|-------|-------|
| **ID** | GAP-053 |
| **Area** | World |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | world |

## Summary

marens_refuge.tscn is one room with only Maren, the Scene 6 trigger, and an exit; the designed exterior, ground-floor lore interactables, and Basement Library (ley-line tap, Artifact Vault, Specimen Jar) are absent.

## Current state (implementation)

No basement transition, bookshelf/lore interactables, or named POIs exist.

## Desired state (per design)

Three zones (exterior, ground floor with Pendulum Work Desk, basement library) with key items and lore per the design.

## Proposed approach

Add the basement sub-map and ground-floor lore interactables; wire the Pendulum-examination cutscene to the Work Desk.

## Acceptance criteria

- [ ] Basement Library sub-map exists
- [ ] Ground-floor lore interactables present
- [ ] Pendulum-examination cutscene wired to the Work Desk

## Design references

- docs/story/city-thornmere.md:965-1123
- docs/story/interiors.md:195-276

## Code references

- game/scenes/maps/towns/marens_refuge.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** game/scenes/maps/towns/marens_refuge.tscn is a single room: Maren (npc_id 'maren_refuge'), Scene6Trigger (dialogue_scene_id 'scene_6_marens_warning'), and ExitToOverworld. No basement transition, bookshelf/lore interactables, Pendulum Work Desk, or named POIs. Design city-thornmere.md:965-1123 and interiors.md:195-276 specify exterior + ground-floor lore + Basement Library (ley-line tap, Artifact Vault, Specimen Jar).
- **Notes:** Accurate partial-impl gap. Adding a basement sub-map and wiring a cutscene is feature work, not a bounded fix.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
