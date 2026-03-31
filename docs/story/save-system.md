# Save System

> Defines what gets persisted, when saves happen, how slots work, how
> death interacts with saves, and how saves survive game updates.
> Engine-agnostic — specifies the contract, not the implementation.
>
> **Related docs:** [items.md](items.md) | [economy.md](economy.md) |
> [crafting.md](crafting.md) | [overworld.md](overworld.md) |
> [difficulty-balance.md](difficulty-balance.md) |
> [postgame.md](postgame.md) | [events.md](events.md) |
> [ui-design.md](ui-design.md) | [progression.md](progression.md) |
> [characters.md](characters.md)

---

## 1. Design Principle

**Save the player's choices and progress. Derive everything that is a
function of those choices at load time.**

This split means most balance patches (stat tweaks, price changes,
rebalanced items) need zero save migration — the values come from data
tables, not the save file.

### Persisted (written to save file)

| Category | Examples |
|----------|---------|
| Character progression | Level, XP, current HP/MP, status ailments |
| Equipment | Which item in which slot per character |
| Ability loadout | Equipped subset of level-unlocked abilities |
| Ley Crystals | Which crystals collected, their XP/level |
| Inventory | All items with quantities |
| Currency | Gold |
| World state | Event flags (58 numbered + parameterized `boss_cutscene_seen_*`), current act, location, position |
| Quest progress | Active quests with step, completed quest list |
| Crafting | Arcanite Charges, device loadout, synergies, recipes |
| Formation | Active 4, reserve 0–2, guests, row assignments |
| Completion tracking | Bestiary entries, treasure chests, items ever found |
| Metadata | Save format version, playtime, timestamp, slot type |

### Derived at load time (NOT saved)

| Category | Source |
|----------|--------|
| Max HP/MP | Level + growth curve + equipment + crystals |
| ATK/DEF/MAG/MDEF/SPD/LCK | Level + growth curve + equipment bonuses |
| Available abilities/spells | Character level (from [abilities.md](abilities.md) / [magic.md](magic.md) tables) |
| Shop inventories | Event flags + [economy.md](economy.md) rules |
| NPC dialogue | Event flags + dialogue priority stack |
| Encounter tables | Location + act |
| Equipment stat values | Game data tables |
| Item descriptions/prices | Game data tables |

---

## 2. Configuration

Player preferences live in a **separate global config file**, completely
independent of save data. Loading a save never changes settings. This is
the FF6 model — config is system-level.

### Config Fields

**Battle & Display Settings**
- Battle speed (1–6)
- ATB mode (Active / Wait)
- Text speed (Instant / Fast / Normal / Slow)
- Battle Cursor (Reset / Memory)
- Window Color (RGB sliders, 0–31 each)

**Audio Settings**
- Sound (Stereo / Mono)
- Music volume (0–10)
- SFX volume (0–10)

**Visual Settings**
- Screen shake toggle
- Mode 7 rotation intensity

**Accessibility Settings** — See [accessibility.md](accessibility.md) for details
- Patience Mode (On / Off)
- Color-Blind Mode (Off / Deutan-Protan / Tritan)
- High-Res Text (On / Off)
- Reduce Motion (On / Off)
- Flash Intensity (Off / Reduced / Full)
- Transition Style (Classic / Simple)
- SFX Captions (On / Off)

The config file persists alongside saves but is not part of any save
slot.

---

## 3. Save Data Schema

Nine top-level groups. All IDs are strings. Quantities are integers.

### 3.1 party

Array of up to 6 characters (all recruited party members, not just the
active battle party).

```
party[]: {
  id:              string    -- "edren", "cael", "maren", "sable", "lira", "torren"
  level:           integer
  xp:              integer
  hp:              integer   -- current (max derived from level + equipment)
  mp:              integer   -- current (max derived)
  equipment: {
    weapon:        string|null  -- item ID
    head:          string|null
    body:          string|null
    accessory:     string|null
    leyCrystal:    string|null  -- crystal ID (links to leyCrystals.collected)
  }
  row:             string    -- "front" | "back"
  abilityLoadout:  string[]  -- equipped ability IDs (subset of level-unlocked)
  statusAilments:  string[]  -- active persistent ailments (e.g., ["poison", "blind"])
}
```

Status ailments persist in saves. The player may save while poisoned.
Resting with a consumable item clears ailments; saving without resting
does not.

### 3.2 formation

Party composition for battle and field.

```
formation: {
  active:   string[1-4]  -- ordered character IDs (battle party; fewer than 4
                         -- during Interlude reunion sequence)
  reserve:  string[0-2]  -- ordered character IDs (bench)
  guests:   string[]     -- guest NPC IDs per characters.md (Cordwyn, Kerra)
}
```

