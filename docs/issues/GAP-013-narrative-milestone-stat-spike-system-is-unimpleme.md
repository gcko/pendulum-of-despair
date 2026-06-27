# GAP-013: Narrative milestone stat-spike system is unimplemented (no framework; 11 of 12 spikes absent)

| Field | Value |
|-------|-------|
| **ID** | GAP-013 |
| **Area** | Progression |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | progression |

## Summary

No system applies one-time story-triggered permanent stat boosts; only Cael's exists (incorrectly). No generic hook is wired to EventFlags, and negative deltas (e.g. Torren HP -15%) are unsupported.

## Current state (implementation)

None of the 11 non-Cael spikes exist in code or data; the only implementation is the divergent Cael damage hack.

## Desired state (per design)

A data-driven framework mapping event-flag -> {character, stat_deltas, percent_deltas, once}; on flag set, PartyState applies deltas to base_stats idempotently and records applied spike IDs in save.

## Proposed approach

Add a spikes data file and an apply hook in PartyState triggered by EventFlags; guard double-application in save; cover idempotency and percent reductions with tests. Absorbs GAP-010.

## Acceptance criteria

- [ ] Setting a spike flag applies its deltas once and persists
- [ ] Negative/percent deltas (e.g. -15% HP) work
- [ ] Re-setting a flag does not double-apply
- [ ] Cael's spike is delivered through this system, not damage_calculator

## Design references

- docs/story/progression.md:380-407 (12 one-time permanent boosts)

## Code references

- game/scripts/ (no milestone/spike application)
- game/scripts/combat/damage_calculator.gd:45-47 (only spike, divergent)


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Repo-wide search for spike/milestone application finds only damage_calculator.gd:45-47 `# Cael's Pallor Shimmer: +10% physical damage ... if attacker_id == "cael": raw *= 1.1` — a live combat multiplier, not a one-time permanent base_stats spike. No spike data file and no EventFlags-driven apply hook exist in game/scripts. Design progression.md:380-407 lists 12 one-time permanent boosts (incl. Torren's MAG +8/SPD +4/HP -15% and the campfire All stats +2).
- **Notes:** 11 of 12 spikes absent; the lone Cael implementation is divergent (combat hack rather than the hidden permanent ATK+2/MAG+2/SPD+1 spike at progression.md:388). Building this is a data-driven framework with idempotency, percent/negative deltas, and save persistence — a feature, not a bounded fix. Issue notes it absorbs GAP-010.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
