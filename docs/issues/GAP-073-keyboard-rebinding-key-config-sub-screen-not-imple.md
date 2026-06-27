# GAP-073: Keyboard rebinding / Key Config sub-screen not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-073 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save, ui |

## Summary

There is no Key Config entry and no rebinding sub-screen or conflict detection; keys are fixed to the project input map.

## Current state (implementation)

SETTINGS has no key_config; no InputMap remap/conflict logic exists.

## Desired state (per design)

A Key Config sub-screen rebinds all battle/menu actions, warns on conflicts requiring resolution, and persists mappings.

## Proposed approach

Add a Key Config sub-scene using InputMap.action_erase_events/action_add_event with a capture-next-key flow and conflict checks; persist overrides in config.

## Acceptance criteria

- [ ] All actions are rebindable
- [ ] Conflicts are detected and must be resolved
- [ ] Mappings persist across sessions

## Design references

- docs/story/accessibility.md §4/§7
- docs/story/ui-design.md §10.3/§17

## Code references

- game/scripts/ui/menu_config.gd:9-54


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu_config.gd SETTINGS (9-54) has no key_config entry. Repo-wide grep for `key_config` and `InputMap` across scripts/ returns nothing — no remap/conflict logic.
- **Notes:** Confirmed missing feature. Rebinding sub-screen with capture-next-key + conflict detection + persistence is substantial. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