### 3.3 inventory

All held items, split by category. Equipment currently worn by party
members is tracked in `party[].equipment`, not here — inventory tracks
only unequipped gear.

```
inventory: {
  consumables:  { itemId: string, qty: integer }[]
  equipment:    { itemId: string, qty: integer }[]  -- unequipped gear
  materials:    { itemId: string, qty: integer }[]  -- crafting materials
  keyItems:     string[]                            -- unique, no quantities
}
```

### 3.4 crafting

Arcanite Forging system state. See [crafting.md](crafting.md) for the
full interaction model.

```
crafting: {
  arcaniteCharges:     integer       -- current AC pool (max 12)
  deviceLoadout:       (string|null)[5]  -- 5 device slots, null = empty
  discoveredSynergies: string[]      -- synergy IDs the player has found
  unlockedRecipes:     string[]      -- recipe IDs (gated by schematic key items)
}
```

### 3.5 leyCrystals

Crystal collection and progression. Assignment to characters is stored
in `party[].equipment.leyCrystal`.

```
leyCrystals: {
  collected: {
    crystalId: string,
    xp:        integer,
    level:     integer   -- 1–5
  }[]                    -- up to 18 crystals
}
```

### 3.6 world

World state, progression flags, and player location.

```
world: {
  eventFlags:      Record<string, boolean|integer|string>
                   -- 58 numbered flags (per events.md) plus an unbounded set
                   -- of parameterized boss_cutscene_seen_<boss_id> flags.
                   -- Mixed types: most are boolean, council_result is integer,
                   -- reunion_order_1..4 are string.
  act:             string   -- "1", "2", "interlude", "3", "4", "epilogue", "postgame"
  currentLocation: string   -- map/scene identifier
  currentPosition: { x: integer, y: integer }
  gold:            integer
}
```

### 3.7 quests

Quest tracking. Active quests carry a step counter for multi-stage
progression.

```
quests: {
  active:    { questId: string, step: integer }[]
  completed: string[]  -- quest IDs
}
```

### 3.8 completion

Post-game completion tracking (4 categories per
[postgame.md](postgame.md)). Displayed at Pendulum tavern via Sable.

```
completion: {
  bestiary:   string[]  -- enemy IDs encountered (out of 235)
  treasures:  string[]  -- chest IDs opened
  itemsFound: string[]  -- item IDs ever obtained
  -- quest completion tracked via quests.completed
}
```

### 3.9 meta

Save file metadata. Not game state — used by the save/load system
itself.

```
meta: {
  version:   integer   -- save format version (starts at 1)
  playtime:  integer   -- total seconds played
  savedAt:   string    -- ISO 8601 timestamp
  slotType:  string    -- "manual" | "auto"
}
```

---

## 4. Save Point Interaction

Save points (ley crystal markers, campgrounds, inn exteriors) present a
3-option menu on interaction.

### Menu Options

1. **Rest** — opens a sub-menu of available rest items:

   | Item | HP/MP Restore | AC Restore | Clears Ailments | Cost |
   |------|--------------|------------|-----------------|------|
   | Sleeping Bag | 25% | 25% | Yes | 250g (buy) |
   | Tent | 50% | 50% | Yes | 500g (buy) |
   | Pavilion | 100% | 100% | Yes | 1,200g (buy) |
   | *(no items)* | 0% HP, 25% MP | 0% | No | Free |

   Consumes one of the selected item. If the player has none of the
   three rest items, a free fallback restores 25% MP only — no HP, no
   AC, no status clear. See [items.md](items.md) and
   [economy.md](economy.md) for pricing and availability.

2. **Rest & Save** — same rest sub-menu, then immediately opens the
   save screen after resting.

3. **Save** — opens the save screen directly. Saves current state
   as-is, including injuries, ailments, and depleted resources.

### Inns

Town inns are a paid service (varies by town, Free at Aelhart to 300g at
Caldera; see [economy.md](economy.md) for full price list). They provide
full HP/MP/AC restore and clear all status ailments — effectively a
Pavilion for gold. At an inn, selecting "Rest" or "Rest & Save" shows a
single confirmation prompt ("Rest for Xg?") instead of the rest item
sub-menu. The player's own rest items are not offered as an alternative
at inns — the inn's paid rest is the only option.

### Device Reconfiguration

Lira can reconfigure her device loadout at any save point, independent
of whether the player rests. The save point location itself enables
this — no rest item required. See [crafting.md](crafting.md) for device
loadout rules.

### Exception: Wellspring Nexus

The Wellspring Nexus save point in the Dry Well of Aelhart F7 grants
free full restore without a rest item (unique save point, only location
with this property). See [dungeons-world.md](dungeons-world.md).

