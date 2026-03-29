# Act II Part 1: The Fraying — Diplomacy

> Hope kindles. The party rides out to secure alliances while Cael
> stays behind with the Pendulum and his nightmares. Every success
> is genuine. Every success is also the Pallor's work — the world
> building trust just before the floor drops out. The diplomatic arc
> is the game's longest stretch of unbroken optimism, which makes
> what follows unbearable.
>
> **Scenes:** 8 | **Layer:** 1 (Narrative Spine)
>
> **Navigation:** [← Act I](act-i.md) |
> [Act II Part 2 →](act-ii-part-2.md) | [README](README.md)
>
> **Related docs:** [outline.md](../outline.md) Act II |
> [events.md](../events.md) flags 7--14, 40--43, 54 |
> [locations.md](../locations.md) |
> [npcs.md](../npcs.md) |
> [sidequests.md](../sidequests.md) § Ley Stag

---

## Scene 8: The Diplomatic Mission

<!-- Scene: diplomatic_mission | Tier: 2 | Trigger: diplomatic_mission_start (flag 8) -->
<!-- Location: Valdris Crown, Throne Hall | Party: all six -->
<!-- Variants: none -->
<!-- Cross-ref: outline.md § Act II Diplomatic Mission, events.md flag 8 -->

*(Throne hall. King Aldren stands at the strategic table. A map
of the Thornmere Wilds is spread before him — three tribal
settlements marked in ink. Dame Cordwyn stands at his right.
The full party is assembled.)*

**KING ALDREN** : The ley lines are failing faster than Aldis
projected. The Compact has taken two more border towns. And now
we have an artifact in our vaults that my court mage tells me is
a door to something that feeds on despair.

*(He looks at the map.)*

**KING ALDREN** : We need allies. The Thornmere tribes have never
committed to a formal alliance with Valdris, but if the ley lines
threaten their forests, they may listen.

**EDREN** : The tribes won't negotiate with soldiers.

**TORREN** : They'll negotiate with me. I'm one of them. But
I'll need the rest of you — Valdris needs to show up in person,
not through messengers.

**KING ALDREN** : Then go. Sable — I'd like you to stay. Keep an
eye on things here. Particularly on Cael's research.

**SABLE** : Keep an eye on Cael. Got it.

