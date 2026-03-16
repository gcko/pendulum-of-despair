# Continuity Audit

Cross-reference of all story documents: outline.md, world.md, characters.md, locations.md, npcs.md, events.md, and sidequests.md. Issues are categorized as CRITICAL, IMPORTANT, MINOR, or SUGGESTION.

---

## 1. Name/Reference Consistency

### 1.1 Missing Locations (referenced but not defined in locations.md)

| Issue | Severity | Referenced In | Details |
|-------|----------|---------------|---------|
| **Caldera** not in locations.md | **CRITICAL** | npcs.md, sidequests.md, events.md | Multiple NPCs are placed in "Caldera" (Forgemaster Elyn Drayce, Dael Corran, Cira, Tash, Mira Thenn, Guildmaster Fenn Acari, Sera Linn, Jace Renn, Kel). Sidequests "The Fading Shifts," "The Auditor's Conscience," "The Forgewright's Gambit," "The Cartographer's Last Map," "Unbowed," and "Stars and Gears" all take place partly in Caldera. Yet Caldera has no entry in locations.md. It appears to be the Compact's largest forge-city, distinct from Corrund (the capital) and Ashmark. |
| **Ironmark Citadel** not in locations.md | **IMPORTANT** | npcs.md, sidequests.md, events.md | General Vassar Kole and Commissar Brant are located at "Ironmark Citadel" (the Compact's military HQ). The side quest "The Commissar's Confession" begins there. No entry in locations.md. |
| **Ashport** not in locations.md | **IMPORTANT** | npcs.md | Holt Varen (merchant-engineer) and Nara Voss (textile merchant) are in "Ashport." Pell is at "Ashport, harbor district." Tash references "that Ashport job." No location entry exists. |
| **Greywood Camp** not in locations.md | **IMPORTANT** | npcs.md, sidequests.md, events.md | Elder Savanh, Kael Thornwalker, Orun, Grandmother Seyth, Dorin, and Wren are all located at "Greywood Camp" (the largest tribal settlement). The side quest "What the Stars Said" starts here. No location entry exists. |
| **Stillwater Hollow** not in locations.md | **IMPORTANT** | npcs.md, sidequests.md, events.md | Yara is located here. Torren's optional scene (Scene 1) takes place here. events.md references it. No location entry. |
| **Sunstone Ridge** not in locations.md | **MINOR** | npcs.md, events.md | Ashara is located here. Referenced in events.md as a ley line nexus site. No location entry. |
| **Deeproot Shrine** not in locations.md | **MINOR** | npcs.md, sidequests.md | Brenn and Fiara are located in this area. The side quest "Ink and Ashes" takes place here. The side quest "What the Stars Said" visits it. No location entry. |
| **Ashfen** not in locations.md | **MINOR** | npcs.md, sidequests.md | Rhona and Tavin are in the "Ashfen" area. The side quest "The Weight of Coin" takes place here. No location entry. |
| **Windshear Peak** is in locations.md | OK | -- | Confirmed present as an optional vista. |

### 1.2 NPC Name Inconsistencies

| Issue | Severity | Details |
|-------|----------|---------|
| **General Varek vs. General Vassar Kole** | **CRITICAL** | events.md (line 72) and the Axis Tower location description (locations.md line 452) call the Interlude boss "General Varek." npcs.md calls him "General Vassar Kole" consistently. events.md also uses "General Vassar Kole" in its own NPC thread section (line 368) and NPC tracker (line 703). The same document uses both names. The boss at the Axis Tower and the boss at Ironmark Citadel appear to be the SAME character with two names, or they are two different characters conflated into one. Based on the narrative flow, this is one character: the Interlude boss encountered during the "Finding Lira" sequence in Corrund. The name "Varek" must be corrected to "Kole." |
| **Valdris Capital vs. Valdris Crown** | **IMPORTANT** | npcs.md consistently uses "Valdris Capital" for the NPC location field (e.g., "Valdris Capital, Throne Hall"). locations.md calls it "Valdris Crown (Capital)." events.md uses "Valdris Crown." outline.md uses "the Valdris capital." The canonical name should be "Valdris Crown" per locations.md, with "the capital" used descriptively. npcs.md location fields should use "Valdris Crown." |
| **Father Aldous's monastery name** | **IMPORTANT** | npcs.md says Father Aldous is at "Monastery of the Still Water" in the Valdris Highlands. locations.md says Highcairn has the "Monastery of the Vigil." events.md references the Highcairn monastery. outline.md says Edren retreats to "a remote monastery in the Valdris highlands." These should be the same place. The canonical name should be "Monastery of the Vigil" at Highcairn, per locations.md. |

### 1.3 NPCs Referenced in events.md / sidequests.md but Missing from npcs.md

| Issue | Severity | Details |
|-------|----------|---------|
| **Vessa** (Roothollow spirit-speaker) | **IMPORTANT** | Referenced in locations.md, events.md (flag 3, flag 7, NPC tracker), and sidequests.md (minor quest 3 "Root-Weaver's Request"). She has no entry in npcs.md despite being a quest-giver with dialogue. |
| **Commander Halda** (Thornwatch garrison commander) | **IMPORTANT** | Referenced in locations.md, events.md (multiple flags), and sidequests.md (minor quest 2 "Border Patrol"). Has dialogue and quest-giver role but no npcs.md entry. |
| **Spirit-speaker Caden** (Duskfen) | **IMPORTANT** | Referenced in locations.md, events.md (flags 8, 12), and sidequests.md (post-game). Has dialogue and a significant story role but no npcs.md entry. |
| **Wynne** (Canopy Reach spirit-speaker) | **IMPORTANT** | Referenced in locations.md, events.md (flags 9, 14), and sidequests.md ("What the Stars Said" visits Canopy Reach). Has dialogue and a story role but no npcs.md entry. |

### 1.4 Faction Naming

| Issue | Severity | Details |
|-------|----------|---------|
| No issues found | -- | "Carradan Compact," "Valdris," "Thornmere Wilds," "the Pallor," "Arcanite Forging," "Forgewright" are all used consistently. |

### 1.5 Artifact/Concept Naming

| Issue | Severity | Details |
|-------|----------|---------|
| No issues found | -- | "Pendulum of Despair," "the Convergence," "Bridgewrights," "the Unraveling" are consistent throughout. |

---

## 2. Timeline Consistency

### 2.1 Act Progression Alignment

| Issue | Severity | Details |
|-------|----------|---------|
| events.md aligns with outline.md | OK | The act-by-act progression in events.md matches the story outline precisely. Act I party assembly, Act II diplomatic mission and betrayal, Interlude party scatter/reunion, Act III march and trials, Act IV sacrifice all match. |
| King Aldren post-death appearances | OK | King Aldren is listed as "Dead" from the Interlude onward. He does not appear in any scene after Act II. The events.md NPC tracker correctly marks him as "--" for Interlude, Act III, and Epilogue. events.md flag 13 properly handles his death. |

### 2.2 NPC Location/Timeline Issues

| Issue | Severity | Details |
|-------|----------|---------|
| **Kole's location inconsistency** | **IMPORTANT** | npcs.md places General Kole at "Ironmark Citadel." events.md NPC tracker (line 703) places him at "Corrund (citadel) - boss." events.md critical path step 28 places the boss fight at "Corrund (Axis Tower)." The Axis Tower is in Corrund per locations.md. It is unclear whether Ironmark Citadel is part of Corrund or a separate location. The "Finding Lira" sequence clearly takes place in Corrund. Kole's location in npcs.md should be reconciled with Corrund. |
| **Forgemaster Drayce's location** | **MINOR** | npcs.md says Drayce is in "Caldera." events.md NPC tracker says "Caldera." This is consistent but Caldera doesn't exist in locations.md (see section 1.1). |
| **Osric listed at Millhaven in Acts I-II** | **MINOR** | npcs.md says Osric's location is "Valdris, Eastern Border -- Millhaven (Acts I-II)." But his backstory says he already walked to the capital as a refugee. His Act II presence is in the refugee quarter, not Millhaven. The location header is misleading. |

### 2.3 Side Quest Availability vs. Timeline

| Issue | Severity | Details |
|-------|----------|---------|
| **"The Fading Shifts" references Caldera in Act II** | **IMPORTANT** | The quest is available in "Act II, after the diplomatic mission reaches Compact territory." The diplomatic mission goes to the Thornmere tribes, not Compact territory. The player visits Duskfen, Canopy Reach, and Ashgrove during Act II. Compact territory access (Caldera) isn't clearly established during Act II's diplomatic mission route. Millhaven is accessible as an optional stop, but Caldera is not on the Act II route per locations.md or events.md. This quest may need to be moved to the Interlude, or Caldera needs to be added to the Act II accessible area list. |
| **"The Gloves She Wore" timing** | **MINOR** | Listed as "Act II, after Cael's betrayal at end of Act II (available during early Interlude)." The betrayal ends Act II. This quest is actually an Interlude quest. The availability description is correct but could be clearer. |
| **"The Third Door" references Dry Well of Aelhart** | **MINOR** | The quest sends the party to the Dry Well of Aelhart, Floor 4 (Living Quarters), which is Interlude-accessible (Floors 1-4 open during Interlude; Floor 5+ gated to Act III). The quest-critical tablet is on Floor 4, so the quest is completable during the Interlude without requiring Act III access. Consistent. |
| **"What the Stars Said" references Canopy Reach** | **MINOR** | Available "Act II, after securing the tribal alliance." The quest visits Canopy Reach. locations.md says Canopy Reach is "Inaccessible" during the Interlude. If the player doesn't complete this quest before the Interlude, they can't access Canopy Reach later. This should be documented as a missable quest, or Canopy Reach access should be modified. |

---

## 3. Playability Analysis

### 3.1 Dead Ends and Progression Blockers

| Issue | Severity | Details |
|-------|----------|---------|
| **Aelhart becomes permanently inaccessible after Act I** | **MINOR** | events.md says Aelhart is "cut off" in Act II. The Dry Well quest in the Interlude requires visiting Aelhart. These are contradictory unless the Interlude re-opens Aelhart access. locations.md says the Dry Well is accessible during/after the Interlude. Clarification needed: does the player return to Aelhart in the Interlude despite it being "cut off"? |
| **No dead ends in critical path** | OK | The critical path in events.md (section 5) provides clear progression from step 1 through step 45. Every flag unlocks the next required area or event. |

### 3.2 Location Revisit Frequency

| Issue | Severity | Details |
|-------|----------|---------|
| **Canopy Reach visited once** | **SUGGESTION** | Canopy Reach is only visited in Act II for the diplomatic mission. It becomes inaccessible in the Interlude. The "What the Stars Said" quest provides one reason to revisit during Act II, but there's no Interlude or Act III content. Consider adding Interlude content or keeping it accessible. |
| **Maren's Refuge underused after Act I** | **SUGGESTION** | Visited in Act I. Abandoned in the Interlude. An optional Maren party scene (Scene 2) exists for the Interlude revisit, and the side quest "A Letter Never Sent" sends the party here. Adequate. |
| **Millhaven destroyed, no return** | OK | Appropriate narrative justification -- the pit erupts. The ruins are used for the "Seedgrain" side quest. |

### 3.3 Town-Dungeon Pacing

| Issue | Severity | Details |
|-------|----------|---------|
| Pacing is well-structured | OK | Act I: Aelhart (town) -> Thornwatch (town) -> Ironmouth/Ember Vein (dungeon) -> Roothollow (town) -> Maren's Refuge (town) -> Valdris Crown (town). Act II: Valdris Crown (town) -> Roothollow (town) -> Duskfen (town) -> Fenmother's Hollow (dungeon) -> Canopy Reach (town) -> Ashgrove (gathering) -> Valdris Crown (siege set-piece). Interlude: Four reunion arcs each with town-dungeon-town cadence. Act III: Pallor Wastes (gauntlet dungeon) -> Convergence (final dungeon). The Act III gauntlet is deliberately pacing-heavy with no rest. This is a design choice, not a flaw. |

### 3.4 Save Points and Boss Preparation

| Issue | Severity | Details |
|-------|----------|---------|
| **Pallor Wastes -- no save points before trials** | **SUGGESTION** | locations.md says "No shops, no save points except faint ley line clearings." events.md confirms "no save points except for brief clearings." The five Pallor trials are mini-boss encounters along the gauntlet. It's unclear whether the ley line clearings serve as save points BEFORE each trial. Recommend confirming that a clearing/save exists before each of the five trials AND before the Convergence entrance. |
| **Save points before other bosses** | OK | Fenmother's Hollow has Duskfen (town with save) immediately before. The Axis Tower has Corrund's Undercroft. Highcairn monastery has the town of Highcairn. Adequate. |

### 3.5 Difficulty Curve

| Issue | Severity | Details |
|-------|----------|---------|
| Progression is reasonable | OK | Act I: Tutorial -> low-level encounters. Act II: Mid-level, with the Fenmother as the first real boss challenge. Interlude: Four separate dungeon arcs with escalating difficulty (Highcairn, Corrund, Roothollow, Archive of Ages). Act III: Gauntlet + final boss. Post-game: Super dungeon and super boss. The curve is well-paced for a JRPG. |

---

## 4. Missing Connections

### 4.1 NPCs with No Side Quest or Story Event Connection

| NPC | Severity | Details |
|-----|----------|---------|
| **Bren** (baker) | **SUGGESTION** | Flavor only. Could be given a minor quest -- delivering bread to refugees, or sourcing ingredients during the Interlude. |
| **Wynn** (gate guard) | **SUGGESTION** | Flavor only. Could be involved in the Valdris siege defense or have a small escort/refugee quest. |
| **Nella** (flower seller) | **SUGGESTION** | Flavor only. Her starbloom connection to ley lines could tie into a minor collectible or a potion-crafting quest. |
| **Nara Voss** (textile merchant) | OK | Intentionally disconnected per npcs.md ("She exists because a world made entirely of people with tragic backstories isn't a world -- it's a mausoleum.") |
| **Pell** (dock worker) | **SUGGESTION** | Flavor only. His Thornmere heritage could tie into a small quest about reconnecting with his past, echoing the acceptance theme. |
| **Orun** (tribal warrior) | **SUGGESTION** | Flavor only. His coming-of-age arc across two conversations is effective as-is but could benefit from a minor combat quest. |
| **Dorin** (woodcarver) | **SUGGESTION** | Flavor only but referenced in the epilogue. His totem-cracking arc could tie into a minor quest involving Torren's spirit-speaking. |

### 4.2 Underused Locations

| Location | Severity | Details |
|----------|----------|---------|
| **Canopy Reach** | **SUGGESTION** | Visited once in Act II, inaccessible in Interlude. Could be reopened for the "What the Stars Said" quest or given Interlude content. |
| **Thornwatch** | **SUGGESTION** | Visited in Acts I-II. Falls in the Interlude ("overrun, partially burned"). Could be revisited as a short dungeon -- clearing the fallen fort of Pallor manifestations. |
| **Ashgrove** | OK | Visited in Act II (alliance) and Act III (somber pass-through). Two meaningful visits. |

### 4.3 Unresolved Plot Threads

| Thread | Severity | Details |
|--------|----------|---------|
| **Commander Halda's fate** | **MINOR** | events.md says "Commander Halda's fate unknown" when Thornwatch falls. No resolution in any document. This could be intentional (echoing Voss's unresolved disappearance) or could be addressed in a side quest. |
| **Thessa's disappearance** | **MINOR** | events.md says "Temple of the Old Pacts shuttered. Thessa not found." No resolution. Like Halda, this could be intentional ambiguity. |
| **Marrek's identity** | OK | Intentionally unresolved per events.md and npcs.md. "There is no answer. That's the point." |
| **The sealed door in the Ley Line Depths** | OK | Explicitly noted as "mystery element -- unanswerable in this playthrough, seeds for future content." |

### 4.4 NPCs Who Should React to Events but Lack Dialogue Changes

| NPC | Severity | Details |
|-----|----------|---------|
| **Vessa** (Roothollow spirit-speaker) | **IMPORTANT** | She warns about the Pendulum in Act I and is present during the Interlude crisis at Roothollow, but she has no defined dialogue changes. She should react to the Pendulum's return to the capital, the betrayal, and the Interlude's petrification of the great tree. She needs an npcs.md entry. |
| **Caden** (Duskfen spirit-speaker) | **IMPORTANT** | Plays a role in the alliance and the post-game but has no NPC entry with dialogue progression. |
| **Halda** (Thornwatch commander) | **MINOR** | Has dialogue in locations.md and events.md but no NPC entry for progression tracking. |

---

## 5. Thematic Consistency

### 5.1 Acceptance vs. Denial in Each Act

| Act | Assessment | Notes |
|-----|------------|-------|
| **Act I** | OK | The Pendulum is introduced as a door. Characters begin in denial about its significance. Maren's warning is the first call to acceptance. Cael's nightmares are "dismissable" -- denial as gameplay mechanic. |
| **Act II** | OK | Cael's arc is pure denial of grief, weaponized by the Pallor. King Aldren denies the danger, seeing the Pendulum as salvation. The diplomatic mission forces acceptance of the world's interconnection. Sable's ignored warning is denial with consequences. |
| **Interlude** | OK | Each reunion arc models a form of acceptance. Edren accepts he can't heal alone. Lira accepts she can't save Cael. Torren accepts he can't protect everything. Sable accepts her role matters. Maren accepts the cost of truth. |
| **Act III** | OK | The Pallor trials are the thematic climax -- each overcome through acceptance, not combat. "The Pallor feeds on denial. Acceptance starves it." |
| **Act IV** | OK | Cael's sacrifice is the ultimate acceptance. Lira tells Edren to let him go. The entire act is about releasing what you cannot keep. |

### 5.2 Side Quest Thematic Alignment

| Quest | Assessment | Notes |
|-------|------------|-------|
| The Fading Shifts | Strong | Everyday despair through exploitation mirrors the Pallor's cosmic despair. |
| The Gloves She Wore | Strong | Small human failures that precede catastrophic ones. Acceptance of guilt. |
| The Third Door | Strong | Directly interrogates the game's central sacrifice. Is acceptance wisdom or surrender? |
| The Spirit That Stopped Singing | Strong | Old power vs. new trust. Acceptance of diminished connection. |
| The Auditor's Conscience | Strong | Accountability as acceptance. Documentation as resistance. |
| Seedgrain | Strong | Osric's grain is the Pendulum in miniature. Letting go to grow something new. |
| The Honest Thief | Strong | Sable's practical heroism. Showing up is enough. |
| What the Stars Said | Strong | The world has its own voice in its salvation. Oral tradition as magic. |
| The Commissar's Confession | Strong | Moral mediocrity examined. Cowardice acknowledged vs. denied. |
| A Letter Never Sent | Strong | The Pallor's cruelest weapon: prevention of connection. |
| Minor quests | OK | All connect to themes of loss, community, documentation, or resistance. |

### 5.3 World Transformation

| Transition | Assessment | Notes |
|------------|------------|-------|
| Act I -> Act II | OK | Gradual decline. Markets thin, ley lines weaken, political tensions rise. Believable escalation. |
| Act II -> Interlude | OK | Catastrophic rupture. The Unraveling is the game's World of Ruin. Properly earned by the betrayal, the siege, and the king's death. |
| Interlude -> Act III | OK | Partial stabilization through the party's reunification efforts. The nexus stabilized, but only as a "stay of execution." |
| Act III -> Epilogue | OK | Earned transformation. The world heals into something new, not restored. Hybrid magic/technology reflects the game's reconciliation theme. |

---

## 6. Summary of All Issues

### CRITICAL (2)
1. **Caldera missing from locations.md** -- A major city with 8+ NPCs, 6+ side quests, and significant story content has no location entry.
2. **General Varek/Kole name conflict** -- The Interlude boss is called "Varek" in some places and "Kole" in others within the same document (events.md).

### IMPORTANT (10)
3. Ironmark Citadel missing from locations.md
4. Ashport missing from locations.md
5. Greywood Camp missing from locations.md
6. Stillwater Hollow missing from locations.md
7. "Valdris Capital" vs. "Valdris Crown" naming inconsistency in npcs.md
8. Father Aldous's monastery name ("Still Water" vs. "Vigil")
9. Vessa missing from npcs.md (quest-giver with no entry)
10. Commander Halda missing from npcs.md (quest-giver with no entry)
11. Spirit-speaker Caden missing from npcs.md (story role with no entry)
12. Wynne missing from npcs.md (story role with no entry)

### MINOR (7)
13. Sunstone Ridge missing from locations.md
14. Deeproot Shrine missing from locations.md
15. Ashfen missing from locations.md
16. "The Fading Shifts" availability during Act II is questionable (Caldera not on diplomatic route)
17. Aelhart accessibility contradiction (cut off in Act II, but Dry Well accessible in Interlude)
18. Commander Halda's fate unresolved
19. Osric's location header in npcs.md is misleading

### SUGGESTION (9)
20. Canopy Reach visited only once with no Interlude content
21. Save points before Pallor Wastes trials should be explicit
22. Bren, Wynn, Nella, Pell, Orun, Dorin could benefit from minor quest connections
23. Thornwatch could be revisited as a cleared dungeon
24. "What the Stars Said" may be permanently missable if not completed before the Interlude

---

## 7. Fixes Applied

The following CRITICAL and IMPORTANT issues were fixed directly in the story documents:

### Fix 1: General Varek -> General Kole (CRITICAL)
**File:** events.md
**Change:** Replaced all references to "General Varek" with "General Kole" in the Act II to Interlude transition table and the Interlude flag 17 description. The Axis Tower boss is General Vassar Kole, consistent with npcs.md.

### Fix 2: Valdris Capital -> Valdris Crown (IMPORTANT)
**File:** npcs.md
**Change:** Updated all NPC location fields from "Valdris Capital" to "Valdris Crown" to match the canonical name in locations.md.

### Fix 3: Monastery of the Still Water -> Monastery of the Vigil (IMPORTANT)
**File:** npcs.md
**Change:** Updated Father Aldous's location from "Monastery of the Still Water" to "Monastery of the Vigil" at Highcairn, matching locations.md.

### Fix 4: Added missing NPCs to npcs.md (IMPORTANT)
**File:** npcs.md
**Change:** Added entries for Vessa (Roothollow spirit-speaker), Commander Halda (Thornwatch garrison), Spirit-speaker Caden (Duskfen), and Wynne (Canopy Reach) to fill the gaps where quest-givers and story-role NPCs lacked documentation.

### Fix 5: Added missing locations to locations.md (CRITICAL + IMPORTANT)
**File:** locations.md
**Change:** Added entries for Caldera (CRITICAL), Ironmark Citadel, Ashport, Greywood Camp, Stillwater Hollow, and Sunstone Ridge to fill all CRITICAL and IMPORTANT gaps. Each entry follows the established format with faction, acts, type, description, key features, and player activities.

### Fix 6: General Kole's location reconciled (IMPORTANT)
**File:** npcs.md
**Change:** Updated General Kole's location from "Ironmark Citadel" to "Ironmark Citadel, southeast of Corrund" and clarified in his backstory that the Interlude boss encounter takes place when the party infiltrates the citadel through the Axis Tower (which connects to the citadel complex in Corrund). This reconciles the Corrund/Ironmark inconsistency.

### Fix 7: Osric's location header corrected (MINOR, fixed opportunistically)
**File:** npcs.md
**Change:** Updated Osric's location from "Valdris, Eastern Border -- Millhaven (Acts I-II)" to "Valdris Crown, refugee quarter (Act II onward)" to match his actual presence in the story.
