# Battle Dialogue & System Text

> Boss phase barks, party combat callouts, tutorial prompts, and
> system messages. Everything the player reads during combat and
> in menus. Boss dialogue is a continuation of the narrative — each
> boss speaks in character, and phase transitions carry emotional
> weight.
>
> **Layer:** 3 (Battle & System) | **Covers:** All acts
>
> **Navigation:** [← NPC Ambient](npc-ambient.md) | [README](README.md)
>
> **Related docs:** [bestiary/bosses.md](../bestiary/bosses.md) |
> [abilities.md](../abilities.md) |
> [combat-formulas.md](../combat-formulas.md) |
> [ui-design.md](../ui-design.md)

---

## Boss Pre-Fight & Phase Transitions

### Act I Bosses

#### Vein Guardian
<!-- Cross-ref: bestiary/bosses.md § Vein Guardian -->

*(Pre-fight — no dialogue. The construct assembles silently.)*

*(Phase 2 transition:)*
The Guardian's crystal core fractures. It draws inward,
condensing. The glow intensifies.

*(Defeat:)*
The construct shatters. Crystal fragments scatter across the
chamber floor. The passage behind it clears.

#### Corrupted Fenmother
<!-- Cross-ref: bestiary/bosses.md § Corrupted Fenmother -->

*(Pre-fight:)*
The water surges. Something vast stirs beneath the surface —
tendrils of grey-green light reaching for the walls.

*(Phase 2 transition:)*
The Fenmother shrieks — corruption pulses through the chamber.
The water rises.

*(Phase 3 transition:)*
The corruption recedes from her eyes. For a moment, the spirit
underneath is visible — ancient, tired, asking for help.

*(Defeat — cleansed, not killed:)*
The grey drains from the water. The Fenmother's form settles,
translucent and calm. She sinks beneath the surface. The hollow
goes quiet.

---

### Act II Bosses

#### The Ashen Ram
<!-- Cross-ref: bestiary/bosses.md § The Ashen Ram -->

*(Pre-fight — Dame Cordwyn:)*
**CORDWYN** : Here it comes — the Ashen Ram. Hold the gate!

*(Phase 2 transition:)*
The Ram crashes into the wall. Stone cracks. The ground splits.

**CORDWYN** : It's breached the outer wall! Get in close —
the armour's thinner at the joints!

*(Phase 3 transition:)*
The hull splits open. Inside, a pulsing core of grey energy.

**CORDWYN** : There — that's its heart! Hit it with everything!

*(Defeat:)*
**CORDWYN** : The Ram is down. Valdris stands. For now.

#### General Vassar Kole
<!-- Cross-ref: bestiary/bosses.md § General Vassar Kole -->

*(Pre-fight — covered in act-ii-part-2.md and interlude.md)*

*(Phase 2 transition:)*
One crystal shatters. The Despair Aura flickers.

**KOLE** : Impressive. Most impressive. You've broken one.

*(Defeat:)*
The second crystal explodes. The grey aura dissipates. Kole
falls to his knees. The Pallor energy drains from the room.
Soldiers collapse — some wake confused. Some don't wake.

---

### Act III Trial Bosses

#### The Crowned Hollow (Edren's Trial)
<!-- Cross-ref: bestiary/bosses.md § The Crowned Hollow -->

*(Phase 2 — invulnerable, voices of the dead:)*
Every command you gave. Every name they carried.

*(Turn 1 Defend:)*
The weight presses down. Edren's knees buckle — but hold.

*(Turn 2 Defend:)*
The crown's fire dims. The Hollow falters.

*(Turn 3 Defend — victory:)*
You stayed.

#### The Perfect Machine (Lira's Trial)
<!-- Cross-ref: bestiary/bosses.md § The Perfect Machine -->

**MACHINE** : Lira. You came back. I am almost finished. I just
need your hands.

*(If Repair attempted:)*
**MACHINE** : Almost. Try again.

*(If Repair attempted again:)*
**MACHINE** : It hurts. But it will be worth it.

*(Dismantle used:)*
**MACHINE** : ...that hurts. But I understand.

#### The Last Voice (Torren's Trial)
<!-- Cross-ref: bestiary/bosses.md § The Last Voice -->

*(Phase 2 — the request:)*
**LAST VOICE** : Let me go.

*(If attacked:)*
**LAST VOICE** : Please. I have been here so long.

*(Release used:)*
The voice fades. The stone cracks, then settles. A single green
shoot appears where the spirit stood.

