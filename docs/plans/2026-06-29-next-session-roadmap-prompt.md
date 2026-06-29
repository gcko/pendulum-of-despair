# Next-Session Kickoff Prompt — Bundle-Roadmap Continuation

> Copy the block below and send it as the first message of the next session.
> It re-uses the project's proven loop (ultracode ANALYZE → decisions →
> TDD → PR → multi-agent review) and is keyed to
> [`docs/plans/bundle-roadmap.md`](./bundle-roadmap.md).

---

## The prompt to send

```
ultrathink + ultracode. Pick up the Pendulum of Despair JRPG (Godot 4.7 /
GDScript / GUT 9.7.0) where the last session left off. Load the pod-dev skill
first and read your memory (MEMORY.md + project_combat_bundles_2026-06.md +
project_followups_2026-06.md) before doing anything.

STATUS (all merged to main):
- The combat slice is now substantial. Bundles 1/2a/2b (magic submenu, ATB
  config, damage modifiers, status system), 3a (enemy special abilities GAP-024),
  3b (data-driven boss-AI interpreter GAP-009), and 4a/4b (Act-I enemy kits +
  selector, Compact doc exception, Paralysis #248) are ALL merged. The
  enemy+boss-AI roadmap item (GAP-024/009/028) is COMPLETE.
- Open follow-ups already triaged + filed (do NOT re-file): #246 (GAP-003
  deferrals: party Slow/Sleep/Despair ATB mods, ally Haste, Despair dmg-penalty,
  Confusion/Berserk auto-action, enemy→party infliction tail), #256 (bespoke
  Act-I enemy abilities: drain/self-destruct/counter/flee/gold-theft/knockback),
  #257 (no-kit enemies: the_flickering, compact_patrol/scout), #260 (paralysis
  auto-skip: message-clobber break-vs-continue + missing _check_end_conditions),
  #253 (boss multi-turn charge interrupts, Act II+), #254 (Cael corrupted-Rally,
  Act III). #252 was found already-implemented and closed.

YOUR TASK — follow docs/plans/bundle-roadmap.md to pick and ship the NEXT bundle:
1. SELECT: `gh issue list --label gap-analysis --state open`, then choose the
   next coherent 2-4 issue bundle per the roadmap. Strong candidates now that the
   combat layer is rich (recommend ONE to me, with rationale):
     (a) Encounter scaling & formations — GAP-025 #185 / GAP-026 #186 /
         GAP-027 #221 (act/location scaling, per-tile zones, formation overrides).
         Exercises the now-complete combat layer end-to-end.
     (b) Battle party-panel HP/MP bars — GAP-057 #203 / GAP-063 #227 (combat UI;
         makes the slice fully playtest-legible).
     (c) Permanent stat-accumulation framework — GAP-011 #161 / GAP-013 #180
         (Ley Crystal accrual + milestone spikes; absorbs GAP-010's framework tail).
   Also offer a "PLAYTEST PAUSE" option: the combat slice (player abilities +
   enemy kits + boss AI + statuses incl. Paralysis) is now big enough to drive a
   real Act-I battle headlessly and shake out integration bugs before more code.
   OR knock out the small filed follow-ups (#260 is a ~10-line fix; #256 has
   several "cheap" bespoke abilities) as a quick warm-up bundle.
2. ANALYZE with ultracode: fan out read-only spec/cartographer agents (Workflow
   tool) over the chosen issues' docs/issues/GAP-*.md + the canonical design docs
   they trace to + the code touchpoints. Design docs are LAW — quote exact values
   to file:line, never invent numbers.
3. Present the implementation plan + genuine scope/balance/ambiguity decisions to
   me with AskUserQuestion BEFORE writing code. Stop and ask if a design doc is
   silent.
4. IMPLEMENT test-first with /gut-tdd (RED → GREEN → REFACTOR), reusing existing
   systems (don't duplicate). 
5. /create-pr, then /godot-review-loop <PR#> (3 rounds) — fix ALL findings,
   re-verify, push, watch CI to green, post the summary.
6. File follow-ups for anything deferred; close/comment issues; land cleanly
   (work is NOT done until `git push` succeeds and CI is green).

GUARDRAILS / GOTCHAS (learned this project — still apply):
- Run the full GUT suite via Godot headless; redirect stdout to a file and grep
  (Totals / [Failed]). ALWAYS check Scripts/Tests counts — GUT 9.7.0 silently
  skips files with parse errors. assert_lte/assert_gte (NOT _le/_ge).
- pre-push runs import + the full GUT suite; NEVER --no-verify; never bypass hooks.
- Godot bin: /Applications/Godot.app/Contents/MacOS/Godot. macOS --import can
  wedge in U-state → reboot clears it (a wedged hook means tests did NOT run).
- Branch off main; conventional commits (subject must be lowercase — commitlint
  rejects sentence-case); scope ∈ engine/story/assets/ci/deps.
- CI vs local: a pre-existing combat playtest had RNG-fragile assertions that
  passed locally but failed on CI's environment. Seed RNG-dependent tests, or
  make them retry/statistical. Battle-booting tests that run BEFORE
  test_combat_playtest can perturb its seed(7) — prefer a fake-manager harness or
  free the battle immediately + reset game state in after_each.
- Workflow (ultracode) scripts are plain JS: NEVER put an unescaped backtick
  inside a backtick-template-literal prompt (it silently closes the literal →
  parse error). Use string concatenation or escape with \\\`.
- DO NOT `git stash pop` — a stale unrelated "COPE tear-apart Round 1" stash
  conflicts with main. Leave it. Many old local branches are unpruned.
- The pr-review-response / godot-review-loop / issue-bundle / gut-tdd skills are
  the repo-level (Godot-aware) versions — read the actual SKILL.md, not the
  system-reminder summary. No /re-review on this repo.

Start by orienting (pod-dev + memory + `gh issue list --label gap-analysis`),
recommend the next bundle (or a playtest pause), then kick off the ultracode
ANALYZE and bring me the plan + decisions.
```

---

## Why these candidates (context for me, not part of the prompt)

The roadmap's **"Data-driven enemy & boss AI"** bundle is done. The natural next
moves keep momentum in/around the combat slice:

- **Encounter scaling & formations** is the direct continuation — it feeds the
  combat engine that now exists (enemy kits, boss AI, statuses) with proper
  act/location difficulty and formation variety, and is independently testable.
- **Party-panel HP/MP bars** (GAP-057 #203, #227) is small and makes the combat
  slice legible for a real playtest.
- A **playtest pause** is genuinely worth weighing: combat is now broad enough
  (player magic/abilities + 18 enemy kits + 4 boss scripts + status incl.
  Paralysis) that a headless Act-I battle run would likely surface integration
  bugs cheaper than writing more features.

Pick per the user's appetite; default to recommending **Encounter scaling &
formations** unless the user wants to playtest or clear the small filed
follow-ups (#260/#256) first.