### Minor Recovery Sources

These are small flavor mechanics outside the save point / inn system.
They do not interact with save slots or auto-save. None restore AC.
Only the altar blessing can address status ailments (all ailments, as
an alternative to HP restore — not both). Full ailment clearing
alongside HP/MP/AC restore requires rest items or inns.

| Source | Location(s) | Effect | Limits |
|--------|-------------|--------|--------|
| Altar blessing | Temples / chapels (per [building-palette.md](building-palette.md)) | Restore 25% HP to all party OR cure all status ailments (player chooses one) | Once per visit; no AC |
| Soup Kitchen | Carradan Undercroft (per [city-carradan.md](city-carradan.md)) | Restore 25% HP to all party | Once per visit; no AC, no ailment clear |
| Resistance Waypoint | Ironmark Tunnels (per [dungeons-city.md](dungeons-city.md)) | Restore 50% HP/MP to all party (bedroll rest) | Once per visit; not a save point; no AC, no ailment clear |
| Sacred Sites | Ashgrove, Stillwater Hollow (per [geography.md](geography.md)) | Passive 2% HP/MP per second while standing still (overworld only) | No encounters while at site; no AC, no ailment clear |

**"Once per visit"** resets when the player leaves the building or
location and re-enters. Leaving a room within the same building does
not reset it. Sacred Sites reset when the player steps off the site's
overworld location entry (the named map tile).

**Altar and font share one blessing.** Temples have both a priest
(altar) and a stone font ([interiors.md](interiors.md)). The priest
offers the full choice: restore 25% HP OR cure all ailments. The font
offers only the ailment-cure option (a shortcut for players who know
what they want). Using either consumes the single once-per-visit
blessing — interacting with one greys out the other until the next
visit. At Highcairn Monastery, Father Aldous serves the priest role
(offering the blessing at the hearth rather than an altar).

**Design rationale:** These are comfort mechanics for players exploring
without rest items, not substitutes for the rest system. The numbers are
small enough that they don't undermine rest item value but large enough
to feel helpful.

---

## 5. Slot Management

### Slot Count

- **3 manual save slots** (player-controlled)
- **1 auto-save slot** (system-controlled, separate from manual)

### Save Screen (accessed from save point menu)

Shows **3 manual slots only**. Auto-save is hidden — the player never
sees a slot they cannot write to.

Each slot displays:
- Location name, playtime (HH:MM), gold
- Active party members (1–4): walking sprite, name, level, HP bar
- Empty slots show centered "Empty" text in muted grey

**Operations:**
- **Save** — select a slot to write to. Populated slots prompt
  "Overwrite existing save?"
- **Copy** — duplicate one manual slot to another manual slot
- **Delete** — clear a manual save slot. Prompts "Delete this save?"

See [ui-design.md](ui-design.md) for save/load screen layout details.

### Load Screen (accessed from title screen)

Shows **auto-save at top** (blue accent, labeled "AUTO"), then 3 manual
slots below a divider. Empty slots are not selectable.

### Auto-Save Slot Rules

- Cannot be manually overwritten, copied to, or deleted
- Can be loaded from the Load screen
- Can be copied *from* (to a manual slot) — lets players promote an
  auto-save to a manual slot

---

## 6. Auto-Save

### Behavior

Silent and invisible — no UI indicator, no save animation. Writes to
the dedicated auto-save slot only.

### Triggers

Auto-save fires when:
1. Entering a new dungeon floor
2. Entering a boss trigger zone (before the boss fight starts)
3. Entering a new town or settlement
4. Completing a sidequest

### Does NOT Trigger