#### The Index (Maren's Trial)
<!-- Cross-ref: bestiary/bosses.md § The Index -->

**INDEX** : All of it. Every name. Every scream. Every moment
before the end. Take it all. Or end it all. There is no third
choice.

*(Annulment used:)*
The library stops collapsing. The pages settle. The Index
fragments into light.

---

### Act III — Vaelith, the Ashen Shepherd
<!-- Cross-ref: bestiary/bosses.md § Vaelith, the Ashen Shepherd -->

*(Pre-fight and defeat covered in act-iii.md Scene 35.)*

#### Pre-Fight Phase (Invulnerable, 10 Attacks)

*(Vaelith attacks while delivering calm observations. The party
cannot damage them. This is a demonstration of power gap — and
of character.)*

**VAELITH** : Your form is excellent, Edren. Cael taught you the
high guard, I assume. He was always precise.

**VAELITH** : Torren, you favour your left side when tired. The
spirits could have told you that. Did you not ask?

**VAELITH** : Lira — how does it feel to defend a kingdom that
never deserved your loyalty? I'm genuinely curious.

**VAELITH** : Sable. You carry no titles, no magic, no ancestral
weapon. Just stubbornness. I've seen empires fall to less.

**VAELITH** : Maren. You've read about me, haven't you? Tell me
— did the accounts do me justice?

