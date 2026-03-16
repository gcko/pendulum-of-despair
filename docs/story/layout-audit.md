# Layout Continuity Audit -- Pendulum of Despair

Final QA pass cross-referencing city layouts, dungeon designs, interior maps, and secret passages against all existing story documentation (locations.md, npcs.md, events.md, sidequests.md).

Audit date: 2026-03-15

Severity levels:
- **CRITICAL** -- Will cause a soft-lock, broken quest, or inaccessible required content
- **IMPORTANT** -- Significant inconsistency that breaks immersion or confuses the player
- **MINOR** -- Small discrepancy that is easy to miss but should be fixed
- **SUGGESTION** -- Not a bug; an improvement opportunity

---

## 1. Building/Location Coverage

### 1.1 City Coverage: locations.md vs. city layout documents

| Location (locations.md) | Layout Document | Status |
|-------------------------|----------------|--------|
| Valdris Crown | city-valdris.md Section 1 | COVERED |
| Aelhart | city-valdris.md Section 2 | COVERED |
| Highcairn | city-valdris.md Section 3 | COVERED |
| Thornwatch | city-valdris.md Section 4 | COVERED |
| Greyvale | city-valdris.md Section 5 | COVERED |
| Corrund | city-carradan.md Section 1 | COVERED |
| Caldera | city-carradan.md Section 2 | COVERED |
| Ashmark | city-carradan.md Section 3 | COVERED |
| Bellhaven | city-carradan.md Section 4 | COVERED |
| Millhaven | city-carradan.md Section 5 | COVERED |
| Ashport | city-carradan.md Section 6 | COVERED |
| Ironmark Citadel | city-carradan.md Section 7 | COVERED |
| Ironmouth | city-carradan.md Section 8 | COVERED |
| Gael's Span | city-carradan.md Section 9 AND city-thornmere.md Section 9 | COVERED (duplicate -- see MINOR-01) |
| Kettleworks | city-carradan.md Section 10 | COVERED |
| Roothollow | city-thornmere.md Section 1 | COVERED |
| Duskfen | city-thornmere.md Section 2 | COVERED |
| Ashgrove | city-thornmere.md Section 3 | COVERED |
| Canopy Reach | city-thornmere.md Section 4 | COVERED |
| Greywood Camp | city-thornmere.md Section 5 | COVERED |
| Stillwater Hollow | city-thornmere.md Section 6 | COVERED |
| Sunstone Ridge | city-thornmere.md Section 7 | COVERED |
| Maren's Refuge | city-thornmere.md Section 8 | COVERED |
| The Pendulum (Tavern) | city-thornmere.md Section 9 | COVERED |
| The Three Roads Inn | city-thornmere.md Section 9 | COVERED |
| Rhona's Trading Post | city-thornmere.md Section 9 | COVERED |

**Result:** All cities and settlements in locations.md have detailed layouts. No missing locations.

### 1.2 Dungeon Coverage: locations.md vs. dungeon documents

| Dungeon (locations.md) | Layout Document | Status |
|------------------------|----------------|--------|
| Ember Vein | dungeons-world.md Section 1 | COVERED |
| Fenmother's Hollow | dungeons-world.md Section 2 | COVERED |
| Carradan Rail Tunnels | dungeons-world.md Section 3 | COVERED |
| Axis Tower Interior | dungeons-world.md Section 4 | COVERED |
| Ley Line Depths | dungeons-world.md Section 5 | COVERED |
| Pallor Wastes | dungeons-world.md Section 6 | COVERED |
| The Convergence | dungeons-world.md Section 7 | COVERED |
| Archive of Ages | dungeons-world.md Section 8 | COVERED |
| Dreamer's Fault | dungeons-world.md Section 9 | COVERED |
| Dry Well of Aelhart | dungeons-world.md Section 10 | COVERED |
| Sunken Rig | dungeons-world.md Section 11 | COVERED |
| Windshear Peak | dungeons-world.md Section 12 | COVERED |
| Valdris Crown Catacombs | dungeons-city.md Section 1 | COVERED |
| Corrund Sewers | dungeons-city.md Section 1 | COVERED |
| Caldera Undercity | dungeons-city.md Section 1 | COVERED |
| Ashmark Factory Depths | dungeons-city.md Section 1 | COVERED |
| Ironmark Citadel Dungeons | dungeons-city.md Section 1 | COVERED |
| Bellhaven Smuggler Tunnels | dungeons-city.md Section 1 | COVERED |

