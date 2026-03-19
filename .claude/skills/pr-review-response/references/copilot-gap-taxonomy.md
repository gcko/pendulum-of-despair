# Copilot Gap Taxonomy

Categories for classifying gaps between our story-review-loop and
Copilot findings. Used by the gap analysis step in pr-review-response.

| Category | Description | Example |
|----------|-------------|---------|
| Source verification | Value in PR doesn't match canonical source doc | Act assignment wrong |
| Classification | Entity type/category wrong | World vs city dungeon |
| Numeric propagation | Number differs between files | Timing mismatch |
| Exception tracking | General rule contradicted by specific exception | Stage 4 + Millhaven |
| Reference format | Cross-file citation broken or incorrect | Section number wrong |
| Mirror staleness | Spec/plan copy diverged from story doc | Plan says verbatim but differs |
| Self-contradiction | Same doc contradicts itself | Rule says X, example shows Y |
| Post-fix regression | A fix introduced a new problem | Fixed timing but broke silence rule |

## How to Use

1. Read each Copilot comment
2. Match it to the most specific category above
3. Map to the agent that should have caught it:
   - Source verification, Classification, Numeric propagation -> Agent 6 (Canonical Verifier)
   - Exception tracking -> Agent 4 (Script Supervisor)
   - Reference format -> Agent 3 (Technical)
   - Mirror staleness -> Agent 1 (Propagation)
   - Self-contradiction -> Agent 3 (Technical, Pass F)
   - Post-fix regression -> Fix step (full-section re-read)
4. Check if the gap is covered by an existing item in
   `story-review-loop/references/verification-checklists.md`
5. If not, draft a new checklist item (one line)
