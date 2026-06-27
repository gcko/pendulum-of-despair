# GAP-003: Status-effect infliction is never wired into combat actions

| Field | Value |
|-------|-------|
| **ID** | GAP-003 |
| **Area** | Combat |
| **Severity** | HIGH |
| **Type** | partial-impl |
| **Effort** | M |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | combat, tracker |

## Summary

roll_status() and apply_status() are implemented but have zero callers; no spell, ability, item, or enemy action ever inflicts Poison/Sleep/Silence/Petrify/Slow/Confusion/Despair, and the ATB never receives status-driven Stop/Sleep/Haste/Slow modifiers.

## Current state (implementation)

The two-stage status accuracy roll and party status container exist but are dead-ended. ATB frozen/status_mods plumbing exists with nothing feeding it. Boss debuffs (e.g. Marked for Sorrow) cannot be applied. Tracker flags this at game-dev-gaps.md:612.

## Desired state (per design)

Damaging/status spells, Tricks debuffs, and enemy abilities call roll_status then apply_status, set ATB frozen/status_mods for Stop/Sleep/Haste/Slow/Despair, and apply poison ticks, honoring boss immunity lists.

## Proposed approach

Add a status-application step to spell/ability/enemy resolution; map status names to ATB modifiers (set_status_mods/set_frozen) and to per-turn ticks in battle_state.tick_statuses.

## Acceptance criteria

- [ ] A poison spell inflicts poison and ticks damage each turn
- [ ] Stop/Sleep freeze the target's ATB gauge
- [ ] Boss immunity lists are respected
- [ ] Tests assert infliction success/failure across the two-stage roll

## Design references

- docs/story/combat-formulas.md §Status Effect Accuracy / §Status Spell Resolution
- docs/story/magic.md (status spells)

## Code references

- game/scripts/combat/damage_calculator.gd:160 (roll_status uncalled)
- game/scripts/combat/battle_state.gd:136 (apply_status uncalled)
- game/scripts/combat/battle_actions.gd (no status path)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