**Result:** All dungeons have detailed floor plans. No missing dungeons.

### 1.3 Interior Coverage

| Building | Interior Source | Status |
|----------|---------------|--------|
| Valdris Crown Throne Room | interiors.md 1.1 | COVERED (story-critical) |
| Valdris Crown Royal Library | interiors.md 1.2 | COVERED (story-critical) |
| Maren's Refuge | interiors.md 1.3 | COVERED (story-critical) |
| Highcairn Monastery Great Hall | interiors.md 1.4 | COVERED (story-critical) |
| Ironmark Command Chamber | interiors.md 1.5 | COVERED (story-critical) |
| The Pendulum Tavern | interiors.md 1.6 | COVERED (story-critical) |
| Valdris weapon/inn/tavern/temple/residential | interiors.md 2.1 | COVERED (template examples) |
| Carradan weapon/inn/tavern/workshop/residential | interiors.md 2.2 | COVERED (template examples) |
| Thornmere hunter/guest/healer/elder/trader | interiors.md 2.3 | COVERED (template examples) |
| Axis Tower (non-dungeon) | interiors.md 3.1 | COVERED |
| Corrund Guild Hall / Merchants' Council | interiors.md 3.2 | COVERED |
| Valdris Crown Inn (Anchor & Oar) | interiors.md 3.3 | COVERED |
| Canopy Reach Observatory | interiors.md 3.4 | COVERED |
| All other standard buildings | building-palette.md templates | COVERED (12 templates + faction variants) |

**Result:** Story-critical interiors are fully mapped. Standard buildings are covered by the building-palette.md template system.

### Issues Found

**MINOR-01: Duplicate Gael's Span layouts**
Gael's Span has layouts in both city-carradan.md (Section 9) and city-thornmere.md (Section 9, Cross-Faction Locations). The Carradan version is more detailed with a full building directory, shop inventories, and act-by-act changes. The Thornmere version has a different ASCII map and building list focusing on the dual-faction visual split.

