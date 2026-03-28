# Story Outline

Pendulum of Despair follows a four-act structure with a pivotal interlude after the midpoint betrayal.

## Act I: The Gathering Storm

### The Opening (Tutorial)

The game opens in the Ember Vein -- a Carradan mine where something ancient
has been unearthed. **Edren** and **Cael** descend on King Aldren's orders.
The player controls Edren. Cael follows.

**The taste of power (dual preview):**

- Edren carries **Arcanite-enhanced gear** from the Valdris armory -- confiscated
  Compact prototypes, issued only for high-risk missions. The sword and shield
  hit harder than normal Act I levels. This gear breaks during the escape from Carradan soldiers after the
  Vein Guardian, giving the player a preview of Arcanite Forging that Lira
  unlocks later.
- Cael has **unexplained extra power**. His attacks shimmer faintly. His damage
  output exceeds his stats. The game offers no explanation. In hindsight --
  after the betrayal -- the player realizes this was the Pallor's first touch.
  Cael was already marked before the story began.

The dungeon teaches combat across four floors (see Ember Vein in
`dungeons-world.md`). After the Vein Guardian falls and Carradan soldiers
force the party to flee, Lira and Sable join during the escape.

### The Dawn March (Opening Credits)

As the party emerges from the mine, **Vaelith** is waiting (see `vaelith_ember_vein`
flag in `events.md`). After Vaelith's departure, the screen cuts to black.

Music shifts. The player controls Edren walking a trail from Ironmouth toward
the Thornmere Wilds at dawn -- forward only, no encounters. Cael walks
alongside. Lira and Sable trail behind, visible but not in dialogue.

Dialogue triggers as they walk:

1. Cael: *"Those miners... they just stopped. No fight, no wounds. They gave up."*
2. Edren: *"We'll let the court decide what it is."*
3. Cael: *"And the stranger? You're not concerned?"*
4. Edren: *"I'm concerned about all of it."*
5. *(Beat of silence as the trail widens to show the valley below)*
6. Cael: *"...I keep thinking about their faces."*

Character names, game title, and credits overlay the walk. The sequence ends
at the Wilds border.

**Game title card: PENDULUM OF DESPAIR.**

The `opening_credits_seen` flag is set.

### Setup

The narrative context begins in **Valdris**, an ancient kingdom in decline.
(The player experiences this through the Ember Vein tutorial above.) The ley lines that power traditional sorcery are dimming. Carradan Forgewright outposts are creeping into the Thornmere Wilds. King Aldren sends **Edren** and **Cael** — two knights and close friends — to investigate a disturbance at an ancient ruin on the border of the Wilds. Carradan miners have unearthed something.

### The Discovery

At the ruin, they find **the Pendulum of Despair** — inert, unremarkable, but surrounded by dead miners with no wounds. Their faces are frozen in expressions of absolute hopelessness. Cael is unsettled. Edren wants to bring it back to Valdris for study.

### Party Assembly

- **Lira** appears — a Forgewright defector tracking the same ruin. She found Carradan documents referencing "Project Pendulum" and defected to investigate. She warns them the Compact wants the artifact.
- They're ambushed by Carradan soldiers. **Sable** — a local thief looting the ruin — gets caught up in the escape.
- They flee into the Thornmere Wilds. **Torren**, a ranger and spirit-speaker, finds them. He recognizes the Pendulum from old spirit-lore.
- Torren insists they seek out **Maren**, an exiled Valdris court mage living deep in the Wilds.

### The Stranger at the Mine

*(Tier 1: Full Cutscene)*

As the party emerges from the ruin's outer passage into the cold night air, a grey-cloaked stranger is already there — leaning against a broken stone column as though they had been waiting for some time. They do not reach for a weapon. They introduce themselves as Vaelith, in the manner of someone sharing a pleasantry, and ask to see the Pendulum. Edren refuses. The stranger tilts their head with what might be academic disappointment, studies the artifact from a polite distance, and murmurs something about what a fragile little thing it is to build hope around. Then they bow, wish the party a safe journey to the capital, and walk back into the dark without haste. No threat is made. No threat is needed. The party exchanges glances and moves on.

