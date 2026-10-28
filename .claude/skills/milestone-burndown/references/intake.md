# Intake: what to ask before any subagent runs

Read this at Step 0. The answers decide how much the burn-down costs and who
may merge, so collect them before the first Agent call. Record every answer in
the ledger (`references/ledger.md`). On a resumed run, show the recorded
settings and ask one question, "Keep these settings?", instead of the full set.

## 1. Skip what the invocation already answered

```
/milestone-burndown <milestone number or title>
    [plan=<model>:<effort>] [build=<model>:<effort>] [review=<model>:<effort>]
    [merge=ask|wave|never] [parallel=<2-4>]
```

A value given in the invocation is an answer. Ask only for what is missing.
If no milestone was named, ask for it first, on its own: list the open
milestones with their open counts and offer the three with the most open
issues, plus Other.

## 2. Ask the three stage questions in one AskUserQuestion call

Ask each stage separately, because each stage has a different job. Put the
recommendation first and label it `(Recommended)`. Each option's description
gives the reason in one line. Other always accepts any `<model>:<effort>` pair,
for example `sonnet:xhigh`.

| Stage | Who runs at this setting | Option 1 (Recommended) | Option 2 | Option 3 | Option 4 |
|---|---|---|---|---|---|
| **Planning** | triage verifiers (Step 1), plus any research agent you dispatch while planning a wave (Step 2) | `fable:high` | `opus:xhigh` | `opus:high` | `sonnet:high` |
| **Building** | one builder per bundle (Step 3) | `opus:high` | `opus:xhigh` | `sonnet:high` | `fable:high` |
| **Review** | every reviewer agent dispatched by `/pr-review-response` and the loops it runs (Step 6) | `opus:xhigh` | `fable:high` | `opus:high` | `sonnet:high` |

Header chips: `Planning`, `Building`, `Review`. The fourth question in the same
call is merge authority (section 3).

### Why these recommendations

These were checked against the model lineup and the effort guidance as of
**2026-10**. Pricing per million tokens, input/output: Fable 5.1 $10/$50,
Opus 5.5 $4/$20, Sonnet 5.5 $2/$10, Haiku 5.5 $0.10/$0.50 (prompts up to
100K tokens; $0.50/$2.50 beyond).

- **Planning → `fable:high`.** Planning uses few tokens: it reads issues and
  splits files once per wave. It also has the most leverage. A wrong file split
  costs a whole wave of conflicts, and a wrong "already fixed" verdict closes a
  live bug. That is where the most capable model pays for itself. It runs at
  `high`, not `xhigh`, because Fable turns already run long.
- **Building → `opus:high`.** Builders are the largest share of the spend:
  several run in parallel, each with long tool loops. The gates (gdlint,
  gdformat, Godot import, the GUT floors) catch mechanical mistakes, so steady
  execution matters more than peak reasoning. Opus 5.5 defaults to `medium`, so
  always pass the effort explicitly. Sonnet 5.5 at `high` is the half-price
  option for doc-only or mechanical bundles.
- **Review → `opus:xhigh`.** Review findings decide how many waves there are,
  and `xhigh` is the level the effort guidance calls best for most coding and
  agentic work. Review runs one effort level above building on purpose.
  `fable:high` is the alternative when you want a reader whose model differs
  from the builders'. Review spend multiplies quickly: `/story-review-loop`
  runs six agents per round, on every PR, every round.
- **Haiku is never recommended for a stage.** Wrong triage, building or review
  is more expensive than the tokens Haiku saves. The one exception to
  section 5's "every Agent call in a stage" rule: the orchestrator may hand
  Haiku a purely mechanical lookup, such as "does this path exist on
  origin/main", and should say that it did.

**When these go stale:** the Agent tool's `model` parameter lists the aliases
that exist right now. If a recommended alias is not in that list, recommend the
closest tier that is, say you did, and record the substitution in the ledger.
Do not offer an alias the tool would reject.

## 3. Merge authority, the fourth question of the same call

Header chip `Merging`. Merging is outward-facing and hard to undo, so the user
chooses how much of it to delegate:

1. **Ask before each merge (Recommended)**, `merge=ask`. You present each PR's pre-merge
   checklist (`references/stack-and-merge.md` section 4) and merge it after
   a yes.
2. **One approval per wave**, `merge=wave`. One yes covers merging the
   whole stack bottom-up. The checklist still runs immediately before each
   merge, and any check that fails stops the sequence and returns the decision
   to the user.
3. **I merge myself**, `merge=never`. You prepare everything and hand over
   the ordered list. The user merges one PR at a time and tells you after each.
   You run the after-merge steps, then the next PR's checklist, before they
   merge that one.

## 4. Optional second call, only when the first left gaps

Ask these only if the invocation did not set them and the defaults do not fit
this milestone (more than 12 open issues, or a mix of code and docs):

- **Bundles per wave** (`Parallel`): 3 (Recommended), 2, or 4. More than 4
  makes stack review and restacking cost more than the parallelism saves, and
  headless Godot runs one at a time anyway (the mutex in
  `scripts/quality-gates/godot-lock.sh`).

## 5. How the answers are applied

- Pass `model` and `effort` on **every** Agent call in that stage. A call
  without them inherits the session's model at its default effort. That
  default is not what the user chose.
- Never use `subagent_type: "fork"` for staged work. A fork ignores both
  `model` and `effort`.
- A research agent dispatched while planning gets the same `SCRATCH:` line as
  every staged agent, `<scratchpad>/research-<n>/`, with the same rules
  (`references/agent-briefs.md`).
- The review settings follow review work into sub-skills.
  `/pr-review-response`, `/godot-review-loop`, `/story-review-loop` and
  `/story-review-loop-cope` dispatch reviewer agents of their own. Every one of
  those Agent calls carries the review `model` and `effort`. Those skills name
  no model, so this adds to them without overriding them.
- The orchestrator is this session, and a skill cannot change its model. If the
  user wants it changed, point them to the app's model picker. Do not try to
  work around that.
- The orchestrator may **propose** a different build setting for a single bundle in
  the wave plan, for example `opus:xhigh` for a bundle that changes combat
  formulas or save logic. It applies only if the user approves that wave plan.
