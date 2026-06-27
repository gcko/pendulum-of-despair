# GAP-084: Architecture doc enemy schema diverges from actual JSON data and runtime code

| Field | Value |
|-------|-------|
| **ID** | GAP-084 |
| **Area** | Docs |
| **Severity** | MEDIUM |
| **Type** | doc-inconsistency |
| **Effort** | S |
| **Epic** | No |
| **Status** | open |
| **GitHub Issue** | _(set during migration)_ |
| **Source domains** | arch |

## Summary

§2.1 documents a single-tier steal object and §2.8 proposes flat steal_common/steal_rare, but data and code use nested steal:{common,rare}; the doc also omits the threat and locations fields present in every enemy record.

## Current state (implementation)

enemy.gd reads steal_data.get(tier) with tier common/rare; ley_vermin has nested steal + threat + locations; grep 'threat' in the doc returns 0.

## Desired state (per design)

The doc shows the nested two-tier steal shape and includes threat and locations fields.

## Proposed approach

Update §2.1 example and remove/replace the stale §2.8 note; add threat and locations to the documented fields.

## Acceptance criteria

- [ ] Doc shows nested two-tier steal
- [ ] threat and locations documented
- [ ] §2.8 stale note removed/updated

## Design references

- docs/plans/technical-architecture.md §2.1/§2.8

## Code references

- game/data/enemies/act_i.json
- game/scripts/entities/enemy.gd:259-271

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis). Verify against current code before acting._