### The First Warning

Maren examines the Pendulum and delivers the first warning: *"This thing has no power. It's a door. And something on the other side knows you opened it."*

### Act I Ends

The full party is assembled. They decide to bring the Pendulum to the Valdris capital for safekeeping. Cael begins having nightmares — brief, dismissable. The player might not even notice.

---

## Act II: The Fraying

### Act I–II Transition: The Road to Valdris

<!-- This section covers the journey between acts. Act II proper begins at pendulum_to_capital (arriving at Valdris). -->

The journey back to the capital takes several days through disputed country. On the second evening, Torren spots a figure on a ridge above the road — still, watching, gone by the time the party doubles back. The campsite they find is recently abandoned: two teacups still warm, a small fire tamped down with care. A single page of journal sits on a flat stone, covered in script so archaic that Torren can only piece together fragments. The words he manages to read describe a cycle — something about a door opening and closing across ages. He cannot tell if it is prophecy or history. The party does not know who left it or who the second teacup was for.

### Valdris in Decline

The party returns to find Valdris deteriorating. Ley lines are failing faster. Carradan forces have taken two border towns. The king is desperate and sees the Pendulum as a potential weapon, despite Maren's warnings.

### The Pallor's Work Begins

Cael is tasked with studying the Pendulum alongside court scholars. The Pallor begins its manipulation in earnest. Cael's nightmares intensify — visions of his family's death, twisted by whispers: *Valdris let them die. Edren could have saved them. No one cared.* None of it is true, but grief doesn't need truth.

### The Diplomatic Mission

Edren, Lira, and Torren are sent to the Thornmere tribes to broker an alliance against the Compact. The world opens up — the player explores the Wilds, discovers that the ley lines aren't just dimming but being drained *toward something*.

The diplomatic arc has three alliance steps before the Council:

1. **Duskfen alliance.** The party travels to Duskfen and clears Fenmother's Hollow — a corrupted spirit guardian in the deep marsh. Spirit-speaker Caden's trust is earned. (`duskfen_alliance` flag)
2. **Ley Stag bonding.** Returning to Roothollow after the Fenmother, spirit-speaker Vessa performs a brief ritual at the heartwood shrine. A ley-bonded stag joins the party as a mount — the Wilds' answer to the Compact's rail. (`stag_bonded` flag; see [transport.md](transport.md))
3. **Canopy Reach alliance.** The party ascends to Canopy Reach and secures Wynne's support. A panoramic view from the canopy reveals the first visual hint of the Convergence — grey haze on the horizon. (`canopy_alliance` flag)

In a frontier tavern near the edge of Compact-held territory, they find Vaelith already there — buying rounds, charming the locals, asking a barkeep about mining routes that were abandoned two generations ago. Vaelith greets the party as old acquaintances and pulls up a chair. The conversation is light, curious, almost pleasant. They ask Edren about the Valdris court. They ask Torren about the old spirit-lore of the ley lines. Then, almost as an afterthought, they turn to Lira and ask how Cael is sleeping lately. She tells them Cael did not make the journey. Vaelith nods, as if this confirms something, finishes their drink, and takes their leave. The question about Cael's sleep will seem like idle small talk until it doesn't.

#### The Thornmere Council (Playable Scene)

The diplomatic mission culminates at the Ashgrove council stones -- a Tier 3
playable scene where the player's choices determine siege support levels.

**Phase 1 (Private Audiences):** The player moves freely around Ashgrove,
speaking with Elder Savanh, Spirit-speaker Caden, and Wynne privately. Each
conversation offers 2-3 dialogue choices. Hidden approval scores track each
leader's support (see `council_savanh_approval`, `council_caden_approval`,
`council_wynne_approval` flags in `events.md`).

**Phase 2 (Council Fire):** Three topics are debated: why the Wilds should
help Valdris, who controls the Pendulum, and what happens after. Leaders react
openly to the player's responses.