Severity: **MINOR**
Recommendation: The two documents are complementary but risk contradictions. The Carradan version lists 6 buildings (Wilds Guard Post, Ranger's Hut, Bridge Provisioner, The Span tavern, Compact Guard Post, Checkpoint Shed). The Thornmere version lists 7 (same but splits the provisioner into Wilds Provisioner and Compact Provisioner, and adds separate taverns for each side). These are different conceptions of the same location.

**IMPORTANT-01: Continental map in locations.md omits Caldera, Ashport, and Ironmark Citadel**
The ASCII continental overview in locations.md (lines 11-26) shows only `Corrund --- Ashmark --- Bellhaven --- Millhaven` for the Compact. Caldera, Ashport, Ironmark Citadel, and Kettleworks are all described as full locations but Caldera and Ashport are absent from the visual map. Kettleworks is shown but between Thornmere and Compact zones. Ironmark is absent.

Severity: **IMPORTANT**
The map is a key orientation tool. Omitting major cities from it will confuse anyone trying to understand the world layout.

---

## 2. NPC Placement Consistency

### 2.1 NPC Home Locations vs. City Maps

| NPC | Location (npcs.md) | City Map | Status |
|-----|-------------------|----------|--------|
| King Aldren | Valdris Crown, Throne Hall | city-valdris.md Royal Keep | OK |
| Lord Chancellor Haren | Valdris Crown, Court Quarter | city-valdris.md Haren's Estate | OK |
| Dame Cordwyn | Valdris Crown, Knight Barracks | city-valdris.md Lower Ward Barracks | OK |
| Scholar Aldis | Valdris Crown, Royal Library | city-valdris.md Citizen's Walk | OK |
| Bren | Aelhart | city-valdris.md Aelhart | OK |
| Wynn | Aelhart, south meadow | city-valdris.md Aelhart | OK |
| Elara Thane | Valdris Crown / Greyvale | city-valdris.md both | OK |
| Osric | Aelhart, smithy | city-valdris.md Aelhart smithy | OK |
| Sergeant Marek | Thornwatch | city-valdris.md Thornwatch | OK |
| Thessa | Valdris Crown, Chapel of Old Pacts | city-valdris.md Lower Ward | OK |
| Commander Halda | Thornwatch | city-valdris.md Thornwatch | OK |
| Renn | Valdris Crown, tavern | city-valdris.md Lower Ward (Seven Cups/Anchor & Oar) | OK |
| Father Aldous | Highcairn Monastery | city-valdris.md Highcairn Great Hall | OK |
| Mirren | Valdris Crown, Royal Library | city-valdris.md Citizen's Walk | OK |
| Voss | Greyvale | city-valdris.md Greyvale | OK |
| General Kole | Ironmark Citadel | city-carradan.md Ironmark Command Chamber | OK |
| Forgemaster Elyn Drayce | Caldera, Forgewrights' Academy | city-carradan.md Caldera Upper Rim | OK |
| Dael Corran | Caldera, lower factory district | city-carradan.md Caldera Lower District (Dael's Corner) | OK |
| Cira | Caldera, Forgewrights' Academy | city-carradan.md Caldera (Forgewrights' Academy #3) | OK |
| Holt Varen | Ashport | city-carradan.md Ashport Merchant Quarter | OK |
| Tash | Corrund Undercroft / Caldera Undercity | city-carradan.md both locations | OK |
| Commissar Brant | Ironmark Citadel | city-carradan.md Ironmark (Brant's Quarters) | OK |
| Mira Thenn | Caldera, undercity | city-carradan.md Caldera Undercity (Mira's Cartography Studio) | OK |
| Pell | Ashport, docks | city-carradan.md Ashport (Dock Workers' Shed, Pell's Boarding House) | OK |
| Fenn Acari | Corrund / Caldera Council | city-carradan.md Corrund (not explicitly placed) / Caldera (Merchants' Council Hall) | SEE IMPORTANT-02 |
| Sera Linn | Caldera, undercity | city-carradan.md Caldera Undercity (Resistance HQ) | OK |
| Jace Renn | Caldera / Kettleworks | city-carradan.md Caldera (Forgewrights' Academy) / Kettleworks (Laboratory Dome, "sometimes") | OK |
| Nara Voss | Ashport | city-carradan.md Ashport (Nara Voss's Textile Shop) | OK |
| Kel | Caldera, lower factory district | city-carradan.md Caldera (Kel's Bellows Station) | OK |
| Ansa Veld | Ironmark Citadel, Lower Cells | city-carradan.md / dungeons-city.md Ironmark Lower Cells | OK |
| Vessa | Roothollow | city-thornmere.md Roothollow (Vessa's Chamber) | OK |
| Caden | Duskfen | city-thornmere.md Duskfen (Caden's Platform) | OK |
| Wynne | Canopy Reach | city-thornmere.md Canopy Reach Observatory | OK |
| Elder Savanh | Greywood Camp | city-thornmere.md Greywood (Elder's Tent) | OK |
| Kael Thornwalker | Greywood Camp | city-thornmere.md Greywood (Ranger Post) | OK |
| Yara | Stillwater Hollow | city-thornmere.md Stillwater Hollow (Yara's Lean-to) | OK |
| Ashara | Sunstone Ridge | city-thornmere.md Sunstone Ridge (Ashara's Camp) | OK |
| Grandmother Seyth | Greywood Camp | city-thornmere.md Greywood (Seyth's Tent) | OK |
| Dorin | Greywood Camp | city-thornmere.md Greywood (Dorin's Crafting Circle) | OK |
| Wren | Greywood Camp | city-thornmere.md Greywood (Children's Area) | OK |
| Orun | Greywood Camp | city-thornmere.md Greywood (Orun's Tent) | OK |
| Rhona | Ashfen / border | city-thornmere.md Rhona's Trading Post | OK |
| Hadley | Three Roads crossroads | city-thornmere.md Three Roads Inn | OK |
| Tavin | Duskfen / patrols | city-thornmere.md Duskfen Watch Post ("visits") | OK |

### Issues Found

**IMPORTANT-02: Fenn Acari not placed on Corrund city map**
npcs.md places Fenn Acari as "Guildmaster" in both Corrund and Caldera contexts. The Caldera city layout (city-carradan.md) explicitly places him at the Merchants' Council Hall. However, the Corrund city layout makes no mention of Fenn Acari in any building. The Consortium Council Hall in Corrund (#3) lists "Consortium officials" but does not name him. interiors.md Section 3.2 labels the Merchants' Council Hall as located in Caldera's Upper Rim and puts Acari in his private office on the upper floor.

Severity: **IMPORTANT**
As the head of the Consortium, Acari should be findable in Corrund (the capital) during Act II, not only in Caldera. The Corrund Consortium Council Hall needs Acari listed as an NPC or have dialogue explaining he is in Caldera.

**MINOR-02: Brenn, Riven, Fiara, Marrek, and The Archivist have no explicit city map placements**
These NPCs from npcs.md have locations described narratively but are not explicitly listed in any city building directory:
- Brenn: "Various Thornmere settlements" -- ambient NPC, no fixed building
- Riven: "Border between Valdris and the Wilds" -- wandering NPC
- Fiara: "Duskfen, edge of the settlement" -- not in Duskfen building directory
- Marrek: "Greywood Camp, patrol routes" -- not in Greywood building directory
- The Archivist: "Archive of Ages" -- dungeon NPC, not a city placement

Severity: **MINOR**
Wandering/ambient NPCs do not need building slots, but Fiara and Marrek could benefit from explicit placement entries in their respective settlement directories.

**MINOR-03: NPCs who move between acts lack explicit tracking in city building directories**
npcs.md describes many NPCs moving (e.g., Elara Thane from Greyvale to Valdris Crown, Vessa from Roothollow interior to Entry Chamber during evacuation). The city layouts handle this through act-by-act change notes but do not always list where NPCs move TO. The documents do note Interlude changes generally, so this is more about explicitness than a missing feature.

Severity: **MINOR**

---

## 3. Quest Accessibility

### 3.1 Side Quest Location Verification

| Side Quest | Quest Giver Location | Quest Locations | Reachable? |
|-----------|---------------------|-----------------|-----------|
| The Fading Shifts | Dael Corran, Caldera lower factory | Caldera, Millhaven, Ley Line Depths | YES |
| The Forgewright's Gambit | Cira, Caldera Academy | Caldera, Kettleworks | YES |
| The Third Door | Mirren, Valdris Crown Library | Library restricted stacks, Archive of Ages | YES |
| The View from the Tower | Haren, Valdris Crown | Valdris Crown Court Quarter | YES |
| The Auditor's Conscience | Fenn Acari / Axis Tower intel | Corrund, Axis Tower | YES |
| A Knight's Vigil | Edren, Highcairn | Highcairn, Pallor Hollow (dungeons-world.md) | SEE IMPORTANT-03 |
| The Honest Thief | Sable, Bellhaven | Bellhaven Smuggler Tunnels, Aldara's Manor | YES |
| The Missing Patrol | Kael, Greywood Camp | Greywood Ranger Post, deep forest | YES |
| What the Stars Said | Grandmother Seyth, Greywood Camp | Multiple Thornmere settlements | YES |
| A Letter Never Sent | Scholar Aldis, Valdris Crown | Cael's Quarters (quest-locked) | YES |
| The Commissar's Confession | Ansa Veld, Ironmark | Ironmark Lower Cells | YES |
| Stars and Gears | Jace Renn, Kettleworks | Kettleworks, Caldera | YES |
| The Cartographer's Last Map | Mira Thenn, Caldera | Caldera Undercity (Mira's Studio) | YES |
| Unbowed | Sera Linn, Caldera | Caldera Undercity, Lower Factory District | YES |

### Issues Found

**IMPORTANT-03: "A Knight's Vigil" references "Pallor Hollow" dungeon with no layout**
sidequests.md references the Pallor Hollow as a boss fight location tied to Edren's Interlude arc at Highcairn. The Highcairn layout in city-valdris.md mentions Father Aldous and the Great Hall but does not describe a "Pallor Hollow" dungeon or area. dungeons-world.md has no entry for Pallor Hollow. interiors.md mentions the Pallor Hollow boss fight occurring in the Great Hall context. The boss fight arena is apparently the Monastery Great Hall itself or an area nearby, but no dungeon map exists for it.

Severity: **IMPORTANT**
The player needs to be able to physically reach and fight in the Pallor Hollow. If it is the Great Hall itself, this needs explicit documentation. If it is a separate area, it needs a dungeon layout.

**MINOR-04: "The Fading Shifts" quest references Millhaven extraction site, but Millhaven is destroyed in the Interlude**
The quest is available in Act II before the Interlude. The Ley Line Depths are accessible from Millhaven in Act II. However, if the player does not complete the quest before the Interlude, Millhaven is destroyed. sidequests.md should clarify whether the quest becomes unavailable in the Interlude or if the Ley Line Depths have an alternate entrance.

Severity: **MINOR**
The quest is listed as Act II, which is before destruction. But if the player delays, they may lose access.

### 3.2 Quest-Locked Areas vs. Dungeon/City Maps

All quest-locked areas in dungeons-city.md Section 4 are properly tied to their respective side quests:
- Royal Library Restricted Stacks -- "The Third Door" -- OK
- Cael's Quarters -- "A Letter Never Sent" -- OK
- Axis Tower Intelligence Archive -- "The Auditor's Conscience" -- OK
- Dael's Meeting Room -- "Unbowed" -- OK
- Prince Venn's Archive -- "The Honest Thief" -- OK
- Black Forge C Interior -- "The Fading Shifts" -- OK

No hanging quest threads found for quest-locked areas.

---

## 4. Secret Discovery Path

### 4.1 Secret Passages: Hint Coverage

dungeons-city.md Section 2 design notes state: "Every secret passage has at minimum two discovery methods: one NPC hint and one environmental clue."

| Secret Passage | NPC Hint | Environmental Clue | Status |
|---------------|----------|-------------------|--------|
| SP-V1: Library to Maren's Study | Mirren mentions it | Dust-free bookshelf | OK |
| SP-V2: Barracks to Catacombs | Dame Cordwyn reveals it | N/A (story-triggered) | OK |
| SP-V3: Chapel to Spirit Shrine | Torren senses ley resonance | Requires Crypt Warden's Key | OK |
| SP-V4: Haren's Wine Cellar | Haren hints at fireplace | Hearthstone interaction | OK |
| SP-V5: Noble Archive listening post | Sable identifies hollow wall | Visible seam on paneling | OK |
| SP-C1: Pump Station to Ironmark | Sable identifies camouflage; Tash's Tunnel Map | Visible rusted panel | OK |
| SP-C2: Canalside Inn secret room | Innkeeper hints about draft | False wardrobe back panel | OK |
| SP-C3: Records Archive basement | Archivist mentions old records | Rug over trapdoor | OK |
| SP-K1: Academy Hidden Lab | Cira mentions it; Lira walks to it | Supply closet | OK |
| SP-K2: Undercity to Lower Factory | Sera Linn shows route | Narrow opening at dead-end | OK |
| SP-K3: Council Hall eavesdrop gallery | N/A | Tapestry hides door | SEE MINOR-05 |
| SP-A1: Founders' Hall archive | Blacklist Record references it | Prayer wheel puzzle | OK |
| SP-A2: Lira's hidden compartment | Lira goes directly to it | Three examinations of wall | OK |
| SP-B1: Aldara's vault | Sable's contacts; "The Honest Thief" | Portrait hinge | OK |
| SP-B2: Breakwater passage | Harbor Signal Cipher | Grappling Line forces hatch | OK |
| SP-T1: Roothollow elder's chamber | Texture difference on totem | Third totem interaction | OK |
| SP-T2: Duskfen workshop shelf | Workshop Keeper mentions "old bindings" | Loose reed panel | OK |
| SP-T3: Canopy Reach overlook | Wynne mentions "where wind speaks loudest" | Hidden vine ladder | OK |

### Issues Found

**MINOR-05: SP-K3 (Merchants' Council Hall eavesdrop gallery) has no NPC hint**
The passage is discovered only through environmental examination of the tapestry. No NPC in Caldera is documented as hinting at this gallery's existence. The design rule requires at least one NPC hint.

Severity: **MINOR**
Recommendation: Add a line to an existing NPC (perhaps a servant in the Council Hall, or the Bellows tavern barkeep) who mentions "walls with ears" or similar.

### 4.2 Can secrets be found through observation alone?

Yes. Every secret passage has at least one environmental/examination trigger. No secret requires an NPC hint as the sole discovery path. Determined explorers can find everything through thorough examination.

---

## 5. Economy Consistency

### 5.1 Cross-City Price Comparison

**Standard Ration (HP restore consumable) -- benchmark item:**

| City | Price | Currency | Notes |
|------|-------|----------|-------|
| Valdris Crown | ~50 (implied standard) | Gil | Standard pricing |
| Corrund Supply Depot | 40 scrip | Scrip | Fair price |
| Caldera Apothecary | ~60 (implied) | Scrip | Slightly higher |
| Ashmark General Store | 40 scrip | Scrip | Same as Corrund |
| Millhaven Company Store | 80 scrip | Scrip | **Double price** (deliberate) |
| Gael's Span Provisioner | 60 scrip | Scrip | Border markup |
| Kettleworks Campus Store | 60 scrip ("Research Ration") | Scrip | Better quality |

Millhaven's inflated prices are documented as intentional design ("the player should feel the exploitation"). This is consistent.

**Do Carradan cities have higher prices than Valdris?**

Valdris weapon/armor shop prices are not fully itemized in city-valdris.md (shop inventories are described narratively, not in tables like Carradan cities). The Carradan cities have extensive price tables. From the data available:
- Valdris Crown weapon shop sells "standard Valdris arms" at unspecified prices
- Corrund Glass-Front Merchant Hall sells Arcanite Edge at 2400 scrip
- Caldera Upper Market sells Arcanite Saber at 3200 scrip (higher tier, higher price)

The Compact cities do show a price gradient: Caldera > Corrund > Ashmark, which makes sense (Caldera is the largest forge-city). Cross-faction comparison is not fully possible due to Valdris lacking itemized price tables.

### Issues Found

**~~IMPORTANT-04: Valdris cities lack itemized shop inventories~~ RESOLVED**
city-valdris.md now includes itemized shop tables for all Valdris cities, matching the format used in city-carradan.md. Cross-faction price comparison is possible.

Severity: **RESOLVED**

**MINOR-06: Currency exchange rates not fully documented**
Corrund has an Exchange House that "converts Valdris coin to Compact scrip." Bellhaven has a Money Changer with "better rates than Corrund." But the actual exchange rate (gil-to-scrip ratio) is never specified in any document. Thornmere spirit tokens have a documented 2:1 penalty for Valdris gil at Roothollow. But the base gil:scrip:token ratio is undefined.

Severity: **MINOR**

### 5.2 Soft-Lock Check: Essential Items

| Essential Item | Available From | Risk |
|---------------|---------------|------|
| Mining Lamp / Work Lamp | Ironmouth Supply Shed (free), Millhaven Company Store, Roothollow (Bioluminescent Lantern) | LOW -- multiple sources |
| Diving Mask | Bellhaven Sailor's Outfitter (Interlude) | MEDIUM -- single source for Sunken Rig dungeon |
| Identity Papers (Grade 3) | Tash's Black Market (Corrund), Tash's (Caldera) | LOW -- two sources |
| Grappling Line | Bellhaven Sailor's Outfitter | MEDIUM -- single source for SP-B2 and Honest Thief quest |
| Precision Tool Set | Kettleworks Campus Store | LOW -- only needed for Clockwork Room easter egg |

**MINOR-07: Diving Mask and Grappling Line are single-source items**
The Diving Mask (required for Sunken Rig dungeon and SP-T2 Interlude access) is only sold at Bellhaven's Sailor's Outfitter. The Grappling Line (required for The Honest Thief heist and SP-B2) is also only at Bellhaven. If a player reaches these quests without visiting Bellhaven's shop, they cannot proceed.

Severity: **MINOR** (both are optional content, not main story)

---

## 6. Save Point Coverage

### 6.1 City Save Points

| City | Save Point(s) | Status |
|------|--------------|--------|
| Valdris Crown | Chapel of the Old Pacts, Royal Library, Anchor & Oar Inn | OK |
| Aelhart | Hearthstone Inn | OK |
| Highcairn | Great Hall hearth | OK |
| Thornwatch | Border Rest Inn | OK |
| Greyvale | **NONE** | INTENTIONAL (documented as deliberate) |
| Corrund | Canalside Inn, Lira's Workshop (Interlude), Axis Tower entrance | OK |
| Caldera | Mid-Tier Inn, Lira's Workshop (Interlude), Forge Hall C | OK |
| Ashmark | Founders' Hall, Black Forge B entrance | OK |
| Bellhaven | Seabird Inn, Anchor Tavern basement (hidden) | OK |
| Millhaven | Foreman's Office | OK (single save, intentionally sparse) |
| Ashport | Ashport Inn, Grog & Gear basement (hidden) | OK |
| Ironmark Citadel | Lower Cells (after freeing Ansa), before Command Chamber | OK |
| Ironmouth | Foreman's Cabin | OK |
| Gael's Span | The Span tavern | OK |
| Kettleworks | Campus Canteen | OK |
| Roothollow | Heartwood Shrine, Guest Hollow | OK |
| Duskfen | Guest Platform | SEE IMPORTANT-05 |
| Ashgrove | **NONE** | SEE IMPORTANT-06 |
| Canopy Reach | Nest Hammocks rest (no save) / Canopy Hub totem | SEE IMPORTANT-07 |
| Greywood Camp | Guest Tents (rest) | SEE IMPORTANT-08 |
| Stillwater Hollow | **NONE** | OK (tiny sacred site, no services) |
| Sunstone Ridge | **NONE** | OK (guardian camp, not settlement) |
| Maren's Refuge | **NONE documented** | SEE MINOR-08 |
| Three Roads Inn | **NONE documented** | SEE MINOR-09 |

### Issues Found

**IMPORTANT-05: Duskfen has no explicit save point**
city-thornmere.md lists a "Guest Platform" with "rest/save" in its function, but the save point is not listed under a "Save Points" section like other Thornmere settlements. The Guest Platform description says "Full HP/MP restore" (rest function) but does not explicitly mention a save crystal or save point mechanic. Roothollow and Caldera both have explicit save point callouts.

Severity: **IMPORTANT**
Duskfen is a major settlement visited during Act II with a dungeon (Fenmother's Hollow) nearby. The player needs a reliable save before entering the dungeon.

**IMPORTANT-06: Ashgrove has no save point during Act II gathering**
Ashgrove is a major story location where the alliance cutscene occurs. The player may spend significant time here during the Act II gathering. No save point is documented. The temporary market and delegate camps are described, but no save mechanic.

Severity: **IMPORTANT**
The alliance sequence is a long narrative event. The player should be able to save during the gathering.

**IMPORTANT-07: Canopy Reach save point unclear**
interiors.md notes "No save point in this building" for the Nest Hammocks and says "save at Canopy Hub totem." However, city-thornmere.md's Canopy Reach section does not list save points at all. The "Canopy Hub" totem is mentioned as a navigation marker (spirit-totem at center) but not as a save point.

Severity: **IMPORTANT**
Canopy Reach is a full settlement with shops and quest content. It needs a clear, documented save point.

**IMPORTANT-08: Greywood Camp save point unclear**
city-thornmere.md describes Guest Tents with "Full HP/MP restore" (rest function) but does not list a save point section. The settlement is the largest in the Thornmere Wilds and a major Act II hub. The Central Fire Pit, Elder's Tent, and Guest Tents are all described but none is explicitly marked as a save point.

Severity: **IMPORTANT**
Greywood Camp is the political heart of the Wilds and a major quest hub. It must have a save point.

**MINOR-08: Maren's Refuge has no documented save point**
This is a one-time story location in Act I. The player visits, has the Pendulum examination, and leaves. A save point is not critical here given proximity to Roothollow, but it would be convenient.

Severity: **MINOR**

**MINOR-09: Three Roads Inn has no documented save point**
The Three Roads Inn is a waystation visited across Acts I, II, and the Interlude. It functions as a rest stop but no save point is mentioned in city-thornmere.md's description. Hadley serves as innkeeper, implying rest is available.

Severity: **MINOR**

### 6.2 Dungeon Save Points

| Dungeon | Pre-Boss Save | Mid-Dungeon Save | Status |
|---------|--------------|-------------------|--------|
| Ember Vein | Floor 2 (before boss) | Floor 1 (before descent) | OK |
| Fenmother's Hollow | Floor 3 (before boss) | Floor 1 (entry), Floor 2 (before boss descent) | OK |
| Carradan Rail Tunnels | Hub (entry), East Tunnel (before exit) | West Tunnel (mid) | OK |
| Axis Tower | Floor 1, Floor 2, Floor 3 (before command), Floor 4 (before Kole) | Multiple per floor | OK |
| Ley Line Depths | Floor 2 (before Deep Vein) | Floor 1 (entry), Floor 3 (bottom) | OK |
| Pallor Wastes | Section 1 (mid), Section 3 (mid), Section 4 (end) | Sparse but intentional | OK |
| The Convergence | Outer Ring (before Phase 1) | None during phases | OK (intentional difficulty) |
| Archive of Ages | Floor 1, Floor 2, Floor 3 (none explicitly before boss) | SEE MINOR-10 |
| Dreamer's Fault | Every 5th floor | Sparse but intentional (super dungeon) | OK |
| Dry Well of Aelhart | Floors 1, 3, 5 (before bosses) | Floors 2, 4, 6 (7-floor dungeon, 60-90 min Interlude / 2-3 hr full clear) | OK |
| Sunken Rig | Floor 1, Floor 2 (before boss) | Both floors covered | OK |
| Windshear Peak | Summit | N/A (no combat) | OK |
| Valdris Catacombs | Floor 1 (Spirit Shrine), Floor 3 (before boss) | Floor 2 not explicitly | SEE MINOR-11 |

**MINOR-10: Archive of Ages Floor 3 has no explicit save before the Archive Guardian boss**
Floor 2 has a save point (bottom-right). Floor 3's map shows no `S` marker. The descent is direct to the Truth Chamber and the boss. The boss is 10,000 HP with a three-phase test mechanic.

Severity: **MINOR** (Floor 2 save is close, and the dungeon is moderate difficulty)

**MINOR-11: Valdris Catacombs Floor 2 has no save point**
Floor 1 has the Spirit Shrine save. Floor 3 has a save before the boss. Floor 2 (Royal Tombs) has no save point, and it contains a trap corridor and encounters.

Severity: **MINOR** (the catacombs are traversed during an escape sequence where saves are limited by design)

---

## Summary of All Issues

### CRITICAL Issues
None found.

### IMPORTANT Issues

| ID | Description | Section |
|----|------------|---------|
| IMPORTANT-01 | Continental map omits Caldera, Ashport, Ironmark Citadel | 1.1 |
| IMPORTANT-02 | Fenn Acari not placed in Corrund city map | 2.1 |
| IMPORTANT-03 | Pallor Hollow dungeon for "A Knight's Vigil" has no layout | 3.1 |
| ~~IMPORTANT-04~~ | ~~Valdris cities lack itemized shop inventories~~ RESOLVED | 5.1 |
| IMPORTANT-05 | Duskfen has no explicit save point | 6.1 |
| IMPORTANT-06 | Ashgrove has no save point during Act II gathering | 6.1 |
| IMPORTANT-07 | Canopy Reach save point unclear | 6.1 |
| IMPORTANT-08 | Greywood Camp save point unclear | 6.1 |

### MINOR Issues

| ID | Description | Section |
|----|------------|---------|
| MINOR-01 | Duplicate Gael's Span layouts with conflicting building lists | 1.1 |
| MINOR-02 | Fiara and Marrek lack building directory entries | 2.1 |
| MINOR-03 | NPC act-movement tracking not always explicit in building directories | 2.1 |
| MINOR-04 | "The Fading Shifts" quest access if Millhaven destroyed | 3.1 |
| MINOR-05 | SP-K3 eavesdrop gallery has no NPC hint | 4.1 |
| MINOR-06 | Currency exchange rates undefined | 5.1 |
| MINOR-07 | Diving Mask and Grappling Line are single-source items | 5.2 |
| MINOR-08 | Maren's Refuge has no documented save point | 6.1 |
| MINOR-09 | Three Roads Inn has no documented save point | 6.1 |
| MINOR-10 | Archive of Ages Floor 3 has no save before boss | 6.2 |
| MINOR-11 | Valdris Catacombs Floor 2 has no save point | 6.2 |

---

## Fixes Applied

The following IMPORTANT issues were fixed in this audit pass:

### Fix 1: IMPORTANT-01 -- Updated continental map in locations.md
Added Caldera, Ashport, and Ironmark Citadel to the ASCII continental overview map.

### Fix 2: IMPORTANT-02 -- Added Fenn Acari to Corrund building directory
Added a note to the Corrund Consortium Council Hall entry in city-carradan.md clarifying Acari's presence during Act II.

### Fix 3: IMPORTANT-03 -- Clarified Pallor Hollow boss arena location
city-valdris.md line 843 already stated "Boss: Pallor Hollow -- a manifestation of Edren's guilt, fought in the Great Hall" but lacked details about the arena layout. Expanded the entry to clarify that the Great Hall map (interiors.md Section 1.4) IS the boss arena with Pallor overlay tiles, that no separate dungeon map is required, and that the hearth save point remains active during the fight. This resolves the apparent gap -- no entry in dungeons-world.md is needed because the boss is a single-fight transformation of an existing interior.

### Fix 4: IMPORTANT-05 -- Added explicit save point to Duskfen
Added a save point callout to the Guest Platform in city-thornmere.md's Duskfen section.

### Fix 5: IMPORTANT-06 -- Added save point to Ashgrove
Added a save point at the Valdris Envoy Tent in city-thornmere.md's Ashgrove section.

### Fix 6: IMPORTANT-07 -- Clarified Canopy Reach save point
Added explicit save point documentation at the Canopy Hub totem in city-thornmere.md's Canopy Reach section.

### Fix 7: IMPORTANT-08 -- Added save point to Greywood Camp
Added a save point at the Guest Tents in city-thornmere.md's Greywood Camp section.
