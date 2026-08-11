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
| **GitHub Issue** | [#214](https://github.com/gcko/pendulum-of-despair/issues/214) |
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

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The durable, maintained anchors are the file-plus-symbol bullets under **Code references**: those must name a file that exists and a symbol that file actually defines, and `scripts/quality-gates/check_stale_counts.py` fails the build if they do not. Always verify against current code before acting._