**Phase 3 (Vote):** Each leader votes independently. Result stored in
`council_result` flag (0-3). Outcome determines allied support at the Valdris
Siege -- from full Thornmere tribal commitment (archers, barricades, healing herbs)
to no support at all.

See `docs/superpowers/specs/2026-03-17-narrative-expansion-design.md` Section 3,
Scene 1 for full Council design.

### The Stranger's Work (Cutscene)

*(Tier 1: Full Cutscene -- party not present)*

The player sees a scene the party will never witness. Somewhere in the Wilds, a village has been touched by the Pallor — its people listless, grey-eyed, sitting in doorways and staring at nothing. Vaelith moves among them. They speak gently, crouching to meet people's eyes, resting a hand on a shoulder here, offering a quiet word there. The comfort they give is real in the moment; the villagers' faces ease, their breathing slows, something like peace settles over them. Vaelith stays for hours. When they finally rise and walk away into the treeline, the village is quieter than before. The grey in the villagers' eyes has deepened. The relief Vaelith offered was genuine — but in receiving it, something in the villagers gave way further. The player understands, even if they cannot articulate it yet, that Vaelith does not cause the Pallor's spread through cruelty. Vaelith spreads it through care.

### Sable's Warning

Sable stays behind in Valdris and notices Cael's behavior shifting — talking to himself, isolating, growing cold. She tries to warn the others but can't reach them in the Wilds. When the diplomatic team finally returns, Sable delivers her warnings that evening — but it is too late to act. The assault comes the next morning.

### The Romance in Bloom

Lira and Cael's romance unfolds in flashback scenes interspersed throughout Act II — campfire conversations, a quiet moment on the castle walls, her teaching him Forgewright engineering, him showing her the stars from the Valdris towers. The player falls in love with their relationship just as it's about to shatter.

### Cael's Last Night (Playable Scene)

The night before the betrayal. The player controls **Cael** -- the only time
in the game outside of Sable's Interlude. The player does not know this is the
last night.

Four locations in Valdris Crown are available; time allows three visits:
- **Lira's Workshop:** Tender, guarded conversation. Neither says what they need to.
- **Training Grounds (Edren):** They spar like old times. Edren: *"Same time
  tomorrow?"* Cael: *"...Same time tomorrow."*
- **Maren's Study:** Cael asks questions too specific about the Pallor's
  previous offers. Maren notices but does not press.
- **Pendulum Vault:** No dialogue. Cael's reflection in the glass is wrong for
  one frame.

Each visit sets a flag (`cael_last_night_lira`, `cael_last_night_edren`, `cael_last_night_maren`, `cael_last_night_vault`) that alters
the betrayal cutscene's camera work and emotional framing. No visit is wrong --
each reveals a different truth about Cael's state. The control switch to Cael
is unmarked; it hits only in retrospect.

See `docs/superpowers/specs/2026-03-17-narrative-expansion-design.md` Section 3,
Scene 2 for full design.

### The Betrayal

*(Tier 1: Full Cutscene)*

The Carradan Compact launches a surprise assault on Valdris the morning after the diplomatic team returns. In the chaos, Cael makes his move. The Pallor has convinced him the Pendulum can end all suffering — not as a weapon, but by reshaping the world. He takes the Pendulum, opens a gate using the weakened ley lines, and vanishes.

But not before confronting Lira. She begs him to stay. He tells her he's doing this *for* her — for everyone. He believes it. She can see he's not entirely himself, but he's not entirely gone either. He leaves.

### The Siege of Valdris

*(Tier 1: Full Cutscene, transitions to playable)*

The Compact's assault does not end with Cael's departure. Their vanguard has shattered the outer gates, and through the breach the party hears the ground-shaking advance of the Ashen Ram — a Forgewright siege engine powered, impossibly, by Pallor energy rather than stable ley lines. Its approach turns the cobblestones grey. The soldiers behind it move like men in a dream. The party meets the Ram on the battlements, fighting it as it advances. Mid-fight the Ram breaches the wall, and in the wreckage the party destroys its Pallor core. The battle turns there, but barely.

