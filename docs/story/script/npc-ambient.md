# NPC Ambient Dialogue

> Town NPC dialogue organized by location. Each NPC has flag-dependent
> variants that shift as the story progresses. Dialogue reflects
> personal stakes, faction worldview, and the cost of world events
> on ordinary people. The world is a barometer — Nella's flowers
> tell you more about the state of things than any briefing.
>
> **Layer:** 2 (NPC Ambient) | **Covers:** All acts
>
> **Navigation:** [README](README.md) | [Battle Dialogue →](battle-dialogue.md)
>
> **Related docs:** [npcs.md](../npcs.md) |
> [locations.md](../locations.md) |
> [events.md](../events.md) |
> [economy.md](../economy.md)

---

## Valdris Crown

### Bren (Market Square, Baker)

**BREN** : Used to sell out by noon. Now I'm carrying loaves
home at sunset. Not because people don't want bread — because
they can't pay.

(If `cael_betrayal_complete` set.)
**BREN** : The ovens still work. That's something. Half the
ley-lamps on this street are dead, but flour doesn't need magic.

(If `interlude_begins` set.)
**BREN** : Market's half empty. I still bake though. What else
would I do?

(If `epilogue_complete` set.)
**BREN** : Smoke's rising from the chimney again. First time the
whole street's smelled like bread in months.

### Wynn (Gate District Guard)

**WYNN** : Another group of refugees from the eastern border.
Third one this week. Running out of room on the ledger.

(If `cael_betrayal_complete` set.)
**WYNN** : Gate's still standing. Can't say that about much else.

(If `interlude_begins` set.)
**WYNN** : Gate's open but there's nowhere to go. People come in.
Nobody leaves.

(If `epilogue_complete` set.)
**WYNN** : First caravan out since the rupture. Twelve wagons.
I counted twice to make sure I wasn't dreaming.

### Nella (Market Square, Flower Seller)

**NELLA** : Starbloom today — only grows where ley lines run
shallow. My grandmother said they're good luck.

(If `cael_betrayal_complete` set.)
**NELLA** : The starblooms wilted overnight. All of them. I've
never seen that before.

(If `interlude_begins` set.)
**NELLA** : I dry them now. Press flat, tie with string. People
buy anyway. I think they just want to remember what colour
looked like.

(If `epilogue_complete` set.)
**NELLA** : Look. Fresh starblooms. The first ones in months.
The petals are smaller, but they're real. They're growing again.

### Old Harren (Crown's Rest Inn)

**HARREN** : Forty years behind this bar. I remember every face.

(If `vaelith_tavern_encounter` set.)
**HARREN** : Had a strange guest last month. Very polite. Tipped
well. Asked about old mines. Funny thing — he knew details about
this inn I never told anyone. Said the original hearth was three
feet to the left. He was right.

*(If spoken to again.)*

**HARREN** : His face. I can't quite recall it. Polite. Grey coat.
That's all I have. Isn't that strange?

(If `interlude_begins` set.)
**HARREN** : Inn's full every night. Not with travelers. With
people who have nowhere else to go.

### Elara Thane (Court Mage Tower)

**ELARA** : My grandmother could call a storm lasting three days.
I called one last month that lasted three minutes. Progress.

(If `cael_nightmares_begin` set.)
**ELARA** : The wind pact feels... thin. Like hearing someone
breathe in the next room. Present, but distant.

(If `interlude_begins` set.)
**ELARA** : The spirit isn't dead. I can feel it. It just won't
speak. Maybe it's afraid too.

(If `epilogue_complete` set.)
**ELARA** : She spoke. This morning. One word. Just my name.
I cried for an hour.

### Osric (Refugee Quarter)

**OSRIC** : They didn't burn Millhaven. They just moved in.
Changed the signs. My deed meant nothing.

*(If spoken to again.)*

**OSRIC** : I still have the seed grain. Hanna picked it — said
it was the best of the season. I can't plant it here. This isn't
my soil.

(If `epilogue_complete` set.)
**OSRIC** : I planted it. The seed grain. In a pot on the
windowsill. It's not a field, but it's growing.

### Lord Chancellor Haren (Council Chambers)

(If `cael_betrayal_complete` set.)
**HAREN** : The king valued your counsel, Edren. But the king
is dead and the counsel didn't save him.

(If `interlude_begins` set.)
**HAREN** : I wrote seventeen letters last week. Three came back
unopened. The rest — I suspect they never arrived at all.

### Captain Isen (Harbor Command)

