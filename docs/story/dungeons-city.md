# City Dungeons, Secret Passages & Hidden Areas

This document defines the hidden infrastructure within cities: underground dungeons, secret passages between buildings, hidden rooms that reward exploration, quest-locked areas, and escape routes used during story events. Every entry references existing locations from `city-valdris.md`, `city-carradan.md`, `city-thornmere.md`, `npcs.md`, `sidequests.md`, and `events.md`.

Design philosophy: cities should feel layered. The surface is what everyone sees. Below that, history piles up -- old tunnels, forgotten tombs, smuggler routes, maintenance corridors. A player who examines walls, talks to the right NPC, or returns after a story event should discover that every city has a second map underneath the first. Think Vector's dinner sequence in FF6, the secret passages in Guardia Castle in Chrono Trigger, or the hidden rooms in Baron that only open after the party returns with the right key. Curiosity is always rewarded. Never punished.

---

## Table of Contents

1. [City Dungeons](#1-city-dungeons)
   - [Valdris Crown Catacombs](#valdris-crown-catacombs)
   - [Corrund Undercity / Sewers](#corrund-undercity--sewers)
   - [Caldera Undercity](#caldera-undercity)
   - [Ashmark Factory Depths](#ashmark-factory-depths)
   - [Ironmark Citadel Dungeons](#ironmark-citadel-dungeons)
   - [Bellhaven Smuggler Tunnels](#bellhaven-smuggler-tunnels)
2. [Secret Passages](#2-secret-passages)
3. [Hidden Rooms & Easter Eggs](#3-hidden-rooms--easter-eggs)
4. [Quest-Locked Areas](#4-quest-locked-areas)
5. [Escape Routes](#5-escape-routes)

---

## 1. City Dungeons

### Valdris Crown Catacombs

**Location:** Beneath the Royal Keep and Court Quarter, Valdris Crown
**Access:** Servants' Passage in the Royal Keep (Interlude -- opened by Dame Cordwyn during the escape after the Carradan assault). A second entrance exists behind the altar in the Chapel of the Old Pacts (Lower Ward), but requires the Crypt Warden's Key (found in Maren's Old Study).
**Acts available:** Interlude (mandatory escape route), post-Interlude (optional return)
**Floors:** 3 (Ossuary, Royal Tombs, Deep Catacombs)
**Theme:** Pale limestone corridors, alcove burials, ley-crystal sconces that still glow faintly. The catacombs predate the current dynasty. Older sections show carved script in a language Maren or Torren can partially read -- references to pacts between early Valdris rulers and the spirits that sustained the ley lines.

**Narrative connection:** During the Interlude, the Carradan assault breaches the eastern wall. King Aldren dies in the chaos. The surviving party members (Edren's group) flee through the Servants' Passage into the catacombs beneath the Keep. The catacombs serve as the escape route from the city, exiting through a collapsed wall on the northeastern hillside outside the city walls. On return visits, the catacombs become an optional exploration dungeon with undead encounters and deep lore about Valdris's founding.

#### Floor 1: Ossuary (Entry Level)

```
VALDRIS CROWN CATACOMBS -- Floor 1: Ossuary
(64 tiles wide x 56 tiles tall, 4 screens)

KEY:  ### = limestone wall   [...] = alcove/room   === = passage
      ~~~ = stagnant water   +++ = collapsed rubble   S = save point
      ^ = stairs up          v = stairs down

                    ^ TO SERVANTS' PASSAGE (Royal Keep)
                    |
    ####################################################
    #                                                  #
    #   [ENTRY         ]     === ===     [WARDEN'S    ]#
    #   [VESTIBULE     ]    |       |    [ALCOVE      ]#
    #   [(torch rack,  ]    | BONE  |    [(empty desk,]#
    #   [ old banners) ]    | HALL  |    [ Crypt Key  ]#
    #   [              ]=====       =====[ needed for  ]#
    #                   |   |       |    [ Deep Catac.)]#
    #                   |   |       |                   #
    #   [BURIAL   ][BURIAL  |       |  [BURIAL  ][BUR-]#
    #   [ALCOVE A ][ALCOVE B]       |  [ALCOVE C][IAL ]#
    #   [(coffins,][(coffins,       |  [(coffins][D   ]#
    #   [ lore)   ][ undead)]       |  [        ][    ]#
    #              |        |       |                   #
    #   ===        |        |       |         ===       #
    #   |          |  ======+===+===|          |        #
    #   |          |  |    FLOODED  |          |        #
    #   [SEALED   ]|  | ~~~CHAMBER~~|   [SPIRIT       ]#
    #   [TOMB     ]|  | ~~~(waist~~~|   [SHRINE       ]#
    #   [(Interlude|  | ~~~deep)~~~~|   [(pact tablet,]#
    #   [ only:   ]|  | ~~~~~~~~~~~~|   [ ley crystal ]#
    #   [ loot)   ]|  |     S      |   [ S = save)   ]#
    #              |  +======+======+                   #
    #              |         |                          #
    #              |    v TO FLOOR 2                    #
    #              |    (Royal Tombs)                   #
    ####################################################
    |
    ^ ALTERNATE ENTRANCE: Behind altar,
      Chapel of the Old Pacts (requires Crypt Warden's Key)
```

**Encounters (Interlude escape):** Minimal. Two fixed encounters with Restless Dead (coffin lids opening as the party passes). These are weakened undead -- the ley energy that sustained their bindings is failing. They are more sad than threatening. Maren, if present, can speak to them: "They were bound to guard these halls. The binding is breaking. They don't know what else to do."

**Encounters (optional return):** Random encounters with Crypt Shades (incorporeal, weak to light magic), Bone Wardens (physical attackers, slow), and Tomb Mites (small, fast, annoying). The Flooded Chamber has waterborne encounters: Drowned Sentinels (rusted armor, heavy but sluggish).

**Treasure:**
- Burial Alcove A: Royal Funeral Urn (sell for 800g, or keep -- Mirren will identify it as belonging to Queen Verath, third dynasty, for lore)
- Burial Alcove C: Ley-Etched Shield (equipment -- DEF +14, MAG DEF +8, faint glow in dark areas)
- Sealed Tomb (Interlude only, collapsed wall reveals after earthquake from the assault): Founder's Circlet (accessory -- +all stats +3, inscription reads "The crown is the burden, not the jewel")
- Flooded Chamber: Chest on a dry ledge -- 3x Healing Draught, 1x Phoenix Pinion
- Spirit Shrine: Examine the pact tablet for lore about the original spirit-pact that founded Valdris. If Torren is present, he translates the full text and the party receives a permanent +5% spirit magic resistance.

#### Floor 2: Royal Tombs

```
VALDRIS CROWN CATACOMBS -- Floor 2: Royal Tombs
(64 tiles wide x 56 tiles tall, 4 screens)

KEY:  ### = limestone wall   [===] = sarcophagus   === = passage
      |T| = trap (pressure plate)   S = save point
      ^ = stairs up          v = stairs down

                    ^ TO FLOOR 1 (Ossuary)
                    |
    ####################################################
    #               |                                  #
    #   [ANTECHAMBER  ]                                #
    #   [(royal guard  ]     [KING ALDREN'S           ]#
    #   [ statues line ]     [EMPTY TOMB              ]#
    #   [ the walls)   ]=====[(prepared but never     ]#
    #                  |     [ used -- he was buried   ]#
    #                  |     [ in the field. Plaque    ]#
    #                  |     [ reads: "A place waits") ]#
    #   ====+==========+==========+====                #
    #       |                     |                    #
    #   [QUEEN    ]          [DYNASTY   ]              #
    #   [VERATH'S ]=== |T| ===[HALL     ]              #
    #   [TOMB     ]          [(six stone]              #
    #   [(3rd     ]          [ sarcoph- ]              #
    #   [ dynasty,]          [ agi in   ]              #
    #   [ mural   ]          [ alcoves, ]              #
    #   [ walls)  ]          [ each     ]              #
    #              |         [ labeled)  ]              #
    #   [KNIGHT   ]|         |          |              #
    #   [COMMANDER]=== === ==+          |              #
    #   [CRYPT    ]    |     |          |              #
    #   [(Cordwyn ]    |     |    S     |              #
    #   [ recognz.]    |     |  (save)  |              #
    #   [ names)  ]    |     |          |              #
    #              ====+==+==+====      |              #
    #                     |             |              #
    #   [COLLAPSED ]++++  |    [MAREN'S           ]    #
    #   [PASSAGE   ]++++==+====[SECRET CACHE      ]    #
    #   [(rubble -- ]++++      [(hidden behind     ]    #
    #   [ Interlude  ]         [ false wall panel; ]    #
    #   [ escape     ]         [ requires examining]    #
    #   [ exit NE)   ]         [ the 4th dynasty   ]    #
    #                          [ sarcophagus)      ]    #
    #                  |                               #
    #             v TO FLOOR 3                         #
    #             (Deep Catacombs)                      #
    ####################################################
```

**Puzzle element:** The Dynasty Hall contains six sarcophagi, each labeled with a dynasty number (1st through 6th). The trap in the passage to Queen Verath's tomb is a pressure plate that triggers a ceiling collapse (damage + slow). The safe path requires reading the inscriptions on the sarcophagi -- the 3rd dynasty inscription mentions "the queen who walked left" -- stepping on the left tile of the pressure plate corridor avoids the trap.

**Encounters:** Tomb Guardians (animated stone statues, heavy physical attacks, slow), Royal Wraiths (spectral knights, magic attacks, weak to holy/light), Pallor Wisps (Interlude only -- grey-white entities that inflict Despair status).

**Treasure:**
- Queen Verath's Tomb: Verath's Diadem (accessory -- +MAG +8, +MAG DEF +6, "She ruled for forty years and never raised her voice")
- Knight Commander Crypt: Commander's Oath (weapon -- longsword, ATK +20, grants counterattack when HP < 50%. Dame Cordwyn: "I knew these names. Every one of them. They'd be ashamed of what we've become.")
- Dynasty Hall, 2nd sarcophagus: 1000g pouch hidden in a false bottom
- Maren's Secret Cache: Maren's Early Research Journal (key item -- provides additional dialogue options during "The Third Door" quest), 2x Mana Tincture, 1x Starbloom Tea

**Lore:** The murals on Queen Verath's tomb walls depict the "Grey Seasons" -- a period predating the current understanding of the Pallor. Figures with hollow eyes stand in fields of ash. A woman with a crown holds a door closed with both hands. Maren recognizes the imagery: "This is older than my research. Much older. They knew. They always knew."

**Faded Portrait (forgotten gallery corridor, between Dynasty Hall and Knight Commander Crypt):** A painting in a forgotten gallery corridor, 800 years old, half-hidden behind a collapsed display case. Labeled "Diplomat-Emissary to the Grey Accord." The face is obscured by age -- cracked pigment, darkened varnish -- but the pose and clothing look familiar. Maren: "This style predates the Compact by centuries. The Grey Accord is not in any history I have read." If the party has encountered Vaelith, Edren adds quietly: "The posture. The way they stand. Hands behind their back, weight on the left foot. I have seen someone stand like that." The painting cannot be taken. It is too fragile. But the image stays.

#### Floor 3: Deep Catacombs

```
VALDRIS CROWN CATACOMBS -- Floor 3: Deep Catacombs
(48 tiles wide x 42 tiles tall, 3 screens)

KEY:  ### = rough stone (older construction)   === = passage
      *** = ley-crystal vein (faint glow)      S = save point
      !!! = boss arena boundary

                    ^ TO FLOOR 2 (Royal Tombs)
                    |
    ############################################
    #           |                              #
    #   [ANCIENT    ]     ***   ***            #
    #   [PASSAGE    ]    *   * *   *           #
    #   [(pre-Valdris]   * LEY     *           #
    #   [ stonework, ]   * CRYSTAL *           #
    #   [ older than ]   * VEIN    *           #
    #   [ the city)  ]   *  (light *           #
    #   [           ]=====*  source)*           #
    #                     ***   ***            #
    #                         |                #
    #   [SPIRIT    ]     [RITUAL              ]#
    #   [WELL      ]=====[ CHAMBER            ]#
    #   [(dry --   ]     [(circular,          ]#
    #   [ once a   ]     [ pact-circle carved ]#
    #   [ ley tap) ]     [ into the floor,    ]#
    #                    [ seven candle       ]#
    #       S            [ positions -- one   ]#
    #     (save)         [ for each Tower)    ]#
    #                    [                    ]#
    #   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  #
    #   !  [CATACOMB HEART               ]  !  #
    #   !  [(open chamber, ley veins     ]  !  #
    #   !  [ converge here. Optional     ]  !  #
    #   !  [ boss: the Undying Warden -- ]  !  #
    #   !  [ guardian spirit bound to    ]  !  #
    #   !  [ protect the catacombs,      ]  !  #
    #   !  [ maddened by the ley line    ]  !  #
    #   !  [ failure. Fought only on     ]  !  #
    #   !  [ return visits, not during   ]  !  #
    #   !  [ the Interlude escape.)      ]  !  #
    #   !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  #
    #                    |                     #
    #   [NORTHEAST EXIT -- collapsed section  ]#
    #   [(emerges on hillside outside city    ]#
    #   [ walls, behind a pile of rubble that ]#
    #   [ was dislodged by the assault)       ]#
    ############################################
```

**Optional boss (return visit only):** The Undying Warden is a spirit-construct bound to guard the catacombs since Valdris's founding. The ley line failure has driven it half-mad. It attacks with spectral swords and ley-crystal shards. Phase 1: physical attacks with spectral weapons. Phase 2 (below 50% HP): ley-crystal eruptions from the floor, AoE magic damage. Torren can attempt to calm it mid-fight (special command available if Torren is in the party) -- this doesn't prevent the fight but changes the Warden's final dialogue from rage to gratitude. Defeating the Warden releases its binding. It says either "Finally. Rest." (if calmed) or "You... are not... the enemy..." (if not).

**Boss rewards:** Warden's Binding (accessory -- grants Auto-Protect and Auto-Shell at battle start, unique), Catacomb Map (key item -- reveals all secret passages in Valdris Crown on the minimap), 2000g.

**Treasure:**
- Ley Crystal Vein: Harvest 2x Ley Crystal Shard (crafting material -- used in Lira's advanced recipes)
- Ritual Chamber: Examining the pact-circle with Maren or Torren reveals the original Seven Tower binding ritual. Lore entry unlocked. If all seven candle positions are lit (requires 7x Ley-Lanterns or the Bioluminescent Lantern from Roothollow), a hidden compartment opens: the Pact-Keeper's Rod (weapon -- staff, MAG +24, "The first sorcerers spoke to the ley lines. The ley lines spoke back.")
- Spirit Well: 1x Mana Tincture (the well is dry, but a residue of ley energy remains)

---

### Corrund Undercity / Sewers

**Location:** Beneath Corrund, accessible from the Undercroft Sewer Entrance and the Abandoned Pump Station
**Access:** Sewer Entrance in the Undercroft (Interlude -- available once Sable reaches Corrund). Abandoned Pump Station connects to the Ironmark tunnel system.
**Acts available:** Interlude (mandatory for Axis Tower infiltration), Act III (passage through)
**Floors:** 3 screens (Sewer Junction, Maintenance Tunnels, Axis Tower Sublevel)
**Theme:** Brick-lined tunnels, iron pipes, brackish canal water, forge-smoke residue on the walls. The sewers were originally maintenance access for the ley-line conduit system that powers Corrund's Forgewright engines. As the city grew upward, the lower levels were abandoned. The resistance and black market moved in. Now the tunnels serve three masters: the city's infrastructure, the resistance network, and the Pallor that seeps through the conduits.

**Narrative connection:** Sable uses the sewer network to bypass the North Canal Gate checkpoint during the Interlude. The tunnels connect the Undercroft to the Axis Tower underground level, providing the infiltration route for the Kole confrontation at Ironmark. The Abandoned Pump Station passage leads to a separate tunnel system that reaches Ironmark Citadel -- this is how the party approaches Brant's rear gate.

#### Sewer Junction (Screen 1)

```
CORRUND SEWERS -- Screen 1: Sewer Junction
(48 tiles wide x 42 tiles tall)

KEY:  ### = brick wall   ~~~ = sewer water (waist deep)
      === = pipe/conduit   [...] = room/alcove   S = save
      >>> = grate/gate

    ####################################################
    #                                                  #
    #   >>> FROM UNDERCROFT SEWER ENTRANCE >>>          #
    #                                                  #
    #   [ENTRY        ]     ~~~~~~~~~~~                #
    #   [CHAMBER      ]     ~ MAIN    ~                #
    #   [(Tash's mark ]     ~ SEWER   ~   [SUPPLY     ]#
    #   [ on the wall-]===  ~ CHANNEL ~   [CACHE A    ]#
    #   [ follow the  ]  |  ~ (flowing~===[(resistance]#
    #   [ scratches)  ]  |  ~ west)   ~   [ supplies, ]#
    #                    |  ~~~~~~~~~~~   [ 800 gold) ]#
    #              ======+======                       #
    #              |            |                       #
    #   [JUNCTION      ]  [VALVE           ]           #
    #   [PLATFORM      ]  [ROOM            ]           #
    #   [(raised above ]  [(three pipes    ]           #
    #   [ water level, ]  [ with valves -- ]           #
    #   [ three tunnel ]  [ puzzle: route  ]           #
    #   [ exits)    S  ]  [ water to drain ]           #
    #              |   |  [ flooded tunnel)]           #
    #   ===========+===+============                   #
    #   |              |            |                   #
    #   v              v            v                   #
    #   TO SCREEN 2    TO AXIS     TO PUMP             #
    #   (Maintenance)  TOWER       STATION             #
    #                  SUBLEVEL    (Ironmark            #
    #                  (Screen 3)  tunnel)              #
    ####################################################
```

**Carved Sigils (doorframes throughout):** Sigils scratched into the stone doorframes at knee height, easy to miss. They appear on three doorframes in the Sewer Junction and two more in the Maintenance Tunnels. Maren identifies them as ward-marks from a pre-Compact magical tradition meaning "I passed here and found it wanting." The marks are old -- decades at least -- but carved with a steady hand and deliberate precision. They do not match any Corrund graffiti or resistance markings. Sable: "Tash's people don't mark that low. These weren't made by anyone who works down here." If the party has found the journal fragments, Maren adds: "The same tradition. The same era. Someone has been walking through every city on this continent for a very long time."

**Puzzle:** The Valve Room contains three pipe valves labeled A, B, and C. One tunnel exit (to the Maintenance Tunnels) is flooded. The player must route water away from the flooded passage by turning valves in the correct sequence: A (open), C (close), B (open). Incorrect sequences flood the Junction Platform temporarily (damage + forced retreat). Lira can bypass the puzzle entirely by examining the pipe schematic on the wall -- she identifies the correct sequence automatically.

**Encounters:** Forge-Smoke Creatures (gaseous, fire-element, weak to water), Malfunctioning Service Automata (Compact maintenance drones gone haywire, physical attackers), Sewer Rats (weak, appear in swarms). The Tunnel Map key item from Tash's Black Market reveals enemy patrol routes, reducing encounter rate by 50%.

**Treasure:**
- Supply Cache A: 800 gold, 3x Standard Ration, 1x Repair Kit
- Valve Room (after solving puzzle): Forgewright Prototype Gauntlet (equipment -- DEF +8, grants +15% damage to mechanical enemies)
- Hidden in the sewer water near the Junction Platform (requires wading): Corrund Sewer Ring (accessory -- poison immunity, "Whoever made this spent too much time down here")

#### Maintenance Tunnels (Screen 2)

```
CORRUND SEWERS -- Screen 2: Maintenance Tunnels
(48 tiles wide x 42 tiles tall)

KEY:  ### = brick/iron wall   === = conduit pipe (glowing blue)
      [...] = room   |P| = Pallor residue (grey shimmer)

    ####################################################
    #                                                  #
    #   ^ FROM SEWER JUNCTION (Screen 1)               #
    #                                                  #
    #   [RESISTANCE     ]                              #
    #   [WAYPOINT       ]     ===conduit===            #
    #   [(bedrolls,     ]     =           =            #
    #   [ lanterns,     ]     = (ley energy=            #
    #   [ Sera's mark   ]     =  flowing)  =            #
    #   [ on the wall)  ]     =           =            #
    #                         ===conduit===            #
    #                              |                    #
    #   [SUPPLY    ]     [CONDUIT JUNCTION     ]       #
    #   [CACHE B   ]=====[(pipes converge,     ]       #
    #   [(military ]     [ energy arcs between ]       #
    #   [ intel    ]     [ conduits -- the ley ]       #
    #   [ documents]     [ line feed for the   ]       #
    #   [ + 1200   ]     [ Axis Tower. |P|     ]       #
    #   [ gold)    ]     [ Pallor residue      ]       #
    #                    [ visible on pipes)    ]       #
    #                         |                        #
    #   [ABANDONED  ]    [OLD FOREMAN'S        ]       #
    #   [SERVICE    ]=====[ OFFICE              ]       #
    #   [BAY        ]    [(desk, logbooks,     ]       #
    #   [(broken    ]    [ maintenance records ]       #
    #   [ automata  ]    [ from 40 years ago.  ]       #
    #   [ parts)    ]    [ Hidden compartment  ]       #
    #                    [ in desk: tunnel map ]       #
    #                    [ to Ironmark)        ]       #
    #                         |                        #
    #   >>> TO PUMP STATION (Ironmark tunnel) >>>      #
    #                                                  #
    ####################################################
```

**Treasure:**
- Supply Cache B: Compact Military Intelligence Documents (key item -- reveals patrol routes, used in "The Commissar's Confession" side quest), 1,200 gold
- Old Foreman's Office hidden compartment: Ironmark Tunnel Map (key item -- required to navigate the Ironmark passage without getting lost; without it, the tunnel has random dead ends that loop back), 1x Arcanite Torch
- Resistance Waypoint: Free rest (bedrolls restore HP/MP), resistance graffiti reads "WE REMEMBER WHAT WE WERE"
- Resistance Waypoint (wall): A beautiful tapestry hanging on the brick wall, donated by "a kind traveler" according to the resistance fighters who cannot remember exactly when it appeared. Depicts a pastoral scene -- rolling hills, a village, figures at rest. Fine grey thread embroidery, exquisite craftsmanship. If examined after the Doma moment cutscene (flag: vaelith_doma_moment), the party notices the pastoral figures have grey eyes. Sable: "Those eyes. I have seen those eyes." Maren: "The thread is grey. Not dyed grey -- the material itself. I do not know what fiber this is." The tapestry cannot be removed without destroying it. The resistance fighters consider it good luck.
- Abandoned Service Bay: Salvaged Automaton Core (crafting material -- used in Lira's Forgewright recipes)

#### Axis Tower Sublevel (Screen 3)

```
CORRUND SEWERS -- Screen 3: Axis Tower Sublevel
(48 tiles wide x 42 tiles tall)

KEY:  ### = iron-reinforced wall   === = ley conduit (bright blue)
      |P| = Pallor contamination   !!! = boss transition boundary
      S = save point

    ####################################################
    #                                                  #
    #   ^ FROM SEWER JUNCTION (Screen 1)               #
    #                                                  #
    #   [CONDUIT        ]     ===  ===  ===            #
    #   [ENTRANCE       ]     = AXIS  TOWER =           #
    #   [(the pipes     ]=====  = POWER CORE =          #
    #   [ widen here -- ]     = (massive ley =          #
    #   [ industrial    ]     = conduit       =         #
    #   [ scale)        ]     = junction --   =         #
    #   [        S      ]     = blue-white    =         #
    #                         = glow with     =         #
    #   [SEALED    ]          = grey streaks  =         #
    #   [ARMORY    ]          = |P| Pallor    =         #
    #   [(Compact  ]          = contamination =         #
    #   [ weapons, ]          = visible)      =         #
    #   [ locked -- ]          ===  ===  ===            #
    #   [ Ironmark ]                |                   #
    #   [ Key      ]          [ELEVATOR SHAFT    ]     #
    #   [ opens)   ]          [(Forgewright lift  ]     #
    #                         [ to Axis Tower    ]     #
    #   [CONDUIT   ]          [ Floor 1. Puzzle: ]     #
    #   [CONTROL   ]==========[ redirect conduit ]     #
    #   [ROOM      ]          [ flow to power    ]     #
    #   [(levers   ]          [ the lift. Three  ]     #
    #   [ that     ]          [ conduit switches ]     #
    #   [ redirect ]          [ in the Control   ]     #
    #   [ ley flow)]          [ Room)            ]     #
    #                         [                  ]     #
    ####################################################
```

**Puzzle:** The elevator to the Axis Tower is unpowered. The Conduit Control Room has three switches that redirect ley energy through the Power Core. The correct combination routes energy to the elevator without overloading the core. Incorrect combinations cause energy arcs (party-wide damage). The solution is written in maintenance shorthand on the Control Room wall -- Lira reads it automatically; other party leaders must pass an inspection check (examine the faded placard three times to decipher it).

**Treasure:**
- Sealed Armory (requires Ironmark Key from Kole's defeat -- only accessible on return): Arcanite-Bonded Blade (weapon -- ATK +26, +10% damage to Pallor enemies), Compact Officer's Shield (DEF +16), 3,000 gold
- Conduit Control Room: Ley-Conduit Regulator (accessory -- +MP regen, reduces ley-exposure damage)

---

### Caldera Undercity

**Location:** Beneath Caldera, accessible via the hidden stairway in Housing Block B (Middle Tiers)
**Access:** Examine the back wall of Housing Block B to find the hidden stairway. Requires either Sable in the party (she spots the concealed entrance) or the Resistance Contact List key item from Tash.
**Acts available:** Act II (limited -- Tash's market and The Bellows only), Interlude (full access)
**Screens:** 4 (Market Hub, Resistance Quarter, Forge Channel, Escape Passage)
**Theme:** Abandoned forge-channels and maintenance tunnels from Caldera's early industrial period. The volcanic heat seeps through the walls -- the temperature is noticeably warm. Old forge-channel grooves in the floor once carried molten metal. Now they carry resistance fighters, stolen goods, and hope.

**Narrative connection:** The undercity is where the resistance operates openly during the Interlude. Sera Linn's HQ coordinates worker evacuations. Tash's black market provides essential supplies. Lira's hidden workshop is the crafting and save hub. The Abandoned Forge Channel connects to the Lower Factory District (used during the "Unbowed" side quest to evacuate workers). The Escape Tunnel provides emergency exit to the overworld south.

#### Map: Caldera Undercity

```
CALDERA UNDERCITY
(64 tiles wide x 56 tiles tall, 4 screens)

KEY:  ### = volcanic stone wall   *** = old forge-channel (warm glow)
      [...] = room/area   === = passage   S = save point
      ^^^ = heat vent (impassable)

    ^ HIDDEN STAIRWAY FROM HOUSING BLOCK B (Middle Tiers)
    |
    ####################################################
    #   |                                              #
    #   [STAIRWAY       ]                              #
    #   [LANDING        ]                              #
    #   [(Resistance    ]                              #
    #   [ sentry post)  ]                              #
    #           |                                      #
    #   ========+========                              #
    #   |                |                              #
    #   [TASH'S     ]    [THE           ]              #
    #   [BLACK      ]    [BELLOWS       ]              #
    #   [MARKET     ]    [(tavern --    ]              #
    #   [(den:      ]    [ barkeep,    ]              #
    #   [ contraband]    [ resistance  ]              #
    #   [ papers,   ]    [ contacts,   ]              #
    #   [ intel)    ]    [ cheap drinks]              #
    #               |    [ rumors)     ]              #
    #   ============+====+======                       #
    #               |           |                      #
    #   [SERA LINN'S    ]  [SMUGGLER'S         ]      #
    #   [RESISTANCE     ]  [CACHE              ]      #
    #   [HQ             ]  [(Arcanite components]      #
    #   [(safe house,   ]  [ hidden behind     ]      #
    #   [ planning      ]  [ false wall panel) ]      #
    #   [ maps,     S   ]  [                   ]      #
    #   [ comms)        ]  [                   ]      #
    #               |       |                          #
    #   ============+=======+====                      #
    #               |            |                     #
    #   [LIRA'S         ]  [MIRA'S            ]       #
    #   [HIDDEN         ]  [CARTOGRAPHY       ]       #
    #   [WORKSHOP       ]  [STUDIO            ]       #
    #   [(save point,   ]  [(hidden behind    ]       #
    #   [ crafting S    ]  [ false map wall -- ]       #
    #   [ bench,        ]  [ requires Mira's  ]       #
    #   [ story scene)  ]  [ trust. Ley line  ]       #
    #                      [ maps inside)     ]       #
    #   ============+======+=======                    #
    #               |              |                   #
    #   [ABANDONED FORGE   ]  [ESCAPE             ]   #
    #   [CHANNEL           ]  [TUNNEL             ]   #
    #   [(passage to Lower ]  [(emergency exit    ]   #
    #   [ Factory Dist.    ]  [ to overworld      ]   #
    #   [ via crawlspace   ]  [ south -- tight    ]   #
    #   [ behind Forge     ]  [ passage through   ]   #
    #   [ Hall D. ***      ]  [ volcanic rock)    ]   #
    #   [ warm glow in     ]  [                   ]   #
    #   [ channel grooves) ]  [                   ]   #
    ####################################################
```

**Connection to Corrund:** The Abandoned Forge Channel connects to a longer tunnel system that eventually reaches the Corrund sewer network via the Abandoned Pump Station. This is a separate multi-screen passage (detailed in the Escape Routes section) used during Sable's infiltration arc.

**Encounters:** Heat Sprites (fire-element, weak to water), Corrupted Forge Constructs (half-melted automata reactivated by ley surges, physical/fire attacks), Pallor Seep (Interlude only -- grey ooze that inflicts Despair status, weak to all elements but high HP).

**Treasure:**
- Smuggler's Cache: 3x Smuggled Arcanite Core, 1x Pallor Ward (jury-rigged), 1,500 gold
- Forge Channel (hidden chest in a dead-end branch): Molten Core (crafting material), Ember Ring (accessory -- fire resist +25%, "Caldera remembers when the forge-channels ran with light")
- Escape Tunnel entrance: Survival Pack (3x Standard Ration, 2x Healing Draught, 1x Smoke Capsule)

### Sidequest Boss: The Pallor Nest Mother (6000 HP)

**Availability:** During the "Unbowed" sidequest (Interlude, after reaching Caldera). The Nest Mother encounter occurs in the deepest point of the undercity tunnels -- the junction where the old forge-channels meet the natural volcanic vents. The party must pass through this area to complete the worker evacuation route.

A massive Pallor creature that has burrowed into the tunnel junction, using the volcanic warmth and residual ley energy to breed. It resembles a bloated, grey-white arthropod the size of a wagon, its carapace fused with the tunnel walls. Grey tendrils extend from its body into the surrounding rock, feeding corruption into the tunnel network. It is the source of the Pallor nests that have been infesting the lower passages. The air around it tastes of ash and despair.

**Guest NPC: Kerra** -- A former Valdris soldier who volunteered for the evacuation escort. She fights alongside the party during this encounter as a guest NPC. Low combat stats (ATK 18, DEF 14, HP 800) but she does not flee, does not falter, and positions herself between the Nest Mother's spawn and the evacuees without being asked. If Kerra falls to 0 HP, she is incapacitated but survives the quest (her epilogue role is reduced but not eliminated).

**Attacks:**
- **Brood Pulse** -- The Nest Mother sends a wave of Pallor energy through the tunnel. AoE, 200-250 damage to all party members + 20% chance to inflict Despair status (ATB speed -25%, damage dealt -20%, 4 turns). Also spawns 2 Grey Crawlers (150 HP each).
- **Nest Defense** -- Passive ability. While any of the Nest Mother's spawn are alive, her carapace hardens: +50% DEF. The party must clear the adds before dealing meaningful damage to the Mother.
- **Tendril Lash** -- Physical attack, targets two party members, 300 damage each. The tendrils extend from the walls, attacking from unexpected angles.
- **Corruption Surge** -- Channels Pallor energy through the tunnel floor. Creates 3 contaminated zones (2x2 tiles) that deal 100 damage/turn to anyone standing in them. Zones last 3 turns.
- **Spawn Brood** -- Every 4 turns, the Nest Mother spawns 3 Pallor Mites (100 HP each, melee attackers that target the party's backline).
- **Desperate Contraction** -- Below 25% HP, the Nest Mother attempts to collapse the tunnel ceiling. 3-turn charge. 600 AoE damage if it completes. Can be interrupted by dealing 1000+ damage during the charge.

**Strategy:** Manage the spawn cycle. Burst damage on the Nest Mother during windows when no adds are alive (Nest Defense is down). Keep Kerra alive by drawing aggro away from her. Flame and Spirit attacks are most effective. The volcanic environment means Flame-based attacks cause secondary explosions on the Nest Mother's Pallor tendrils (visual flourish, no mechanical bonus beyond the elemental weakness).

**Weakness:** Flame (150% damage), Spirit (125% damage).
**Resistance:** Frost (50% damage).
**Immunity:** Despair.
**Drop:** Nest Mother's Core (crafting material -- concentrated Pallor essence, used in anti-Pallor weapon modifications), Broodchamber Map (key item -- reveals the full extent of the Pallor nest network beneath Caldera, referenced in Act III intelligence), 1500 Gold.

---

### Ashmark Factory Depths

**Location:** Beneath Black Forge B, Ashmark
**Access:** During "The Fading Shifts" side quest, the party investigates the smelting line and discovers a maintenance hatch in Forge B's lower level that leads to the Factory Depths. Also accessible during the Interlude if Lira is in the party (she knows the hatch location).
**Acts available:** Act II (quest-triggered), Interlude (Lira required)
**Floors:** 2 (Maintenance Level, Extraction Pipeline)
**Theme:** Industrial horror. The Factory Depths are the guts of Ashmark's forge system -- massive pipes carrying ley energy, conveyor mechanisms, cooling systems. Below the maintenance level, the extraction pipeline connects to Millhaven's pumping infrastructure. Workers have been disappearing from the night shifts. Their tools are found at their stations. Their shift logs simply stop mid-entry. The deeper you go, the more the machinery shows signs of Pallor contamination: grey residue on pipe joints, Arcanite glow flickering between blue-white and dead grey, the hum of the machines shifting into a frequency that sounds like a sigh.

**Narrative connection:** The Factory Depths are where the party discovers that the ley energy flowing through Ashmark's forges is contaminated -- not with the Pallor directly, but with the byproduct of over-extraction. This is the "fading" in its mechanical form. The deeper level connects to the pipeline from Millhaven, where the contamination originates. Lira's dual expertise (Forgewright engineering + Maren's ley-tapping techniques) is required to stabilize the rupture.

#### Floor 1: Maintenance Level

```
ASHMARK FACTORY DEPTHS -- Floor 1: Maintenance Level
(48 tiles wide x 42 tiles tall, 3 screens)

KEY:  ### = iron wall   === = pipe (ley energy, blue glow)
      |P| = Pallor residue   ~~~ = cooling fluid
      [...] = room   S = save point

    ^ MAINTENANCE HATCH (Black Forge B, lower level)
    |
    [Near entrance: Two grey teacups on a pipe junction ledge,
     still faintly warm. The same herbal blend found at the
     Ember Vein and Fenmother's Hollow. Someone sat here and
     watched the factory machinery before descending.]
    |
    ####################################################
    #   |                                              #
    #   [HATCH ROOM     ]     ===pipe===               #
    #   [(ladder down,  ]     =        =               #
    #   [ tools left    ]     = (blue, =               #
    #   [ mid-task on   ]     = flickering)            #
    #   [ the floor)    ]     =        =               #
    #           |             ===pipe===               #
    #   ========+=================+====                #
    #   |                         |                    #
    #   [WORKER'S       ]    [PUMP CONTROL     ]      #
    #   [LAST STATION   ]    [ROOM             ]      #
    #   [(shift log     ]    [(dials spinning  ]      #
    #   [ stops mid-    ]    [ erratically.    ]      #
    #   [ sentence:     ]    [ Pressure gauge  ]      #
    #   [ "Heard        ]    [ in the red.     ]      #
    #   [  something    ]    [ Puzzle: balance ]      #
    #   [  in the--")   ]    [ pressure across ]      #
    #   [        S      ]    [ four valves)    ]      #
    #               |         |                       #
    #   ============+=========+====                    #
    #               |              |                   #
    #   [COOLING    ][CONVEYOR     ]  [SEALED       ] #
    #   [TANK       ][JUNCTION     ]  [MAINTENANCE  ] #
    #   [(flooded   ][(conveyor    ]  [CLOSET       ] #
    #   [ -- wading ][belts cross  ]  [(locked --   ] #
    #   [ required) ][overhead.    ]  [ Shift Fore- ] #
    #   [~~~~~~~~~~~][Moving parts ]  [ man's Key   ] #
    #   [           ][= hazard)    ]  [ from office ] #
    #   [    chest  ][      |P|    ]  [ above.      ] #
    #               |      |      |  [ Contains    ] #
    #               v      |      |  [ evidence)   ] #
    #          TO FLOOR 2  |      |                   #
    ####################################################
```

**Puzzle:** The Pump Control Room puzzle requires balancing pressure across four valves to prevent a steam explosion. The correct sequence is indicated by the pressure readings on each gauge. Lira solves it in one action. Without Lira, the player must read the gauges and match flow rates (a numerical matching puzzle -- pair the gauges so each pair sums to 100).

**Encounters:** Overclocked Automata (machines running at dangerous speeds, fast physical attacks), Pipe Wraiths (entities formed from leaked ley energy, magic attacks), Forge Roaches (swarm enemies, low damage, high annoyance). In areas marked |P|, encounters include Pallor-Touched Workers -- these cannot be killed. They are fought to 0 HP and then "wake up" confused. They were the missing workers, sleepwalking through the maintenance level. Defeating them in combat snaps them out of the fugue state temporarily.

**Treasure:**
- Worker's Last Station: Shift Foreman's Key (key item -- opens the Sealed Maintenance Closet)
- Cooling Tank (requires wading through ~~~ tiles, damage over time without fire-resist gear): Emberstone (unique fire-element crafting material, referenced in city-carradan.md)
- Sealed Maintenance Closet: Blacklist Evidence Dossier (key item -- documents proving the Forge-Masters' Guild knew about the fading and suppressed reports. Used in "The Auditor's Conscience" quest), Forgewright's Creed (lore document + minor stat boost, if not already obtained from the Prayer Wheel Garden above)

#### Floor 2: Extraction Pipeline

```
ASHMARK FACTORY DEPTHS -- Floor 2: Extraction Pipeline
(48 tiles wide x 42 tiles tall, 3 screens)

KEY:  ### = reinforced iron   ===|P|=== = contaminated pipeline
      *** = ley energy leak (dangerous, damage tiles)
      !!! = mini-boss arena   S = save point

    ^ FROM FLOOR 1 (Maintenance Level)
    |
    ####################################################
    #   |                                              #
    #   [PIPELINE       ]                              #
    #   [JUNCTION       ]     ===|P|===|P|===          #
    #   [(the pipe from ]     = MILLHAVEN     =        #
    #   [ Millhaven     ]     = EXTRACTION    =        #
    #   [ enters here.  ]=====  = FEED (massive=       #
    #   [ Grey streaks  ]     = pipe, cracked =        #
    #   [ visible in    ]     = at joints,    =        #
    #   [ the flow)  S  ]     = grey fluid    =        #
    #               |         = leaking)      =        #
    #   ============+=========+=======                 #
    #               |                 |                #
    #   [RUPTURE        ]   [MONITORING       ]       #
    #   [SITE           ]   [STATION          ]       #
    #   [(the pipe has  ]   [(abandoned --    ]       #
    #   [ cracked open. ]   [ instruments    ]       #
    #   [ *** ley energy]   [ still running. ]       #
    #   [ leaks from    ]   [ Readouts show  ]       #
    #   [ the rupture.  ]   [ contamination  ]       #
    #   [ Damage tiles  ]   [ levels. Lira:  ]       #
    #   [ surround it)  ]   [ "This isn't    ]       #
    #                       [ Pallor. This   ]       #
    #   !!!!!!!!!!!!!!!!!!  [ is what happens]       #
    #   ! [CONTAMINATION ]  [ when you drain ]       #
    #   ! [HEART         ]  [ a ley line     ]       #
    #   ! [(boss: The    ]  [ past its       ]       #
    #   ! [ Forge Warden ]  [ breaking       ]       #
    #   ! [ -- Drayce's  ]  [ point.")       ]       #
    #   ! [ failsafe     ]  [                ]       #
    #   ! [ automaton,   ]                           #
    #   ! [ corrupted by ]                           #
    #   ! [ ley rupture, ]                           #
    #   ! [ defending    ]                           #
    #   ! [ the tap)     ]                           #
    #   !!!!!!!!!!!!!!!!!!                            #
    ####################################################
```

**Boss: The Forge Warden (8500 HP)**

The Ley Rupture Guardian referenced in early reports is, in truth, the Forge Warden -- a massive Forgewright automaton built by Forgemaster Elyn Drayce as a failsafe to protect the ley tap. Its original purpose was to seal the extraction pipeline and neutralize threats if the tap destabilized. But the ley rupture has corrupted its logic circuits, and it now interprets the party's presence as the threat it was designed to stop. It is a towering construct of brass, Arcanite conduit, and crystallized ley energy -- Drayce's engineering at its most impressive and most dangerous.

Lira recognizes the design: "This is Drayce's failsafe. Built to protect the tap if anything went wrong. But it thinks *we* are what went wrong."

**Phase 1 (8500-4250 HP) -- Programmed Defense:**
- **Ley Bolt** -- Fires concentrated ley energy, single target, 350-400 damage. Fast cast, used frequently.
- **Shield Protocol** -- Erects an Arcanite barrier that absorbs the next 1000 damage. 4-turn cooldown.
- **Containment Pulse** -- AoE shockwave, 250-300 damage to all party members + pushes them back (positional displacement). Marks a zone as "contaminated" for 3 turns (standing in it deals 100 damage/turn).
- **Pipeline Drain** -- The Warden absorbs ley energy from the ruptured pipe, healing 500 HP. Lira can use a special Forgewright action to reroute the pipe flow, cutting off its energy source (disables Pipeline Drain for the rest of the fight).

**Phase 2 (below 4250 HP) -- Corrupted Logic:**
The ley contamination overrides the Warden's programmed protocols. Its movements become erratic -- it targets allies and enemies indiscriminately, attacks the walls, and its voice synthesizer produces fragments of Drayce's recorded maintenance instructions mixed with static.
- All Phase 1 attacks, but targeting becomes semi-random (may attack empty spaces or strike its own shield).
- **Overload Beam** -- Massive ley energy beam, line AoE, 500-600 damage. 2-turn charge. Telegraphed by the Warden's chest core glowing bright blue. Can be interrupted by physical attacks totaling 800+ damage during the charge.
- **System Failure** -- At random intervals, the Warden freezes for 1 turn (sparking, voice glitching). Free damage window.
- **Emergency Protocol** -- Below 20% HP, the Warden attempts to self-destruct and seal the entire pipeline. A 3-turn countdown begins. The party must deal enough damage to destroy it before the countdown ends, or Lira must use Forgewright Override (special action) to abort the sequence.

**Lira's Special Interaction:** Lira's Forgewright ability deals 150% damage to the Warden (she knows exactly where the maintenance panels are). Her Forgewright Override action can disable Pipeline Drain and abort Emergency Protocol. Unique dialogue after Phase 1: "The logic boards are fried. It's not following Drayce's orders anymore -- it's following the corruption's."

**Post-boss:** After the Warden falls, the party discovers a tuning fork artifact lodged in the ley tap's resonance chamber. The tap's destabilization was not caused by over-extraction alone -- someone introduced a resonance frequency that amplified the ley line's collapse. The tuning fork matches artifacts found at other destabilized sites (Vaelith breadcrumb). Confronting Forgemaster Drayce with the Warden's wreckage cracks their facade -- Drayce knew the tap was failing and built the Warden to cover it up, not fix it.

Lira stabilizes the rupture using a combination of Forgewright pipe-sealing and Maren's ley-tapping technique (the first time old and new magic work together constructively). The contamination stops flowing. The faded workers upstairs will not recover, but no new cases will develop.

**Weakness:** Storm (150% damage), Spirit (125% damage).
**Resistance:** Flame (50% damage), Earth (75% damage).
**Immunity:** Petrify, Poison.
**Drop:** Drayce's Failsafe Core (accessory -- +12 DEF, +8 MAG DEF, auto-Shield Protocol once per battle at 25% HP), Corrupted Tuning Fork (key item -- Vaelith breadcrumb, same type found at multiple corruption sites; they stack as evidence), 2000 Gold.

**Treasure:**
- Monitoring Station: Extraction Rate Documentation (key item -- used in "The Fading Shifts" reward chain and referenced in the Bridgewrights' founding)
- Post-boss: Forgewright Stabilizer (accessory -- reduces magical damage taken, unique to Lira; quest reward)
- Post-boss: Dael's Ledger (key item -- Dael Corran's personal records documenting the extraction timeline and worker casualties; unlocks Lira's ultimate weapon forge in Act III)
- Pipeline Junction: Ley Residue Sample (key item -- can be shown to Jace Renn at Kettleworks for bonus dialogue in "Stars and Gears")

---

### Ironmark Citadel Dungeons

**Location:** Lower Cells and hidden passages within Ironmark Citadel
**Access:** The party arrives via the Axis Tower underground tunnel network (from Corrund sewers). Brant opens the Rear Gate after a scripted conversation. The Lower Cells are inside the Inner Ring.
**Acts available:** Interlude only
**Theme:** Military prison. Iron walls, Arcanite-bonded bars, the flat hum of Pallor-charged machinery. The cells are designed to break people. The sixteen holdout soldiers who refused Kole's Pallor influence are held here -- not tortured, not interrogated, just left. The Pallor's method is patience. It waits for you to stop caring.

**Narrative connection:** Ansa Veld and the holdout soldiers provide intel about Kole's defenses and the Command Chamber's layout. Freeing them is part of the Interlude's Ironmark Citadel dungeon sequence. Brant's secret passage (a maintenance corridor he discovered while drinking alone) provides the party's entry route to the Inner Ring.

#### Map: Lower Cells & Brant's Passage

```
IRONMARK CITADEL -- Lower Cells & Secret Passage
(48 tiles wide x 42 tiles tall, 3 screens)

KEY:  ### = Arcanite-bonded iron wall   |B| = cell bars
      [...] = room   === = passage   S = save point
      >>> = locked gate

    FROM REAR GATE (Brant's entry point)
    |
    ####################################################
    #   |                                              #
    #   [BRANT'S        ]                              #
    #   [SECRET         ]     [GUARD        ]          #
    #   [PASSAGE        ]     [STATION      ]          #
    #   [(maintenance   ]     [(two Pallor- ]          #
    #   [ corridor he   ]=====[ touched     ]          #
    #   [ found while   ]     [ soldiers -- ]          #
    #   [ avoiding      ]     [ fixed patrol]          #
    #   [ Kole's men.   ]     [ route. Can  ]          #
    #   [ Narrow,       ]     [ be avoided  ]          #
    #   [ bottles in    ]     [ or fought)  ]          #
    #   [ the corners)  ]     [             ]          #
    #                              |                   #
    #   ===========================+====               #
    #   |                               |              #
    #   >>> CELL BLOCK A >>>  >>> CELL BLOCK B >>>     #
    #   |                     |                        #
    #   |B|[CELL 1  ]|B|     |B|[CELL 5  ]|B|        #
    #   |B|[(empty, ]|B|     |B|[(Ansa   ]|B|        #
    #   |B|[ tally  ]|B|     |B|[ Veld -- ]|B|        #
    #   |B|[ marks) ]|B|     |B|[ the     ]|B|        #
    #   |                     |B|[ leader) ]|B|        #
    #   |B|[CELL 2  ]|B|     |                        #
    #   |B|[(holdout]|B|     |B|[CELL 6  ]|B|        #
    #   |B|[ sold-  ]|B|     |B|[(holdout]|B|        #
    #   |B|[ iers)  ]|B|     |B|[ group) ]|B|        #
    #   |                     |                        #
    #   |B|[CELL 3  ]|B|     |B|[CELL 7  ]|B|        #
    #   |B|[(holdout]|B|     |B|[(empty --]|B|        #
    #   |B|[ group) ]|B|     |B|[ scratch ]|B|        #
    #   |                     |B|[ marks:  ]|B|        #
    #   |B|[CELL 4  ]|B|     |B|["I gave  ]|B|        #
    #   |B|[(the one]|B|     |B|[ in")    ]|B|        #
    #   |B|[ who    ]|B|     |     S                   #
    #   |B|[ gave   ]|B|     |   (save after          #
    #   |B|[ in --  ]|B|     |    freeing Ansa)       #
    #   |B|[ message]|B|     |                        #
    #   |B|[ on the ]|B|     >>> TO COMMAND CHAMBER >>>#
    #   |B|[ wall)  ]|B|     (Kole boss fight)        #
    #   |            |                                 #
    #   |  [TUNNEL ENTRANCE     ]                      #
    #   |  [(to Axis Tower      ]                      #
    #   +==[ underground --     ]                      #
    #      [ the party's        ]                      #
    #      [ original arrival   ]                      #
    #      [ route)             ]                      #
    ####################################################
```

**Puzzle:** The cell gates are controlled by a mechanism in the Guard Station. The Pallor-touched soldiers carry a partial key. The full key requires combining the partial key with a command code found on a clipboard in the Guard Station. The code is written in Compact military cipher -- Sable can decode it, or the party can use the Compact Military Cipher key item found in the Coal Yard hidden passage in Ashmark.

**Encounters:** Pallor-Touched Soldiers (human enemies -- slow, heavy, hits hard, empty eyes; they do not speak during combat). The Guard Station has two fixed encounters. Cell Block corridors have random encounters with Pallor Wisps (grey entities that inflict Despair status).

**Key NPC:** Ansa Veld, Cell 5. She is gaunt but sharp. She provides:
- Kole's patrol timing (reduces encounters in the Inner Ring)
- The Command Chamber's weak point (a conduit panel behind the throne that can be sabotaged, reducing Kole's Phase 2 healing)
- Names of every soldier who refused and every soldier who was turned. She has memorized them all.

**Treasure:**
- Cell 1 (empty cell with tally marks): Examining the tally mark wall reveals a hidden stone behind the 47th mark. Behind it: a folded note from the soldier who gave in. Reading it grants the Resolve Charm (accessory -- immunity to Pallor fear status).
- Guard Station: Ironmark Key (key item -- opens sealed areas in Corrund and the Axis Tower Sublevel armory)
- Cell 4: The message reads "I couldn't hold on. Forgive me. Tell Sella I tried." If the party later visits Corrund's Undercroft and speaks to an NPC named Sella, she thanks them for the message and gives them a Keepsake Locket (accessory -- +DEF +4, +MAG DEF +4, "He tried. That's something.")

---

### Bellhaven Smuggler Tunnels

**Location:** Beneath the Stilts District and Dockside, Bellhaven
**Access:** Three entrances: (1) Sable's Childhood Home -- examine the loose floorboards to reveal a trapdoor (requires Sable in the party). (2) The Anchor Tavern basement -- the barkeep shows Sable a hidden panel behind the bar. (3) Tidal Flats at low tide -- a sea cave entrance visible only when the water recedes.
**Acts available:** Act II (limited -- Anchor Tavern entrance only, basic exploration), Interlude (full access)
**Screens:** 3 (Dock Tunnels, Smuggler's Den, Sea Caves)
**Theme:** Saltwater, driftwood bracing, barnacle-crusted walls, the sound of the tide. These tunnels were dug by smugglers two generations ago and maintained by Bellhaven's underworld ever since. The merchant princes know about them and tolerate them because the smugglers also run their less legitimate operations. Sable grew up playing in the shallow caves. She knows every turning.

**Narrative connection:** Sable's contacts in Bellhaven operate through the tunnels. During "The Honest Thief" side quest, the party uses the tunnels to reach the merchant prince's warehouse district without being detected by private security. The Sea Caves connect to the tidal flats and provide access to the Breakwater from below -- useful during the Interlude.

#### Map: Bellhaven Smuggler Tunnels

```
BELLHAVEN SMUGGLER TUNNELS
(64 tiles wide x 56 tiles tall, 3 screens)

KEY:  ### = stone/coral wall   ~~~ = tidal water (rises and falls)
      [...] = room/cave   === = passage   S = save point
      ^^^ = barnacle wall (impassable)

    ^ FROM SABLE'S CHILDHOOD HOME (trapdoor)
    |
    ####################################################
    #   |                                              #
    #   [SABLE'S        ]                              #
    #   [HIDEAWAY       ]     [OLD            ]        #
    #   [(a child's     ]     [SMUGGLER       ]        #
    #   [ hiding spot --]     [STASH          ]        #
    #   [ scratched     ]=====[(rusted lock -- ]        #
    #   [ drawings on   ]     [ Sable picks it]        #
    #   [ the wall,     ]     [ without       ]        #
    #   [ a tin box)    ]     [ thinking.     ]        #
    #                         [ Chest: old    ]        #
    #           |             [ coins, a      ]        #
    #           |             [ corroded      ]        #
    #   ========+=============+ dagger)       ]        #
    #   |                     |                        #
    #   [DOCK            ]    [SMUGGLER'S          ]   #
    #   [TUNNEL          ]    [DEN                 ]   #
    #   [(runs beneath   ]    [(central chamber.   ]   #
    #   [ the Dockside   ]    [ Crates, cargo      ]   #
    #   [ warehouses.    ]=====[ nets, a table with ]   #
    #   [ Crate stacks   ]    [ sea charts. This   ]   #
    #   [ against walls. ]    [ is where Sable's   ]   #
    #   [ Sound of       ]    [ old contact        ]   #
    #   [ loading above) ]    [ operates.    S     ]   #
    #           |              |                       #
    #   ========+==============+====                   #
    #           |                   |                  #
    #   ^ TO ANCHOR TAVERN         |                  #
    #     BASEMENT (hidden panel)  |                  #
    #                              |                  #
    #   [TIDAL           ]    [SEA CAVES          ]   #
    #   [PASSAGE         ]    [(natural caverns   ]   #
    #   [(~~~ water      ]    [ carved by the     ]   #
    #   [ rises at high  ]=====[ tide. Biolum-    ]   #
    #   [ tide -- timing ]    [ inescent algae    ]   #
    #   [ puzzle. Must   ]    [ on the walls.     ]   #
    #   [ cross between  ]    [ The Tidecaller's  ]   #
    #   [ tides or take  ]    [ Horn is hidden    ]   #
    #   [ damage)        ]    [ here. Exit to     ]   #
    #   [~~~  ~~~  ~~~   ]    [ tidal flats and   ]   #
    #                         [ Breakwater base)  ]   #
    #                         [                   ]   #
    ####################################################
```

**Puzzle:** The Tidal Passage floods on a timer (the tide). The player has a limited window to cross between high tides. A gauge on the wall (installed by the smugglers) shows the current tide level. Crossing during high tide inflicts continuous water damage. Sable knows the timing automatically ("Twelve seconds between surges. Run when I say run.").

**Encounters:** Sea Crawlers (crustacean creatures, high DEF, weak to lightning), Tide Wraiths (waterborne spectral enemies, Act II only -- the Pallor hasn't reached the ocean yet), Drowned Lookouts (Interlude only -- Pallor-touched smugglers who wandered into the deeper caves and didn't come back).

**Treasure:**
- Sable's Hideaway: Tin Box (examine for Sable character scene -- contains a copper coin, blue fabric scrap, and a child's drawing. "I hid here when the world got too loud. Guess some things don't change.")
- Old Smuggler Stash: 500 gold (old Compact coins, pre-reformation), Corroded Dagger (weapon -- low ATK, but Sable: "My first real blade. I stole it from a drunk. I was nine.")
- Smuggler's Den: Sea Chart Collection (key item -- reveals hidden coastal locations on the overworld map), 3x Smoke Capsule, 1x Grappling Line
- Sea Caves: Tidecaller's Horn (unique item -- summons a water elemental once per battle, as referenced in city-carradan.md)
- Dock Tunnel (hidden behind crate stack, push puzzle): Merchant Prince's Private Ledger (key item -- evidence of dual arms sales, used in "The Honest Thief" side quest)

---

## 2. Secret Passages

Every secret passage follows the same design rules: (1) there is always a discoverable hint before the passage itself, (2) the passage always contains something worth finding, and (3) the passage should make the player re-evaluate the building it's hidden in.

### Valdris Crown

#### SP-V1: Royal Library to Maren's Old Study

**Entrance location:** Royal Library basement archives (Citizen's Walk) -- the third bookshelf from the left on the back wall
**Discovery method:** Mirren mentions "Maren's private route to the Keep" in dialogue during the Interlude. Alternatively, examining the bookshelf reveals that one shelf has no dust on it -- it's been used recently. Interact to swing the shelf open.
**Where it leads:** A narrow stone passage (one screen, no encounters) ascending through the city's limestone foundation to Maren's Old Study in the Royal Keep.
**Contents:** The passage walls have ley-crystal fragments embedded in the limestone -- a natural vein that Maren used to light her way. Midway through: a small alcove with a writing desk and a half-finished letter from Maren to Mirren, never sent. Key item: Maren's Unsent Letter (lore -- reading it with Maren in the party triggers a dialogue scene about their estrangement).
**Availability:** Interlude onward. The bookshelf mechanism was sealed by Maren when she left the court; the ley line failure has weakened the seal enough to force it open.

#### SP-V2: Barracks to Catacombs

**Entrance location:** Barracks storage room (Lower Ward) -- the back wall behind the weapon racks
**Discovery method:** Dame Cordwyn reveals this passage during the Interlude escape sequence. She learned it from a previous commander: "Every barracks has a bolt-hole. This one goes deep."
**Where it leads:** A steep stairway descending to the Ossuary level of the Valdris Crown Catacombs (Floor 1, near Burial Alcove A).
**Contents:** The passage itself contains a weapons cache -- 2x Iron Longsword, 1x Knight's Blade, 3x Healing Draught. Emergency supplies for exactly this situation.
**Availability:** Interlude onward. Story-triggered by Cordwyn.

#### SP-V3: Chapel of the Old Pacts to Spirit Shrine

**Entrance location:** Chapel of the Old Pacts (Lower Ward) -- behind the altar, a panel concealed by the altar's stone facing
**Discovery method:** Requires the Crypt Warden's Key (found in Maren's Old Study). Alternatively, Torren senses a ley line resonance from behind the altar and identifies the mechanism if he's in the party.
**Where it leads:** A spiral staircase descending to the Spirit Shrine on Catacomb Floor 1.
**Contents:** The staircase walls are carved with spirit-pact symbols older than the chapel itself. The chapel was built to conceal this entrance. Examining the symbols with Maren or Torren reveals that the original Valdris settlers made their first pact with the ley line spirits in the shrine below.
**Availability:** Act I (with Crypt Warden's Key or Torren), expanding content in Interlude.

#### SP-V4: Haren's Estate Hidden Wine Cellar

**Entrance location:** Haren's Estate (Court Quarter) -- the fireplace in his study
**Discovery method:** Speak to Haren during the Interlude. If the player examines the fireplace, Haren says: "My father built that. He said every chancellor needs a place to think where no one can find him." Interact with the right hearthstone to open a passage.
**Where it leads:** A small underground wine cellar (one room) beneath the estate.
**Contents:** Vintage wine bottles (sellable, 200g each), a locked chest containing Haren's personal journal (lore -- his private assessment of King Aldren's failures, far more critical than his public statements), and the Charter Draft (an early version of the governing council document from his side quest). If "The View from the Tower" quest is active, finding the Charter Draft here provides additional dialogue options.
**Availability:** Interlude onward.

#### SP-V5: Noble Archive to Council Chambers

**Entrance location:** Noble Archive (Court Quarter) -- a section of wood paneling that sounds hollow when struck
**Discovery method:** Examining the wood paneling on the east wall. There is a visible seam if the player inspects carefully. Alternatively, Sable identifies it automatically: "Hollow wall. Someone built a listening post."
**Where it leads:** A narrow corridor between walls, ending at a grille that looks into the Council Chambers. From here, conversations in the Council Chambers can be overheard.
**Contents:** The corridor itself has a small bench (someone sat here regularly) and a notebook containing transcripts of council discussions spanning years. Key item: Council Transcripts (lore -- reveals that the council knew about the ley line decline years before the public did and chose to suppress the information).
**Availability:** Act II onward. The listening post was built by a previous lord chancellor -- paranoia has a long tradition in Valdris politics.

### Corrund

#### SP-C1: Abandoned Pump Station to Ironmark Tunnel

**Entrance location:** Abandoned Pump Station (Undercroft) -- behind a rusted panel on the back wall
**Discovery method:** The panel is visible but appears to be just another piece of failing infrastructure. Sable can identify the concealed passage: "That's not rust. That's camouflage." Alternatively, purchasing the Tunnel Map from Tash's Black Market reveals the entrance on the minimap.
**Where it leads:** A long maintenance tunnel (2 screens) that passes beneath the Corrund River and connects to the Ironmark Citadel tunnel network. This is the primary approach route for the Interlude's Ironmark sequence.
**Contents:** Screen 1: Empty except for resistance markings on the walls and a supply cache (3x Standard Ration, 1x Arcanite Torch). Screen 2: A junction where the tunnel branches -- one path leads to Ironmark, the other to a dead end containing a collapsed section with a chest: Compact Engineering Manual (key item -- Lira can study it for a permanent +5% damage with Forgewright weapons).
**Availability:** Interlude. The panel was sealed from the Ironmark side; Brant loosened it as part of his defection.

#### SP-C2: Canalside Inn Secret Room

**Entrance location:** Canalside Inn (Canal District) -- the second-floor guest room, behind the wardrobe
**Discovery method:** Rent the second-floor room (costs 200 gold). Examine the wardrobe -- its back panel is false. Sable spots it automatically. Without Sable, the innkeeper hints: "That room has a draft. Can't figure out where it comes from."
**Where it leads:** A small hidden room between the inn's walls -- a merchant's panic room from an earlier era.
**Contents:** Merchant's Strongbox (600 gold, 2x Precision Lens, 1x Compact Trade Writ -- if "The Auditor's Conscience" has not been completed, this provides an alternate path to unlocking full Compact shop inventories), and a peephole looking into the Bargeman's Tavern below (Sable: "Now that's useful.").
**Availability:** Act II onward.

#### SP-C3: Records Archive Basement

**Entrance location:** Records Archive (west of Axis Tower) -- a trapdoor beneath the archivist's desk, concealed by a rug
**Discovery method:** Speak to the archivist three times. On the third visit, she mentions that "the really old records are kept below." She doesn't volunteer the entrance location. Examining the rug reveals the trapdoor.
**Where it leads:** A basement archive room containing pre-Consortium records from Corrund's founding era.
**Contents:** Founding Era Documents (lore -- Corrund was built by refugees from a ley line catastrophe in a distant region, not by pioneers as the Consortium claims), a locked document case containing Project Pendulum's original authorization memo (key item -- used in "The Auditor's Conscience" quest), and a Ley Line Survey from the founding era showing that the ley lines beneath Corrund were already strained before the Compact's extraction began.
**Availability:** Act II (basic lore), Interlude (Project Pendulum documents appear after Axis Tower events).

### Caldera

#### SP-K1: Forgewrights' Academy Hidden Lab

**Entrance location:** Forgewrights' Academy (Upper Rim) -- the supply closet in the east wing
**Discovery method:** Cira mentions the lab during "The Forgewright's Gambit" quest: "There's a room the Guild doesn't know about. Lira built it during her last year." Alternatively, if Lira is in the party and visits the academy, she walks directly to it.
**Where it leads:** A hidden laboratory behind the supply closet wall -- a small room Lira constructed during her student years by walling off part of an unused utility space.
**Contents:** Lira's early research notes (lore -- her first doubts about extraction, written in coded shorthand), prototype tools (Lira's Modified Calibration Set -- accessory, +crafting quality), and a ley energy monitoring device she built that still works. The device shows real-time ley contamination levels -- in the Interlude, the readings are alarming.
**Availability:** Act II (with Cira's quest or Lira in party), Interlude.

#### SP-K2: Undercity to Lower Factory District

**Entrance location:** Abandoned Forge Channel (Undercity) -- a crawlspace behind Forge Hall D's foundation
**Discovery method:** Sera Linn shows the party this route during the "Unbowed" quest (evacuating workers). Without the quest, examining the channel's dead-end wall reveals a narrow opening.
**Where it leads:** Through a tight passage into a storage room behind Forge Hall D (Lower Factory District). The passage is marked with resistance symbols.
**Contents:** The passage itself has no treasure but serves as a critical shortcut between the undercity and the factory district. The storage room contains abandoned forge tools and a logbook documenting that Forge Hall D's explosion was not an accident -- it was caused by a ley surge that the foreman failed to report. Key item: Forge Hall D Incident Report (lore -- supports Dael Corran's claims about Guild negligence).
**Availability:** Interlude.

#### SP-K3: Merchants' Council Hall Eavesdrop Gallery

**Entrance location:** Merchants' Council Hall (Upper Rim) -- a servants' staircase behind the main hall's tapestry
**Discovery method:** Examine the largest tapestry in the main hall. It depicts Caldera's founding. Behind it, a narrow door leads to a servants' staircase. The door is not locked -- it's simply hidden by the tapestry.
**Where it leads:** An observation gallery above the council chamber -- a narrow balcony with a lattice screen, allowing anyone in the gallery to hear council proceedings without being seen.
**Contents:** The gallery contains a chair (someone uses this regularly), a notebook with partial transcripts of recent council meetings (lore -- Fenn Acari's private doubts about extraction policy are recorded here), and a mounted spyglass that looks down into the chamber. If the player visits during the Interlude, they can overhear a live council debate about the ley line crisis.
**Availability:** Act II onward.

### Ashmark

#### SP-A1: Founders' Hall Secret Archive

**Entrance location:** Founders' Hall (north end of Ashmark) -- behind the glass case containing the original Forgewright anvil
**Discovery method:** Activate all functioning prayer wheels in the Prayer Wheel Garden in the correct sequence (as described in city-carradan.md). This opens a panel behind the anvil case. Alternatively, the Blacklist Record key item from The Soot tavern references "the archive behind the anvil."
**Where it leads:** A small vault room behind the display case.
**Contents:** The original Forgewright patents (lore -- the first Arcanite forging process was not invented by the Compact; it was adapted from ley line techniques taught by Thornmere spirit-speakers. The Compact's founding myth is a lie). Key item: Original Forging Patents (provides bonus dialogue with Torren and Maren -- "They learned from us. And then they pretended they didn't."). Also contains: Master Smith's Hammer (weapon -- ATK +22, +fire element, "The first hammer struck in cooperation, not conquest").
**Availability:** Act II onward (requires prayer wheel puzzle or Blacklist Record).

#### SP-A2: Lira's Old Room Hidden Compartment

**Entrance location:** Tenement Row 3, Lira's old room -- behind a loose brick in the wall near the window
**Discovery method:** Examine the wall near the window. Lira, if present, goes directly to it: "I left something here. In case I ever came back." Without Lira, the player must examine the wall three times to notice the loose brick.
**Where it leads:** Not a passage -- a hidden wall compartment.
**Contents:** Lira's Defection Journal (key item -- a personal account of why she left the Compact, written over several months. Provides lore and additional dialogue in multiple scenes), a sketch of the Caldera skyline seen from this window, and the Forge Apprentice's Ring (accessory -- +crafting quality when Lira is in party, as referenced in city-carradan.md).
**Availability:** Act II onward.

### Bellhaven

#### SP-B1: Merchant Prince Aldara's Secret Vault

**Entrance location:** Prince Aldara's Manor (Merchant Prince District) -- the study, behind a portrait
**Discovery method:** During "The Honest Thief" quest, Sable identifies the vault entrance based on intelligence from her contacts: "Aldara keeps his real books behind the painting of his father. Old money, old tricks." Without the quest, examining the portrait closely reveals a hinge.
**Where it leads:** A walk-in vault beneath the manor.
**Contents:** Aldara's Private Ledger (key item -- proof of dual arms sales to both Valdris and the Compact during the border war; primary evidence for "The Honest Thief"), 5,000 gold in locked strongboxes (Sable can pick them), a collection of foreign artifacts (lore -- Aldara has been trading with nations beyond the known continent), and the Sea Prince's Signet (accessory -- +gold earned from sales, +charm in negotiations).
**Availability:** Interlude (quest-triggered or independent exploration with Sable).

#### SP-B2: Breakwater Hidden Passage

**Entrance location:** The Breakwater fortification (harbor mouth) -- a maintenance hatch at the base of the lighthouse
**Discovery method:** Examine the lighthouse base at low tide. The hatch is visible but appears rusted shut. A Grappling Line (tool, purchasable from Sailor's Outfitter) can force it open. Alternatively, the Harbor Signal Cipher key item (found atop the lighthouse) references "the lower access" in its decoded text.
**Where it leads:** A passage running through the Breakwater's interior, connecting the lighthouse to the Dockside. The passage passes through the fortification's old ammunition magazine (now empty).
**Contents:** Empty ammunition racks (environmental storytelling -- the Breakwater was once heavily armed), a chest in the magazine containing the Lighthouse Keeper's Log (lore -- decades of harbor observations, including a reference to "grey things in the water" thirty years ago -- early Pallor signs), 1x Prototype Arcanite Round (consumable -- massive single-target damage, one use), and an exit to the Dockside behind Warehouse 1.
**Availability:** Act II onward.

### Thornmere Settlements

#### SP-T1: Roothollow Elder's Alcove Hidden Chamber

**Entrance location:** Elder's Alcove (Roothollow interior) -- interact with the third totem from the left
**Discovery method:** As described in city-thornmere.md. The third totem has a slightly different texture (one pixel difference in the bark pattern). Interacting with it causes a root wall to part.
**Where it leads:** The Root-Weaver's Workshop -- a small chamber where the tribe's root-weavers practice growing architecture from living roots.
**Contents:** Root-Weaver's Ring (accessory -- +15% nature magic, as referenced in city-thornmere.md), a demonstration of root-weaving in progress (interactive -- watching it with Lira triggers a scene where she compares it to Forgewright engineering: "You grow your buildings. We forge ours. Same problem, different material."), and a root-woven chest containing 2x Spirit Token, 1x Root-Silk Thread.
**Availability:** Act I onward.

#### SP-T2: Duskfen Spirit-Binding Workshop Hidden Shelf

**Entrance location:** Spirit-Binding Workshop (Duskfen) -- a loose reed panel on the back wall
**Discovery method:** The Workshop Keeper mentions "the old bindings" if asked about the workshop's history. Examining the back wall reveals a reed panel that lifts away.
**Where it leads:** A shelf carved into the platform's pilings -- below the waterline in the Interlude (requires diving or waiting for low water).
**Contents:** Ancient Spirit-Binding Totem (unique accessory -- permanently hosts a minor water spirit that grants +15% water resistance and +MP regen. The spirit whispers occasionally in battle -- flavor text: "The water remembers you."), and a fenwood tablet describing the original spirit-binding pact between the Duskfen and the Fenmother.
**Availability:** Act II (above water), Interlude (requires diving -- Diving Mask from Bellhaven's Sailor's Outfitter).

#### SP-T3: Canopy Reach Wind-Spirit Shrine Overlook

**Entrance location:** Wind-Spirit Shrine (Upper Canopy, Canopy Reach) -- the shrine's highest platform has a vine ladder that's easy to miss
**Discovery method:** Wynne mentions "the place where the wind speaks loudest" in dialogue. The vine ladder is on the shrine's back wall, partially concealed by foliage. Examining the back wall reveals it.
**Where it leads:** A tiny platform above the canopy -- the highest accessible point in the entire game. The sky is fully visible. At night, the stars are clear.
**Contents:** No items. This is a view reward. Standing on the platform triggers a party dialogue scene where each present member comments on the view. If "What the Stars Said" is active, one of the ley line inscription fragments is carved into the platform's railing. If all party members are present, the scene includes a rare moment of genuine levity -- Sable makes a joke about the height and Edren actually laughs.
**Availability:** Act II.

### Cross-City Connections

#### SP-X1: Corrund Sewer to Caldera Forge Channel

**Entrance location:** Corrund Sewer Network (Maintenance Tunnels, Screen 2) -- the passage labeled "TO PUMP STATION"
**Discovery method:** The Tunnel Map key item from Tash reveals this connection. Without it, the passage appears to dead-end at a collapsed section. With the map, the party can navigate around the collapse through a narrow detour.
**Where it leads:** A multi-screen tunnel passage (3 screens of linear corridor with random encounters) that eventually connects to the Caldera Undercity via the Abandoned Forge Channel.
**Contents:** Screen 1: Resistance waypoint (bedrolls, graffiti: "KEEP MOVING"). Screen 2: A junction where a side passage leads to a collapsed room containing a chest with 2,000 gold and a Compact Military Dispatch (lore -- orders for Kole's Pallor experiments, predating his promotion). Screen 3: The final passage opens into Caldera's Abandoned Forge Channel.
**Availability:** Interlude.

#### SP-X2: Greyvale Hidden Cellar

**Entrance location:** Greyvale -- the burned-out house on the east side of town, beneath a collapsed floor
**Discovery method:** Examine the rubble in the burned house. A section of floor gives way, revealing a cellar. In Act II, a Valdris loyalist NPC standing nearby hints: "My father kept things in the cellar. Important things. I haven't been able to get down there."
**Where it leads:** A single-room cellar beneath the house.
**Contents:** Valdris Intelligence Cache (key item -- Carradan troop movements from the border war, useful in Act II diplomatic scenes), a Valdris regimental banner (sellable or keepable -- Edren comments: "Third Regiment. Good soldiers. They deserved better."), 800g, 2x Healing Draught. In the Interlude, the cellar also contains a Pallor Antidote (the loyalist NPC is catatonic above -- the antidote cannot help him).
**Availability:** Act II onward.

---

## 3. Hidden Rooms & Easter Eggs

### The Clockwork Room (Developer Homage)

**Location:** Kettleworks, Laboratory Dome -- a maintenance panel on the dome's inner wall, accessible only by examining the panel while holding the Precision Tool Set and the Ley-Analysis Lens simultaneously (both purchased from the Campus Store)
**Discovery method:** There is no in-game hint. This is a pure exploration reward. The maintenance panel is interactive only when both items are in inventory.
**Contents:** A small room decorated unlike anything else in the game. Instead of the Compact's industrial aesthetic, the room is warm, cluttered, and personal. A workbench covered in half-finished projects. A chalkboard with equations that don't correspond to any in-game system. A bookshelf with titles like "A History of Imaginary Machines" and "On the Nature of Constructed Worlds." Four NPC sprites sit at desks -- they introduce themselves as "the people who built all of this" and offer meta-commentary about the game's design. One says: "We argued about the ending for weeks." Another says: "The forge-smoke particles took longer than the boss fights." The room contains a unique accessory: the Maker's Mark (all stats +1, flavor text: "For the ones who stayed late").

### The Midnight Market (Time-Locked Room)

**Location:** Corrund, Brass Fountain Plaza -- the fountain's base
**Discovery method:** Examine the fountain's base between midnight and 1:00 AM (in-game time). At all other times, the inscription is unreadable. During the midnight hour, the inscription glows faintly and reads: "Trade in what you've lost." Interacting with it during this window opens a hidden staircase.
**Contents:** A subterranean market lit by grey ley-crystal lanterns. A single NPC merchant -- unnamed, face hidden by a hood -- sells items that cannot be obtained anywhere else. The stock changes each time the player visits. Possible items include: Memory Dust (consumable -- restores a dead party member to full HP with full MP, three uses per purchase), the Hourglass Pendant (accessory -- grants one free turn at the start of every battle), and the Grey Coin (unique currency item -- can be traded at the Midnight Market for an item from any previous cycle of the Pallor). The merchant never speaks. The transaction is entirely gestural. The room has no save point. If the player leaves, they cannot return until the next midnight.

### The Visible Treasure (Spatial Puzzle)

**Location:** Valdris Crown, Eastern Wall Battlements -- a chest is visible through an arrow slit, sitting on a ledge on the outer wall face. It can be seen from the Battlements screen but there is no way to reach it from that screen.
**Access:** The chest is reachable only from the Catacomb Northeast Exit (Floor 3 of the Valdris Crown Catacombs). After emerging from the catacombs on the hillside, a narrow path along the outer wall leads to the ledge. The path is not marked and is easy to miss -- it appears to be a decorative cliff edge.
**Contents:** Crown Jewel Fragment (accessory -- DEF +10, MAG DEF +10, flavor text: "A piece of something that was never whole. Like everything in Valdris."). The player has likely been staring at this chest since Act I. Reaching it in the Interlude (or later) is the payoff.

### The Cycle Keeper (NPC Conditional Appearance)

**Location:** Ashgrove, First Tree Stump -- only appears after completing all three of the following quests: "The Third Door," "What the Stars Said," and "A Letter Never Sent"
**Discovery method:** Return to the First Tree Stump after completing all three quests. An NPC who was not there before sits on the stump. They appear as a translucent figure -- neither alive nor dead, neither spirit nor human.
**Dialogue:** The Cycle Keeper speaks about the previous cycles of the Pallor in first-person. They were the "second person" referenced in "The Third Door" -- the one who walked through the door with the host and survived, carrying the Pallor's accumulated grief. They have been alive for thousands of years. They do not age. They do not forget. They say: "I carry every age. Every face. Every name of every person the Pallor took. I was supposed to be the bridge -- the one who holds the memory so the next generation doesn't repeat it. But generations don't listen to immortals. They listen to stories." They look at the party. "Tell better stories than I did."
**Reward:** The Cycle Keeper's Burden (accessory -- +15 to all stats, but the equipped character occasionally speaks dialogue from past cycles in battle -- names of people long dead, fragments of languages that no longer exist). This is the strongest stat accessory in the game but comes with a constant reminder of cost.

### Previous Cycle Graffiti (Scattered Easter Eggs)

Hidden in specific locations throughout the game, small pieces of graffiti from previous Pallor cycles can be found. They appear as faint, barely visible markings on walls, floors, or stone surfaces. Each requires careful examination to notice (the sprite is one shade different from the surrounding wall).

| # | Location | Text | Context |
|---|----------|------|---------|
| 1 | Valdris Crown Catacombs, Floor 2, Queen Verath's Tomb | "She held the door. We forgot her name." | A previous cycle's host |
| 2 | Corrund Sewer Junction, wall near the Valve Room | "The machines did not save us." | A past industrial civilization |
| 3 | Roothollow, Heartwood Shrine, base of the altar | "The tree remembers what we cannot." | Pre-tribal writing |
| 4 | Ashmark, Black Forge B, upper catwalk | "We built too much. We listened too little." | Etched in pre-Compact script |
| 5 | Bellhaven, Sea Caves, deepest wall | "The water carried the grey before the land did." | Maritime civilization's warning |
| 6 | Ashgrove, Council Stones, base of the tallest stone | "The door opens from both sides." | The Pallor's nature |
| 7 | Ironmark Citadel, Cell 7 (the empty cell) | "I gave in too." | A previous soldier in a previous fortress |
| 8 | Caldera Undercity, Abandoned Forge Channel | "Heat does not burn the grey away." | A previous forge-city's discovery |
| 9 | Greyvale, the dry well | "The water stopped first. Then everything else." | Pattern recognition |
| 10 | Duskfen, beneath the Central Landing (visible only from underwater) | "She sleeps. She has always slept. One day she will not wake." | About the Fenmother -- or something older |

Finding all 10 unlocks no achievement or reward. The knowledge itself is the reward. Maren, if present for the 10th discovery, says: "Ten messages. Ten ages. And every single one of them thought they were the last." Beat. "We think that too."

---

## 4. Quest-Locked Areas

These areas within cities only become accessible when a specific side quest is active or has been completed. They are designed to make the quest narrative feel integrated into the city's physical space.

### Valdris Crown: Royal Library Restricted Stacks

**Quest:** "The Third Door" (Major Side Quest #3)
**Trigger:** Mirren grants access after the quest begins
**Location:** Royal Library (Citizen's Walk) -- a locked iron gate at the back of the basement archives
**What the player finds:** The Restricted Stacks contain the oldest documents in Valdris -- pre-dynasty records written on stone tablets and preserved bark. The fragmentary text referencing the Pallor's previous cycles is stored here. Mirren guides the party to the specific shelf. The room also contains: Archivist's Seal (accessory -- +lore entries revealed when examining objects throughout the game), 2x Mana Tincture, and a Stone Tablet Fragment (key item -- used in the quest to confirm the existence of the Third Door).

### Valdris Crown: Cael's Quarters (Interior)

**Quest:** "A Letter Never Sent" (Major Side Quest #10)
**Trigger:** Scholar Aldis provides a key after the quest begins
**Location:** Cael's Quarters (Lower Ward) -- the door is sealed and warded in Act II and the Interlude
**What the player finds:** Cael's room, undisturbed since his departure. The walls are covered in research notes. His bed is made but there's an indent where he sat for hours. His desk has the blank paper with "Dear L" written at the top. The room's ley-lamp still works -- it flickers in a pattern that Maren identifies as the Pendulum's resonance. Treasure: Cael's Research Notes (key item -- complete set, used in multiple quest chains), Cael's Personal Effects (key item -- a carved wooden bird, a pressed flower, a letter from King Aldren thanking him for his service. Each triggers a brief dialogue scene).

### Corrund: Axis Tower Intelligence Archive

**Quest:** "The Auditor's Conscience" (Major Side Quest #5)
**Trigger:** Accessible after the Axis Tower Interlude dungeon is cleared
**Location:** Axis Tower, Floor 2 -- a secure room that was sealed during the dungeon sequence
**What the player finds:** Project Pendulum's intelligence files, including Fenn Acari's authorization memos, the geological survey team's warnings, and the casualty reports classified as "equipment accidents." Key items: Project Pendulum Full Dossier (used in the quest), Compact Geological Survey (lore -- reveals that the Convergence was identified as dangerous decades ago), Intelligence Staff Roster (key item -- names of the people who knew and said nothing).

### Caldera: Dael's Meeting Room

**Quest:** "Unbowed" (Minor Side Quest #10)
**Trigger:** Sera Linn directs the party to Dael's Corner after the quest begins
**Location:** Dael's Corner (Lower Factory District) -- the back room, normally locked
**What the player finds:** Dael's organizing headquarters. A table covered in maps of the factory district's tunnel system. Worker schedules with the names of those showing fading symptoms highlighted. A crate of medical supplies Dael has been hoarding. The room serves as the staging area for the worker evacuation in the "Unbowed" quest. After the quest: Dael's Manifesto (key item -- a political document arguing for worker representation in the Forge-Masters' Guild. Referenced in the epilogue as contributing to Caldera's post-war labor reforms).

### Bellhaven: Prince Venn's Archive

**Quest:** "The Honest Thief" (Major Side Quest #7)
**Trigger:** After obtaining Prince Aldara's Private Ledger, Prince Venn's door is marked as accessible. Venn himself invites the party in -- he wants to see what Aldara was hiding.
**Location:** Prince Venn's Manor (Merchant Prince District) -- the archive room on the upper floor
**What the player finds:** Venn's counter-intelligence files on Aldara -- years of surveillance documenting Aldara's dual arms sales. Venn knew all along and was waiting for leverage. The archive contains: Venn's Dossier on Aldara (key item -- combined with Aldara's Ledger, provides complete evidence for the quest's political crisis), the Merchant Prince's Signet Ring (accessory -- referenced in city-carradan.md as hidden in Warehouse 2, but this is a second copy Venn had made), and 3,000 gold in a strongbox that Venn offers as payment for the party's discretion.

### Ashmark: Black Forge C Interior

**Quest:** "The Fading Shifts" (Major Side Quest #1)
**Trigger:** During the investigation, the party needs to examine the damaged forge
**Location:** Black Forge C (center south of Ashmark) -- normally sealed due to explosion damage
**What the player finds:** The interior of the damaged forge, where a ley surge caused the explosion. The walls are scorched but the pipeline infrastructure is partially intact. Evidence here confirms that the ley energy flowing through the forge was contaminated. A maintenance terminal still has power -- Lira can access the extraction logs showing contamination levels rising for months before the explosion. Treasure: Explosion Origin Analysis (key item -- technical proof for Dael's claims), Scorched Arcanite Ingot (crafting material -- damaged but usable in Lira's recipes), 1x Emberstone Fragment.

---

## 5. Escape Routes

During key story events, the party must flee through cities under pressure. These routes are designed as one-way, time-pressured traversals that repurpose familiar city spaces in unfamiliar ways.

### Valdris Crown: The Interlude Escape

**Context:** The Carradan assault breaches the eastern wall. King Aldren dies. Cael's betrayal is revealed. The surviving party (Edren, Sable, and available allies) must escape the city as it falls.
**Entry point:** Royal Keep, Throne Hall -- the escape begins after the cutscene of King Aldren's death.
**Party:** Edren (mandatory), Sable (mandatory), plus any available party members.

**Route:**

```
ESCAPE ROUTE -- Valdris Crown Interlude

[1] THRONE HALL
    King Aldren is dead. Cordwyn grabs Edren: "The Servants' Passage. NOW."
    |
    v
[2] SERVANTS' PASSAGE (Royal Keep)
    A narrow corridor behind the Keep's walls. No encounters.
    The passage shakes -- the eastern wall is collapsing.
    The party reaches a junction: left goes to the Grand Corridor
    (blocked by rubble), right goes DOWN.
    |
    v
[3] BARRACKS ESCAPE (Lower Ward -- if Cordwyn leads)
    OR
    CATACOMB ENTRY (via SP-V2, Barracks to Catacombs)
    Cordwyn reveals the bolt-hole. The party descends.
    |
    v
[4] CATACOMB FLOOR 1: OSSUARY
    2 fixed encounters: Restless Dead (weakened, more pathetic
    than dangerous). The party moves fast. Save point at the
    Spirit Shrine -- the only save during the escape.
    |
    v
[5] CATACOMB FLOOR 2: ROYAL TOMBS
    1 fixed encounter: Royal Wraith (stronger -- it mistakes
    the party for intruders). The party passes King Aldren's
    empty tomb. Edren pauses. Cordwyn: "Keep moving."
    The Dynasty Hall pressure plate trap is active --
    first-time traversal during the escape means the player
    must solve it under pressure.
    |
    v
[6] CATACOMB FLOOR 3: DEEP CATACOMBS
    No encounters during the escape (the Undying Warden is
    dormant -- it only activates on return visits). The party
    passes through the Catacomb Heart and reaches the
    Northeast Exit.
    |
    v
[7] NORTHEAST EXIT -- HILLSIDE
    The party emerges on the hillside outside the city walls.
    Behind them, smoke rises from Valdris Crown. The eastern
    wall is a ruin. Fires burn in the Lower Ward.
    Cutscene: Edren looks back. Cordwyn does not.
    The party splits for the Interlude's individual arcs.
```

**Encounters along the route:** 3 fixed encounters total. The escape is not about combat difficulty -- it's about emotional weight. The encounters are speed bumps, not roadblocks. The real challenge is navigating the catacombs (simple but unfamiliar) under narrative pressure.

**Key moments:**
- The Servants' Passage shaking: environmental cue that the assault is destroying the city above. Dust falls from the ceiling. Distant explosions (audio).
- King Aldren's empty tomb: Edren stops. If the player presses interact, Edren says: "They prepared this for him. He'll never use it." If the player moves on without interacting, Cordwyn says: "He knew. At the end. He knew it was over."
- The Northeast Exit: The party emerges into daylight. The camera pans to show the smoke rising from the capital. This is the last time the party sees Valdris Crown intact (it fractures into noble fiefdoms during the Interlude).

---

### Corrund: Sable's Infiltration Route

**Context:** During the Interlude, Sable must reach Lira in the Compact's territory. She enters Corrund through the Undercroft sewer entrance, navigates to Lira's hidden workshop via the tunnel network, and eventually infiltrates the Axis Tower.
**Entry point:** Undercroft Sewer Entrance (Corrund, south end of the Undercroft).
**Party:** Sable (mandatory), joined by Lira mid-route.

**Route:**

```
INFILTRATION ROUTE -- Corrund (Sable's Arc)

[1] UNDERCROFT SEWER ENTRANCE
    Sable arrives via the overworld. The North Canal Gate
    checkpoint is too strict. Tash provides the sewer route.
    |
    v
[2] SEWER JUNCTION (Corrund Sewers Screen 1)
    Sable navigates the junction. Valve puzzle required to
    proceed. Random encounters with Forge-Smoke Creatures
    and Service Automata.
    |
    v
[3] MAINTENANCE TUNNELS (Screen 2)
    Resistance waypoint -- rest opportunity.
    Sable follows Tash's marks on the walls.
    |
    v
[4] SURFACE EXIT -- UNDERCROFT
    Sable emerges in the Undercroft near Tash's Black Market.
    Conversations with Tash and Sable's Contact provide intel.
    |
    v
[5] CORRUND SURFACE NAVIGATION
    Sable must cross from the Undercroft to the Consortium
    Quarter. The Canal District is flooded in sections.
    Routes: (A) Cross via the Lower Bridge (risky -- patrols),
    (B) Use the canal itself (swim, requires Diving Mask),
    (C) Purchase Grade 3 Identity Papers from Tash and
    walk through the Middle Bridge checkpoint.
    |
    v
[6] LIRA'S HIDDEN WORKSHOP (Consortium Quarter, secret)
    Sable finds the entry mechanism (SP-C2 variant --
    a false wall identified by Sable's contacts).
    Lira joins the party. Save point. Story cutscene.
    |
    v
[7] RETURN TO SEWERS
    Lira and Sable descend back to the sewer network.
    |
    v
[8] AXIS TOWER SUBLEVEL (Corrund Sewers Screen 3)
    Elevator puzzle. Ascent to Axis Tower Floor 1.
    The Axis Tower dungeon sequence begins.
```

**Encounters along the route:** Standard sewer encounters plus Corrund-specific enemies (Compact Security Drones in the surface sections if spotted). The infiltration route is designed to feel tense but navigable -- Sable is in her element. Her dialogue reflects this: "Sewers, fake papers, talking my way past guards. This is literally my job."

**Key moments:**
- The Undercroft surface section: Sable sees children in the alleys who aren't playing. They just stand there. "That's new," she says. "Kids always play. Even in the Undercroft. Especially in the Undercroft."
- Finding Lira's Workshop: The reunion scene. Lira has been working alone for months, tracking Cael through Compact intelligence. Her walls are covered in notes and string. Sable: "You look terrible." Lira: "You look like you crawled through a sewer." Sable: "I did crawl through a sewer."
- The elevator puzzle: Lira solves the conduit routing while Sable watches. "I can pick any lock in the Compact. She can rewire a building's power grid. We make a good team."

---

### Caldera: Worker Evacuation Route (Unbowed Quest)

**Context:** During the "Unbowed" side quest, the party escorts twenty workers and their families through the undercity tunnels to a new safe house.
**Entry point:** Sera Linn's Resistance HQ (Caldera Undercity).
**Party:** Player's active party plus a group of NPC evacuees (escort mechanic).

**Route:**

```
EVACUATION ROUTE -- Caldera Undercity (Unbowed Quest)

[1] SERA LINN'S RESISTANCE HQ
    Sera briefs the party. Twenty workers and families.
    Three safe houses compromised. One new location secured
    near the canal district connection.
    |
    v
[2] UNDERCITY MAIN PASSAGE
    The group moves through the Abandoned Forge Channel.
    The evacuees slow movement speed. Random encounters
    with Pallor Nests (must be cleared before the group
    can proceed -- corrupted residue on the tunnel walls
    that spawns Grey Crawlers if disturbed).
    |
    v
[3] TUNNEL JUNCTION
    A branch point. Left: shorter route through a narrow
    passage (fits the party but not the evacuees). Right:
    longer route through a wider passage (fits everyone
    but has more encounters). The choice affects time and
    difficulty but not outcome.
    |
    v
[4] FORGE CHANNEL PASSAGE (SP-K2)
    Through the crawlspace behind Forge Hall D.
    The evacuees squeeze through one at a time.
    A timed sequence -- Compact Security patrols pass
    above. The party must wait for patrol gaps.
    |
    v
[5] NEW SAFE HOUSE (Lower Factory District, hidden basement)
    The evacuees arrive. Sera's contact opens the door.
    The families file in. A child asks: "Is this home now?"
    Sera: "For now. That's enough."
```

**Encounters:** Pallor Nests (3 fixed encounters -- clearing corrupted residue from the tunnel walls), Grey Crawlers (random encounters spawned by the nests), and one Compact Security Drone patrol (avoidable with timing, fightable if caught).

---

### Bellhaven: The Honest Thief Heist Route

**Context:** During "The Honest Thief" quest, the party infiltrates Prince Aldara's manor to steal medical supplies and potentially incriminating documents.
**Entry point:** Smuggler's Den (Bellhaven Smuggler Tunnels).
**Party:** Sable (mandatory), plus available party members.

**Route:**

```
HEIST ROUTE -- Bellhaven (The Honest Thief Quest)

[1] SMUGGLER'S DEN
    Sable's contact provides the manor's guard schedule
    and a rough map of the warehouse's layout.
    |
    v
[2] DOCK TUNNELS
    The party moves through the dock tunnels beneath
    the Dockside warehouses. Stealth section: avoid
    dock worker patrols by timing movement between
    crate stacks and loading bays.
    |
    v
[3] SURFACE EXIT -- DOCKSIDE
    Emerge behind Warehouse 1 (using the SP-B2
    Breakwater passage in reverse, or through a
    dock-level maintenance hatch).
    |
    v
[4] MERCHANT PRINCE DISTRICT APPROACH
    Stealth navigation through the upper city streets
    at night. Guard patrols follow fixed routes.
    Sable can use Smoke Capsules to create distractions.
    Lira can disable Forgewright alarm tripwires.
    Torren can sense guards through walls (spirit-sense).
    |
    v
[5] ALDARA'S MANOR -- EXTERIOR
    Scale the garden wall (Grappling Line required).
    Disable the garden's Forgewright motion sensor
    (Lira's skill check, or brute-force with a timed run).
    |
    v
[6] ALDARA'S MANOR -- INTERIOR
    Navigate the manor: ground floor (servants' quarters,
    kitchen -- avoid the night staff), upper floor (study,
    the portrait hiding SP-B1), and the warehouse wing
    (medical supplies). The study contains the Private
    Ledger. The warehouse contains the medical supplies.
    |
    v
[7] EXTRACTION
    Return route: back through the garden, down to
    Dockside, into the smuggler tunnels. If the alarm
    was tripped, guard patrols are doubled on the return.
    The medical supplies are heavy (movement speed reduced)
    unless the party uses the Dock Tunnel crate transport
    (a smuggler's pulley system, activated by Sable's
    contact for 500 gold).
```

**Encounters:** The heist is stealth-focused. Combat encounters only occur if the party is detected. Detection triggers an escalation: first patrol reinforcements, then Forgewright Security Drones, then (if the alarm rings for 3 turns) a mini-boss: Aldara's Head of Security (human boss, high DEF, calls reinforcements).

---

## Appendix: Connection Map

All city dungeon and secret passage connections visualized:

```
                        VALDRIS CROWN
                    /        |        \
              Catacombs  SP-V1-V5   Escape Route
              (3 floors)             (to hillside NE)
                                         |
                                    overworld travel
                                         |
                        CORRUND
                    /        |        \
            Sewers/Undercity SP-C1-C3  Infiltration Route
            (3 screens)      |         (Sable's arc)
                    |        |
                SP-X1        SP-C1
            (tunnel to       (tunnel to
             Caldera)         Ironmark)
                    |              \
                CALDERA         IRONMARK CITADEL
              /        \         Lower Cells
        Undercity    SP-K1-K3    Brant's Passage
        (4 screens)
            |
        Forge Channel
            |
        ASHMARK
        Factory Depths    SP-A1-A2
        (2 floors)
            |
        (pipeline to Millhaven)

                        BELLHAVEN
                    /        |        \
            Smuggler       SP-B1-B2   Heist Route
            Tunnels                   (Honest Thief)
            (3 screens)

                    THORNMERE SETTLEMENTS
                    SP-T1 (Roothollow)
                    SP-T2 (Duskfen)
                    SP-T3 (Canopy Reach)

                    CROSS-CITY
                    SP-X1 (Corrund <-> Caldera)
                    SP-X2 (Greyvale cellar)
```

---

## Design Notes

**Encounter philosophy:** City dungeons should feel different from wilderness dungeons. Enemies are the products of civilization's failures -- malfunctioning machines, corrupted infrastructure, undead bound by broken pacts, Pallor seeping through the systems people built. Every city dungeon encounter is a mirror: the cities built these tunnels, and the tunnels spawned these monsters.

**Treasure philosophy:** City dungeon treasure should tell stories. A ledger is more interesting than a potion. A training sword carried by a dead knight is more valuable than a generic blade. Every chest should make the player think about the person who put those items there and why.

**Passage discovery philosophy:** Every secret passage has at minimum two discovery methods: one NPC hint and one environmental clue. No passage should require a guide to find. The most rewarding passages are the ones the player suspects exist before finding them -- the hollow wall they knocked on three hours ago, the bookshelf with no dust.

**Escape route philosophy:** Escape sequences should repurpose familiar spaces. The player should recognize where they are -- this is the city they've been shopping in, talking to NPCs in, saving at. Now it's hostile. Now the buildings they browsed are obstacles. The emotional weight comes from the contrast between what the city was and what it is now.