During the fighting, Edren spots a figure standing on the broken outer wall above the gate. Not in Compact armor. Not directing anyone. Vaelith watches the city burn with the calm attentiveness of someone observing an interesting experiment. The party cuts their way toward them. They do not flee. They speak throughout the fight — complimenting the party's footwork, noting that Torren favors his left side when tired, asking Lira with genuine curiosity how it feels to defend a city for a king who never deserved it. The party cannot land a decisive blow. Vaelith overwhelms them — not with malice, but with the casual ease of eight centuries of accumulated power. "You are doing wonderfully," they say, as the party's strength gives out. "Truly. I have not been this entertained in centuries." The party falls. They wake in the aftermath of the siege, Valdris wounded and leaderless. The night does not feel like a victory.

### Act II Ends

The Carradan assault is repelled, barely. Valdris is wounded. The king is dead. The ley lines, already failing, begin to unravel.

The party reunites in a broken capital. Maren reveals what she's kept secret: the Pendulum isn't a door to power. It's a door to the Pallor itself. And Cael just opened it from the other side.

---

## The Interlude: The Unraveling

### The World Changes

*(Tier 1: Full Cutscene -- Ley Rupture)*

Time passes — weeks, maybe months. The ley lines have ruptured. Magic is wild and unstable. The Thornmere Wilds are twisting — forests petrifying, spirit creatures going mad. Valdris has fractured into squabbling noble houses. The Carradan Compact is also suffering — their Forgewright engines relied on stable ley lines, and now machines are misfiring or running on Pallor energy without anyone understanding why.

### The Party Scatters

*(Tier 2: Walk-and-Talk (Sable solo))*

- **Edren** retreats to a remote monastery in the Valdris highlands, paralyzed by guilt.
- **Lira** returns to the Carradan Compact under a false identity, searching for Cael.
- **Torren** goes back to the Thornmere tribes, trying to hold the Wilds together as the spirit world collapses.
- **Sable** moves between all three factions — carrying messages, gathering information, stealing what she needs. She's the thread that holds everything together.
- **Maren** disappears. She leaves a single message: *"I've gone to find what came before the Pendulum."*

In the weeks that follow, reports of the grey stranger reach each of them separately. Dame Cordwyn, the Valdris garrison commander, has compiled a file of sightings spanning decades — possibly centuries, if the older accounts are genuine. A travelling scholar fitting the same description appears in records from three different kingdoms during three different eras of Pallor activity. Sable finds the file and keeps it to herself for a while, not sure what to do with it. More immediate is what Brant tells her when she finally tracks him down — Brant, whose cowardice at the rear gate at Ironmark Citadel still has people talking. He cannot look at her when he confesses it: a figure matching Vaelith's description visited him weeks before the assault. They talked for hours. Brant cannot recall everything they discussed, only that afterward, the conviction slowly settled in him that resistance was pointless, that Valdris was already lost, that the door had been open too long to close. He did not recognize it as planted. It felt like clarity. The party, comparing notes through Sable, begins to understand that the siege did not begin at the gates. It began much earlier, in conversations they were not present for.

### Sable's Journey (Playable)

The player chooses the order of reunions. Previously reunited members are
present for later reunions, changing dialogue and emotional dynamics. Finding
Lira first means she helps stabilize Torren's ley nexus. Finding Edren first
means his steadiness grounds Lira's infiltration. Finding Torren first
provides spirit-sense hints for subsequent searches. Finding Maren first
recontextualizes all other reunions. The final reunion is always the most
emotionally charged. Flags `reunion_order_1` through `reunion_order_4` track
the sequence. The story converges at the same point regardless of order.

The player controls Sable as she tracks down each party member. Each reunion is its own short arc:

**Finding Edren** — A Pallor manifestation attacks the monastery — creatures born of hopelessness, grey and hollow. Edren fights again, not because he's healed, but because people need him.

