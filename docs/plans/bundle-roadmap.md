# Gap-Closure Roadmap

A living plan for closing the remaining `gap-analysis` GitHub Issues. Work ships
as **bundles** — small sets of 2–4 related issues that share a code touchpoint
and land as ONE PR via the `/issue-bundle` skill.

**Ordering lives in the [GitHub Project](https://github.com/users/gcko/projects/3).**
Every open issue carries exactly one phase milestone and is on the Project
board. The 2026-08-10 re-plan also gave each issue open at that moment a
Project `Priority` of P0/P1/P2 and, for L and XL work only, a `Size`. Issues
filed since then are milestoned but **unprioritized** — they carry no
`Priority`, and a handful carry no type label either. This document is the
prose companion — the Project is the queue.

### How to read the phase headers

Counts were measured against the live milestones on **2026-08-12**. Each header
reads `(N open — P prioritized below, U filed since the re-plan)`:

- **N open** is the milestone's open-issue count on GitHub.
- **P prioritized below** is what the bullets enumerate: the P0/P1/P2 items from
  the re-plan that are still open.
- **U filed since the re-plan** is the remainder — real, milestoned work that
  this document deliberately does not name, because it would rot faster than it
  is read. Query it instead:
  `gh issue list --milestone "<phase>" --state open`.

Nothing recomputes these numbers. `check_stale_counts.py` reconciles the GAP
docs with `docs/issues/README.md` but knows nothing about this file, so a phase
list can keep planning work that has already merged (#410 was exactly that).
Re-measure the headers whenever you touch a phase.

**Process:** pick the next `Ready` items inside the lowest-numbered open phase →
implement together on one branch (`/game-designer` or `/gut-tdd`) → one PR
(`/create-pr`) → review & fix (`/pr-review-response`). Epics are too big to
bundle — slice them into their own multi-PR efforts.

---

## Shipped

| Bundle | Issues | State |
|--------|--------|-------|
| Bundle 1 | GAP-001 magic submenu, GAP-007 ATB config | ✅ merged (PR #241) |
| Bundle 2a | GAP-010 Cael spike, GAP-008 type-traits (slice) | ✅ merged (PR #243) |
| Bundle 2b | GAP-003 status system (player→enemy core) | ✅ merged (PR #245) |
| Bundle 3a | GAP-024 enemy abilities, GAP-028 bestiary reconciliation | ✅ merged (PR #251) |
| Bundle 3b | GAP-009 data-driven boss AI | ✅ merged (PR #255) |
| Bundle 4a | Act-I enemy kits + selector schema (#249/#250) | ✅ merged (PR #258) |
| Bundle 4b | Paralysis + player-ATB auto-skip (#248) | ✅ merged (PR #259) |
| Bundle 5 | GAP-025 encounter scaling, GAP-026 per-tile zones, GAP-027 formation overrides | ✅ merged (PR #268) |
| Bundle 6 | GAP-057 HP/MP bars, GAP-063 Weave Gauge (guest row → #272) | ✅ merged (PR #275) |

All six planned bundles have shipped. The original clustering (2026-06-28) is
exhausted; the phases below are the 2026-08-10 re-plan over the 93 issues open
at that moment. Two of its phases have since closed out entirely:

| Phase | Milestone state | Issues |
|-------|-----------------|--------|
| Phase 1 — Live Regressions | ✅ 0 open, 11 closed | #164, #165, #171, #184, #190, #192, #260, #269, #270, #274, #276 |
| Infra & Docs | ✅ 0 open, 15 closed | the re-plan's #235, #236, #237, #238, #265 plus ten filed and closed afterwards |

A successor milestone, **Infra & Docs II — Citation Rot & Doc Hygiene**, is
open with 7 issues; it postdates the re-plan and has no phase section below.

---

## Phase order

Phases are strictly ordered by *what unblocks what*, not by severity. The
gap-analysis `sev:*` labels are kept as historical signal but are **not** the
priority axis — Project `Priority` is.

### Phase 1 — Live Regressions (0 open — complete)

Behavior that was already built and demonstrably wrong. All eleven issues are
closed; the roster is in the Shipped table above. Nothing is queued here.

### Phase 2 — Combat Completion (29 open — 11 prioritized below, 18 filed since the re-plan)

Closes out the combat layer so it can be considered feature-complete before the
world grows around it.

- **P0:** #178 GAP-008 buff/type multipliers never applied · #158 GAP-002 **EPIC**
  six character commands (XL — slice per character)
- **P1:** #177 GAP-006 ATB speed factors ~4× off spec · #246 deferred status
  effects · #256 bespoke Act-I enemy abilities · #257 kits for no-kit Act-I
  enemies · #176 GAP-005 twelve dual-tech combos (L)
- **P2:** #253 boss charge interrupts · #254 Cael-as-boss Rally kit · #272 guest
  NPC battle support · #273 battle party-row polish

### Phase 3 — Progression & Save (15 open — 12 prioritized below, 3 filed since the re-plan)

The Esper/Magicite-model progression framework plus save integrity. #161 and
#174 gate most of the rest.

- **P0:** #161 GAP-011 permanent crystal accumulation (L) · #174 GAP-066
  Faint-and-Fast-Reload persistence (L)
- **P1:** #180 GAP-013 milestone stat spikes (L) · #181 GAP-014 crystal negative
  effects · #209 GAP-068 auto-save triggers · #211 GAP-070 playtime increment ·
  #218 GAP-083 SaveManager unit tests (L)
- **P2:** #220 GAP-015 XP for reserve/KO · #232 GAP-076 save validation depth ·
  #233 GAP-077 config-persistence ownership · #210 GAP-069 save Copy/Delete ·
  #231 GAP-075 inn rest flow

### Phase 4 — Items, Shop & Crafting (8 open — 4 prioritized below, 4 filed since the re-plan)

- **P1:** #183 GAP-021 item effect stubs (L) · #163 GAP-017 shop Sell mode (L)
- **P2:** #182 GAP-018 shop Buy mode UI (L) · #162 GAP-016 **EPIC** Arcanite
  Forging (XL)

### Phase 5 — Dialogue & Story Flags (16 open — 6 prioritized below, 10 filed since the re-plan)

Prerequisite for Acts II–IV and the sidequest system: consequences must stick
before story content depends on them.

The re-plan's only P0 here, #170 GAP-037 choice consequences for standalone
dialogue, has shipped and is closed. **#191 GAP-039 dialogue animation now
leads the phase** as its highest-priority open item. It is still P1 on the
Project board and this document does not overrule that — promoting it to P0
means editing the board, not this list.

- **P1:** #191 GAP-039 dialogue animation (L) · #194 GAP-045 NPC act-state
  variants · #193 GAP-043 Act II content ungated in Act I
- **P2:** #224 GAP-040 speaker name tag · #225 GAP-041 Cael grey border ·
  #271 reconcile mechanical period flags with canon

### Phase 6 — World & Overworld (33 open — 24 prioritized below, 9 filed since the re-plan)

The largest phase by far. #167 is the keystone — the continental overworld —
and almost every other world issue is cheaper after it lands.

- **P0:** #167 GAP-029 **EPIC** continental overworld (XL) · #197 GAP-050 Aelhart
  starting village (L)
- **P1:** #168 GAP-030 **EPIC** transport (XL) · #169 GAP-031 **EPIC** act world
  transforms (XL) · #172 GAP-044 **EPIC** sidequest system (XL) · #173 GAP-047
  **EPIC** Acts II–IV (XL, largest single effort) · #198 GAP-051 Thornwatch (L) ·
  #199 GAP-052 Roothollow (L)
- **P2:** #187 region banners · #188 GAP-033 overworld map screen (L) · #189
  biome weather · #223 overworld save points · #267 zone rects → tileset data ·
  #266 Act III overworld transforms · #262 Veilstep field-cast · #263 Tunnel Map
  + Kole patrol · #264 Ley Stag encounter suppression · #200 Maren's Refuge
  basement · #201 GAP-055 Ironmouth (L) · #202 GAP-056 Valdris interiors (L) ·
  #226 GAP-054 Duskfen (L) · #196 GAP-049 **EPIC** faction cities (XL) · #195
  GAP-048 **EPIC** world dungeons (XL) · #239 GAP-091 **EPIC** post-game (XL)

### Phase 7 — UI, Menus & Art (14 open — 12 prioritized below, 2 filed since the re-plan)

#217 gates the icon/portrait work — every art-dependent UI issue below is
blocked until real assets exist.

- **P0:** #217 GAP-082 **EPIC** all art assets are placeholders (XL)
- **P1:** #204 GAP-058 portraits + walking sprites (L) · #205 GAP-059 status-icon
  system · #207 GAP-061 equip stat comparison · #208 GAP-062 battle results ·
  #212 GAP-071 color-blind mode · #214 GAP-073 key rebinding (L)
- **P2:** #229 GAP-065 item screen grid · #206 GAP-060 abilities screen ·
  #228 GAP-064 window color · #230 GAP-074 orphaned config toggles ·
  #213 GAP-072 SFX captions

### Phase 8 — Audio (7 open — all 7 prioritized below)

- **P0:** #154 wire AudioManager into runtime (L)
- **P1:** #155 SFX panning + Mono mode · #175 GAP-078 **EPIC** music/SFX assets (XL)
- **P2:** #156 ambient spot-effect layering · #215 GAP-079 **EPIC** corruption
  evolution (XL) · #216 GAP-080 **EPIC** leitmotif layering (XL) · #234 GAP-081
  `enter_pallor()`

### Infra & Docs (0 open — complete)

The re-plan's five P2 items (#235 GAP-084 architecture doc vs. enemy JSON, #236
GAP-086 `inventory_helpers` misplaced in `autoload/`, #237 GAP-087 oversized
files, #238 GAP-089 design-doc numeric balance, #265 encounter-table
reconciliation) are all closed, along with ten later additions.

### Infra & Docs II — Citation Rot & Doc Hygiene (7 open — all unprioritized)

Successor milestone, opened after the re-plan and currently in burn-down. It
holds the citation-gate, spelling-ratchet and doc-accuracy work; none of its
issues carry a Project `Priority`. Query it directly:
`gh issue list --milestone "Infra & Docs II — Citation Rot & Doc Hygiene" --state open`.

---

## Notes

- Issue numbers map to GAP-NNN via the issue titles (`gh issue list --label gap-analysis`).
- Phase order is dependency order. Within a phase, work P0 → P1 → P2, then the
  unprioritized remainder.
- Among the issues the re-plan sized, only L and XL carry a `Size`; an unsized
  one from that set is S/M and not worth estimating. Issues filed since are
  unsized because nobody sized them, which says nothing about their effort.
- The 14 open `epic`-labeled issues are all XL and must be sliced before
  implementation (verified 2026-08-12).
