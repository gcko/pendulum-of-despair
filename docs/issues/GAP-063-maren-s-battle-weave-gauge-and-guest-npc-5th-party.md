# GAP-063: Maren's battle Weave Gauge and guest-NPC 5th party row not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-063 |
| **Area** | UI |
| **Severity** | LOW |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | partial — Weave Gauge shipped in PR #275; guest row moved to #272 |
| **GitHub Issue** | [#227](https://github.com/gcko/pendulum-of-despair/issues/227) |
| **Source domains** | ui |

## Summary

battle_party_panel hardcodes 4 rows each with only an ATBBar; there is no Weave Gauge bar for Maren and no compact 5th row for guest NPCs (Cordwyn/Kerra).

## Current state (implementation)

_rows = [null x4]; Row0-3 only; no WeaveBar node.

## Desired state (per design)

Maren's row shows a purple Weave Gauge below MP; a compact 5th guest row appears when a guest is present.

## Proposed approach

Add a conditional WeaveBar for Maren and a 5th compact Row visible when a guest occupies the party.

## Acceptance criteria

- [ ] Maren shows a Weave Gauge in battle
- [ ] A 5th row appears for guest NPCs
- [ ] Layout handles 4 vs 5 members

## Design references

- docs/story/ui-design.md §2.9/§2.3

## Code references

- game/scripts/ui/battle_party_panel.gd — `_update_weave()` (Maren's gauge; the guest row is still absent)
- game/scenes/core/battle.tscn


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** LOW
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** battle_party_panel.gd:11 var _rows = [null, null, null, null]; _ready (15-20) wires exactly Row0-3. battle.tscn defines only Row0-Row3, each with NameLabel/HPLabel/MPLabel/ATBBar (ColorRect grep shows ATBBar at 83,106,129,152) — no WeaveBar node and no 5th row. Design ui-design.md:2.9 (lines 310-318) 'Maren's party panel row includes a third gauge below her MP bar: a thin Weave Gauge bar (purple #aa44ff)'.
- **Notes:** Confirmed missing. LOW: niche per-character/guest UI. Not fixNow.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._

## Partial resolution (PR #275, 2026-07-20)

Maren's purple (#aa44ff) Weave Gauge ships: thin bar below her MP bar in battle rows, fill = wg/100 from live battle state. The guest-NPC 5th row is deferred to issue #272 — the engine has no guest support (no Cordwyn/Kerra data, all party iteration capped at 4), so the row would have no data source.
