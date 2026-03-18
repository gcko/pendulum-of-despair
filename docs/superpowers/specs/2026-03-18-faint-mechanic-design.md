# Faint Mechanic & Party Wipe Rules Design Spec

**Date:** 2026-03-18
**Status:** Draft
**Scope:** Documentation-only pass. All `docs/story/` files were audited; only
files containing combat-mechanic KO/death terminology required changes (4 of 16).
See Section 6 for the specific file list.

---

## 1. Problem Statement

The story docs inconsistently use "KO," "death," "kill," and related terms for
what happens when a character loses all HP in battle. This conflates the
reversible combat mechanic (character is knocked out and can be revived) with
permanent narrative deaths (King Aldren dies in the siege, Cael's sacrifice).
Additionally, the party-wipe consequence rules exist only partially -- the
fast-reload animation is documented, but what progress is kept vs. lost is not.

## 2. Design Goals

1. Establish "Faint" as the single mechanical term for 0-HP in battle.
2. Clearly distinguish Faint (reversible, combat) from death (permanent, story).
3. Document party-wipe consequences: what's kept, what's reset.
4. Preserve the FF4/FF6-style instant reload flow already in events.md.

## 3. Terminology Rules

### 3.1 Faint (replaces KO)

"Faint" is the status effect applied when a character's HP reaches 0 in battle.

| Context | Old Term | New Term |
|---------|----------|----------|
| Status effect name | KO | Faint |
| Status effect state | KO'd | Fainted |
| Spell/ability targets | "Single ally (KO'd)" | "Single ally (Fainted)" |
| Ability interruption | "if he's KO'd" | "if he's Fainted" |
| Auto-revive trigger | "Auto-revive at 30% HP on KO" | "Auto-revive at 30% HP on Faint" |
| Enemy defeat description | "on death" / "Shatters on death" | "on defeat" / "Shatters on defeat" |
| Instant KO mechanic (player) | "instantly KO'd" | "instantly Fainted" |
| Instant KO mechanic (enemy) | "instant kill" | "instant defeat" |
| Instant Death immunity (enemy) | "Instant Death" | "Instant Defeat" |

### 3.2 Exceptions -- Keep "death"/"dead"/"die"

The following contexts retain death-related language:

- **Narrative story deaths:** King Aldren's death in the siege, Cael's sacrifice,
  the Great Spirit asking to die, Vaelith's release. These are permanent,
  plot-driven events -- not the Faint mechanic.
- **Flavor text that builds atmosphere:** Spell descriptions like Second Dawn's
  "The dead do not stay dead when the ley lines still burn." This is poetic
  language, not mechanical terminology.
- **Environmental descriptions:** Dead miners in Ember Vein, dead aquatic life in
  Fenmother's Hollow, dead forest in the Grey March. These describe the world,
  not combat mechanics.
- **Lore/dialogue references to death as a concept:** Characters discussing
  mortality, the Pallor's death toll, historical deaths across cycles.

### 3.3 The Bright Line

> If a character can be revived by a spell, item, or reload, they **Fainted**.
> If a character is gone from the story permanently, they **died**.

Guest NPCs who reach 0 HP (e.g., Kerra, Cordwyn) use "incapacitated" as they
already do -- this is correct and does not change.

## 4. Party Wipe Consequences

### 4.0 Wipe Trigger

A party wipe occurs when all **player-controlled** party members are Fainted in
battle. Guest NPCs (Cordwyn, Kerra, etc.) do not count -- if every player
character is Fainted but a guest NPC is still standing, the wipe still triggers.
Guest NPCs cannot carry a fight alone.

When a wipe triggers, the fast-reload sequence fires (see events.md section 2c).

### 4.1 Kept on Full Party Faint

| Category | Rule | Rationale |
|----------|------|-----------|
| XP and level-ups | Kept (includes spells/abilities learned from those level-ups) | Prevents grinding punishment; standard JRPG convention (FF4/FF6) |
| Gold/currency | Kept (all gold, including battle rewards and sale proceeds) | Prevents soft-lock: player could spend all gold on consumables, lose the fight, and respawn with no resources to recover. Note: since inventory resets but gold persists, selling items then wiping lets the player keep gold while items return. Accepted -- gold has limited exploitability (shops sparse, resale values low). Matches FF4/FF6. |
| Boss cutscene skip flags | Kept (`boss_cutscene_seen_<boss_id>`) | Prevents re-watching cutscenes on retry |

### 4.2 Reset to Last Save

Everything not listed in 4.1 resets to last save state. This includes:

| Category | Rule | Rationale |
|----------|------|-----------|
| Inventory and consumables | Reset | Entire inventory reverts to last save -- items used, collected, bought, or sold between save and wipe are all undone |
| Equipment changes | Reset | Reverts to last-saved loadout; prevents item duplication from reset chests |
| Chest openings | Reset | Must be re-collected; rewards dungeon re-traversal |
| Field item pickups | Reset | Same as chests -- items collected between save and wipe are gone |
| Shop transactions | Reset | Buy/sell actions between save and wipe revert (gold persists per 4.1, purchased items revert) |
| Party composition | Reset | If a story event added/removed a member between save and wipe, that reverts |
| Storyline flag updates | Reset | Events, quest progress flags, NPC state changes revert (boss cutscene skip flags exempt per 4.1) |
| Dungeon progress | Reset | Doors opened, switches flipped, puzzles solved revert |

**Simplifying principle:** The game reloads the last save file. A small number
of values persist outside the save file (XP, levels, gold, and boss cutscene
skip flags -- see 4.1). Everything else comes from the save. This eliminates
edge cases around unsaved
field pickups, equipment swaps, and shop transactions -- they simply were not
saved, so they do not exist after reload.

### 4.3 Interaction with Existing Rules

- **Boss cutscene skip flags** (`boss_cutscene_seen_<boss_id>`): These are kept
  (they persist outside the save system specifically to avoid re-watching
  cutscenes on retry). Already documented in events.md.
- **Narrative defeats** (e.g., unwinnable Vaelith fight): Exempt from the
  fast-reload sequence. These transition to aftermath cutscenes, not the
  Faint/reload flow. Already documented in events.md.

## 5. Fast Reload Flow (Unchanged -- Updated Terminology)

The existing fast-reload sequence in events.md section 2c remains as designed.
Text shown below reflects post-edit terminology:

1. **The Fall (2s):** Last Faint animation plays. Battle UI fades. Music
   hard-cuts to silence.
2. **Fade to Black (2s):** Black screen. No text, no menu, no "Game Over."
3. **Instant Reload:** Fade in at last save point. Save file is loaded, then
   persistent values (XP, levels, gold, cutscene flags) are applied on top.
   HP and MP are set to 100% of the resulting max. Save point marker glows
   briefly. Ambient music resumes. ~4 seconds total.

No retry option. No Game Over screen. Matches FF4/FF6 philosophy.

## 6. Files Requiring Changes

### 6.1 Terminology Changes (KO -> Faint)

| File | What Changes |
|------|-------------|
| `docs/story/magic.md` | **Status Effect Reference table** (near end of file): KO row -> Faint. **Last Breath (Reraise) row**: "on KO" -> "on Faint". **Spell targets** throughout: "(KO'd)" -> "(Fainted)". **Unmaking spell** (Void): "instantly KO'd" -> "instantly Fainted". Applies to both player and enemy spell descriptions. |
| `docs/story/abilities.md` | Cael's Rally: "KO'd" -> "Fainted". Any other KO references in ability descriptions. |
| `docs/story/events.md` | Section 2c title: "Death and Fast Reload" -> "Faint and Fast Reload". "all party members are KO'd" -> "all party members are Fainted". "Last KO animation" -> "Last Faint animation". "If the player dies before the first save point" -> "If the party Faints before the first save point". Add party-wipe consequence tables (Section 4). |
| `docs/story/dungeons-world.md` | Enemy "on death" -> "on defeat" (e.g., Crystal Sentry, Crystal Warden). "Instant Death" immunity -> "Instant Defeat". "instant kill" -> "instant defeat". |
| `docs/story/dungeons-city.md` | Same pattern as dungeons-world.md for enemy entries. |
| `docs/story/sidequests.md` | Any KO references in sidequest encounters or NPC mechanics. |
| `docs/story/outline.md` | Any combat-context death/KO references (verify; may not need changes). |
| `docs/story/characters.md` | Any combat-context death/KO references (verify; may not need changes). |
| `docs/story/npcs.md` | Any combat-context death/KO references (verify; may not need changes). |

### 6.2 New Content (Party Wipe Rules)

| File | What's Added |
|------|-------------|
| `docs/story/events.md` | Expand section 2c with "What's Kept" and "What's Reset" tables per Section 4 above. |

## 7. Out of Scope

- No code changes. This is a documentation-only pass.
- No changes to the save system design itself.
- No changes to how individual spells/abilities work mechanically (only
  terminology in their descriptions).
- No changes to narrative death scenes or environmental death descriptions.
