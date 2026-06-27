# GAP-024: Enemy special abilities absent from data; regular-enemy AI can only basic-attack or defend

| Field | Value |
|-------|-------|
| **ID** | GAP-024 |
| **Area** | Enemies |
| **Severity** | HIGH |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | enemies |

## Summary

No enemy has an abilities array, so the AI's 20% ability roll always falls through to defend (effective 70% attack / 30% defend); no designed kits (Poison, Frenzy, Flame Breath AoE, Pack Howl, swarm-on-death) exist and enemy actions never inflict status.

## Current state (implementation)

grep '"abilities"' in enemy data returns nothing; battle_actions never calls enemy.apply_status. Tracker admits the apply path is unwired but doesn't track the missing ability data.

## Desired state (per design)

Each enemy carries its designed ability list (id, target, element, power, status, rate); the AI selects and resolves them, inflicting status (via roll_status), handling multi-hit, AoE-on-death, and pack buffs.

## Proposed approach

Add an abilities schema to enemy JSON (Act I families first), populate from palette-families.md/act-i.md, wire battle_actions to resolve effects + call apply_status, and handle AoE-on-death and group buffs. Depends on GAP-003.

## Acceptance criteria

- [ ] Act-I enemies have populated ability lists
- [ ] Enemies inflict status and use multi-hit attacks
- [ ] Unstable Crystal's Shard Burst fires on death
- [ ] Pack/group buffs function

## Design references

- docs/story/bestiary/palette-families.md (per-family 'New Abilities')
- docs/story/bestiary/act-i.md:104-107

## Code references

- game/data/enemies/act_i.json (no 'abilities' field in any of 28 entries)
- game/scripts/combat/battle_ai.gd:31-39
- game/scripts/combat/battle_actions.gd (no apply_status path)

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
