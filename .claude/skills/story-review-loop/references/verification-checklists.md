# Verification Checklists

Reference for review agents (primarily Agent 1 and Agent 6).
Each item is a single check. Grows from Copilot gap analysis.

## Entity Property Verification

- Location act availability matches locations.md
- Dungeon act availability matches dungeons-world.md or dungeons-city.md
- Dungeon classification (world/city) matches canonical source doc
- Dungeon canonical name matches exactly (no parenthetical variants)
- Character pronouns match characters.md
- Corruption stages match dynamic-world.md / biomes.md
- Numeric properties (duration, timing, HP) match across all files

## Cross-Reference Format Verification

- Section citations use correct heading format from target doc
- Relative links point to files that exist
- "Per <doc>" claims reference real sections in that doc

## Mechanic Exception Tracking

- When a general rule is stated, verify no entity has a documented
  exception that contradicts it
- When an exception is documented, verify the general rule
  acknowledges it
- "Destroyed" locations should not be assigned corruption stages

## Internal Coherence (New Content)

- Section numbering is monotonic (no 5.5 before 5.4, no duplicate numbers)
- Diagram labels match the text they summarize (no hard-coded values that drift)
- Terms introduced in one paragraph are not contradicted by an adjacent
  paragraph in the same section (e.g., "first non-musical sound" vs palette
  that includes the same sound type)
- Multi-step workflow descriptions have unambiguous ordering (no "commit
  and push" in step 5 AND step 5b without clarifying which push is canonical)

## Spec/Plan Mirror Checks

- When music.md changes, check spec sections 3-13 for mirrored content
- When events.md section 2c changes, check spec sections 4-5
- Plan "verbatim" instructions must match actual implementation
