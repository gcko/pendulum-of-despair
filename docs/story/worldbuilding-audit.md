# Worldbuilding Cross-Reference Audit

Cross-reference of biomes.md, geography.md, dynamic-world.md, and visual-style.md against all existing story documents (outline.md, world.md, characters.md, locations.md, npcs.md, events.md, sidequests.md). Issues categorized as CRITICAL, IMPORTANT, MINOR, or SUGGESTION.

Previous continuity audit: continuity-audit.md (covers outline/world/characters/locations/npcs/events/sidequests).

---

## 1. Location Name Consistency

### 1.1 Locations in New Documents Not in locations.md

| Issue | Severity | Referenced In | Details |
|-------|----------|---------------|---------|
| **Gael's Span** not in locations.md | **IMPORTANT** | locations.md (ASCII map only), geography.md (ASCII map, Gael's Bluff), visual-style.md (full visual profile) | Gael's Span appears on the ASCII map in locations.md (line 22), has a full visual profile in visual-style.md (section 2), and is positioned on the geography.md map with detail about the bridge-town. However, it has NO location entry with faction, acts, type, key features, or player activities. visual-style.md treats it as a full visitable town. |
| **Kettleworks** not in locations.md | **IMPORTANT** | locations.md (ASCII map only), geography.md (ASCII map, Kettleworks Ridge), visual-style.md (full visual profile) | Same issue as Gael's Span. Kettleworks appears on the ASCII map in locations.md (line 22), has a full visual profile in visual-style.md, and is referenced in geography.md's ley line network (The Forgeward Line passes through it). No location entry exists. |
| **Deeproot Shrine** referenced in visual-style.md but not in locations.md | **MINOR** | visual-style.md (section 4 "Spiritual Sites"), npcs.md, sidequests.md | visual-style.md section 4 lists "Deeproot Shrine" alongside Ashgrove and Stillwater Hollow as a spiritual site dungeon. npcs.md and sidequests.md also reference it. No location entry in locations.md. Previously flagged in continuity-audit.md. |
| **Greywood River** referenced in visual-style.md but not in geography.md | **MINOR** | visual-style.md (Gael's Span profile, line ~307) | Gael's Span visual profile says the bridge spans "the Greywood River." geography.md does not name this river. The Corrund River's upper reach is at Gael's Bluff per geography.md, suggesting the "Greywood River" is either the Corrund's upper reach renamed or a different waterway. |

### 1.2 Spelling and Name Consistency

| Issue | Severity | Details |
|-------|----------|---------|
| **Continent name "Ardenmere"** used only in geography.md | **MINOR** | geography.md names the continent "Ardenmere" (line 11). No other document uses this name. world.md, outline.md, locations.md, and others refer only to "the continent." The name should be consistent or geography.md should note it is introducing the name. Not an error, but a gap. |
| All other location names consistent | OK | Valdris Crown, Corrund, Ashmark, Bellhaven, Millhaven, Roothollow, Duskfen, Ashgrove, Canopy Reach, Highcairn, Thornwatch, Greyvale, Ironmouth, Caldera, Ashport, Ironmark Citadel, Greywood Camp, Stillwater Hollow, Sunstone Ridge, Maren's Refuge, Windshear Peak are all consistently spelled across all documents. |

### 1.3 Biome Assignment Consistency

| Issue | Severity | Details |
|-------|----------|---------|
| All biome assignments consistent | OK | biomes.md's "Locations Using This Biome" lists match visual-style.md's biome assignments and the biome-to-location appendix in biomes.md. Checked: Aelhart (Valdris Highlands), Valdris Crown (Valdris Highlands urban), Thornwatch (Valdris Highlands military), Greyvale (Valdris Highlands ruined), Highcairn (Mountain/Alpine), Corrund (Carradan Industrial), Ashmark (Carradan Industrial heavy), Caldera (Carradan Industrial volcanic), Bellhaven (Coastal/Harbor), Ashport (Coastal/Harbor industrial), Millhaven (Carradan Industrial extraction), Ironmouth (Carradan Industrial frontier), Ironmark Citadel (Carradan Industrial military), Roothollow (Thornmere Deep Forest), Duskfen (Thornmere Wetlands), Ashgrove (Ashlands), Canopy Reach (Thornmere Deep Forest vertical), Greywood Camp (Thornmere Deep Forest open), Stillwater Hollow (Thornmere Deep Forest + Ley Line Nexus subtle), Sunstone Ridge (Ley Line Nexus amber), Maren's Refuge (Thornmere Deep Forest), Windshear Peak (Mountain/Alpine bare). |

---

## 2. Geography-Location Alignment

### 2.1 ASCII Map vs. Faction Assignments

| Issue | Severity | Details |
|-------|----------|---------|
| Geography map positions match faction assignments | OK | geography.md places Valdris locations (Aelhart, Valdris Crown, Highcairn, Thornwatch, Greyvale) in the northwest. Compact locations (Corrund, Ashmark, Caldera, Bellhaven, Ashport, Millhaven, Ironmark Citadel, Kettleworks) in the southeast. Thornmere settlements (Roothollow, Duskfen, Ashgrove, Canopy Reach, Greywood Camp, Stillwater Hollow, Sunstone Ridge, Maren's Refuge, Windshear Peak) in the central band. The Convergence at dead center. All consistent with locations.md and world.md. |
| **Gael's Span positioned as Wilds-to-Compact border** | **MINOR** | geography.md places Gael's Span at the southern edge of the Wilds on the Corrund River. locations.md's ASCII map shows it between the Wilds and the Compact. visual-style.md describes it as a contested border point with two different faction flags. This is consistent but Gael's Span has no location entry to formalize its faction status (see 1.1). |

### 2.2 Travel Routes

| Issue | Severity | Details |
|-------|----------|---------|
| Travel routes consistent | OK | locations.md's overworld routes match geography.md's terrain descriptions. Aelhart to Thornwatch (highland road), Thornwatch to Ironmouth (forest descent), Ironmouth to Roothollow (deep forest trail), Roothollow to Maren's Refuge (deep path). The diplomatic road (Valdris Crown to Duskfen to Canopy Reach) matches the geography. The Corrund to Roothollow Interlude route crosses the Compact-Wilds border, consistent with geography.md's Broken Hills description. |
| dynamic-world.md overworld routes match locations.md | OK | dynamic-world.md's overworld route section (starting at line 593) lists the same routes as locations.md with matching act availability and terrain descriptions. |

### 2.3 Ley Line Positions

| Issue | Severity | Details |
|-------|----------|---------|
| Ley line positions consistent between geography.md and biomes.md | OK | geography.md defines seven major ley lines converging at the Convergence. biomes.md's Ley Line Nexus biome lists Sunstone Ridge (amber variant), Ley Line Depths (underground), Ember Vein (introductory), the Convergence (extreme), and Stillwater Hollow (subtle) as nexus locations. These match geography.md's node definitions (Convergence, Valdris Crown, Sunstone Ridge, Roothollow Rise, Millhaven Pit, Fenmother's Hollow). |
| Ley line states consistent with events.md | OK | geography.md's ley line state by act matches events.md's world state changes. Act I dimming, Act II strained with the Hearthline and Shoreward failing, Interlude rupture destroying Millhaven and fracturing the Thornvein, Epilogue stabilization. |
| **geography.md ley line diagram includes Kettleworks** | **MINOR** | geography.md's ley line network diagram (line ~305) shows the Forgeward Line passing through Kettleworks on its way to Corrund. events.md does not reference Kettleworks ley line effects. This is consistent but under-documented due to Kettleworks lacking a location entry. |

---

## 3. Dynamic World-Events Alignment

### 3.1 Event Flags and Dynamic World Changes

| Issue | Severity | Details |
|-------|----------|---------|
| `carradan_assault_begins` flag | OK | events.md defines this flag. dynamic-world.md references it for the Valdris Crown eastern wall breach (line 702) and the throne room transformation (line 703). Consistent. |
| `king_aldren_dead` flag | OK | events.md defines this. dynamic-world.md references it for the throne room tile swap (line 703). Consistent. |
| `ley_line_rupture` flag | OK | events.md defines this at the Interlude transition. dynamic-world.md references it for the Millhaven destruction (line 709), the Carradan Rail Tunnel collapse (line 734), and the overworld ley line fissures (line 767). Consistent. |
| `convergence_reached` flag | OK | events.md defines this at Act III arrival. dynamic-world.md references it for the Convergence Plateau Fracture (line 724). Consistent. |
| **Gael's Span and Kettleworks have no dynamic world entries** | **IMPORTANT** | dynamic-world.md has transformation entries for every location in locations.md but no entries for Gael's Span or Kettleworks. visual-style.md has visual profiles for both. These locations exist in the visual design but have no defined world-state changes. |

### 3.2 Act-by-Act States

| Issue | Severity | Details |
|-------|----------|---------|
| dynamic-world.md act states match events.md | OK | Checked all major locations. Valdris Crown (Act I stable, Act II declining with assault, Interlude fractured, Epilogue rebuilding), Roothollow (Act I healthy, Act II diplomatic, Interlude petrifying, Epilogue healing), Corrund (Interlude disrupted with Axis Tower, Act III disarray, Epilogue rebuilding), Millhaven (Act II extraction, Interlude destroyed). All match events.md's world state tables. |
| dynamic-world.md Pallor corruption timeline matches biomes.md | OK | dynamic-world.md Section 6 ("The Pallor's Visual Progression") lists corruption stages by act and location that match biomes.md Section 5 ("Pallor Corruption Overlay System"). Act I: none visible. Late Act II: Stage 1 in limited areas. Interlude: Stage 1-2 everywhere, Stage 2 dominant. Act III: Stage 3 in the Wastes, Stage 2 elsewhere. Both documents agree on the specific per-location corruption stages. |

### 3.3 Missing Dynamic World Entries

| Issue | Severity | Details |
|-------|----------|---------|
| **Gael's Span** has no dynamic-world.md entry | **IMPORTANT** | See 3.1 above. |
| **Kettleworks** has no dynamic-world.md entry | **IMPORTANT** | See 3.1 above. |
| **Deeproot Shrine** has no dynamic-world.md entry | **MINOR** | Referenced in visual-style.md as a spiritual site but has no dynamic-world state. Also has no locations.md entry (previously flagged). |

---

## 4. Visual Style-Biome Alignment

### 4.1 Color Palette References

| Issue | Severity | Details |
|-------|----------|---------|
| visual-style.md location palettes match biomes.md | OK | Spot-checked all location visual profiles. Aelhart uses Valdris Highlands hex values (#7DBE6E, #D6CDB8, #8B6B42, #D4A832). Corrund uses Carradan Industrial hex values (#A86B4E, #6B3E2A, #5A5A62, #E88830, #C49840, #82B8D4). Roothollow uses Thornmere Deep Forest values (#2E6B3A, #4A3A2E, #2A3A28, #68D8B8, #6B4A30, #B088D8). Duskfen uses Thornmere Wetlands values (#3A4A38, #7A8A48, #5A4A38, #A8A898, #C8D858). All match biomes.md definitions. |
| Epilogue meadow palette is unique (as designed) | OK | visual-style.md Scene 9 introduces #6AB87A, #D878B8, #78B8D8, #D8B878, #78A8D8, #F8F0E0 as the epilogue meadow palette. biomes.md confirms the epilogue state uses different colors from Act I. The post-credits green #4AE060 appears nowhere else. This is deliberate per visual-style.md's color script. |

### 4.2 Location Visual Profile Coverage

| Issue | Severity | Details |
|-------|----------|---------|
| **Greyvale** has no visual profile in visual-style.md | **MINOR** | Greyvale is a visitable location in Acts II and Interlude with defined dynamic-world states but no dedicated visual profile section in visual-style.md. It is referenced only in biomes.md as using "Valdris Highlands (ruined variant)." |
| **Greywood Camp** has no visual profile in visual-style.md | **MINOR** | Greywood Camp is a major settlement visited in Acts II and Interlude. It has biome assignment (Thornmere Deep Forest, open-forest variant) and full dynamic-world states but no visual profile in visual-style.md. |
| **Stillwater Hollow** has no visual profile in visual-style.md | **MINOR** | Stillwater Hollow is visitable in Acts II and Interlude with dynamic-world entries but no visual-style.md profile. |
| **Sunstone Ridge** has no visual profile in visual-style.md | **MINOR** | Sunstone Ridge is visitable in Acts II and Interlude with dynamic-world entries but no visual-style.md profile. |
| **Maren's Refuge** has no visual profile in visual-style.md | **MINOR** | Act I location with dynamic-world entry but no visual-style.md profile. |
| **Ironmark Citadel** has no visual profile in visual-style.md | **MINOR** | Interlude dungeon with full dynamic-world entry but no visual-style.md profile. |
| **Windshear Peak** has no visual profile in visual-style.md | **MINOR** | Optional location in Acts II-III with dynamic-world entries but no visual-style.md profile. |
| Gael's Span and Kettleworks HAVE visual profiles | OK | These two are in visual-style.md but missing from locations.md and dynamic-world.md (reverse of the above pattern). |

### 4.3 Signature Scene Consistency with Story Outline

| Issue | Severity | Details |
|-------|----------|---------|
| **Scene 10 (Ashgrove Reunion): Torren's death contradicts outline.md** | **CRITICAL** | visual-style.md Scene 10 (line 655) states: "Torren's totem (not Torren -- he did not survive his sacrifice) is carried by a Roothollow elder from the west." This directly contradicts: (1) outline.md which says "Torren returns to the spirit-speakers" in the epilogue, (2) characters.md which says Torren "Survives," (3) events.md NPC tracker which lists Torren as "Home" in the Epilogue, (4) locations.md which says Torren "returns to the spirit-speakers," (5) sidequests.md which has Torren-specific post-game content. Only visual-style.md claims he dies. |
| Scene 2 (Cael's Betrayal) | OK | visual-style.md places this at end of Act II at the Convergence. However, outline.md says Cael "vanishes" using the weakened ley lines, and the confrontation with Lira happens at Valdris Crown before the Convergence. The visual-style.md description refers to "the Convergence" but the camera zoom to overworld scale showing the grey pulse is a cinematic effect, not a literal location change. Slightly ambiguous but not contradictory since the grey light erupts from wherever Cael opens the gate. |
| Scene 5 (Torren's Sacrifice) | OK | Consistent with outline.md and locations.md which describe Torren "nearly killing himself" during the Interlude ritual, then the party arriving to stabilize the nexus. visual-style.md describes the same scene with added visual detail. The phrase "his last frame is a transparent silhouette" is dramatic description of near-death, not actual death (consistent with "nearly kills himself"). |
| All other signature scenes | OK | Scenes 1, 3, 4, 6, 7, 8, 9, 11, 12 are consistent with the story outline and events.md. |

---

## 5. Missing Coverage

### 5.1 Locations Without Dynamic World Entries

| Location | Severity | Details |
|----------|----------|---------|
| **Gael's Span** | **IMPORTANT** | Appears in visual-style.md with a full visual profile and on the ASCII maps in locations.md and geography.md. No locations.md entry, no dynamic-world.md entry. |
| **Kettleworks** | **IMPORTANT** | Same as Gael's Span. Has visual-style.md profile, appears on maps and in geography.md's ley line network. No locations.md entry, no dynamic-world.md entry. |
| **Deeproot Shrine** | **MINOR** | Referenced in visual-style.md dungeon section, npcs.md, sidequests.md. No locations.md, biomes.md, dynamic-world.md, or geography.md entries. |

### 5.2 Biomes Referenced but Not Defined

| Issue | Severity | Details |
|-------|----------|---------|
| No missing biome definitions | OK | All 11 biomes defined in biomes.md are referenced and used. No location references a biome that does not exist. |

### 5.3 Dungeons Without Visual Approach

| Issue | Severity | Details |
|-------|----------|---------|
| visual-style.md covers dungeon visual approaches | OK | Section 4 covers Natural Caves (Ember Vein, Dry Well), Forgewright Facilities (Rail Tunnels, Axis Tower, Sunken Rig), Ancient Ruins (Archive of Ages, Ember Vein inner chambers), Corrupted Areas (Pallor Wastes), and Spiritual Sites. All major dungeon types are covered. |
| **Fenmother's Hollow** not explicitly named in visual approach | **MINOR** | The submerged ruin dungeon is not explicitly named in visual-style.md section 4, though it would fall under "Natural Caves" transitioning to underground. biomes.md covers it in the Thornmere Wetlands section (line 265: "Fenmother's Hollow -- submerged ruin variant"). |
| **Ley Line Depths** not explicitly in dungeon approach | **MINOR** | Not named in visual-style.md section 4. Covered by biomes.md (Underground/Cavern transitioning to Ley Line Nexus). |

### 5.4 Missing Connections Between New Documents

| Issue | Severity | Details |
|-------|----------|---------|
| **geography.md introduces the continent name "Ardenmere"** | **MINOR** | No other document uses this name. Should be referenced in world.md for consistency. |
| **geography.md's "Greywood River" not in geography.md's rivers** | **IMPORTANT** | visual-style.md's Gael's Span profile references the "Greywood River" that the bridge spans. geography.md describes Gael's Bluff as being where "Gael's Span crosses the Corrund River's upper reach" (line 180). This is a name conflict: is the river at Gael's Span the Corrund River or the Greywood River? |

---

## 6. Summary of All Issues

### CRITICAL (1)
1. **Torren's fate contradicted in visual-style.md Scene 10** -- visual-style.md says Torren "did not survive his sacrifice." Five other documents (outline.md, characters.md, events.md, locations.md, sidequests.md) say he survives.

### IMPORTANT (5)
2. **Gael's Span missing from locations.md and dynamic-world.md** -- Has a full visual-style.md profile, appears on maps, but no location entry or world-state transformations.
3. **Kettleworks missing from locations.md and dynamic-world.md** -- Same as Gael's Span. Also part of geography.md's ley line network.
4. **Gael's Span and Kettleworks missing from dynamic-world.md** -- No transformation entries for either location despite visual-style.md treating them as full towns.
5. **Greywood River vs. Corrund River name conflict** -- visual-style.md says Gael's Span crosses the "Greywood River"; geography.md says it crosses the Corrund River's upper reach.
6. **Deeproot Shrine** referenced in visual-style.md section 4 but still missing from locations.md (previously flagged in continuity-audit.md as MINOR; elevated here because visual-style.md now treats it as a named dungeon type).

### MINOR (10)
7. Continent name "Ardenmere" used only in geography.md.
8. Greyvale has no visual-style.md profile.
9. Greywood Camp has no visual-style.md profile.
10. Stillwater Hollow has no visual-style.md profile.
11. Sunstone Ridge has no visual-style.md profile.
12. Maren's Refuge has no visual-style.md profile.
13. Ironmark Citadel has no visual-style.md profile.
14. Windshear Peak has no visual-style.md profile.
15. Fenmother's Hollow not explicitly named in visual-style.md dungeon approach.
16. Ley Line Depths not explicitly named in visual-style.md dungeon approach.

### SUGGESTION (3)
17. Consider adding visual-style.md profiles for the 7 locations that have dynamic-world.md entries but no visual profiles (issues 8-14).
18. Consider adding Fenmother's Hollow and Ley Line Depths to visual-style.md section 4 explicitly.
19. Propagate the continent name "Ardenmere" to world.md or note it as geography.md's introduction.

---

## 7. Fixes Applied

The following CRITICAL and IMPORTANT issues were fixed directly in the story documents:

### Fix 1: Torren's Fate in visual-style.md Scene 10 (CRITICAL)
**File:** visual-style.md
**Change:** Corrected Scene 10 (Ashgrove Reunion) to show Torren arriving in person from the west, consistent with outline.md, characters.md, events.md, locations.md, and sidequests.md which all confirm he survives.

### Fix 2: Added Gael's Span to locations.md (IMPORTANT)
**File:** locations.md
**Change:** Added a full location entry for Gael's Span as a Thornmere Wilds / Carradan Compact border location, consistent with its visual-style.md profile, geography.md map position, and its role as a contested crossing point.

### Fix 3: Added Kettleworks to locations.md (IMPORTANT)
**File:** locations.md
**Change:** Added a full location entry for Kettleworks as a Carradan Compact research facility, consistent with its visual-style.md profile, geography.md map position, and its position on the Forgeward Ley Line.

### Fix 4: Greywood River -> Corrund River in visual-style.md (IMPORTANT)
**File:** visual-style.md
**Change:** Corrected the Gael's Span visual profile to reference "the Corrund River's upper reach" instead of "the Greywood River," matching geography.md's established river naming.

### Fix 5: Added Gael's Span and Kettleworks to dynamic-world.md (IMPORTANT)
**File:** dynamic-world.md
**Change:** Added transformation entries for both locations in the appropriate sections, covering their Act I/II states and Interlude changes.