- Mid-dungeon-floor (prevents save-scumming chests)
- During boss fights
- During boss rush tiers (save suppressed — see
  [Section 9](#9-boss-rush-save-suppression))

See [difficulty-balance.md](difficulty-balance.md) for how auto-save
placement interacts with encounter balancing.

---

## 7. Faint-and-Fast-Reload

When all player-controlled party members are Fainted (guest NPCs do
not count), the game reloads from the most recent save.

### Sequence

1. Last Faint animation plays (2s)
2. Fade to black (2s) — no "Game Over" text, no menu, no prompt
3. Load most recent save (manual or auto, whichever is newer)
4. Merge death-persistent values (see below)
5. Process any level-ups from accumulated XP (full HP/MP restore on
   level-up)
6. Set HP/MP to 100% of max; clear all status ailments
7. Write merged state back to the same save slot on disk
8. Resume at save point (~4s total from wipe to gameplay)

### Death-Persistent Values

These values are captured from the dying game state and merged into the
loaded save:

| Value | Rationale |
|-------|-----------|
| XP per character | Prevents grinding punishment; enables FF6-style gradual leveling through repeated boss attempts. Levels are derived from XP during reload (Step 5), not independently persisted. |
| Gold | Prevents soft-locks from spending all gold on consumables before a boss |
| `boss_cutscene_seen_*` flags | Auto-skip boss intro dialogue on retry |

### Resets to Save State

Everything else reloads from the save file as written:
- Inventory (items used, collected, bought, sold)
- Equipment
- Chest openings
- Shop transactions
- Party composition
- Event flag updates (except boss cutscene flags)
- Dungeon progress

### Durability

The merged state (accumulated XP/gold) is **written back to the save
file** after reload. If the player quits and relaunches after dying,
their accumulated progress is preserved. A player who dies 5 times to a
boss has gained 5 runs worth of XP from trash fights, and that progress
survives across sessions.

### Level-Up at Reload

If merged XP crosses a level threshold, the level-up happens during
reload. The player sees their character at a higher level when gameplay
resumes. Full HP/MP restore applies (standard level-up behavior per
[progression.md](progression.md)).

### Narrative Defeats

Unwinnable story fights (e.g., Vaelith siege) are exempt. These
transition directly to aftermath cutscene instead of triggering
Faint-and-Fast-Reload. See [events.md](events.md) for the full list of
narrative defeat encounters.

### Fallback

If the party Faints before the first save point (early Ember Vein),
reload at dungeon entrance with starting state.

---

## 8. Post-Game Save State

After the epilogue completes (`epilogue_complete` flag set), the game
prompts the player to save. This save captures the **post-epilogue
world state**:

- Memorial scene, survivors rebuilding
- All post-game content accessible (boss rush, Dreamer's Fault,
  completion tracking at Pendulum tavern)
- The final boss **cannot be re-fought** in the post-game world —
  Cael's sacrifice is permanent, consistent with the anti-cycle theme
  and No NG+ decision. Boss rush memorial encounters are separate (see
  [Section 9](#9-boss-rush-save-suppression)).

Loading a post-game save places the player in the post-epilogue world
with full access to optional content. See
[postgame.md](postgame.md) for post-game content details.

---

## 9. Boss Rush Save Suppression

During boss rush tiers (post-game content per
[postgame.md](postgame.md)):

- **Auto-save fires once** on tier entry
- **Manual saving and loading disabled** until the tier is completed
  or forfeited
- **Mid-tier exit** forfeits progress; must restart the tier
- **Purpose:** Prevents save-scumming to restore consumables between
  boss rush fights

Faint-and-Fast-Reload still functions during boss rush — it reloads
the tier-entry auto-save, preserving accumulated XP/gold per standard
rules. See [postgame.md](postgame.md) for boss rush tier structure.

---

## 10. Save Migration

### Versioned Format

Every save file carries an integer `version` in its `meta` block
(starts at 1). The game ships with a chain of migration functions.

### Load Flow

```
1. Read save file
2. Check meta.version against CURRENT_SAVE_VERSION
3. If version < current:
   a. Run migration chain: v1->v2, v2->v3, ..., vN->current
   b. Update meta.version to current
   c. Write migrated save back to disk
4. Proceed with normal load
```

### Migration Types

| Change Type | Migration Needed? | Example |
|-------------|-------------------|---------|
| New field added | Yes — add with default | New `spiritFavor` tracking system |
| Field renamed | Yes — map old to new | `gp` to `gold` |
| Field removed | Yes — strip old field | System removed from game |
| Balance retuned | No | Tent heals 60% instead of 50% |
| New items added | No | New enemy in bestiary |
| Prices changed | No | Potion costs 75g instead of 50g |
| New abilities | No | Ability list derived from level |

Most game updates need zero migration because balance values are derived
from data tables at load time, not stored in saves.

### Breaking Changes

Rare structural overhauls (e.g., replacing the Ley Crystal system)
require a migration function that converts old state to the replacement
system's format. The version chain handles arbitrary complexity — each
step transforms one version to the next.

---

## 11. Storage Notes

Engine-agnostic. The implementing engine should:

- Store saves as structured data (JSON or equivalent)
- Use **one file per slot** (3 manual + 1 auto = 4 files)
- Store global config in a separate file
- Place all save/config files in the engine's standard user data
  directory
- Handle file corruption gracefully (detect, warn, do not crash)

### Corruption Detection

On load, validate that required fields exist and have expected types.
If validation fails, mark the slot as corrupted in the load screen UI
and prevent loading. Do not silently load partial data.

### File Size

A fully populated save (post-game, all 235 bestiary entries, all
treasures, all items) should fit comfortably under 256KB as JSON. No
compression needed.
