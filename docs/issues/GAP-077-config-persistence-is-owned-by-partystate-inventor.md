# GAP-077: Config persistence is owned by PartyState/inventory_helpers, not SaveManager (responsibility split)

| Field | Value |
|-------|-------|
| **ID** | GAP-077 |
| **Area** | Architecture |
| **Severity** | LOW |
| **Type** | design-divergence |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | arch |

## Summary

SaveManager declares CONFIG_PATH but never reads/writes it; config I/O lives in PartyState.save_config/_load_config and inventory_helpers.load_config_from_disk, splitting persistence across three files outside the designated manager.

## Current state (implementation)

Only the constant declaration is in SaveManager; functional config I/O is elsewhere.

## Desired state (per design)

Either move config save/load into SaveManager (where CONFIG_PATH lives) or move CONFIG_PATH out so ownership is coherent.

## Proposed approach

Add SaveManager.save_config/load_config delegating to the JSON helper; have PartyState call SaveManager.

## Acceptance criteria

- [ ] Config ownership is coherent with the architecture
- [ ] CONFIG_PATH lives with the code that uses it
- [ ] Callers updated

## Design references

- docs/plans/technical-architecture.md §1.3/§6.3/§6.6

## Code references

- game/scripts/autoload/save_manager.gd:14
- game/scripts/autoload/party_state.gd:664,698
- game/scripts/autoload/inventory_helpers.gd:269

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
