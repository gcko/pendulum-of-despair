# Boss Deep Pass Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Weave bosses, lore breadcrumbs, and NPC connections throughout all story docs to implement the boss deep pass design spec.

**Architecture:** This is a pure documentation pass -- no code changes. Every task modifies markdown files in `docs/story/` following the exact formatting conventions already established in each file. All new content must cross-reference existing content and maintain internal consistency.

**Tech Stack:** Markdown documentation. All files in `docs/story/`. Spec at `docs/superpowers/specs/2026-03-16-boss-deep-pass-design.md`.

**Spec Document:** `docs/superpowers/specs/2026-03-16-boss-deep-pass-design.md`

**Key Convention References:**
- NPC entries: `docs/story/npcs.md` -- fields in order: Location, Role, Backstory, Dialogue hints, Story relevance, Act presence
- Dungeon bosses: `docs/story/dungeons-world.md` -- inline in floor descriptions with Pattern B (multi-phase) stat blocks
- Event flags: `docs/story/events.md` -- 5-column table: #, Flag Name, Trigger, World Changes, NPCs Affected
- Sidequest format: `docs/story/sidequests.md` -- fields: Quest Giver, Location(s), Availability, Estimated Length, Narrative Arc, Rewards, Thematic Resonance
- Outline: `docs/story/outline.md` -- pure narrative prose, organized by act with `##` and `###` headers

**Important:** ASCII map layouts for Pallor Trial dungeons are OUT OF SCOPE for this plan. They will be built in a follow-up session. This plan adds boss content, NPC entries, event flags, lore breadcrumbs, and narrative integration -- not floor layouts.

---

## Chunk 1: Core Character Setup

### Task 1: Add Vaelith to characters.md

**Files:**
- Modify: `docs/story/characters.md` (add new section)

**Context:** Vaelith is the Pallor General -- an 800-year-old figure from the previous Pallor cycle. They are the spec's central new character. Must be added to `characters.md` under a new `## The Pallor's Champion` section between `## The Antagonist` (the Pallor) and `## Relationships`.

- [ ] **Step 1: Read characters.md to find insertion point**

Read the file. Locate the `## The Antagonist` section (the Pallor entry) and the `## Relationships` section. The new section goes between them.

- [ ] **Step 2: Write Vaelith's character entry**

Add a new section matching the existing character format (bold-labeled fields: Role, Personality, Arc, Fate):

```markdown
## The Pallor's Champion

### Vaelith, the Ashen Shepherd

**Role:** Recurring antagonist -- the Pallor's ancient instrument, a figure from the previous cycle 800 years ago. Appears seven times across the story, escalating from charming curiosity to revealed sociopath to vulnerable final opponent.

**Personality:** Vaelith speaks like a dinner party host -- warm, witty, genuinely interested in people. They ask questions. They remember names. They compliment Lira's craftsmanship and Torren's spiritual sensitivity with apparent sincerity. They treat the party like fascinating subjects in a study they have been conducting for centuries. The horror creeps in when you realize the warmth is real -- Vaelith genuinely likes people the way an entomologist likes butterflies. Pinned ones.

In life, Vaelith was a celebrated scholar-diplomat -- charming, brilliant, beloved. When the Pallor rose in their era, they were the one everyone trusted to find a solution. Instead, they found the Pallor fascinating. They did not fall to Despair -- they chose it, the way a scholar chooses a field of study. The Pallor did not break them; it gave them exactly what they wanted: eternity to observe the human condition at its most raw.

**Arc:** Vaelith's arc across seven appearances follows the Kefka template (FF6): the player first encounters a charming oddity at Ember Vein who seems almost helpful. Vaelith reappears as an observer in the Wilds, then as a tavern scholar in Corrund/Bellhaven who asks unsettling questions about Cael. A cutscene the party does not witness reveals the "Doma moment" -- Vaelith comforting Pallor-touched villagers while feeding on their despair. At the Valdris siege, Vaelith appears for an unwinnable fight, treating the party's desperate stand as entertainment. During the Interlude, NPCs reveal Vaelith has been engineering events (Brant's fatalism, ley node destabilization, the Ashen Ram's design). Finally, in the Pallor Wastes, Vaelith faces a party that has done what no previous cycle's heroes managed: the ley network is alive, and Lira forges a weapon from Cael's lingering bond. For the first time in eight centuries, Vaelith stops smiling.

**Fate:** Vaelith does not die dramatically. After defeat, they sit down and look at the party -- really look, without the lens of centuries of contempt. "Eight hundred years. Every cycle, the same. And you... you actually changed something." They dissolve into grey mist. Not destroyed -- released. The eternity they chose finally ends.
```

- [ ] **Step 3: Update the Relationships section**