**ISEN** : I command six boats and twelve sailors. The Compact
has forty gunships. If you're asking about naval strategy,
recalibrate your expectations.

(If `interlude_begins` set.)
**ISEN** : I stopped waiting for orders. The crown's dead, the
council's arguing. People needed boats. Simple enough.

### Mirren (Royal Library Archives)

**MIRREN** : The original text mentions three previous "Doors."
Maren's copy was damaged — only knows about two. I wonder if she
knows she's missing one.

(If `interlude_begins` set.)
**MIRREN** : I locked the Restricted Section myself. If anyone
needs what's in there, they'll have to ask. Politely.

---

## Thornmere Wilds

### Grandmother Seyth (Greywood Camp)

**SEYTH** : My grandmother told me a story about a time the
world forgot how to laugh. A door opened, something grey walked
through. A young man closed it. He didn't come back.

*(If spoken to again.)*

**SEYTH** : You think this is new. It isn't. The world has fought
this before. It just keeps forgetting.

(If `interlude_begins` set.)
**SEYTH** : The forgetting has already started. People talk about
the grey like it just appeared. It's been here before. We wrote
songs about it. Then we forgot the songs.

### Kael Thornwalker (Greywood Camp Patrol)

**KAEL** : My uncle trusts you. I don't. But his judgment is
better than mine in most things.

*(If spoken to again.)*

**KAEL** : Something drove the grey-elk out of the northern
reaches. Grey-elk don't flee. Whatever scared them — I don't
want to meet it.

(If `interlude_begins` set.)
**KAEL** : I killed something yesterday. Grey, hollow, used to
be a fox I think. It didn't fight back. Just looked at me while
it died.

### Ashara (Sunstone Ridge, Ley Guardian)

**ASHARA** : Stand here. Close your eyes. Feel it? The ground
pulls southeast. The lines are draining toward something.

(If `interlude_begins` set.)
**ASHARA** : I've redrawn the wards three times. Energy seeps
through like water through cracked stone. Something is eating
the world from underneath.

### Dorin (Woodcarver)

**DORIN** : Thirty years I've carved these totems. Never cracked
one. Now they all crack. It's not the wood. Something in the
world is breaking, and the wood knows it first.

### Wren (Savanh's Grandchild, 8 Years Old)

**WREN** : Grandmother says the stars still sing. But she can't
hear what I hear. There's something else now. It talks underneath
the singing.

(If `interlude_begins` set.)
**WREN** : The singing stopped. It's just the other voice now.
It's not scary. That's the scary part.

### Rhona (Border Trader, Ashfen)

**RHONA** : Valdris coin, Compact gold — I take both. Information?
That costs more, but I take that in favours.

(If `interlude_begins` set.)
**RHONA** : Fish float belly-up and they're not rotting. Just
floating there, perfectly still. My kids won't go near the water
anymore.

### Fiara (Spirit-touched Wanderer)

**FIARA** : You're standing on a ley line. Step left — there.
Better. It doesn't like being stepped on.

(If `interlude_begins` set.)
**FIARA** : I can see it now. The grey. It's under everything,
like mould under paint. Getting thicker.

(If `epilogue_complete` set.)
**FIARA** : The grey is thinning. Not gone — I don't think it
ever goes. But the ley lines are louder than it is again.

---

## Carradan Compact

### Dael Corran (Caldera, Factory Worker)

**DAEL** : They call it meritocracy. Merit gets you a longer
shift and a shorter life.

*(If spoken to again.)*

**DAEL** : Starts with the small things. Taste goes first. Then
laughter. Then you stop dreaming. Then you stop caring that you
stopped.

(If `interlude_begins` set.)
**DAEL** : Half the line is hollow-eyed. They do the work. They
just don't care if it's done right anymore.

### Cira (Apprentice Forgewright, Caldera)

**CIRA** : Lira left me a note. Three words: "Read the reports."
I read them. I wish I hadn't.

(If `interlude_begins` set.)
**CIRA** : I stayed because I thought I could change things from
the inside. That's what people say when they're too afraid to
leave.

### Jace Renn (Senior Lecturer, Caldera Academy)

**JACE** : My models predicted ley line collapse in twenty years.
We achieved it in three. I underestimated human ambition.

*(If spoken to again.)*

**JACE** : If Lira is alive — and I suspect she is — tell her
the numbers were right. She'll know what that means.

### Mira Thenn (Ley Line Cartographer, Caldera)

**MIRA** : I've mapped every major ley line on the continent.
The map from last year and this year don't look like the same
world.