**Finding Lira** — Sable infiltrates the Compact and discovers Lira is close to finding Cael's trail. They uncover a Carradan general who has willingly embraced the Pallor's influence to seize power. They take him down and recover a map to Cael's location.

**Finding Torren** — The Wilds are dying. Torren has been performing a ritual to hold back the corruption, burning his own life force. When Sable and Edren reach him, he is barely conscious at the center of a grove gone entirely grey. The nexus he has been tending is no longer merely corrupted — a Ley Leech has anchored itself to it, a creature born from the Pallor's spread that sustains itself by drinking the flow between ley lines and exhaling the drained energy as pure hopelessness. The spirits of the Wilds fled from it. The trees nearest the nexus are glass-still, not dead, but emptied. The reunited party defeats it, and the nexus stabilizes, ley lines glowing clean — the first sign the Pallor can be pushed back.

**Finding Maren** — She's in a ruin older than any civilization on the map. She's discovered the truth: the Pallor has tried this before. Every age has had a conduit and a host. Every time, someone closed the door — and it cost them everything.

### The Interlude Ends

The party is reassembled. They know where Cael is — at the Convergence, where all ley lines once met. They know the cost.

Maren says it plainly: *"The door closes from the inside. Someone who carries the Pallor's mark has to choose to shut it. And they don't come back."*

Everyone understands. No one says Cael's name.

---

## Act III: The Convergence

### The Night Before the Convergence (Playable Scene)

A campfire scene. The remaining party (Edren, Lira, Torren, Sable, Maren) is
together for the last time. Cael is absent -- he is at the Convergence.

The player moves freely around the campfire. Each member can be spoken to:
- **Torren** talks about the spirits going quiet.
- **Lira** adjusts her tools, mentions something she never finished building.
- **Sable** makes a joke that does not land. Then a real one that does.
- **Maren** stares at the fire. Says she has seen this story before in the old texts. This time might be different.

If the player speaks to everyone, a group moment triggers -- Edren says
something simple that binds them. Not a battle speech, just acknowledgment.
If the player walks to the exit, the march begins without it.

`campfire_complete` flag set only if the group moment triggers.

### The March

*(Tier 2: Walk-and-Talk)*

The party travels to the Convergence — a shattered plateau at the center of the continent. The sky is grey and static. Hope feels physically heavier here. The Pallor knows they're coming.

### The Trials

The Pallor throws manifestations of each party member's fears:

- **Edren** faces phantom kings and the weight of every command that cost lives — the Crowned Hollow, a towering figure wearing every crown of every leader who failed to stop the Pallor.
- **Lira** faces a vision of the life she and Cael could have had — a cottage, peace, children. Letting go is the hardest thing she does.
- **Torren** faces the spirits of the Wilds accusing him of failing them.
- **Sable** faces her own insignificance — the whisper that she doesn't belong.
- **Maren** faces her younger self, asking why she wasted her life on knowledge that only brought suffering.

Each overcomes their trial not by defeating it, but by **accepting** it. The Pallor feeds on denial. Acceptance starves it. This is the thematic key to the entire game.

### The Pallor Wastes

*(Tier 1: Full Cutscene, in-battle)*

The plateau outside the Convergence is wrong in a way the party has no language for — not hostile, exactly, but voided, as though the land itself has given up the habit of caring. Vaelith is waiting for them here, between the wastes and the Convergence gate. This is the first time the party has seen them without their ease. They are not smiling. They look at the ley lines visible in the sky above the party — threads of light, faint but present — and for a moment they seem genuinely disoriented. They remark, more to themselves than to the party, that the network should not still be alive this late in a cycle. It has never been alive this late. Vaelith turns to look at the party with something that might be recalibration.

