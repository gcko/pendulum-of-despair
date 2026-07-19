# Gap-Closure Bundle Roadmap

A living plan for closing the remaining `gap-analysis` GitHub Issues as
**bundles** — small sets of 2–4 related issues that share a code touchpoint and
ship as ONE PR via the `/issue-bundle` skill. Generated 2026-06-28 from a
multi-agent clustering pass over the ~80 open gap issues; refine as work lands.

**Process:** `gh issue list --label gap-analysis` → pick a coherent bundle →
implement together on one branch (`/game-designer` or `/gut-tdd`) → one PR
(`/create-pr`) → review & fix (`/pr-review-response`). Epics are too big to
bundle — slice them into their own multi-PR efforts.

## Status

| Bundle | Issues | State |
|--------|--------|-------|
| Bundle 1 | GAP-001 magic submenu, GAP-007 ATB config | ✅ merged (PR #241) |
| Bundle 2a | GAP-010 Cael spike, GAP-008 type-traits (slice) | ✅ merged (PR #243) |
| Bundle 2b | GAP-003 status system (player→enemy core) | ✅ merged (PR #245) |
| Bundle 3a | GAP-024 enemy abilities, GAP-028 bestiary reconciliation | ✅ merged (PR #251) |
| Bundle 3b | GAP-009 data-driven boss AI | ✅ merged (PR #255) |
| Bundle 4a | Act-I enemy kits + selector schema (#249/#250) | ✅ merged (PR #258) |
| Bundle 4b | Paralysis + player-ATB auto-skip (#248) | ✅ merged (PR #259) |
| Bundle 5 | GAP-025 encounter scaling, GAP-026 per-tile zones, GAP-027 formation overrides | 🔄 in review |

> Bundle 2 was split after analysis: each of GAP-003/008/010 has an independent
> "do-now" core plus a tail that depends on unbuilt systems (GAP-002 abilities,
> GAP-009 boss AI, GAP-013 spike framework, GAP-023 enemy-element schema). 2a
> shipped the pure damage-math cores; 2b is the status subsystem.

---

## Combat + Enemies + Encounters

1. **Bundle 2b — combat status system** (GAP-003 #159) — `roll_status`→`apply_status`
   wiring, `STATUS_RULES` + spell `status` JSON fields, ATB freeze/mods sync,
   poison ticks, boss immunity. *(L; player→enemy core only — enemy→party defers
   to GAP-009.)*
2. **Data-driven enemy & boss AI + bestiary reconciliation** (GAP-024 #166,
   GAP-009 #179, GAP-028 #222) — *depends on Bundle 2a/2b combat layer. (L)*
3. **Encounter scaling & formations** (GAP-025 #185, GAP-026 #186, GAP-027 #221)
   — act/location scaling, per-tile zones, formation overrides. *(M)*
- **EPIC GAP-002 #158 (XL):** six unique character commands (Bulwark/Rally/
  Forgewright/Spiritcall/Tricks/Arcanum). Slice per character; unblocks the
  deferred GAP-008 buff interactions.

## Save + Progression

1. **Permanent stat-accumulation framework** (GAP-011 #161, GAP-013 #180) —
   Crystal accrual + milestone spikes; **GAP-013 absorbs GAP-010's framework
   tail.** *(L)*
2. **Ley Crystal effects + XP** (GAP-014 #181, GAP-015 #220) — *depends on #1. (L)*
3. **Save backend** (GAP-066 #174, GAP-068 #209, GAP-070 #211, GAP-076 #232) —
   persistence, triggers, playtime, validation. *(L)*
4. **Save-screen & save-point ops** (GAP-069 #210, GAP-075 #231) — Copy/Delete,
   Inn/Rest. *(M)*
5. **Accessibility — visual cues** (GAP-071 #212, GAP-074 #230). *(L)*
6. **Accessibility — input & captions** (GAP-072 #213, GAP-073 #214). *(M)*

## World + Exploration + Story

1. **Dialogue resolver & flag-catalog** (GAP-042 #192, GAP-045 #194, GAP-043 #193)
   — Act-I slice. *(M)*
2. **Act-I Valdris town builds** (GAP-050 #197, GAP-051 #198, GAP-056 #202). *(L)*
3. **Act-I Thornmere expansions** (GAP-052 #199, GAP-053 #200). *(L)*
4. **Settlement namespacing** (GAP-054 #226, GAP-055 #201) — *depends on GAP-049. (S)*
5. **Overworld traversal** (GAP-032 #187, GAP-035 #223) — *depends on GAP-029. (M)*
6. **Overworld map & biome atmosphere** (GAP-033 #188, GAP-034 #189) — *depends on GAP-029. (M)*
- **EPICS:** GAP-029 #167 continental overworld (keystone), GAP-030 #168
  transport, GAP-031 #169 act-based world transforms, GAP-044 #172 sidequest
  system, **GAP-047 #173 Acts II–IV (largest single effort)**, GAP-048 #195 world
  dungeons, GAP-049 #196 faction cities, GAP-091 #239 post-game.

## UI + Items/Economy + Dialogue + Audio

1. **Inventory item effects & routing** (GAP-019 #164, GAP-020 #165, GAP-021 #183). *(L)*
2. **Shop overhaul** (GAP-017 #163, GAP-018 #182, GAP-022 #184) — *depends on #1. (L)*
3. **Dialogue choice-consequence & animation** (GAP-038 #171, GAP-037 #170, GAP-039 #191). *(L)*
4. **Dialogue condition eval & box visuals** (GAP-036 #190, GAP-040 #224, GAP-041 #225) — *depends on #3. (M)*
5. **Battle party-panel HP/MP bars** (GAP-057 #203, GAP-063 #227). *(M)*
6. **Icon & portrait atlas** (GAP-058 #204, GAP-059 #205, GAP-065 #229) — *depends on GAP-082 art. (L)*
7. **Menu detail panels** (GAP-060 #206, GAP-061 #207, GAP-062 #208) — *depends on #6, GAP-002. (L)*
8. **AudioManager transition primitive** (GAP-081 #234) — `enter_pallor`. *(S)*
9. **Window-color theming** (GAP-064 #228). *(M)*
- **EPICS:** GAP-016 #162 crafting, GAP-078 #175 audio production, GAP-079 #215
  corruption evolution, GAP-080 #216 leitmotif layering.

## Infra / Docs

1. **SaveManager ownership consolidation + tests** (GAP-077 #233, GAP-083 #218). *(L)*
2. **Autoload cleanup + oversized-file decomposition** (GAP-086 #236, GAP-087 #237)
   — *depends on #1. (L)*
3. **Architecture/doc reconciliation** (GAP-084 #235, GAP-089 #238). *(M)*
- **EPIC GAP-082 #217 (XL):** all 22 art PNGs are placeholders — blocks the
  icon/portrait UI bundle.

---

## Notes

- Issue numbers map to GAP-NNN via the issue titles (`gh issue list --label gap-analysis`).
- "Depends on" = the named bundle/gap should land first to avoid rework/conflict.
- Sizes (S/M/L/XL) are the clustering agents' estimates — re-confirm at SELECT time.
