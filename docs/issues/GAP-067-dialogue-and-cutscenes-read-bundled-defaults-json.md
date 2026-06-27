# GAP-067: Dialogue and cutscenes read bundled defaults.json instead of the player's saved config

| Field | Value |
|-------|-------|
| **ID** | GAP-067 |
| **Area** | Save |
| **Severity** | HIGH |
| **Type** | bug |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | save |

## Summary

dialogue_box._load_text_speed and cutscene_player._load_config read res://data/config/defaults.json directly, bypassing the path that merges user://config.json, so Text Speed / Reduce Motion / Flash Intensity changes have zero effect.

## Current state (implementation)

Both hardcode the read-only defaults path; the user config file is never read by them.

## Desired state (per design)

Both source settings from PartyState.get_config()/load_config_from_disk and refresh on open.

## Proposed approach

Replace the defaults.json loads with PartyState.get_config(); reload on open() so each dialogue/cutscene picks up current settings.

## Acceptance criteria

- [ ] Changing Text Speed affects the typewriter
- [ ] Reduce Motion/Flash changes affect cutscenes
- [ ] Settings read from the merged user config

## Design references

- docs/story/save-system.md §2
- docs/story/accessibility.md §5/§7

## Code references

- game/scripts/ui/dialogue_box.gd:336-341
- game/scripts/core/cutscene_player.gd:171-174
- game/scripts/autoload/inventory_helpers.gd:269-282

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