*(After Lira forges Cael's Edge — barrier shatters:)*

**VAELITH** : Ah. That's new. In eight hundred years, no one has
done that before.

#### Scholar Mode (HP 50,000--25,001)

*(Detached, analytical. Vaelith treats the fight as a seminar.)*

**VAELITH** : Your grief makes you legible. Every wound tells me
exactly how to hurt you next.

**VAELITH** : Another age. Another failure. The cycle is
exquisitely predictable.

*(After taking a critical hit:)*
**VAELITH** : Interesting. You actually drew blood. When did you
last sharpen that blade, Edren? It's good work.

*(After being debuffed:)*
**VAELITH** : Clever. The Pallor's defences are not infinite.
Neither, I should note, is your time.

*(At HP 37,500 — first real acknowledgment:)*
**VAELITH** : You are the first to push me this far in eight
centuries. I want you to understand what that means. It means
nothing has changed. It just took longer this time.

*(After Temporal Cascade — acting twice:)*
**VAELITH** : Time is a courtesy I extend to mortals. I'm
withdrawing it.

#### Shepherd Mode (HP 25,000--0)

*(The detachment cracks. Underneath is exhaustion, not rage.
Vaelith has done this before, and they are tired.)*

**VAELITH** : You should have stopped. Everyone stops. Every age,
every cycle — they fight until they understand, and then they
stop. That's not weakness. That's wisdom.

**VAELITH** : That weapon is borrowed time, child. He's already
gone. What you're swinging is grief shaped like a sword.

*(After Despair Pulse:)*
**VAELITH** : Feel that? That's not an attack. That's the truth.
The Pallor doesn't create despair. It reveals what was already
there.

*(At HP 12,500:)*
**VAELITH** : I was the first to understand the Pallor. The first
to name it. And the first to realize that naming it changes
nothing. Understanding is not a weapon. It is a weight.

*(At HP 5,000:)*
**VAELITH** : You will reach the Convergence. You will face what
I faced. And you will make the same choice I made. Everyone does.

*(Their voice is not threatening. It is the voice of someone who
has watched this play out more times than memory can hold.)*

*(At HP 2,500 — final bark:)*
**VAELITH** : Something changed. I can feel it. The ley network
should be dead by now. It's not. You did something none of them
did. I just... don't understand what.

---

### Act III-IV — Cael, Knight of Despair

*(Pre-fight, phase transitions, and defeat covered in
act-iv-epilogue.md Scene 37.)*

#### Phase 1 — The Knight (Lv 36, 45,000 HP)

*(Cael fights with his old training. Every move is familiar to
the party — they sparred against these same techniques. That
familiarity is the cruelty.)*

*(Opening — turn 1:)*
**CAEL** : Good. Don't hold back. I need you strong enough for
what comes after.

*(At 75% HP — Despair's Grip unlocks:)*
**CAEL** : You feel that? The weight? That's not me. That's what
I've been carrying since the night I took the Pendulum.

*(Random barks — Phase 1:)*

**CAEL** : That parry. We learned it together. Under Marek. I
remember.

**CAEL** : Lira — your timing is better. You've been practicing.

**CAEL** : Torren, the spirits are screaming at you to run.
You should listen.

**CAEL** : Sable. Still showing up. I always admired that.

**CAEL** : Maren. You called it a door. Back at the refuge. You
were right about all of it. And you couldn't stop me anyway.

*(At 50% HP — voice cracks:)*
**CAEL** : I'm doing this for you. All of it. The machine, the
Convergence — I found a way to end the cycle.

*(After using Marked for Sorrow:)*
**CAEL** : Remember the cost. Someone has to.

*(At 25% HP — invulnerability phase:)*
**CAEL** : I'm doing this for you. Remember that. When it's over,
when you see what I've become — remember I chose this.

*(His eyes close. When they open, they are grey.)*

#### Phase 2 — The Pallor Takes Hold (Lv 38, 35,000 HP)

*(The discipline is gone. Cael doesn't speak in complete
sentences anymore. The Pallor is using his voice, and Cael is
fighting it from inside. What comes through is fragments —
broken signals from a man drowning in grey.)*

*(Phase 2 opening:)*
His movements are wrong. Too fast. Too sharp. The sword screams
when it swings — not metal on air, but something beneath the
metal, howling.

*(Random barks — Phase 2, Pallor voice:)*

The grey speaks through him. Not words — feelings given shape.

**CAEL** : ...stop... fighting... let it...

**CAEL** : The machine... close... so close...

*(After using Hollow Advance — self-buff:)*
The Pallor forces Cael's body forward. His feet leave grooves in
the stone.

*(After using Draining Whisper:)*
Grey mist seeps from Cael's armour. The air tastes of metal and
old grief.

*(At 50% Phase 2 HP — Cael breaks through:)*
**CAEL** : I can still hear you. I can still — the machine is
close. Don't stop. Please don't stop.

*(After landing a critical hit on the party:)*
**CAEL** : ...sorry... can't... control...

*(False Hope — survives at 1 HP:)*
He should have fallen. The Pallor energy flares — grey light
pours from every crack in his armour. He stands. Not because he
wants to. Because the Pallor won't let go.

**MAREN** : He should have fallen. The Pallor won't let him.

**EDREN** : One more push. For him. Not against him. For him.

*(Second killing blow — Phase 2 ends:)*
Cael falls. Not dramatically. He crumples — the way a man does
when he has nothing left. The sword clatters on stone. His hands
open. His eyes close.

And then the machine wakes up.

#### Cael — Party-Specific Reactions During Fight

*(These fire once each during the Cael fight based on party
composition. They are character-specific emotional beats that
remind the player this boss was their friend.)*

(If Edren uses Steadfast Resolve during the fight.)
**EDREN** : I learned this at the monastery. I'm not leaving you,
Cael. Not again.

(If Lira uses a healing ability on the party.)
**LIRA** : The Pallor's grip is fluctuating. He's still in there.
I can see it in the energy patterns.

(If Torren uses Rootsong.)
**TORREN** : The spirits remember him. They're singing for him.
Not against him.

(If Sable is in the party.)
**SABLE** : This is the worst fight I've ever been in. And I've
been in a lot of fights.

*(If spoken after Cael's 50% Phase 2 dialogue:)*
**SABLE** : He said please. Cael never says please. He's still
in there.

(If Maren uses Pallor Sight.)
**MAREN** : I can see the Pallor's grip. It's wrapped around his
heart. But there's a gap. He's holding it open. For us.

---

### Act III-IV — The Pallor Incarnate
<!-- Cross-ref: bestiary/bosses.md § The Pallor Incarnate -->

*(Pre-fight and defeat covered in act-iv-epilogue.md Scene 37e.)*

*(The Pallor Incarnate does not speak as a character. It speaks
through Hollow Voice — weaponized intimacy, using each party
member's deepest fear in the voice of whoever they trust most.)*

#### Hollow Voice — Targeted Attacks

*(Each targets one party member. The voice changes to match
whoever that character fears hearing these words from.)*

*(To Edren — in Cael's voice:)*
You failed me. You saw it coming and you looked away. That's
not loyalty, Edren. That's cowardice.

*(To Edren — second use, in Aldren's voice:)*
I asked you to protect what's left. You can't even protect
yourself.

*(To Lira — in Cael's voice:)*
He's already gone. You're fighting a memory. The Cael you loved
died in a vault in Valdris. This is just his body saying goodbye.

*(To Lira — second use, in Drayce's voice:)*
You broke things your whole life. Called it progress. Called it
love. It was always destruction.

*(To Torren — in the Last Voice's whisper:)*
The spirits are silent. They chose silence. They chose it over
you, Torren. You bore them.

*(To Torren — second use, in Vessa's voice:)*
You left us. You said you'd come back, and you left.

*(To Sable — in her own voice:)*
Nobody is coming. Nobody was ever coming. You showed up because
you had nowhere else to go.

*(To Sable — second use, in Renn's voice:)*
You were always the expendable one. The one nobody would miss.

*(To Maren — in her younger self's voice:)*
You knew. You always knew. Decades of study, and you couldn't
stop a single friend from walking through a door.

*(To Maren — second use, in the Archivist's voice:)*
The sixth group. The same question. The same answer. You changed
nothing.

#### Environmental Barks

*(At 75% HP:)*
The sky splits. Grey static tears across the horizon. The
Convergence machine shudders.

*(At 50% HP:)*
The platform is breaking apart. The grey eats at the edges.
There is less world to stand on.

**LIRA** : The platform — it's collapsing. We're running out of
ground.

**MAREN** : The Pallor is consuming the arena itself. We have to
finish this before there's nothing left to stand on.

*(At 25% HP — Cael's voice from the machine core:)*
**CAEL** : The machine is working. I can feel it pushing back.
Keep going. I can hold it a little longer.

**LIRA** : Cael? Cael!

**EDREN** : He's holding the machine open. Giving us time.
Don't waste it.

*(At 10% HP — final surge:)*
The Pallor Incarnate shudders. Cracks of light — real light,
warm light — split its formless body. Not grey. Gold.

**TORREN** : The ley lines. They're pushing back.

**SABLE** : Hit it. NOW.

*(Defeat:)*
The Incarnate does not scream. It does not rage. It simply
stops — the way a held breath releases. The grey drains inward,
collapses to a point of light, and vanishes.

Silence. The sky is lighter. Not blue — not yet. But lighter.

**MAREN** : It's not destroyed. It's diminished. Pushed back
far enough that the world can breathe again.

**EDREN** : And Cael?

---

## Dreamer's Fault Echo Bosses (Post-Game)

#### The First Scholar (Floors 1--4 Echo Boss)
<!-- Cross-ref: bestiary/bosses.md § The First Scholar -->

*(A figure at a desk in a room that shouldn't exist. Writing.
Always writing. The pen never stops.)*

**FIRST SCHOLAR** : You've come to read what I've written.
Everyone does. Nobody finishes.

*(Phase 2 — pages fill faster:)*
**FIRST SCHOLAR** : Every word is a name. Every name is a life.
Do you know how many names fit on a page? More than you'd think.
Fewer than there were.

*(Defeat:)*
The Scholar closes the book. Sets down the pen. And looks up —
for the first time in an age.

**FIRST SCHOLAR** : Finally. Someone who doesn't want to read.
Someone who just wants it to stop.

*(The book remains on the desk. Open. Blank now.)*

**MAREN** : She was like me. Recording everything so the world
would remember. The difference is she never stopped writing long
enough to live.

#### The Crystal Queen (Floors 5--8 Echo Boss)
<!-- Cross-ref: bestiary/bosses.md § The Crystal Queen -->

*(A throne of fused ley crystal. The figure within is no longer
entirely human — half flesh, half mineral, four voices speaking
in overlapping harmonics.)*

**CRYSTAL QUEEN** : We were four. Then two. Then one. Now...
less than one. But the throne holds. The throne always holds.

*(Phase 2 — four aspects split apart:)*
**CRYSTAL QUEEN** : Each of us chose a direction. North. South.
East. West. We were supposed to meet in the middle. We never
did.

*(Defeat — two voices remain, then one, then none:)*
**CRYSTAL QUEEN** : The throne... was not worth... the sitting.

*(A crown of crystal rolls across the floor. It catches the light
in four colours — flame, ice, spirit, void — before going dark.)*

**TORREN** : She tried to protect everything at once. All four
directions. All four elements. Nobody told her that protecting
everything means holding nothing.

#### The Rootking (Floors 9--12 Echo Boss)
<!-- Cross-ref: bestiary/bosses.md § The Rootking -->

*(A mass of living wood. Roots thick as corridors. A face carved
by centuries of growth — not sculpted, grown. It speaks in the
creak of timber under weight.)*

**ROOTKING** : Grew... to survive. Survived... to protect.
Protected... until the roots forgot what sunlight was.

*(Random barks:)*

**ROOTKING** : Deeper. Always deeper. That was the answer. Grow
down. Hide from the grey. The grey followed.

**ROOTKING** : Do you know what a root does when it finds stone?
It grows through it. Slowly. Centuries. The stone breaks first.
The root always wins. Until now.

*(Phase 2 — anchor exposed:)*
**MAREN** : There — that root. It's the anchor. The whole body
regenerates from it.

**TORREN** : It's been growing for a thousand years. All that
time, alone in the dark, trying to reach sunlight it forgot
existed.

*(Defeat:)*
The Rootking exhales its last. Wood settling. Silence. A single
seed drops from the canopy where the ancient wood stood.

**ROOTKING** : ...sun...light...

#### The Iron Warden (Floors 13--16 Echo Boss)
<!-- Cross-ref: bestiary/bosses.md § The Iron Warden -->

*(A construct of ancient metal. Not Forgewright — older, more
precise, built by hands that understood ley energy at a level
the Compact never achieved. It still follows orders from a
civilization that ended millennia ago.)*

**IRON WARDEN** : Intrusion detected. Protocol: eliminate.

*(Random barks — Phase 1, mechanical precision:)*

**IRON WARDEN** : Orders do not expire. Duty does not fade.

**IRON WARDEN** : Tactical analysis: rotate target priority.

**IRON WARDEN** : You fight with emotion. Inefficient. Effective.
Confusing.

*(Mode 2 — Reinforced:)*
**IRON WARDEN** : Damage threshold exceeded. Activating secondary
plating. Reinforcing structural integrity.

**IRON WARDEN** : You adapt. Noted. Counter-adapting.

*(Mode 3 — Overclock:)*
**IRON WARDEN** : Overclock initiated. Defence parameters:
secondary. Mission priority: absolute.

*(Random barks — Phase 2, something beneath the machine:)*

**IRON WARDEN** : Functionality: compromised. Determination:
absolute.

**IRON WARDEN** : The builders gave me one directive. Protect
this floor. They did not specify from what. Or for how long.

*(Defeat:)*
**IRON WARDEN** : You are... adequate. More than adequate.

*(The gears slow. The molten metal cools. Something in the
Warden's posture changes — not collapse, but release. A soldier
finally allowed to stand down.)*

**IRON WARDEN** : Orders... fulfilled. Post... vacant.

**LIRA** : Its core directive wasn't combat — it was identification.
It scanned us the entire fight. Cross-referencing against a
template its builders left. We matched. After all this time, we
matched.

#### Cael's Echo (Floor 20)
<!-- Cross-ref: bestiary/optional.md § Cael's Echo -->

*(Non-combat encounter. Floor 20 — the deepest chamber of the
Dreamer's Fault. The room is quiet. Grey light, but warm somehow.
Not threatening. Waiting.)*

*(A shade of Cael appears — not truly him, but his reflection in
the Pallor's memory. He looks tired. He looks at peace. He looks
like someone who made a choice and doesn't regret it.)*

**CAEL'S ECHO** : You made it this far. Of course you did.

*(If Edren is in the party.)*
**CAEL'S ECHO** : Edren. You're still sharpening my sword. I can
feel it. You don't have to. But... thank you.

*(If Lira is in the party.)*
**CAEL'S ECHO** : Lira. The Bridgewrights. I heard about them.
Even from here. You built something better. That's all I ever
wanted.

*(If Torren is in the party.)*
**CAEL'S ECHO** : Torren. The spirits are louder on this side.
They say hello. They say the new growth is strong.

*(If Sable is in the party.)*
**CAEL'S ECHO** : Sable. The Pendulum. You named it The Pendulum.

*(He smiles. The first real smile since Act I.)*

**CAEL'S ECHO** : So nobody forgets. Yeah. I know.

*(To all — final words.)*

**CAEL'S ECHO** : It's heavy. Heavier than I thought. But the
door is closed. The grey is quieter now. Not gone — I don't
think it ever goes. But quieter.

**CAEL'S ECHO** : Go home. Live. That's all the door ever asked
for.

*(The shade fades. In its place, on the ground: Cael's Echo
crystal. A knight's memory, crystallized. The room goes warm
for a moment — not ley energy, not magic. Just warmth. Then
it settles, and the party is alone.)*

---

## Party Combat Callouts

### Critical HP Warnings (Below 25%)

**EDREN** : I can hold. Keep fighting.

**LIRA** : Systems failing. Need a moment.

**TORREN** : The spirits are close. Not yet.

**SABLE** : That... stung. I'm fine. Mostly.

**MAREN** : My wards are failing. Be quick.

### Ally Down Reactions

*(When any ally falls in combat:)*

**EDREN** : Get up. That's an order.

**LIRA** : Don't move — you'll make the damage worse. Stabilize.

**TORREN** : Stay with us. The spirits aren't done with you yet.

**SABLE** : Hey. HEY. You don't get to quit.

**MAREN** : The vital signs are failing. We need a Phoenix Feather
before the window closes.

### Boss Phase Reactions

*(Generic — when a boss transitions to a new phase:)*

**EDREN** : It's changing. Stay sharp.

**LIRA** : New pattern. Watch the tells.

**TORREN** : The energy shifted. Careful.

**SABLE** : Oh, that's not good.

**MAREN** : Adaptation. It's learning from us.

### Victory Lines (End of Boss Fight)

**EDREN** : Secure the area. Check for wounded.

**LIRA** : It's done. Let's move.

**TORREN** : The spirits are quieter now. That's a good sign.

**SABLE** : Can we not do that again? Ever?

**MAREN** : Fascinating. Terrible, but fascinating.

---

## System Text

### Battle Results

- "[Character] gained [X] EXP."
- "Found [X] Gold."
- "[Character] reached Level [X]!" *(with level-up fanfare)*
- "Obtained [Item Name]."

### Escape

- *(Success:)* "Escaped!"
- *(Failure:)* "Can't escape!"
- *(Boss:)* Flee option greyed out. *(Not selectable.)*

### Status Effect Notifications

- "[Character] is Poisoned!"
- "[Character] is Silenced!"
- "[Character] is Frozen!"
- "[Character] fell Asleep!"
- "[Character] is Confused!"
- "[Character] is Blinded!"
- "[Character] is Slowed!"
- "[Character] is Burning!"
- "[Character] is afflicted with Despair!"
- "[Character] is Berserk!"
- "[Character] is Stopped!"
- "[Character] is Grounded!"
- "Poison wears off."
- "Silence wears off."
- "[Character] woke up!"
- "[Status] was cured!"

### Element Notifications

- "Weakness!" *(1.5x damage, yellow flash)*
- "Resist!" *(0.5x damage, blue flash)*
- "Immune!" *(0 damage, grey flash)*
- "Absorb!" *(heals target, green flash)*

### Critical Hit

- "Critical!" *(2x damage, screen flash)*

### Save System

- *(Save point contact:)* Save screen opens directly.
- *(Overwrite prompt:)* "Overwrite existing save?"
- *(Save complete:)* "Saved."
- *(Empty slot:)* "— Empty —"
- *(Load screen:)* "Select a save file."

### Game Over

- *(All party members KO:)* "The world grows quiet."
- *(Continue prompt:)* "Continue from last save?"
- *(Yes:)* Returns to title screen → load.
- *(No:)* Returns to title screen.

### Tutorial Prompts (First Encounters)

#### ATB System (First Battle)
"The gauge fills over time. When it's full, you can act. Speed
determines how fast it fills."

#### Defend (Vein Guardian Fight)
"Defending halves incoming damage and fills your gauge faster.
Time your defence against heavy attacks."

#### Status Effects (First Poison)
"Status effects persist after battle ends. Use Remedies or visit
an inn to cure them."

#### Elemental Weakness (First Weakness Hit)
"Enemies have elemental weaknesses. Exploit them for bonus
damage."

#### Row System (After Torren Joins)
"Front row characters deal and receive full physical damage.
Back row reduces both by half. Switch rows freely."

#### Ley Crystals (First Crystal Found)
"Ley Crystals grant permanent stat bonuses or new abilities.
Choose carefully — each crystal can only be used once."

#### Arcanite Forging (First Forge Access)
"Forgewright devices use Arcanite Charges. Craft at forges to
create equipment. Experiment with combinations."

### Shop Prompts

- *(Buy:)* "Buy | Sell | Exit"
- *(Unaffordable:)* Item name in grey text.
- *(Equipped indicator:)* "[E]" next to equipped items.

### Transport Prompts

- *(Rail:)* "[Destination] — [Cost]g"
- *(Ferry:)* "Bellhaven — Ashport: 200g"
- *(Unaffordable destination:)* Fare in grey text.

---

*The battle speaks through its voices — bosses who believe in
what they're doing, a party that refuses to stop, and a world
that communicates through status notifications and the quiet
rhythm of "Saved."*
