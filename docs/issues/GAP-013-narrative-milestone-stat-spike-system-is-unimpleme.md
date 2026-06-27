# GAP-013: Narrative milestone stat-spike system is unimplemented (no framework; 11 of 12 spikes absent)

| Field | Value |
|-------|-------|
| **ID** | GAP-013 |
| **Area** | Progression |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open |
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

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