*(The king's tone softens.)*

**KING ALDREN** : He's been working long hours. Aldis says his
questions are... unusual. Make sure he eats. Make sure he sleeps.

**SABLE** : I'll try. He doesn't always listen.

*(Flag `diplomatic_mission_start` (8) set. Sable stays in Valdris.
Party departs for the Wilds.)*

---

## Scene 9: Duskfen — Spirit-speaker Caden

<!-- Scene: duskfen_alliance | Tier: 3 | Trigger: party reaches Duskfen -->
<!-- Location: Duskfen settlement / Fenmother's Hollow | Party: Edren, Lira, Torren, Maren -->
<!-- Variants: none -->
<!-- Cross-ref: outline.md § Act II Duskfen Alliance, locations.md § Duskfen, npcs.md § Caden -->

### 9a. Duskfen Arrival

*(Duskfen. Reed platforms over black water, connected by rope
bridges. Will-o'-wisp lanterns flicker unreliably. The settlement
is insular, suspicious, quiet. Caden — young, barely into his
twenties, eyes too old for his face — meets them at the bridge.)*

**CADEN** : Torren. You bring outsiders to Duskfen.

**TORREN** : I bring people who need help. And who can offer it.

**CADEN** : The Fenmother is sick. The hollow is poisoned. Our
binding rituals fail. We don't have time for politics.

**EDREN** : We're not here for politics. We're here because the
ley lines are dying, and that affects all of us.

**CADEN** : The ley lines? The Fenmother is screaming. The water
tastes of metal. My predecessor walked into the marsh three months
ago and never came back. Don't talk to me about ley lines. Talk
to me about the thing that's killing my home.

**LIRA** : Show us.

### 9b. Fenmother's Hollow

*(The submerged ruin. Corridors half-flooded, ancient stone
predating the tribes. Ley energy runs through the walls in sick
grey-green veins. The water is discolored. Dead aquatic life
floats at the edges.)*

*(After clearing the dungeon and cleansing the Fenmother — a
corrupted water spirit restored, not killed:)*

**CADEN** : You cleansed her. Not killed — cleansed. That matters.

*(He looks at Torren differently now.)*

**CADEN** : The spirit-speakers at Roothollow will want to hear
of this. Return to Vessa when you can.

**EDREN** : Will Duskfen support an alliance?

**CADEN** : The Fenmother was poisoned by what's seeping through
the ley lines. If you can cleanse this, you understand what we're
facing. I'll speak for Duskfen at the council.

*(Flag `duskfen_alliance` (9) set.)*

---

## Scene 10: Canopy Reach — Wynne

<!-- Scene: canopy_alliance | Tier: 1+3 | Trigger: party reaches Canopy Reach -->
<!-- Location: Canopy Reach / Observatory | Party: Edren, Lira, Torren, Maren -->
<!-- Variants: none -->
<!-- Cross-ref: outline.md § Act II Canopy Reach, locations.md § Canopy Reach, npcs.md § Wynne -->

### 10a. Canopy Reach

*(Treetop settlement. Vertical architecture — ladders, bridges,
platforms ascending through ancient canopy. At the highest level,
Wynne's observatory opens to the sky. She is practical, direct,
and has been watching the horizon for months.)*

**WYNNE** : Valdris sends a knight and a spirit-speaker to ask
for our bows. That's new. Usually they send a letter.

**EDREN** : Letters aren't working.

**WYNNE** : No. They aren't. Come up to the observatory. I want
to show you something.

### 10b. The Panoramic View

*(The observatory platform. The highest point in the Wilds. The
continent stretches in every direction — Valdris Crown's pale
towers to the northwest, Corrund's smoke plumes to the southeast,
rolling forest and farmland between. And dead center, on the
horizon:)*

*(A faint grey haze. Not clouds. Something else. Sitting where
the ley lines converge.)*

**WYNNE** : I've watched that haze grow for six months. It sits
where the ley lines meet. I don't need your scholars to tell me
what that means.

**LIRA** : The Convergence. Where the major ley lines intersect.

**WYNNE** : The wind-spirits are agitated. They feel something
below the canopy that they won't name. When spirits refuse to
name a thing, you should be afraid.

*(She turns to Edren.)*

**WYNNE** : You want an alliance. Fine. But I don't ally with
weakness. Show me Valdris has a plan beyond "hope the ley lines
stabilize." Show me at the council, and you'll have Canopy
Reach's bows.

*(Flag `canopy_alliance` (10) set.)*

---

## Scene 11: The Ley Stag

<!-- Scene: ley_stag_bonding | Tier: 2 | Trigger: optional, at Roothollow heartwood shrine -->
<!-- Location: Roothollow | Party: Edren, Lira, Torren, Maren -->
<!-- Variants: none (optional scene) -->
<!-- Cross-ref: sidequests.md § Ley Stag, events.md flag 54 -->

*(Roothollow. The heartwood shrine. Vessa performs a spirit-bonding
ritual at the great tree's root-altar. Torren stands beside her.
The ley energy beneath the tree pulses — warm gold.)*

*(From the deeper roots, a shape emerges. A stag — tall, antlers
traced with faint ley light, eyes ancient and calm. It steps into
the clearing and stops before Torren.)*

**VESSA** : The stag chose. It doesn't always choose. Count
yourself fortunate.

**TORREN** : It's not fortune. It's need. The Wilds are hurting,
and the stag knows it.

*(The stag lowers its head. Torren places his hand on its brow.
Ley light flows between them — a bond, visible and warm.)*

**LIRA** : It's beautiful.

**TORREN** : It's a responsibility. The stag isn't a tool. It's
the forest's answer to a question we haven't finished asking.

*(Flag `stag_bonded` (54) set. Ley Stag available as mount.)*

---

## Scene 12: The Thornmere Council

<!-- Scene: thornmere_council | Tier: 3 | Trigger: party reaches Ashgrove after alliances -->
<!-- Location: Ashgrove council stones | Party: Edren, Lira, Torren, Maren -->
<!-- Variants: council approval scores (flags 40-42) determine outcome (flag 43) -->
<!-- Cross-ref: outline.md § Act II Thornmere Council, events.md flags 40-43, npcs.md § Savanh/Caden/Wynne -->

### 12a. Ashgrove

*(Ashgrove. A perfect circle of clearing in the deep forest —
half a mile across, open to the sky. The ground is pale ash from
the First Tree that burned in an age no one remembers. Nothing
grows in the ash. Footprints are preserved perfectly — a thousand
years of tribal history pressed into the ground.)*

*(Standing stones ring the center. Three leaders wait. Temporary
shelters dot the clearing's edge. This is where the Thornmere
decides.)*

### 12b. Private Audience — Elder Savanh

<!-- Cross-ref: npcs.md § Elder Savanh, events.md flag 40 -->

*(A firepit near the eastern stones. Elder Savanh sits cross-legged,
watching the party approach. She does not stand.)*

**SAVANH** : Sit. I have questions before I have answers.

**SAVANH** : The Wilds have stayed alive by staying out of other
people's wars. You're asking us to change that. Tell me why.

> **Choice: "The ley lines affect everyone. Neutrality requires a
> stable world."** → `council_savanh_approval` +2

> **Choice: "Valdris and the Wilds share a border. If we fall, the
> Compact comes for you next."** → `council_savanh_approval` +1

> **Choice: "We need your warriors. Valdris can't hold alone."**
> → `council_savanh_approval` +0

(If player chose option 1.)
*(Savanh [nod]. Slow, considered.)*

**SAVANH** : The Wilds have never needed Valdris. But you're right
— the Wilds need the ley lines, and the ley lines don't care
about borders.

(If player chose option 2.)
**SAVANH** : Don't threaten me with the Compact. But... you're not
wrong that they would come.

(If player chose option 3.)
**SAVANH** : At least you're honest about what you want. That's
worth something. Not much, but something.

(If player consulted Grandmother Seyth before this meeting.)

**SAVANH** : You spoke with Seyth. She told you about the grey
times.

**EDREN** : She said the world has faced this before. A door opens.
Someone closes it. The cost is always the same.

*(Savanh is silent for a long time.)*

**SAVANH** : My grandmother told Seyth that story. And her
grandmother told her. We don't speak of it often. It's not a story
that ends well.

> **Choice: "This time doesn't have to end the same way."**
> → `council_savanh_approval` +1 (bonus, only available via Seyth)

### 12c. Private Audience — Spirit-speaker Caden

<!-- Cross-ref: npcs.md § Caden, events.md flag 41 -->

*(The western stones. Caden sits with Torren. Their rapport is
visible — two spirit-speakers, one established, one finding his
footing.)*

**CADEN** : You cleansed the Fenmother. Duskfen owes you. But
alliance is more than debt.

**CADEN** : The spirits know what the Pendulum is. They've been
screaming about it since it came into the Wilds. The question is
whether Valdris is ready to listen.

> **Choice: "We're listening. That's why Torren is here."**
> → `council_caden_approval` +2

> **Choice: "We need spiritual guidance as much as warriors."**
> → `council_caden_approval` +1

> **Choice: "The spirits can scream all they want. We need
> soldiers."** → `council_caden_approval` +0

(If player chose option 1.)
*(Caden looks at Torren. Torren [nod].)*

**CADEN** : Torren trusts you. That's rare from him. You'll have
Duskfen's voice at the council.

(If player chose option 3.)
*(Caden's face closes.)*

**CADEN** : Then you've learned nothing from the Fenmother's Hollow.

### 12d. Private Audience — Wynne

<!-- Cross-ref: npcs.md § Wynne, events.md flag 42 -->

*(The northern stones. Wynne stands, arms crossed. She doesn't
sit for negotiations.)*

**WYNNE** : I showed you the haze. You know what's coming. So
tell me — what's the plan?

> **Choice: "Contain the Pendulum, reinforce the ley wards,
> prepare for a siege."** → `council_wynne_approval` +2

> **Choice: "We don't have a full plan yet. But we have people
> willing to fight."** → `council_wynne_approval` +1

> **Choice: "The plan is to survive. Plans can come after."**
> → `council_wynne_approval` +0

(If player chose option 1.)

**WYNNE** : Specifics. Finally. You're the first person from
Valdris who's told me something I can act on.

(If `party_has(lira)`.)
**WYNNE** : Your Forgewright — Lira. Her people damaged the ley
lines. But she understands the systems better than anyone. If she
can help reinforce the wards, Canopy Reach will commit.

**LIRA** : I can. The extraction damage is reversible with the
right alignment. It's slower than what the Compact does, but it
doesn't break anything.

### 12e. The Council Fire

*(Night. The three leaders gather at the central stones. Torches
burn in a ring. The party stands at the center. The clearing is
full — tribal members watching from the edges.)*

**SAVANH** : We've heard the arguments. Now we decide. Each
leader speaks for their people.

*(Each leader votes based on their approval score.)*

(If `council_savanh_approval` >= 2.)
**SAVANH** : Greywood stands with Valdris. Not for Valdris — for
the ley lines that sustain us all.

(If `council_savanh_approval` < 2.)
**SAVANH** : Greywood will not commit. The risk is too great for
promises alone.

(If `council_caden_approval` >= 2.)
**CADEN** : Duskfen stands. The spirits have spoken. We follow.

(If `council_caden_approval` < 2.)
**CADEN** : Duskfen cannot commit. We barely survived the
Fenmother's illness. We have nothing left to give.

(If `council_wynne_approval` >= 2.)
**WYNNE** : Canopy Reach commits its archers and scouts. Show me
the haze stops growing, and we stay.

(If `council_wynne_approval` < 2.)
**WYNNE** : Canopy Reach will watch. That's all I can promise.

*(Flag `council_result` (43) set. `tribal_alliance_complete` (11)
set regardless of outcome.)*

---

## Scene 13: The Tavern — Vaelith Returns

<!-- Scene: vaelith_tavern | Tier: 3 | Trigger: vaelith_tavern_encounter (flag 13) -->
<!-- Location: Frontier tavern (Corrund road or Bellhaven) | Party: Edren, Lira, Torren, Maren -->
<!-- Variants: none -->
<!-- Cross-ref: outline.md § Act II Tavern Encounter, npcs.md § Vaelith -->

*(A frontier tavern. The party stops for the night on the road
back to Valdris. The room is warm, the ale is thin, the locals
are quiet. A familiar figure sits at the corner table — grey
cloak, calm eyes, a drink barely touched.)*

*(Vaelith. They smile when the party enters.)*

**VAELITH** : What a pleasant surprise. I didn't expect to see
you again so soon.

**EDREN** : Vaelith. The scholar from the mine.

**VAELITH** : I'm flattered you remember. Please, sit. The house
ale is dreadful, but the company is much improved.

*(The party sits. Vaelith is charming, warm, genuinely interested.
Nothing about this feels dangerous. That's the danger.)*

**VAELITH** : I hear you've been busy. Tribal alliances, spirit
rituals, an audience with three leaders at once. Impressive work
for a kingdom on its heels.

**LIRA** : How do you know about the council?

**VAELITH** : People talk. I listen. It's my one real talent.

*(A beat. Vaelith turns to Lira.)*

**VAELITH** : Your friend with the heavy eyes. Cael, was it? How
is he sleeping these days?

*(Lira [bubble_question]. The question is casual. Too casual.)*

**LIRA** : Fine. Why?

**VAELITH** : No reason. Old ruins do strange things to
sensitive minds. I've studied enough of them to know.

*(Vaelith finishes their drink. Stands. Bows.)*

**VAELITH** : Safe travels to Valdris. I do hope the king
appreciates what you've done. Good allies are hard to find.

*(They leave. The door closes. The room feels colder.)*

*(Flag `vaelith_tavern_encounter` (13) set.)*

---

## Scene 14: Vaelith's Doma Moment

<!-- Scene: vaelith_doma | Tier: 1 | Trigger: automatic, mid-Act II (flag 14) -->
<!-- Location: Pallor-touched village | Party: none (dramatic irony cutscene) -->
<!-- Variants: none -->
<!-- Cross-ref: outline.md § Act II Vaelith's Work, npcs.md § Vaelith -->

*(Cutscene. The party is not present. The player watches.)*

*(A small village at the edge of the Wilds. Grey has crept into
the stonework. The villagers move slowly, listlessly. A woman
sits on a doorstep, staring at nothing. A child stands in the
road, motionless.)*

*(Vaelith walks among them. Grey cloak. Gentle hands. They kneel
beside the woman on the doorstep.)*

**VAELITH** : You've been carrying this a long time.

*(The woman looks up. Her eyes are glassy.)*

**VILLAGER** : My husband. The ley surge took our farm. He just...
stopped. Sat down one morning and didn't stand up again.

**VAELITH** : I understand. Grief like that doesn't ask permission.
It just arrives.

*(Vaelith places a hand on her shoulder. Their expression is
genuine — real warmth, real empathy. The woman's breathing slows.
Her shoulders relax. Something releases.)*

*(But as the tension leaves her face, the grey in her eyes
deepens. Not pain. Surrender. The comfort is real, and so is
what it costs — the quiet slide from grief into acceptance into
emptiness.)*

*(Vaelith stands. Moves to the next villager. The same gentle
touch. The same quiet words. The same deepening grey.)*

*(The camera pulls back. The village is still. Peaceful. Empty.)*

*(Flag `vaelith_doma_moment` (14) set.)*

---

## Scene 15: Sable's Warning

<!-- Scene: sable_warning | Tier: 2 | Trigger: party returns to Valdris (flag 12) -->
<!-- Location: Valdris Crown, Lower Ward → Keep | Party: reunited -->
<!-- Variants: none -->
<!-- Cross-ref: outline.md § Act II Sable's Warning, events.md flag 12 -->

*(Valdris Crown. The party returns from the Wilds to find the
city tenser — fewer ley-lamps lit, more soldiers on the walls,
a nervousness in the market vendors' voices. Sable meets them
at the inner gate.)*

**SABLE** : We need to talk. Not here.

*(She leads them to a quiet alcove in the Keep. Checks both
directions. Lowers her voice.)*

**SABLE** : Something's wrong with Cael. He's not sleeping. He's
barely eating. He spends every night in the vault with the
Pendulum. And when he does come out, he asks questions.

**EDREN** : What kind of questions?

**SABLE** : He asked Aldis about historical cases of grief being
"cured." That's not academic. He asked Maren's old notes about
the Pallor's previous offers — what it promised, what it wanted.

**MAREN** : He shouldn't have access to those notes.

**SABLE** : He doesn't. He broke the ward on your study. Aldis
found the breach but didn't report it — she thought it was a
research emergency.

*(Sable [sweat_drop]. She's not joking.)*

**SABLE** : I tried to talk to him. He said he was fine. He said
it three times. People who are fine don't say it three times.

**LIRA** : I'll talk to him.

**SABLE** : It's worse than that. Renn heard something from her
contacts — the Compact is moving troops. Not border probes.
Organized columns, heading for Valdris.

**EDREN** : When?

**SABLE** : Soon. Maybe days.

*(The warning lands. The triumph of the council fades.)*

*(Flag `sable_warning_ignored` (12) set. The assault comes the
next morning.)*

---

*The alliances are secured. The warning is given. Tomorrow,
everything breaks.*

*Continue: [Act II Part 2 — The Betrayal](act-ii-part-2.md)*