(If `interlude_begins` set.)
**MIRA** : My latest map shows broken threads. Not lines —
threads. Like someone pulled a tapestry apart.

### Holt Varen (Bellhaven, Weapons Merchant)

**HOLT** : War is terrible. War is also extremely profitable.
I didn't make the world this way — I just learned to read the
ledger.

(If `interlude_begins` set.)
**HOLT** : Exports down ninety percent. Machines won't forge
right. Pivoted to salvage. Good margin in salvage.

### Nara Voss (Ashport, Textile Merchant)

**NARA** : Ashport silk — best on the continent. Can't get this
weave anywhere else.

(If `interlude_begins` set.)
**NARA** : No silk anymore. The worms won't spin. Something
about the ley lines. Selling wool now. Wool doesn't need magic.

---

## Neutral Spaces

### Hadley (Three Roads Inn)

**HADLEY** : Room's clean. Ale's honest. I don't ask where
you're from and you don't ask where the ale's from.

(If `interlude_begins` set.)
**HADLEY** : Valdris refugees in the east wing. Compact deserters
in the west. They eat at the same tables. Nobody starts anything.
Not in my inn.

*(If spoken to again.)*

**HADLEY** : Somebody has to keep the doors open. Might as well
be me.

(If `epilogue_complete` set.)
**HADLEY** : Sable came by. Said she wanted to take over. Rename
the place. I told her the bar's hers if she promises to keep the
ale honest. She promised.

### Marrek (Travelling Merchant)

**MARREK** : Interesting times. I find interesting times are good
for business. People need things they didn't know they needed.

*(If spoken to again.)*

**MARREK** : I've been on this road longer than most people have
been alive. The road doesn't change. People do.

(If `epilogue_complete` set.)
*(Marrek sits at the crossroads. He raises a glass as the party
passes.)*

**MARREK** : To the road. And to everyone who walked it.

---

## Pallor Wastes Oases (Act III Only)

### Oasis A — Valdris Refugees

**NESSA** : You remember my shop in the Crown District? Gone.
All grey. But I saved what matters — the inventory ledger. Old
habits.

*(If spoken to again.)*

**NESSA** : Stock's thin. Everything here was carried on someone's
back through the Wastes.

**TEV** : Mama says the light is keeping us safe. But I can see
it getting smaller.

**SIR ALDRIC** : Our banner is out there. Third Company, Second
Regiment. They didn't make it, but the standard doesn't have to
die with them.

### Oasis B — Compact Refugees

**DELLEN** : Ashmark Foundry District, sixteen years. Now my
supply chain is "whatever someone drags in from the Wastes."

*(If spoken to again.)*

**DELLEN** : I don't do credit. Can't afford to trust anyone's
tomorrow.

**TOMAS** : I was at Oasis A a month ago. Ward light was steady.
When I left three days back, it was flickering. Ward stones
don't flicker.

(If `oasis_c_fallen` set.)
**SENNA** : The stone cracked. Three days ago. The keeper held
on longer than anyone thought possible.

### Oasis C — Thornmere Refugees

**ELDER THESSA** : Despair Wards. Won't find them anywhere else.
Compact tried to forge equivalents — failed. Can't industrialize
spirit-work.

*(If spoken to again.)*

**THESSA** : Roothollow is grey now. But the recipes are here.

*(She taps her temple.)*

**KEEPER ELARA** : The stone is cracking. I can hold it — but
not forever. There's a ley fissure nearby. If you could bring
water from it...

---

## Shop & Service Lines

### General Stores

**SHOPKEEPER** : What'll it be? Potions, antidotes, survival
goods.

*(Buy selected.)* Take your time. Everything's priced fair.

*(Sell selected.)* Let me see what you've got.

*(Exit selected.)* Come back when you need something.

### Inns

**INNKEEPER** : Rest costs [amount]g. You'll wake up fresh.

*(Accept.)* Sleep well. I'll keep the fire going.

*(Decline.)* Door's always open.

### Herbalists (Thornmere)

**HERBALIST** : Spirit-brewed remedies. Won't find these in any
Compact shop.

### Forgewright Shops (Compact)

**FORGEWRIGHT** : Arcanite-grade equipment. Precision-machined.
Don't ask where the materials come from.

### Oasis Shops

**OASIS VENDOR** : Prices are what they are. Everything here was
carried through the Wastes on someone's back.

---

*The world speaks through its people. Listen to Nella's flowers,
Dorin's totems, and Wren's stars — they'll tell you what's
coming before anyone else does.*
