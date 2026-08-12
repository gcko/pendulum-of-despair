# GAP-013: Narrative milestone stat-spike system is unimplemented (no framework; 11 of 12 spikes absent)

| Field | Value |
|-------|-------|
| **ID** | GAP-013 |
| **Area** | Progression |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | L |
| **Epic** | No |
| **Status** | open — CONFIRMED (premise re-verified 2026-08-11 against the post-#219 tree; still open, severity still MEDIUM) |
| **GitHub Issue** | [#180](https://github.com/gcko/pendulum-of-despair/issues/180) |
| **Source domains** | progression |

## Summary

No system applies one-time story-triggered permanent stat boosts; only Cael's exists (divergently as of 2026-06-27; correctly as of #219 — see Current state). No generic hook is wired to EventFlags, and negative deltas (e.g. Torren HP -15%) are unsupported.

## Current state (implementation)

None of the 11 non-Cael spikes exist in code or data. Cael's is implemented and no longer divergent: GAP-010 (#219) replaced the damage_calculator multiplier with a data-driven `hidden_spike` block in game/data/characters/cael.json, applied by ProgressionHelpers on every base-stat rebuild. What is still missing is the framework the other 11 need — an EventFlags trigger, percent and negative deltas, and applied-spike bookkeeping in the save.

## Desired state (per design)

A data-driven framework mapping event-flag -> {character, stat_deltas, percent_deltas, once}; on flag set, PartyState applies deltas to base_stats idempotently and records applied spike IDs in save.

## Proposed approach

Add a spikes data file and an apply hook in PartyState triggered by EventFlags; guard double-application in save; cover idempotency and percent reductions with tests. Absorbs GAP-010.

## Acceptance criteria

- [ ] Setting a spike flag applies its deltas once and persists
- [ ] Negative/percent deltas (e.g. -15% HP) work
- [ ] Re-setting a flag does not double-apply
- [x] Cael's spike is delivered as data rather than as a damage_calculator hack (done by GAP-010/#219; it still runs through ProgressionHelpers rather than through the milestone framework this gap asks for)

## Design references

- docs/story/progression.md:380-407 (12 one-time permanent boosts)

## Code references

- game/scripts/util/progression_helpers.gd — `leveled_stats_with_spike()` (the whole of the spike machinery today: it adds `char_data.hidden_spike` on top of the leveled base at join and on every level-up, and is keyed off character data, not an event flag)
- game/data/characters/cael.json — the only `hidden_spike` block in the data; the other 11 spikes of progression.md § Narrative Milestone Stat Spikes have no data anywhere


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** Repo-wide search for spike/milestone application finds only damage_calculator.gd:45-47 `# Cael's Pallor Shimmer: +10% physical damage ... if attacker_id == "cael": raw *= 1.1` — a live combat multiplier, not a one-time permanent base_stats spike. No spike data file and no EventFlags-driven apply hook exist in game/scripts. Design progression.md:380-407 lists 12 one-time permanent boosts (incl. Torren's MAG +8/SPD +4/HP -15% and the campfire All stats +2).
- **Re-verified 2026-08-11 (#383):** the 2026-06-27 evidence above is stale in one respect only. `damage_calculator.gd` no longer contains any Cael or spike reference — GAP-010 (#219) removed the `raw *= 1.1` hack and re-delivered the spike as `hidden_spike` data applied by `ProgressionHelpers.leveled_stats_with_spike`. So 1 of 12 spikes is implemented, matching this gap's title, and the divergence sub-claim is closed. Everything else holds: no EventFlags-driven apply hook, no spike data file, no percent or negative deltas, no applied-spike record in the save. Severity stays MEDIUM — the same 11 spikes are missing as before, and nothing about #219 made them harder or easier to build.
- **Notes:** 11 of 12 spikes absent; the lone Cael implementation is divergent (combat hack rather than the hidden permanent ATK+2/MAG+2/SPD+1 spike at progression.md:388). Building this is a data-driven framework with idempotency, percent/negative deltas, and save persistence — a feature, not a bounded fix. Issue notes it absorbs GAP-010.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