Add Vaelith's connections to the existing `## Relationships` section (which has an ASCII diagram of character connections). Add Vaelith's web:
- Vaelith -> Brant (planted fatalism that enabled cowardice at Ironmark)
- Vaelith -> Cael (observing with particular interest; asks about him in the tavern)
- Vaelith -> Lira (recognizes the forgewright pattern from previous cycles)
- Vaelith -> Torren (notes the spirit-speaker as "promising" in journal)
- Vaelith -> Maren (records in the Archive match Vaelith's identity)
- Vaelith -> Riven (Grey Bounty creatures were disturbed by Vaelith's passage)
- Vaelith -> Forgemaster Drayce (consulted on the Ashen Ram's design)

- [ ] **Step 4: Verify cross-references**

Confirm the entry references match existing character names and events: Lira, Torren, Cael, Brant, Ember Vein, Corrund, Bellhaven, Valdris siege, Pallor Wastes, ley network.

- [ ] **Step 5: Commit**

```bash
git add docs/story/characters.md
git commit -m "docs(story): add Vaelith the Ashen Shepherd to characters.md"
```

---

### Task 2: Add Vaelith to npcs.md

**Files:**
- Modify: `docs/story/npcs.md` (add entry under a new section)

**Context:** Vaelith doesn't fit neatly into Valdris/Compact/Thornmere factions. Add under `## Cross-Faction and Unaffiliated NPCs` section. Follow the exact NPC entry format: Location, Role, Backstory, Dialogue hints, Story relevance, Act presence.

- [ ] **Step 1: Read the Cross-Faction section of npcs.md**

Find the `## Cross-Faction and Unaffiliated NPCs` section and read the last few entries to confirm format.

- [ ] **Step 2: Write Vaelith's NPC entry**

```markdown
### Vaelith, the Ashen Shepherd

**Location:** Variable -- appears across multiple locations throughout the story. First encountered at Ember Vein. Later appears in the Thornmere Wilds, Corrund or Bellhaven, the walls of Valdris during the siege, and finally the Pallor Wastes.

**Role:** Pallor General -- an ancient champion of Despair from the previous Pallor cycle, 800 years ago. Recurring antagonist who appears seven times across the story. See characters.md for full arc.

**Backstory:** Vaelith was a scholar-diplomat in the previous civilization. When the Pallor rose in their era, they were the one everyone trusted to find a solution. Instead, they found the Pallor fascinating and chose it willingly -- the only person in recorded history to embrace Despair not out of brokenness but out of intellectual curiosity. The Pallor granted them what they wanted: eternity to observe. For 800 years, Vaelith has walked the continent between cycles, studying people, destabilizing ley nodes with precisely crafted tuning forks, and waiting for the next cycle to begin. They have watched every set of heroes try and fail. They know how hope dies because they have catalogued every variation.

Their influence in the current cycle extends far beyond direct confrontation. They manipulated Commissar Brant's fatalism, consulted on the Ashen Ram's design at the Ironmark construction yard, destabilized ley nodes across the continent, and disturbed Grey Bounty creatures in the Wilds. Records in the Archive of Ages describe a diplomat from the previous cycle who "walked into the grey and did not return." A faded portrait in Valdris Crown's forgotten gallery matches their appearance.

**Dialogue hints:**
- *"Such a fragile little thing to build hope around."* (Ember Vein, examining the Pendulum)
- *"Your friend with the heavy eyes. How is he sleeping?"* (Corrund/Bellhaven tavern, asking about Cael)
- *"You are doing wonderfully. Truly. I have not been this entertained in centuries."* (Valdris siege, unwinnable fight)
- *"...Interesting."* (Pallor Wastes, when Lira's weapon manifests)
- *"Eight hundred years. Every cycle, the same. And you... you actually changed something."* (Pallor Wastes, upon defeat)

**Story relevance:** Ties to main quest

**Act presence:** Act I: Appears post-Vein Guardian at Ember Vein (Appearance 1 -- charming introduction, no combat). Observed watching from a ridge in the Thornmere/Duskfen region during the Act I-II transition (Appearance 2 -- leaves a campsite with two cups of tea and a journal page). Act II: Found in a Corrund or Bellhaven tavern posing as a traveling scholar (Appearance 3). A narrative cutscene (not witnessed by the party) reveals Vaelith feeding on Pallor-touched villagers while comforting them (Appearance 4 -- the "Doma moment"). Appears during the Valdris siege for an unwinnable fight (Appearance 5). Interlude: Not seen directly, but referenced by multiple NPCs including Brant's confession and Cordwyn's reports (Appearance 6). Act III: Penultimate boss in the Pallor Wastes before the Convergence (Appearance 7 -- 20,000 HP).

---
```

- [ ] **Step 3: Commit**

```bash
git add docs/story/npcs.md
git commit -m "docs(story): add Vaelith NPC entry to npcs.md"
```

---

### Task 3: Add Caden to npcs.md

**Files:**
- Modify: `docs/story/npcs.md` (add entry under `## The Thornmere Wilds`)

**Context:** Caden is already referenced in events.md and locations.md but has no npcs.md entry (flagged in continuity-audit.md as IMPORTANT). The boss spec increases Caden's role via the Ley Leech fight. Add under the Thornmere Wilds section.

- [ ] **Step 1: Read existing Caden references**

Search events.md, locations.md, and dungeons-world.md for all existing Caden mentions to ensure the NPC entry is consistent.

- [ ] **Step 2: Write Caden's NPC entry**

Place after related Thornmere NPCs (near Elder Savanh, Orun, or other Duskfen characters):

```markdown
### Caden

**Location:** Duskfen Hollow, Roothollow nexus area

**Role:** Young spirit-speaker of the Duskfen tribe. Torren's spiritual successor.

**Backstory:** Caden is the youngest spirit-speaker in living memory among the Duskfen people. Where Torren learned the old ways through decades of practice and tradition, Caden's gift emerged raw and untrained -- he could hear spirits before anyone taught him the rituals. The elders see him as either a sign of hope or a warning; a gift that powerful without discipline can be dangerous. Torren recognizes in him what he fears about himself: that the connection to the land might outlive the traditions that give it meaning. Caden is untroubled by this philosophical weight. He simply listens, and the land speaks back.

When the Pallor's corruption spreads into the Wilds, Caden is one of the first to sense it. He can feel the Ley Leech feeding on the nexus from miles away -- a wrongness in the spiritual frequency of the land, like a note held too long. He guides the party to Torren's location during the Interlude, serving as both scout and spiritual compass.

**Dialogue hints:**
- *"The ground is screaming. Can you not hear it? It has been screaming for days."*
- *"Torren says I should not listen so hard. But if I stop listening, who will?"*
- *"The old spirits are not gone. They are just... very quiet. You have to be patient."*

**Story relevance:** Ties to main quest

**Act presence:** Interlude: Senses the Ley Leech from miles away and guides the party to Torren's location at the ley nexus. During the Ley Leech boss fight, assists from the perimeter. After the fight, performs a small recovery ritual for the exhausted Torren -- a passing-of-the-torch moment between the old spirit-speaker and the young one. Act III: If the party returns to the Wilds, Caden is maintaining the stabilized nexus in Torren's absence. Epilogue: Referenced as continuing the spirit-speaking tradition in the changed world.

---
```

- [ ] **Step 3: Commit**

```bash
git add docs/story/npcs.md
git commit -m "docs(story): add Caden NPC entry (resolves continuity-audit gap)"
```

---

### Task 4: Add Kerra to npcs.md

**Files:**
- Modify: `docs/story/npcs.md` (add entry under `## Cross-Faction and Unaffiliated NPCs`)

**Context:** Kerra is the former Valdris soldier introduced in the Pallor Nest Mother boss addition to the "Unbowed" sidequest. She ended up in Caldera after the siege and joined Sera Linn's resistance.

- [ ] **Step 1: Write Kerra's NPC entry**

```markdown
### Kerra

**Location:** Caldera, undercity (Sera Linn's resistance network)

**Role:** Former Valdris soldier turned Caldera resistance fighter. Guest NPC during "Unbowed" escort mission.

**Backstory:** Kerra served in the Valdris garrison during the siege. When the walls fell, her entire unit was killed. She survived by falling into the river and was carried downstream. She washed up in Compact territory with nothing -- no rank, no unit, no purpose. Rather than return to what remained of Valdris, she drifted into Caldera's undercity, where Sera Linn's resistance network gave her something to protect again. She does not talk about the siege. She does not sleep well. But when Sera needs someone to lead civilians through dangerous tunnels, Kerra volunteers without hesitation. Her combat skills are diminished by trauma and malnutrition, but her courage is absolute.

**Dialogue hints:**
- *"Stay behind me. Stay quiet. Do exactly what I say and everyone gets through."*
- *"I have already lost everyone once. It is not happening again."*

**Story relevance:** Ties to world event

**Act presence:** Interlude: Found in Caldera's undercity as part of Sera Linn's resistance network. Joins the party as a guest NPC during the "Unbowed" escort mission. Fights alongside the party against the Pallor Nest Mother (low stats, high courage). If she survives the mission, she becomes a recurring presence in Caldera -- organizing the workers, coordinating with Sera. Epilogue: Appears as a militia leader during Caldera's reconstruction.

---
```

- [ ] **Step 2: Commit**

```bash
git add docs/story/npcs.md
git commit -m "docs(story): add Kerra NPC entry for Unbowed sidequest"
```

---

## Chunk 2: Main Story Integration

### Task 5: Weave Vaelith into outline.md

**Files:**
- Modify: `docs/story/outline.md`

**Context:** The outline uses pure narrative prose organized by act. Vaelith must be woven into the existing narrative at 7 points without disrupting the established story flow. This requires reading each act section and inserting Vaelith's appearances as natural extensions of existing beats.

**Important:** `outline.md` is NARRATIVE ONLY. Describe story outcomes, not game mechanics. Do NOT add HP values, stat blocks, phase descriptions, or combat mechanics. Those belong in `dungeons-world.md`. Write as if describing the story to someone who will never play the game.

- [ ] **Step 1: Read the full outline.md**

Read the complete file to understand the current narrative flow and identify the exact insertion points for each Vaelith appearance.

- [ ] **Step 2: Add Appearance 1 to Act I (post-Ember Vein)**

After the existing text about the party retrieving the Pendulum and escaping Ember Vein, add a paragraph describing Vaelith's first appearance -- the charming stranger who appears, examines the Pendulum, speaks cryptically, and walks into the darkness. This should feel like a curious footnote, not a major event.

- [ ] **Step 3: Add Appearance 2 to Act I-II transition**

At the transition between Act I and Act II, where the party is traveling toward Compact territory, add a brief paragraph about spotting a figure on a ridge -- gone when approached, leaving behind a campsite with two warm teacups and a journal page in archaic script.

- [ ] **Step 4: Add Appearance 3 to early Act II**

When the party arrives in Corrund or Bellhaven, add a paragraph about encountering a charming traveling scholar in a tavern who asks pointed questions about Cael.

- [ ] **Step 5: Add Appearance 4 (Doma moment cutscene) to mid-Act II**

Add a standalone paragraph describing a narrative cutscene the player witnesses but the party does not: Vaelith walking among Pallor-touched villagers, comforting them, feeding on their despair. Mark this clearly as a player-only cutscene.

- [ ] **Step 6: Add Appearance 5 to the Valdris siege (Act II climax)**

In the existing siege section, add Vaelith's presence on the walls, the unwinnable fight, and their departure as Valdris burns. Integrate with the existing King Aldren death and Carradan assault narrative.

- [ ] **Step 7: Add Appearance 6 references to the Interlude**

In the Interlude section where the party is scattered, add NPC references to the grey stranger. Connect to Brant's encounter at Ironmark (existing content) and Cordwyn's reports.

- [ ] **Step 8: Add Appearance 7 to Act III (Pallor Wastes)**

In the existing Act III narrative before the Convergence, add the penultimate boss encounter with Vaelith, Lira's weapon manifestation, and Vaelith's defeat.

- [ ] **Step 9: Verify continuity**

Re-read the modified outline to ensure Vaelith's appearances flow naturally with the existing narrative and no existing content was disrupted.

- [ ] **Step 10: Commit**

```bash
git add docs/story/outline.md
git commit -m "docs(story): weave Vaelith's seven appearances into outline.md"
```

---

### Task 6: Add new event flags to events.md

**Files:**
- Modify: `docs/story/events.md`

**Context:** New bosses need event flags and NPC state changes. Must follow the existing 5-column table format. Add flags to the appropriate act sections. Current highest flag number should be identified by reading the file.

- [ ] **Step 1: Read events.md flag tables to find last flag number and format**

Identify the highest-numbered flag, the act sections, and the table format.

- [ ] **Step 2: Add Act I flag for Vaelith's Ember Vein appearance**

Add a new flag: `vaelith_ember_vein` -- triggered after the Vein Guardian is defeated. World changes: grey stranger NPCs appear in Valdris Crown. NPCs affected: Vaelith (first appearance).

- [ ] **Step 3: Add Act II flags**

Add flags for:
- `vaelith_tavern_encounter` -- triggered when the party meets Vaelith in Corrund/Bellhaven
- `vaelith_doma_moment` -- triggered automatically in mid-Act II (cutscene)
- `ashen_ram_defeated` -- triggered when the party defeats the Ashen Ram during the siege
- `vaelith_siege_encounter` -- triggered after the unwinnable fight with Vaelith at Valdris
- `ironbound_defeated` -- triggered when the party defeats the Ironbound in the Rail Tunnels

- [ ] **Step 4: Add Interlude flags**

Update existing flags:
- `torren_found` -- update to include Ley Leech boss defeat, nexus stabilization, and Caden/Kael Thornwalker NPCs.
- `edren_found` -- update to include Pallor Hollow boss defeat, Scar of the Hollow passive, and monastery safe haven.

- [ ] **Step 5: Add Act III flags**

Add flags for:
- `trial_edren_complete` -- Edren completes the Hall of Crowns. Unlocks Steadfast Resolve.
- `trial_lira_complete` -- Lira completes the Unfinished Forge. Unlocks latent weapon ability.
- `trial_torren_complete` -- Torren completes the Silent Grove. Unlocks Rootsong.
- `trial_sable_complete` -- Sable completes the Crooked Mile. Unlocks Unbreakable Thread.
- `trial_maren_complete` -- Maren completes the Restricted Stacks. Unlocks Pallor Sight.
- `vaelith_defeated` -- triggered when the party defeats Vaelith in the Pallor Wastes. Prerequisites: (1) `trial_lira_complete` (Lira's trial unlocks the latent forge ability) and (2) `torren_found` (ley network must be partially restored). Note: all five trials are completed by this point in the Wastes progression, but only Lira's trial and the ley network are mechanically required for Lira's weapon to manifest.

- [ ] **Step 6: Add Vaelith NPC Story Thread to section 3**

Add a `### Vaelith, the Ashen Shepherd (Ties to Main Quest)` subsection in the NPC Story Threads section, following the existing format with per-act prose paragraphs.

- [ ] **Step 7: Add foreshadowing/payoff entries**

Add entries to the Foreshadowing and Payoff Map table for:
- Vaelith's teacups and tuning forks -> revealed as orchestration tools
- Journal fragments -> "The forgewright built a weapon. It failed." -> Lira's weapon succeeds
- Brant's visitor -> Vaelith's manipulation revealed in the Interlude
- The charming tavern scholar -> the Doma moment retroactively recontextualizes the encounter
- Drayce's engineering -> Ironbound and Forge Warden connect "progress at any cost" theme
- Riven's Grey Bounty creatures "disturbed by something" -> Vaelith's passage through the Wilds

- [ ] **Step 8: Add Boss Interconnection Map to events.md**

Add a new subsection `### Boss Interconnection Map` at the end of the NPC Story Threads section (section 3). Include the full interconnection map from the spec (Section 9) showing Vaelith's Web, Pallor's Natural Spread, Character Arc Bosses, and Compact Corruption threads. Use the ASCII diagram format from the spec.

- [ ] **Step 9: Update NPC Location Tracker appendix**

Add a Vaelith row to the location tracker table showing their presence across acts.

- [ ] **Step 10: Commit**

```bash
git add docs/story/events.md
git commit -m "docs(story): add event flags for new bosses and Vaelith arc"
```

---

## Chunk 3: New Dungeon Bosses

### Task 7: Add the Ironbound to Rail Tunnels in dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md` (Rail Tunnels section)

**Context:** The Carradan Rail Tunnels currently have a mini-boss (Corrupted Boring Engine, 6,000 HP) but no full boss. The Ironbound (8,000 HP) goes at the deepest point of the tunnels, after the mini-boss. Must follow Pattern B (multi-phase) stat block format.

- [ ] **Step 1: Read the existing Rail Tunnels section**

Find the Rail Tunnels dungeon in dungeons-world.md. Read the full section to understand the floor layout, the Corrupted Boring Engine placement, and where the Ironbound should go.

- [ ] **Step 2: Add the Ironbound boss entry**

Add a boss entry at the deepest floor of the Rail Tunnels. Use Pattern B format:

```markdown
**Boss: The Ironbound (8000 HP)**

A massive Carradan boring engine fused with its operator during a Pallor corruption event. The machine and the worker are one -- a person trapped inside a machine that will not stop digging. A Drayce-series frame, built for two-person crews. The second operator fled.

**Phase 1 (8000-4000 HP): The Machine**
- **Drill Charge** -- charges the length of the tunnel, 400-500 damage to anyone in its path. Telegraphed by 1-turn wind-up. Positional awareness required.
- **Steam Vent** -- cone AoE from the engine's exhaust, 200-250 damage + Burn status (3 turns).
- **Tunnel Collapse** -- triggers falling debris in a marked zone. 300 damage + Slow (1 turn). Rearranges the arena by blocking some positions and opening others.
- **Bore Forward** -- the Ironbound advances, pushing the party back. If a party member is pushed against the wall, 150 bonus damage.

**Phase 2 (below 4000 HP): The Operator**
The operator's voice breaks through. Attacks become erratic -- the machine hesitates mid-charge, drill strokes stutter.
- All Phase 1 attacks, but with random hesitation windows (1-turn pauses where the machine stops).
- **Hesitation Window** -- during a pause, Lira can use Forgewright to disrupt the engine (bonus 500 damage) or Torren can use Spiritcall to reach the spirit inside (bonus 400 damage + reduces next attack's damage by 50%).
- **Desperate Bore** -- the machine charges twice in succession with no wind-up. Only used when the operator's voice is strongest.

**On defeat:** The machine stops. The operator's spirit speaks a single line -- their partner's name -- and goes still.

**Lira's Special Interaction:** Recognizes the boring engine model. Unique dialogue: "That is a Drayce-series frame. Those were built for two-person crews. Where is the second operator?" Forgewright command deals bonus damage during hesitation windows.

**Torren's Special Interaction:** Spiritcall can reach the trapped spirit during hesitation windows. Provides bonus damage and damage reduction on the Ironbound's next attack.

**Weakness:** Storm (150% damage). Void (125% damage).
**Resistance:** Earth (50% damage), Flame (75% damage).
**Drop:** Operator's Badge (key item -- triggers dialogue with the second operator NPC in Bellhaven), Reinforced Drill Bit (crafting material).
```

- [ ] **Step 3: Update the encounter table**

Add the Ironbound as the final row in the Rail Tunnels encounter table:

```markdown
| **The Ironbound** (Boss) | Boring engine fused with its operator during Pallor corruption. 8,000 HP. | Deepest tunnel section, past the Corrupted Boring Engine |
```

- [ ] **Step 4: Update the Appendix summary table**

Update the Rail Tunnels row in the dungeon summary table to include "The Ironbound" in the Boss column alongside the existing Corrupted Boring Engine mini-boss.

- [ ] **Step 5: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs(story): add the Ironbound boss to Carradan Rail Tunnels"
```

---

### Task 8: Add the Ashen Ram to dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md` (new section or addition to existing Valdris-related content)

**Context:** The Ashen Ram is the Valdris siege boss. It may need its own short dungeon section (the walls of Valdris during the siege) or be added to an existing Valdris location section. Check if a siege/battle section exists; if not, create a new numbered dungeon section for the Valdris siege battlefield.

- [ ] **Step 1: Check for existing Valdris siege content in dungeons-world.md**

Search for Valdris siege, Valdris assault, or Valdris walls content. Determine if a new section is needed or if it fits into an existing one.

- [ ] **Step 2: Create the Valdris Siege Battlefield section**

If no section exists, add a new dungeon section following the standard format:

```markdown
## [N]. Valdris Siege Battlefield

### Dungeon Overview

- **Floors:** 1 (The Walls of Valdris -- a scripted battle sequence, not a traditional dungeon)
- **Size:** 60x40 tiles (wide battlefield with wall sections, towers, and courtyard)
- **Theme:** The fall of Valdris. A defensive battle on the capital's walls as the Carradan Compact assaults with conventional forces and a Pallor-corrupted siege engine. The city's last stand before it falls.
- **Narrative Purpose:** The Act II climax. King Aldren dies. The Ashen Ram reveals Vaelith's hidden hand in the Compact's war machine. Dame Cordwyn fights alongside the party. The victory against the Ram is rendered hollow by the Compact's overwhelming numbers. Vaelith appears for the unwinnable fight that closes Act II.
- **Difficulty:** Hard. Multi-phase boss with add waves and positional mechanics. The allied NPC (Cordwyn) must be managed.
- **Recommended Level:** 18-22
- **Estimated Play Time:** 25-35 minutes (scripted battle sequence, not a full dungeon crawl)
```

- [ ] **Step 3: Write the Ashen Ram boss stat block**

Use Pattern B format with the three phases from the spec: ranged engagement, close combat after breach, and Pallor core activation. Include Cordwyn as allied NPC, Lord Haren's tactical effects, and the Vaelith unwinnable fight trigger on defeat.

```markdown
**Boss: The Ashen Ram (10000 HP)**

A Carradan siege construct corrupted by Pallor-resonant materials -- materials woven into the design after Vaelith visited the construction yard at Ironmark. The Compact thinks the Ram is their weapon. It is Vaelith's.

**Phase 1 (10000-6000 HP): Ranged Engagement**
The Ram advances toward the walls. The party fights from the battlements.
- **Battering Advance** -- the Ram moves closer each turn. After 5 turns, it breaches the wall and Phase 2 begins. Dealing enough damage can delay this by 1 turn.
- **Despair Pulse (Passive)** -- all party members lose 5% max MP per turn from proximity to the Ram's Pallor-resonant frame.
- **Compact Escalade** -- waves of Compact soldiers scale the walls (3-4 soldiers per wave, 800 HP each). Must be managed while damaging the Ram.
- **Lord Haren's Orders** -- if the party made favorable dialogue choices with Haren earlier, he calls archer volleys (200 damage to the Ram per turn) and deploys barricades (reduce soldier wave size by 1).

**Allied NPC: Dame Cordwyn** (5000 HP, ATK 85, DEF 70)
- Fights alongside the party. Has her own turn in the ATB order.
- **Shield Wall** -- reduces damage to one party member by 50% for 1 turn.
- **Rally Cry** -- removes Despair status from all party members. 3-turn cooldown.

**Phase 2 (6000-3000 HP): The Breach**
The Ram breaches the wall. Close combat. Interior mechanisms are exposed -- organic-looking, Pallor-grey.
- **Drill Arm** -- single target, 500-600 damage.
- **Pallor Shrapnel** -- AoE cone, 300-350 damage + Pallor Touched status (ATK/DEF reduced 10% for 3 turns).
- **Engine Surge** -- the Ram charges forward, pushing party members back. 200 damage + knockback.
- Compact soldier waves continue (reduced to 2 per wave).

**Phase 3 (below 3000 HP): The Pallor Core**
The Ram's core activates. Despair Pulse intensifies to party-wide.
- **Despair Pulse (Active)** -- 250 damage to all party members + Despair status (50% chance to skip turn). Every 3 turns.
- **Core Overload** -- massive single-target attack, 800-900 damage. 2-turn charge, can be interrupted by attacking the exposed core (marked target).
- **Cordwyn nearly breaks** -- at the start of Phase 3, Cordwyn's HP drops to 25% and she staggers. Edren dialogue choice: "Stay with me, Cordwyn" (Cordwyn recovers to 50% HP and gains ATK +20 for the rest of the fight) or no action (Cordwyn fights at reduced stats).

**On defeat:** The Ram collapses. The wall is breached but the party holds the line -- momentarily. Then the Compact's overwhelming numbers press through other points. Vaelith appears in the chaos, walking calmly through the battlefield. The unwinnable fight triggers (see Vaelith Appearance 5).

**Weakness:** Storm (150% damage), Flame (125% damage to exposed core only in Phase 3).
**Resistance:** Earth (absorbs), Frost (75% damage).
**Drop:** Pallor-Laced Iron (crafting material -- unique), Compact Battle Standard (accessory -- boosts party DEF when Cordwyn or other allied NPCs are present).
```

- [ ] **Step 4: Add encounter table and update appendix**

Add an encounter table with the Ashen Ram and Compact soldiers, and add a row to the appendix summary table.

- [ ] **Step 5: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs(story): add Valdris Siege Battlefield and Ashen Ram boss"
```

---

### Task 9: Add the Ley Leech to dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md` (new section or addition to Thornmere/ley nexus content)

**Context:** The Ley Leech (9,000 HP) is fought at the largest ley nexus in the Thornmere Wilds during the Interlude, when the party finds Torren. Check if there is an existing dungeon section for this nexus; if not, create one.

- [ ] **Step 1: Search for existing ley nexus / Roothollow dungeon content**

Check if the Torren nexus area already has a dungeon entry. The spec references Roothollow and a ley nexus. Search for existing content.

- [ ] **Step 2: Create the Ley Nexus Hollow section**

If no dungeon exists for this location, create a new section. Use the standard dungeon header format. This is a single-floor boss arena, not a multi-floor dungeon:

```markdown
## [N]. Ley Nexus Hollow

### Dungeon Overview

- **Floors:** 1 (The Nexus Chamber -- a single boss arena)
- **Size:** 50x40 tiles (large circular chamber with radiating ley lines)
- **Theme:** The living heart of the Thornmere Wilds' ley network. A vast underground chamber where ley lines converge in a web of glowing energy -- now corrupted by the Ley Leech. Torren is at the center, burning his life force to hold the nexus together.
- **Narrative Purpose:** The Interlude's Torren recovery sequence. The party must defeat the Ley Leech to free Torren and stabilize the nexus. This is the first major sign that the Pallor can be pushed back. Caden guides the party here. Kael Thornwalker holds the perimeter.
- **Difficulty:** Hard. Positional mechanics on shifting ley lines. Torren unavailable until Phase 2. DPS check in Phase 3.
- **Recommended Level:** 20-24
- **Estimated Play Time:** 20-30 minutes
```

- [ ] **Step 3: Write the Ley Leech boss stat block**

Follow Pattern B with the three phases from the spec.

```markdown
**Boss: The Ley Leech (9000 HP)**

A parasitic Pallor entity latched onto the ley nexus. Unlike most Pallor manifestations (grey, static, hollow), the Leech is grotesquely alive -- swollen with stolen energy, pulsing with color that looks wrong. Vibrant where it should be grey. This is what the Pallor looks like when it is feeding well.

**Arena Mechanic: Shifting Ley Lines**
Glowing ley lines crisscross the chamber floor. Standing on an active (glowing) ley line heals 50 HP per turn. The Leech periodically corrupts ley lines (they turn grey), causing them to deal 75 damage per turn instead. Ley lines shift corruption patterns every 3 turns.

**Phase 1 (9000-4500 HP): Rooted**
The Leech is anchored to the nexus. Torren is visible in the background, struggling to maintain the ritual. The party fights at reduced strength (4 members, no Torren).
- **Tentacle Lash** -- single target, 350-400 damage. Reaches anywhere in the arena.
- **Corruption Pulse** -- corrupts 2 additional ley lines for 3 turns.
- **Siphon** -- drains 200 HP from the nexus (visual effect: ley lines dim). If used 5 times without interruption, the Leech heals 1500 HP. Interrupt by dealing 1000+ damage in a single turn.
- **Nexus Regeneration (Passive)** -- while rooted, heals 100 HP per turn from the nexus connection.

**Phase 2 (below 4500 HP): Unmoored**
Torren breaks free from the ritual and rejoins the party. The Leech detaches from the nexus and becomes mobile.
- All Phase 1 attacks except Nexus Regeneration (no longer rooted).
- **Thrash** -- AoE attack hitting all adjacent characters, 250-300 damage.
- **Leech Bite** -- single target, 300 damage + drains HP equal to damage dealt.
- Moves 2 tiles per turn. Faster and more aggressive but no longer regenerating.

**Phase 3 (below 1800 HP): Desperate Re-attachment**
The Leech tries to re-attach to the nexus. It moves toward the center of the chamber.
- If the Leech reaches the nexus center, it re-attaches and heals 30%. Phase resets to Phase 2.
- **DPS check:** the party must burn the Leech down before it roots again.
- **Torren's Spiritcall** deals 200% damage during Phase 3 (the land's energy fights back through him).
- **Death Throes** -- on defeat, the Leech releases all stolen energy. All ley lines in the chamber glow clean. Party fully healed.

**On defeat:** The nexus stabilizes. Ley lines glow clean across the chamber and extend outward into the earth. Torren collapses from exhaustion. Caden enters the chamber and performs a small recovery ritual -- kneeling beside Torren, humming a spirit-song. A passing-of-the-torch moment.

**Torren's Special Interaction:** Spiritcall deals bonus damage in all phases. In Phase 3, Spiritcall deals 200% damage. After the fight, Torren's dialogue acknowledges that the nexus responded to Caden's ritual: "He did not call the spirits. He asked the land. That is... different. That might be better."

**Weakness:** Flame (150% damage), Spirit (125% damage).
**Resistance:** Frost (50% damage), Earth (75% damage).
**Immunity:** Pallor Touched status (the Leech IS the Pallor).
**Drop:** Nexus Shard (crafting material -- component for Torren's ultimate weapon), Leech Ichor (consumable -- fully restores one character's HP and MP, single use).
```

- [ ] **Step 4: Add encounter table and appendix entry**

- [ ] **Step 5: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs(story): add Ley Nexus Hollow and Ley Leech boss"
```

---

### Task 10: Formalize the Pallor Hollow at Highcairn in dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md` (add to existing Highcairn content or create new section)

**Context:** The Pallor Hollow boss exists narratively but has no dungeon layout or stat block (IMPORTANT-03 in layout-audit.md). This task adds the mechanical definition. Note: full ASCII floor maps are out of scope for this plan -- only the boss stat block and dungeon overview are added here.

- [ ] **Step 1: Search for existing Highcairn dungeon content**

Check if Highcairn Monastery has an existing dungeon section in dungeons-world.md or dungeons-city.md.

- [ ] **Step 2: Create the Highcairn Monastery section**

If no section exists, add a new dungeon section:

```markdown
## [N]. Highcairn Monastery

### Dungeon Overview

- **Floors:** 2 (Monastery Grounds + Inner Sanctum)
- **Size:** 40x30 tiles per floor
- **Theme:** A mountain monastery saturated by the Pallor. Edren has been here alone, stewing in guilt after the fall of Valdris. The grey came out of him -- not into him. His guilt gave the Pallor permission to take shape.
- **Narrative Purpose:** The Interlude's Edren recovery sequence. The party confronts the Pallor Hollow -- a mirror-image of Edren made from his guilt. Defeating it requires Edren to face himself, not overpower the Hollow. Resolves IMPORTANT-03 from layout-audit.md.
- **Difficulty:** Hard. The Hollow uses Edren's own moveset (including player-equipped abilities). Phase 3 requires protecting guest NPC Edren.
- **Recommended Level:** 20-24
- **Estimated Play Time:** 25-35 minutes
```

- [ ] **Step 3: Write the Pallor Hollow boss stat block**

```markdown
**Boss: The Pallor Hollow (11000 HP)**

Not a monster in the traditional sense. It looks like Edren -- a grey, translucent mirror-image, but wrong. It moves like Edren. It fights like Edren. Its face is frozen in the expression Edren wore when Valdris fell.

**Dynamic Moveset:** The Hollow uses Edren's moveset from when the player last controlled him, including any abilities they had equipped. The game remembers what the player built and turns it against them.

**Phase 1 (11000-5500 HP): The Mirror**
- Uses Edren's equipped abilities against the party.
- **Mirror Counter** -- if the party uses physical attacks, the Hollow counters with physical. If magic, it counters with magic. The party must vary their approach (alternate physical and magic turns to avoid counters).
- **Grey Reflection** -- copies the last ability used against it and fires it back at the caster. 2-turn cooldown.
- **Hollow Guard** -- raises DEF by 50% for 1 turn. Uses this when the party is focused on one damage type.

**Phase 2 (5500-2750 HP): The Voice**
The Hollow speaks in Edren's voice. Lines from earlier in the game.
- All Phase 1 attacks, plus:
- **Words of Guilt** -- speaks a line Edren said earlier (to Cael, to the party, orders he gave). Each line triggers Despair status on one party member (50% chance to skip turn, 3 turns). Different lines target different characters.
- **Promise Broken** -- the Hollow repeats a promise Edren made. AoE, 400 damage + ATK/DEF reduction for 2 turns.
- **"I failed them."** -- the Hollow speaks directly. Party-wide Despair Pulse, 200 damage to all.

**Phase 3 (below 2750 HP): The Reckoning**
Edren appears from the monastery's upper floor. He enters the fight as a guest NPC (3000 HP, standard stats). The Hollow stops attacking the party and focuses entirely on Edren.
- The party must protect Edren (if his HP reaches 0, the fight resets to Phase 2 at 4000 HP).
- The Hollow uses all previous attacks but targets only Edren.
- **Resolution Mechanic:** When Edren uses the **Defend** command while the Hollow is targeting him (not attacking, just facing it), the Hollow destabilizes -- its form flickers and it takes 1500 damage. Three Defends end the fight. The player must choose to stop fighting and simply endure.

**On defeat:** The Hollow dissolves into grey mist that flows back into Edren. Not destroyed -- reclaimed. He absorbs it. Edren rejoins the party with a new passive: **Scar of the Hollow** -- max HP permanently reduced by 10%, but grants immunity to Despair status effects for the rest of the game.

**The Monastery Prior's Dialogue:** Found in the monastery, alive but grey-touched. "Your friend came to us broken. We tried to help. But the grey came out of him -- not into him, out. It was already inside. It just needed permission to take shape."

**Cordwyn's Special Interaction:** If Cordwyn is accompanying the party, she has unique dialogue at the start of Phase 1: "That is not him. But it was him. That is what he has been carrying."

**Weakness:** Spirit (150% damage), Flame (125% damage).
**Resistance:** Physical (75% damage -- the Hollow is semi-corporeal), Frost (75% damage).
**Immunity:** Void (the Hollow is made of absence).
**Drop:** Hollow Shard (accessory -- reduces Pallor-type damage by 25%), Edren's Guilt (key item -- lore item describing the previous night's memories. Triggers bonus dialogue in Act III).
```

- [ ] **Step 4: Add encounter table and appendix entry**

- [ ] **Step 5: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs(story): formalize Pallor Hollow boss at Highcairn (resolves IMPORTANT-03)"
```

---

## Chunk 4: Pallor Wastes Content

### Task 11: Add Vaelith penultimate boss to Pallor Wastes in dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md` (Pallor Wastes section)

**Context:** The Pallor Wastes section already exists in dungeons-world.md with Trial Manifestations listed. Vaelith (20,000 HP) is the penultimate boss fought after the five trials, before the Convergence. Must be added to the existing Wastes section.

- [ ] **Step 1: Read the existing Pallor Wastes section**

Find and read the full Pallor Wastes dungeon entry to understand where Vaelith's encounter should be placed.

- [ ] **Step 2: Add Vaelith boss stat block**

Add the full Vaelith boss entry to the Pallor Wastes section, placed after the Trial content and before the Convergence transition:

```markdown
**Boss: Vaelith, the Ashen Shepherd (20000 HP)**

An 800-year-old champion of Despair from the previous Pallor cycle. A scholar-diplomat who chose the Pallor willingly. Has appeared six times throughout the story -- charming, observing, feeding, fighting with one hand. Now, for the first time, the party has done something no previous cycle's heroes managed: the ley network is alive.

**The 10-Attack Threshold (Pre-Fight Phase):**
The fight begins like the previous unwinnable encounter at Valdris. Party attacks deal 0 or negligible damage. Vaelith attacks 10 times, each accompanied by taunting dialogue:
1. "Ah, you came. They always come."
2. "The spirit-speaker, the forgewright, the thief... I have seen your archetypes before."
3. "The last cycle's hero wept at this point. You are holding up rather well."
4-9. (Additional taunts referencing specific party members and events from the game)
10. "Shall we stop pretending? You cannot hurt me. No one can."

After the 10th attack, an in-battle cutscene triggers.

**In-Battle Cutscene: Lira's Weapon**
Cael's lingering connection to the party, channeled through the restored ley network, manifests as raw energy. Lira -- the Forgewright -- instinctively shapes it. She forges a weapon mid-battle from grief, love, and the living land. The weapon glows with ley-line blue threaded with grey (Cael's color). This has never happened in any previous Pallor cycle because the ley network was always dead by this point and no previous forgewright had a personal bond with the Pallor's vessel.

After the cutscene, ALL party members can damage Vaelith. The real fight begins.

**Phase 1 (20000-10000 HP): The Scholar Fights**
Vaelith uses ancient magic from a dead era. No longer dismissive -- focused.
- **Epoch's End** -- party-wide AoE, 500-600 damage. Ancient spell with no modern equivalent.
- **Grey Archive** -- single target, 700-800 damage + Silence (3 turns). Vaelith recites a fact about how the target's archetype died in a previous cycle.
- **Cycle's Weight** -- places a stacking debuff on one party member. Each stack reduces ATK/DEF by 10%. Represents the accumulated weight of failed cycles.
- **Temporal Cascade** -- Vaelith acts twice in one turn. Used every 4th turn.
- **"You are the first to draw blood in eight centuries."** -- dialogue trigger at 15000 HP.

**Phase 2 (below 10000 HP): The Shepherd Falls**
Vaelith shifts to Pallor-fueled abilities. Their form begins to destabilize -- cracks of grey light appear.
- All Phase 1 attacks, plus:
- **Despair Pulse** -- party-wide, 400 damage + Despair status (50% chance to skip turn). Every 3 turns.
- **Reality Warp** -- corrupts the ley lines the weapon draws from. Lira must re-forge the weapon (a timed input prompt -- success maintains full party damage; failure reduces party damage by 50% for 2 turns). Occurs every 5th turn.
- **Unraveling** -- Vaelith attempts to sever Cael's connection. Single target on Lira, 600 damage. If Lira falls below 25% HP, the weapon dims (party damage reduced 25% until Lira is healed above 50%).
- **"This was not in the pattern. You were not in the pattern."** -- dialogue trigger at 5000 HP.
- **"...Interesting."** -- dialogue trigger at 2000 HP.

**On defeat:** Vaelith does not die dramatically. They sit down. They look at the party -- really look, for the first time without the lens of centuries of contempt. "Eight hundred years. Every cycle, the same. And you... you actually changed something." They dissolve into grey mist. Not destroyed -- released. The eternity they chose finally ends.

**Lira's Special Interaction:** Forgewright command during Reality Warp re-forges the weapon (timed input). If Lira has the Boring Engine Schematic from the Rail Tunnels, re-forge timing window is extended by 1 second.

**Torren's Special Interaction:** Spiritcall can sense Vaelith's connection to the Pallor. During Phase 2, Spiritcall reveals Vaelith's next attack (telegraphs the move for 1 turn).

**Maren's Special Interaction:** If Maren has Pallor Sight (from her trial), she can see Vaelith's weak points. Critical hit rate doubled for all party members.

**Sable's Special Interaction:** Unbreakable Thread (from her trial) prevents Reality Tear-type effects. Sable cannot be forcibly removed from the fight.

**Weakness:** Spirit (125% damage -- Vaelith's connection to the Pallor makes spirit energy dissonant).
**Resistance:** Void (50% damage), Frost (75% damage).
**Immunity:** Despair status (Vaelith IS Despair), Instant Death.
**Drop:** Ashen Scholar's Tome (accessory -- party-wide +15% magic damage), Grey Mist Essence (crafting material -- component for Lira's ultimate weapon).
```

- [ ] **Step 3: Update the encounter table and appendix**

Add Vaelith as the final boss in the Pallor Wastes encounter table and update the appendix summary.

- [ ] **Step 4: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs(story): add Vaelith penultimate boss to Pallor Wastes"
```

---

### Task 12: Add Pallor Trial stubs to dungeons-world.md

**Files:**
- Modify: `docs/story/dungeons-world.md` (Pallor Wastes section)

**Context:** The five Pallor Trials need dungeon overview stubs in the Pallor Wastes section. NO ASCII floor maps -- those come in a follow-up session. Each stub includes: overview metadata, boss stat block, resolution mechanic, and unlock description.

- [ ] **Step 1: Add Trial 1 stub -- Edren's "Hall of Crowns"**

Add dungeon overview and boss stat block:

```markdown
### Pallor Trial 1: The Hall of Crowns (Edren)

**Floors:** 3-4 (variable shifting throne rooms)
**Theme:** Leadership guilt and survivor's guilt. Each floor is Valdris Crown in a different state of ruin.
**Enemies:** Hollow Knights -- grey echoes of Valdris soldiers who followed Edren's orders and died. Fight in formation.
**Note:** Full ASCII floor layouts will be created in a follow-up session.

**Boss: The Crowned Hollow (8000 HP)**

A towering armored figure wearing every crown of every leader who failed to stop the Pallor across history. Fights with Edren's own moveset, mirrored.

**Phase 1 (8000-2000 HP):**
- **Mirror Strike** -- uses Edren's equipped weapon attack, mirrored. Damage matches Edren's ATK stat.
- **Crown's Burden** -- AoE, 300-350 damage + ATK reduction on all party members (2 turns).
- **Formation Call** -- summons 2 Hollow Knights (1000 HP each) to fight in formation.
- **Royal Guard** -- counterattacks any physical attack with 150% damage return.

**Phase 2 (below 2000 HP): Invulnerability**
The Crowned Hollow becomes invulnerable to all damage and begins using devastating attacks:
- **Weight of Command** -- party-wide, 500 damage per turn.
- **Every Name They Carried** -- recites names of the fallen. Despair status on all party members.

**Resolution Mechanic (Cecil-type):** The ONLY way to end Phase 2 is for Edren to use the **Defend** command for 3 consecutive turns. Not attacking -- just enduring. Each Defend causes the Hollow to stagger and the ghostly soldiers in the background to lower their weapons. Third Defend ends the fight.

**Unlock:** **Steadfast Resolve** -- party-wide defensive buff that also cleanses Pallor status effects.
```

- [ ] **Step 2: Add Trial 2 stub -- Lira's "The Unfinished Forge"**

```markdown
### Pallor Trial 2: The Unfinished Forge (Lira)

**Floors:** 3-4 (shifting forge-workshop environments)
**Theme:** The need to fix everything. Puzzles involve choosing which projects to abandon.
**Enemies:** Unfinished Constructs -- machines that beg to be repaired. Repairing them wastes turns and spawns more.
**Note:** Full ASCII floor layouts will be created in a follow-up session.

**Boss: The Perfect Machine (7000 HP)**

A flawless automaton with Cael's face. Does NOT attack. Stands in the center and asks Lira to repair it.

**Mechanic:** Each "repair" action the player attempts adds 1500 HP to the boss AND triggers a counterattack:
- **Hopeful Spark** -- 400 damage to Lira + "Almost... try again." dialogue.
- **False Promise** -- heals Perfect Machine to current HP + 1500, party-wide 200 damage.
- Standard attacks deal normal damage, but the boss has high DEF (halves physical damage).

**Resolution Mechanic:** Lira must use her Forgewright command to select **Dismantle** (a unique option that appears only in this fight) instead of her normal Forgewright abilities. Dismantling deals 3500 damage per use and triggers dialogue: "I cannot fix you. I could not fix him. That was never my job." Two Dismantles end the fight.

**Unlock:** Latent ability -- a faint glow in Lira's hands. She forged something from grief instead of metal. This is the prerequisite for manifesting Cael's connection as a weapon against Vaelith.
```

- [ ] **Step 3: Add Trial 3 stub -- Torren's "The Silent Grove"**

```markdown
### Pallor Trial 3: The Silent Grove (Torren)

**Floors:** 2-3 (petrified forest with diminishing ambient sound)
**Theme:** The old ways are dying. Puzzles involve following the last remaining sounds on each floor.
**Enemies:** Stone Spirits -- petrified nature spirits that animate on approach. Cannot speak.
**Note:** Full ASCII floor layouts will be created in a follow-up session.

**Boss: The Last Voice (6000 HP)**

An ancient Great Spirit, massive and beautiful, cracked through with grey stone. Barely alive. Speaks in fragments. Asks Torren to let it rest.

**Phase 1 (6000-1500 HP):**
- **Stone Grasp** -- single target, 350 damage + Slow status (2 turns).
- **Silent Scream** -- AoE, 250 damage + Silence (2 turns). No sound accompanies the attack.
- **Crumbling Form** -- the Spirit loses HP passively (100 per turn). It is dying regardless of the party's actions.

**Phase 2 (below 1500 HP): The Request**
The Last Voice speaks clearly for the first time: "Let me go." Standard attacks still work but deal reduced damage (the Spirit is barely holding together).

**Resolution Mechanic:** Torren must use Spiritcall and select **Release** (a unique option replacing "Call" in this fight). One Release ends the fight. The Great Spirit dies peacefully. The forest remains stone, but a single green shoot appears.

**Unlock:** **Rootsong** -- healing ability that restores HP and MP, drawing from the ley network. Represents speaking for the land itself, not to spirits.
```

- [ ] **Step 4: Add Trial 4 stub -- Sable's "The Crooked Mile"**

```markdown
### Pallor Trial 4: The Crooked Mile (Sable)

**Floors:** 1-2 (twisting alleyways that loop back)
**Theme:** Trust and abandonment. Doors lead to rooms where party members are in danger -- all traps.
**Enemies:** Shadows of Sable -- copies using her Tricks moveset. Fast, evasive. Taunt: "You always leave."
**Note:** Full ASCII floor layouts will be created in a follow-up session.

**Boss: The Open Door (no HP -- not a combat encounter)**

A literal door at the end of the alley, standing open. Warm light, no enemies, freedom. The Shadows of Sable urge her through.

**Resolution Mechanic:** There is no combat. The player must navigate Sable to **turn around and walk back** into the alley -- away from safety, toward the party. This is a movement choice, not a menu command. Walking through the door triggers a false ending and resets the trial. Walking back closes the door. The shadows vanish. Sable says nothing. She just walks back.

**Unlock:** **Unbreakable Thread** -- passive ability preventing Sable from being forcibly removed from battle (counters the Pallor Incarnate's Reality Tear).
```

- [ ] **Step 5: Add Trial 5 stub -- Maren's "The Restricted Stacks"**

```markdown
### Pallor Trial 5: The Restricted Stacks (Maren)

**Floors:** 2-3 (infinite library flooding with grey light)
**Theme:** Knowledge as emotional armor. Reading books grants tactical info but triggers emotional debuffs.
**Enemies:** Archived -- humanoid figures of compressed pages. Attack with factual recitations of how they died.
**Note:** Full ASCII floor layouts will be created in a follow-up session.

**Boss: The Index (7000 HP)**

A vast catalogue entity containing every recorded death from every Pallor cycle. Does not fight conventionally.

**Mechanic:** The Index presents a binary choice:
- **Absorb** -- Maren gains complete Pallor knowledge (massive INT buff) but takes 90% max HP damage and permanent Despair status.
- **Destroy** -- the Index is destroyed (instant kill) but Maren loses all INT buffs gained from reading books in the trial and a unique lore item is lost.

Neither option is correct.

**Resolution Mechanic:** Maren must select **Read One Entry** (a third option that appears if the player examines the Index instead of choosing Absorb or Destroy). Maren reads a single entry -- one person, not a dataset -- and grieves for them individually. The Index shatters because it was built on the premise that people are data. One person mourned breaks its logic.

**Unlock:** **Pallor Sight** -- Maren can see Pallor corruption levels on enemies and objects, revealing hidden weaknesses during the Vaelith fight and the Convergence.
```

- [ ] **Step 6: Add a note that ASCII maps are pending**

At the top of the trial section, add: `**Note:** Full ASCII floor layouts for all five trials will be created in a follow-up session.`

- [ ] **Step 7: Commit**

```bash
git add docs/story/dungeons-world.md
git commit -m "docs(story): add Pallor Trial dungeon stubs with boss stat blocks"
```

---

## Chunk 5: Sidequest Boss Additions

### Task 13: Add boss encounters to sidequests.md

**Files:**
- Modify: `docs/story/sidequests.md`

**Context:** Four existing sidequests gain boss encounters. The sidequest entries need to be updated to reference the new bosses, adjusted rewards, and modified narrative arcs where necessary. Do NOT replace existing content -- extend it.

- [ ] **Step 1: Read the four target sidequest entries**

Read quests #4 (The Spirit That Stopped Singing), #5 (The Missing Patrol -- minor quest), #10 (Unbowed), and #1 (The Fading Shifts) in their current form.

- [ ] **Step 2: Update "The Spirit That Stopped Singing" (quest #4)**

Add the Howling Gale boss encounter to the narrative arc. The boss appears at Windshear Peak during the existing quest flow, before the Roothollow resolution. Add the peaceful vs. combat resolution options and the connection to the Frost Warden. Preserve the existing Elara Thane focus.

- [ ] **Step 3: Update "The Missing Patrol" (MINOR quest section, quest #5 -- NOT in the Major Side Quests section)**

Formalize the grey-elk as the Grey Stag boss (5,500 HP). Add boss-level description, the surviving patrol member NPC, and the NPC's later appearance at the siege. This quest is in the `### Minor Quests` subsection of sidequests.md, not the `### Major Side Quests` section.

- [ ] **Step 4: Update "Unbowed" (minor quest #10)**

Add the Pallor Nest Mother boss (6,000 HP) as a capstone encounter. Add Kerra as a guest NPC. Preserve Sera Linn's role and the Caldera setting.

- [ ] **Step 5: Update "The Fading Shifts" (quest #1)**

Elevate the Ley Rupture Guardian to the Forge Warden boss (8,500 HP). Update the narrative to connect Forgemaster Drayce's engineering and Lira's unique dialogue. Add the Vaelith tuning fork breadcrumb.

- [ ] **Step 6: Commit**

```bash
git add docs/story/sidequests.md
git commit -m "docs(story): add boss encounters to four existing sidequests"
```

---

### Task 14: Add sidequest boss stat blocks to dungeons-world.md and dungeons-city.md

**Files:**
- Modify: `docs/story/dungeons-world.md` (add boss stat blocks to relevant dungeon sections)

**Context:** The four sidequest bosses need Pattern B stat blocks added to the dungeon sections where they are encountered. The Howling Gale goes in or near the Frostcap Caverns / Windshear Peak section. The Grey Stag needs a brief encounter area. The Forge Warden goes in the Ashmark Factory Depths section. The Pallor Nest Mother goes in Caldera undercity content (may be in dungeons-city.md instead).

- [ ] **Step 1: Locate the target dungeon sections**

Search dungeons-world.md for Windshear Peak (section #12), Ashmark Factory Depths, and the highland forest patrol area. Check dungeons-city.md for Caldera undercity content (the "Unbowed" tunnels are in dungeons-city.md).

- [ ] **Step 2: Add the Howling Gale stat block (7,000 HP)**

Place in the **Windshear Peak section (#12)** of dungeons-world.md. This is where the Spirit That Stopped Singing quest takes the party. Include the Spiritcall peaceful resolution mechanic at 30% HP.

- [ ] **Step 3: Add the Grey Stag stat block (5,500 HP)**

Place in the highland/forest area relevant to the Missing Patrol quest. Brief encounter area if no dungeon exists.

- [ ] **Step 4: Add the Forge Warden stat block (8,500 HP)**

Place in the Ashmark Factory Depths section, replacing or upgrading the existing Ley Rupture Guardian entry. Include Lira's unique dialogue and Drayce connection.

- [ ] **Step 5: Add the Pallor Nest Mother stat block (6,000 HP)**

Check dungeons-city.md for Caldera undercity tunnels. Add the Nest Mother with spawning mechanics and Kerra guest NPC.

- [ ] **Step 6: Update encounter tables and appendix entries**

- [ ] **Step 7: Commit**

```bash
git add docs/story/dungeons-world.md docs/story/dungeons-city.md
git commit -m "docs(story): add sidequest boss stat blocks to dungeon docs"
```

---

## Chunk 6: Environmental Storytelling

### Task 15: Add lore breadcrumbs to location-relevant docs

**Files:**
- Modify: `docs/story/dungeons-world.md` (artifacts in dungeon floor descriptions)
- Modify: `docs/story/dungeons-city.md` (artifacts in city dungeon descriptions)
- Modify: `docs/story/locations.md` (if location entries reference discoverable items)

**Context:** Seven physical artifacts and five NPC dialogue breadcrumbs need to be placed in specific locations across the game world. Artifacts go into dungeon floor Key Locations lists. NPC dialogue goes into npcs.md entries or location descriptions.

- [ ] **Step 1: Add Two Grey Teacups to Ember Vein, Duskfen, and Ashmark**

In the Key Locations for the relevant floors, add the teacup artifact as a discoverable item with Torren's identification dialogue.

- [ ] **Step 2: Add the Faded Portrait to Valdris Crown**

Check dungeons-city.md or locations.md for Valdris Crown interior descriptions. Add the portrait to a forgotten gallery corridor with Maren's examination dialogue.

- [ ] **Step 3: Add Carved Sigils to Corrund, Bellhaven, and Caldera**

Add the knee-height sigil artifacts to doorframe descriptions in city dungeon or location entries. Include Maren's identification.

- [ ] **Step 4: Add Scholar's Journal fragments to 6-7 locations**

Place journal pages in: Thornvein Passage, Archive of Ages, Dry Well of Aelhart, Ley Line Depths, Frostcap Caverns, and the **Pallor Wastes** (just before the Vaelith encounter). Each page has a different dated observation in archaic script. Torren and Maren together can translate. Example fragments:
- "The spirit-speakers fell first. They always do."
- "The forgewright built a weapon. It failed."
- "The hero stood at the door and wept. They all weep."
- **The FINAL fragment (Pallor Wastes, mandatory placement):** "This cycle has a forgewright who loves the vessel. That is new. I wonder if it will matter." -- This is the most narratively important fragment. It must be found just before the Vaelith encounter to maximize the payoff when Lira's weapon manifests.

- [ ] **Step 5: Add the Pressed Flower to the Archive of Ages**

Add to the Archive's Key Locations as a discoverable item inside a book.

- [ ] **Step 6: Add the Grey Thread Embroidery to a Corrund tavern**

Add to the Corrund location description or city dungeon interior.

- [ ] **Step 7: Add the Tuning Fork to Ley Line Depths**

Add to the Ley Line Depths floor where destabilized nodes are present. Include Torren's recoil and Lira's craftsmanship observation.

- [ ] **Step 8: Commit**

```bash
git add docs/story/dungeons-world.md docs/story/dungeons-city.md docs/story/locations.md
git commit -m "docs(story): place Vaelith lore breadcrumb artifacts across locations"
```

---

### Task 16: Add NPC dialogue breadcrumbs to npcs.md

**Files:**
- Modify: `docs/story/npcs.md`

**Context:** Five NPCs need additional dialogue hints and act presence updates to reference Vaelith's passage. These are existing NPCs whose entries need extension, not new NPCs.

- [ ] **Step 1: Read existing entries for the five NPCs**

Find and read the current entries for: the Valdris Crown innkeeper (or create one if none exists), a Thornmere herbalist, a Carradan archivist in Corrund, Riven, and Brant.

- [ ] **Step 2: Add breadcrumb dialogue to each NPC**

For each NPC, add a new dialogue hint referencing the "grey stranger" / "charming scholar" / Vaelith's passage, and update their Act presence to note when this dialogue becomes available. Use the exact dialogue lines from the spec's NPC Dialogue Breadcrumbs table.

- [ ] **Step 3: Add the second operator NPC (Bellhaven)**

Add a new NPC entry for the second boring engine operator -- the one who fled when the Ironbound was created. Located in Bellhaven, guilt-ridden, drinking. Triggered by the Operator's Badge key item from the Ironbound fight.

- [ ] **Step 4: Add the Carradan engineer NPC (Ironmark)**

Add a new NPC entry for the engineer who notices the Ashen Ram's altered alloy specs. Located in Ironmark, post-siege.

- [ ] **Step 5: Add the patrol survivor NPC**

Add a new NPC entry for the Missing Patrol survivor found in the cave. Later joins the Valdris militia and appears during the siege.

- [ ] **Step 6: Commit**

```bash
git add docs/story/npcs.md
git commit -m "docs(story): add Vaelith breadcrumb dialogue and supporting NPCs"
```

---

### Task 17: Update dynamic-world.md with Vaelith's influence

**Files:**
- Modify: `docs/story/dynamic-world.md`

**Context:** Vaelith's presence affects how locations transform across acts. The Pallor's visual progression section should reference Vaelith as an active agent accelerating corruption. Several locations' act-by-act state changes should note Vaelith's passing.

- [ ] **Step 1: Read dynamic-world.md structure**

Read the file to identify which location entries and which act states should reference Vaelith.

- [ ] **Step 2: Add Vaelith references to location act states**

For locations where Vaelith has been (Ember Vein surroundings, Corrund/Bellhaven, Valdris Crown, ley nexus areas), add notes to the relevant act state entries about subtle signs of Vaelith's passage (the carved sigils, the teacups, NPC references to a "grey stranger").

- [ ] **Step 3: Update the Pallor's Visual Progression section**

Add a note distinguishing natural Pallor spread from Vaelith-accelerated corruption. Locations Vaelith has visited show corruption progressing faster.

- [ ] **Step 4: Commit**

```bash
git add docs/story/dynamic-world.md
git commit -m "docs(story): add Vaelith's influence to dynamic world state changes"
```

---

### Task 18: Final cross-reference verification pass

**Files:**
- Read (no modify): all files touched in previous tasks

**Context:** After all content is added, do a final verification that all cross-references are consistent -- NPC names match across files, boss HP values are consistent, event flags reference the correct bosses, and the foreshadowing/payoff map entries resolve correctly.

- [ ] **Step 1: Verify Vaelith references across all files**

Grep for "Vaelith" across all story docs. Confirm consistent naming, HP value (20,000), and appearance numbering.

- [ ] **Step 2: Verify new NPC names across all files**

Grep for "Caden", "Kerra", "Ironbound", "Ashen Ram", "Ley Leech", "Pallor Hollow", "Howling Gale", "Grey Stag", "Forge Warden", "Pallor Nest Mother" -- confirm each appears in all expected files.

- [ ] **Step 3: Verify event flags reference correct triggers**

Read the new event flags and confirm each trigger condition matches the boss it references.

- [ ] **Step 4: Verify the appendix summary table is complete**

Check that every new dungeon section has a corresponding row in the dungeons-world.md appendix.

- [ ] **Step 5: File any discovered inconsistencies as beads issues**

If any cross-reference issues are found, fix them immediately or file a beads issue for follow-up.

- [ ] **Step 6: Final commit if any fixes were needed**

```bash
git add docs/story/
git commit -m "docs(story): cross-reference verification fixes for boss deep pass"
```

---

## Task Dependency Map

```
Chunk 1 (Character Setup):
  Task 1 (Vaelith characters.md) ─┐
  Task 2 (Vaelith npcs.md) ───────┤── All independent, can run in parallel
  Task 3 (Caden npcs.md) ─────────┤
  Task 4 (Kerra npcs.md) ─────────┘

Chunk 2 (Story Integration):
  Task 5 (outline.md) ──── depends on Task 1 (Vaelith defined)
  Task 6 (events.md) ───── depends on Task 1 (Vaelith defined); boss names are hardcoded in the plan

Chunk 3 (Dungeon Bosses):
  Task 7 (Ironbound) ─────┐
  Task 8 (Ashen Ram) ─────┤── All independent, can run in parallel
  Task 9 (Ley Leech) ─────┤
  Task 10 (Pallor Hollow) ─┘

Chunk 4 (Pallor Wastes):
  Task 11 (Vaelith boss) ── depends on Task 1 (Vaelith defined)
  Task 12 (Trial stubs) ─── independent

Chunk 5 (Sidequests):
  Task 13 (sidequests.md) ── depends on Tasks 7-10 (boss stat blocks exist)
  Task 14 (dungeon stat blocks) ── independent

Chunk 6 (Environmental):
  Task 15 (lore artifacts) ── depends on Tasks 7-10 (dungeon sections exist)
  Task 16 (NPC dialogue) ─── depends on Tasks 2, 4 (NPCs exist)
  Task 17 (dynamic-world) ── depends on Task 1 (Vaelith defined)
  Task 18 (verification) ─── depends on ALL previous tasks
```

**Parallelization opportunities:**
- Tasks 1, 2, 3, 4 can all run in parallel (Chunk 1)
- Tasks 5, 6, and 17 can run in parallel after Task 1 completes (all depend only on Vaelith being defined)
- Tasks 7, 8, 9, 10 can all run in parallel (Chunk 3)
- Tasks 11 and 12 can run in parallel (Chunk 4)
- Task 18 must run last
