# GAP-072: SFX Captions not implemented

| Field | Value |
|-------|-------|
| **ID** | GAP-072 |
| **Area** | Save |
| **Severity** | MEDIUM |
| **Type** | missing-feature |
| **Effort** | M |
| **Epic** | No |
| **Status** | open — CONFIRMED |
| **GitHub Issue** | [#213](https://github.com/gcko/pendulum-of-despair/issues/213) |
| **Source domains** | save |

## Summary

sfx_captions persists but has no consumer; no caption label appears for any of the 8 gameplay sound events.

## Current state (implementation)

Only reference is the menu_config setting.

## Desired state (per design)

When enabled, a lower-corner label shows the 8 event captions for 2-3s on the corresponding event.

## Proposed approach

Add a global caption CanvasLayer with a timed label; emit caption requests from the systems firing those SFX, gated on config.sfx_captions.

## Acceptance criteria

- [ ] Captions appear for the 8 events when enabled
- [ ] Captions auto-dismiss after 2-3s
- [ ] Disabled by default per config

## Design references

- docs/story/accessibility.md §6

## Code references

- game/scripts/ui/menu_config.gd


## Verification (fresh-eyes adversarial pass)

- **Verdict:** CONFIRMED
- **Verified severity:** MEDIUM
- **Safe to fix immediately:** no — tracked as development work
- **Evidence:** menu_config.gd:53 defines sfx_captions toggle. Repo-wide grep for `sfx_captions` outside menu_config.gd returns nothing — no caption CanvasLayer/label, no emitters.
- **Notes:** Confirmed missing feature. Needs a global caption layer + emit points on 8 SFX events. Not bounded. fixNow=false.

---

_Generated 2026-06-27 by the `pod-gap-analysis` ultracode workflow (design-vs-implementation gap analysis)._

_**How to read the citations.** The `file.ext:NNN` line numbers in the Summary, Evidence and Notes prose are a frozen 2026-06-27 snapshot and are deliberately NOT maintained — the code has moved under them and re-numbering them on every refactor would be busywork that silently rots again. Treat them as historical provenance only. The **Code references** bullets are the measured ones: they carry no line numbers, and `check_gap_code_references()` in `scripts/quality-gates/check_stale_counts.py` fails the build if a path listed there stops existing, if a line anchor is reintroduced, or if a bullet names a `symbol()` its file no longer defines. Most bullets name a file without a symbol, so what the gate guarantees for those is that the file is still there — not where inside it to look. Two kinds of rot slip through that check, both measured and repaired on 2026-08-11. A path check cannot tell you the cited file is still the relevant one, so a decomposition that splits a script into siblings leaves every citation green and pointing at the wrong file (#382); a `symbol()` anchor is the fix, because the gate does follow those. And a bullet that asserts an absence — "no status path", "no equip references" — cannot be checked at all, and keeps passing after the missing thing is built (#383). Where such a bullet names a real script, the repair is a `symbol()` anchor describing what that file does hold; GAP-005, GAP-079 and GAP-080 were converted that way on 2026-08-11 and the gate now follows them. Eight of them cannot be repaired: seven name a directory that holds nothing on the topic (`game/scripts/` for transport logic, and siblings) and one names a `.tscn`, which has no symbols to anchor. For those eight the absence *is* the finding, so re-verify them by hand — a green build says nothing about them. For the same reason, do not lint this section with a blanket `(no…|only…)` ban: across the 188 bullets here that pattern also flags the three inventory bullets it is meant to encourage ("only ember_vein, …") and the `play_animation()` bullet in GAP-039, which is symbol-anchored and already checked. Always verify against current code before acting._
