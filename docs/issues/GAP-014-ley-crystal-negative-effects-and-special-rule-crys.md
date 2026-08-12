# GAP-014: Ley Crystal negative effects and special-rule crystals have data but no mechanics

| Field | Value |
|-------|-------|
| **ID** | GAP-014 |
| **Area** | Progression |
| **Severity** | MEDIUM |
| **Type** | partial-impl |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#181](https://github.com/gcko/pendulum-of-despair/issues/181) |
| **Source domains** | progression |

## Summary

Negative-effect crystals carry descriptive JSON and a UI warning but no mechanics: Frost Veil SPD-15%, Grey Remnant HP-40/level-up + 25% Pallor damage, Flame Heart self-flame, Storm Eye random-target are no-ops; Null Crystal Despair immunity and Cael's Echo character-specific bonuses are absent from data and code.

## Current state (implementation)

negative_effect blocks are description-only; the menu shows a warning string; combat references none of these crystals. Cael's Echo level_bonuses lack the Lira/Edren conditional bonuses.

## Desired state (per design)

Each negative/special effect is mechanically enforced (SPD penalty and Pallor-damage in combat, HP-loss-per-level in progression, Despair immunity in status, Cael's Echo conditional bonuses in data + get_equipment_bonus).

## Proposed approach

Add a negative_effect/special_rule handler keyed off the equipped crystal; hook SPD/Pallor multipliers into battle_state/damage_calculator, HP-loss into level-up, immunity into status; backfill Cael's Echo data. Mostly Act III/post-game scope.

## Acceptance criteria

- [ ] Frost Veil applies SPD-15% in battle
- [ ] Grey Remnant reduces HP on level-up and amplifies Pallor damage
- [ ] Null Crystal grants Despair immunity
- [ ] Cael's Echo grants Lira/Edren conditional bonuses

## Design references

- docs/story/progression.md:336-343,349-352

## Code references

- game/data/ley_crystals.json
- game/scripts/ui/menu_ley_crystal.gd — `_show_detail()` (the only reader of a crystal's negative_effect, and only to warn)
- game/scripts/combat/ (no negative_effect refs)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** ley_crystals.json negative_effect blocks are non-mechanical: frost_veil -> {description:'Wearer SPD -15% in battle', type:'spd_penalty'}, grey_remnant -> {description:'HP -40 per level-up. +25% Pallor damage in combat.', type:'hp_loss_and_vulnerability'} (flame_heart/storm_eye similar). menu_ley_crystal.gd:215-223 only renders the description as a warning string. No combat/progression code references these crystals. null_crystal has empty level_bonuses ([{},{},{},{},{}]) and only an invocation-based temporary 'despair_immune' (turns:3) — the design's passive while-equipped immunity (progression.md:351) is absent. caels_echo level_bonuses carry no Lira/Edren conditional bonuses (progression.md:352).
- **Notes:** Substantively confirmed. Minor wording nit: the issue says 'description-only' but the JSON also carries a `type` discriminator (e.g. spd_penalty) — still no handler consumes it, so the no-mechanics claim holds. Each effect (SPD penalty, Pallor-damage amp, HP-loss-per-level, passive Despair immunity, character-conditional bonuses) is a distinct combat/progression feature, mostly Act III/post-game scope. Not bounded.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Always verify against current code before acting._