They do not stand aside. But the fight this time is different. Lira, drawing on Cael's lingering resonance through the Pendulum's fracture lines and the restored ley network threading through the plateau, shapes the grief she has been carrying since the siege into something she could not have made any earlier in the journey — not a weapon exactly, but an act of love that has learned to push back. It strikes Vaelith in a way that their centuries of experience have not prepared them for. They take a step backward. They take another. The smile does not return. The party presses the advantage until Vaelith is on one knee in the grey dust, and then — for the first time — they simply sit down. They look at the four of them without contempt, without performance, without the careful distance they have maintained across every encounter. They are quiet for a long moment. Then they say that something changed in this cycle, and that they do not fully understand what. They say it without bitterness. They dissolve slowly into grey mist, edges going first — not destroyed, not fleeing, but concluded. Released. The mist drifts upward and is gone. The Convergence gate opens without any further obstacle.

### The Final Battle

Cael is at the Convergence, barely recognizable — wreathed in grey light, the Pendulum fused to his hand. He's built a machine around the ley line nexus: part Forgewright engine, part ancient ritual circle. He's trying to remake the world into a place where no one can feel pain. A world of nothing.

**Phase 1** — Cael fights with his old knightly skills, enhanced by Pallor energy. He knows the party's tactics.

**Phase 2** — The machine activates. The Pallor begins to incarnate through Cael. The party splits between fighting Cael and disabling the machine's ley line anchors.

**Phase 3** — The machine is broken. The Pallor, half-incarnated, is a towering presence of grey static and hollow sound. Cael is at its center, barely conscious.

### Lira Reaches Cael

*(Tier 1: Full Cutscene)*

She pushes through the Pallor's aura and speaks to him. She doesn't beg this time. She tells him about the door. She tells him she can still see him in there. And she tells him she's letting him go.

### Cael Breaks Free

Not fully — the Pallor is still anchored to him. But enough. He looks at Edren:

*"I'm sorry."*
*"I know."*

---

## Act IV: The Closing Door

### The Truth

Cael, half-free and burning with Pallor energy, tells the party what he can see from the inside. The door is open and vast. Destroying the Pendulum won't close it. Killing the incarnation won't close it. The door has to close from the inside.

### The Farewell

Edren refuses to accept it. He argues for another way. Maren shakes her head. Torren puts a hand on Edren's shoulder. Sable has nothing clever to say.

Lira tells Edren to let him go. It costs her everything. But she understood it in Phase 3. This is what acceptance looks like.

### The Sacrifice

*(Tier 1: Full Cutscene)*

Cael walks into the door. The party holds off a final surge of Pallor manifestations — a last stand sequence controlling the full party while Cael's silhouette grows smaller in the grey light.

From inside, Cael sees the Pallor's truth: every grief, every loss, every surrendered hope from every age. It's not evil. It's just heavy. It's been open so long because no one ever chose to stay and bear the weight.

He closes the door. The Pendulum shatters. The grey light collapses inward.

Silence.

---

## Epilogue: The Changed World

### The World Heals

The ley lines stabilize into something new — not restored, but settled. Raw magic and Forgewright technology begin to coexist. The rigid structures on both sides broke during the Unraveling, and what grew back was hybrid.

### The Fates

**Valdris** rebuilds under a council, not a king. Edren declines the throne. He trains the next generation — protectors, not warriors. He carries Cael's sword alongside his own.

**The Carradan Compact** fractures into independent city-states. Several open trade with Valdris. Lira founds **the Bridgewrights** — a guild dedicated to Forgewright craft that works with ley lines rather than draining them. Cael's dream made real, without the Despair.

**The Thornmere Wilds** begin to heal. Torren returns to the spirit-speakers. The stabilized nexus becomes a meeting ground for all three factions.

**Sable** opens a tavern at the crossroads called **The Pendulum**. When asked why: *"So nobody forgets what it cost."*

**Maren** returns to the ancient ruin. She writes a complete history, so the next time Despair finds a crack, the world won't need to learn the lesson again.

### Final Scene

*(Tier 1: Full Cutscene)*

Edren stands at the Convergence — now a quiet meadow where wild magic drifts like fireflies. He places Cael's sword in the ground. Lira is beside him. They don't speak.

The camera pulls up and out. The world is scarred but green, wounded but alive.

**Title card: Pendulum of Despair.**
