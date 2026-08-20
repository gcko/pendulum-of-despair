# Act I Bestiary

The Lv 1–12 power band — the enemies of the Ember Vein, the Valdris and
outer Thornmere overworld, the Ironmouth outpost (the Act I opening /
Scene 3 escape on the Carradan border), and Fenmother's Hollow. See
[README.md](README.md) for type rules, stat formulas, reward
calculations, and the § Location Vocabulary rule the Location(s) column
follows.

> **This file is a power band, not an act.** All 27 enemies below ship in
> `game/data/enemies/act_i.json` and all sit inside § Level Ranges by
> Act's Act I band of 1–12. One of the four sections — Fenmother's
> Hollow — is Act II *content* played at the top of that band; see the
> act boundary note on that section (#287).

**Total:** 27 enemies (22 regular + 1 unique + 2 mini-bosses + 2 bosses)

---

## Ember Vein (Floors 1–4)

Recommended party level: 1–8. First dungeon -- every enemy teaches a
core mechanic.

> **Sanctioned overworld appearance (#270):** Ley Vermin and Unstable
> Crystal are ley-corrupted creatures, not mine-dwellers — the Ember Vein
> is simply where the party first meets them. Ley corruption is not
> confined to the vein, and the encounter design already says so:
> [biomes.md](../biomes.md) lists "ley-corrupted wildlife" in the Valdris
> Highlands encounter feel. Their Location(s) entries below therefore also
> list the overworld zones they appear in per
> `game/data/encounters/overworld.json` — Ley Vermin: `ley_scarred_plains`,
> `valdris_highlands`; Unstable Crystal: `ley_scarred_plains`. Without them
> that zone would have no ley-themed enemy at all. This is a deliberate,
> documented widening of the Location column, **not** an authoring error to
> be "corrected" by removing them from the overworld tables.
>
> One naming caveat. The **Ley-Scarred Plains** is not the **Ley Scar**.
> The former is the exhausted ley-crystal quarry country on Valdris's
> eastern border around Greyvale — now a sanctioned Quarried plains zone
> (increment 148) with its own definition in
> [geography.md](../geography.md)
> § Valdris Territory > 'Terrain Effects on Gameplay' (#265). The latter
> is the Act III optional grinding zone inside
> the Pallor Wastes (increment 506). They share a root because both are
> ley-damaged ground; nothing else connects them.
>
> The other Ember Vein enemies (Tomb Mite, Restless Dead, Mine Shade, Bone
> Warden, Ember Wisp) appear in no other encounter table and stay
> dungeon-confined. **Not reconciled here:** Ley Vermin and Unstable
> Crystal also roll in `thornvein_grotto`
> (`game/data/encounters/caves_and_grottos.json`), and Bone Warden in
> `valdris_catacombs` F1, which neither the column below nor their
> `locations` arrays name. Those are dungeon floors rather than overworld
> zones, the same unmirrored-location class as #270, and are deferred to
> the follow-up sweep.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Ley Vermin | Beast | 1 | 23 | 0 | 8 | 6 | 7 | 5 | 8 | 1 | 4 | Beast Hide (75%) | Sharp Fang (25%) | — | — | — | — | Ember Vein F1–F2, Ley-Scarred Plains, Valdris Highlands |
| Tomb Mite | Beast | 2 | 35 | 0 | 9 | 7 | 8 | 6 | 9 | 2 | 4 | Beast Hide (75%) | Sharp Fang (25%) | — | — | — | — | Ember Vein F1–F2 |
| Restless Dead | Undead | 3 | 72 | 10 | 12 | 8 | 10 | 7 | 10 | 2 | 4 | Bone Fragment (75%) | Spirit Dust (25%) | Spirit | — | — | Poison, Death | Ember Vein F1–F3 |
| Unstable Crystal | Elemental | 3 | 64 | 10 | 13 | 6 | 10 | 7 | 10 | 5 | 10 | Element Shard (75%) | Elemental Core (25%) | Frost | — | Flame | Petrify | Ember Vein F1–F3, Ley-Scarred Plains |
| Mine Shade | Spirit | 4 | 96 | 14 | 11 | 9 | 12 | 8 | 11 | 5 | 11 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Ember Vein F2–F3 |
| Bone Warden | Undead | 4 | 105 | 14 | 14 | 10 | 11 | 8 | 9 | 5 | 11 | Bone Fragment (75%) | Spirit Dust (25%) | Spirit | — | — | Poison, Death | Ember Vein F2–F3 |
| Ember Wisp | Elemental | 5 | 125 | 17 | 13 | 11 | 14 | 9 | 12 | 5 | 12 | Element Shard (75%) | Elemental Core (25%) | Frost | — | Flame | Petrify | Ember Vein F3 |
| The Flickering | Spirit | 6 | 156 | 21 | 17 | 12 | 14 | 10 | 12 | 19 | 38 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Ember Vein F3 (unique) |
| *Ember Drake* | Beast | 8 | 1,500 | 0 | 23 | 11 | 17 | 12 | 14 | 50 | 44 | Drake Scale (75%) | Drake Fang (100%) | Frost | — | — | — | Ember Vein F2 (mini-boss) |
| *Vein Guardian* | Boss | 12 | 6,000 | 42 | 40 | 24 | 39 | 24 | 20 | 50 | 800 | Vein Shard (100%) | Vein Guardian's Core (100%) | Storm | Flame | — | Death, Petrify, Stop, Sleep, Confusion | Ember Vein F4 (boss) |

### Boss Notes — Ember Vein

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **Ember Drake** (Mini-Boss) — Lv 8, 1,500 HP, Beast. 1 phase.
- **Vein Guardian** — Lv 12, 6,000 HP, Boss. 2 phases.

---

## Fenmother's Hollow (Floors 1–3 + Cleansing)

> **Act boundary note (#287): Fenmother's Hollow is Act II content.**
> That is settled canon, not a classification this file disputes — see
> [dungeons-world.md](../dungeons-world.md) § 2 for the reasoning
> (Duskfen opens on `diplomatic_mission_start`, which cannot fire until
> `pendulum_to_capital` has ended Act I). This file previously argued the
> opposite; it was wrong.
>
> Its stat table stays here because **this file is organized by power
> band, not by act.** Every enemy below is Lv 6–12 and every one of them
> ships in `game/data/enemies/act_i.json`; the Corrupted Fenmother (Lv
> 12) sits exactly at the Act I ceiling that [README.md](README.md) § Level
> Ranges by Act gives (Act I 1–12, Act II 13–25 from the Ley Line Depths
> onward). The dungeon is the
> first content of Act II and is deliberately pitched at the top of the
> Act I curve, so splitting the table away from the roster file it
> mirrors would cost more than it clarifies. Do not read its presence
> here as an act assignment. That § Level Ranges by Act row now carries
> the matching exception, so the two documents do not contradict.
>
> **Consequence for #286, stated explicitly.** `serpent_fang` — Marsh
> Serpent's steal and drop — has **no Act I source**. Every remaining
> supplier is Act II or later: Fenmother's Hollow F1–F3 and
> `duskfen_marshland` (both behind `diplomatic_mission_start`),
> `duskfen_hollow`, then Deep Serpent in the Ley Line Depths
> ([act-ii.md](act-ii.md)) and Ashen Serpent in Act III
> ([act-iii.md](act-iii.md)). **That is the canon reading; the current
> build enforces neither gate.** The dungeon transition carries no
> `metadata/required_flag` in `game/scenes/maps/overworld.tscn` and
> `diplomatic_mission_start` is never set by any content
> ([dungeons-world.md](../dungeons-world.md) § 2, tracked as #193), and
> `duskfen_marshland` carries
> no `flag` key in `game/data/encounters/overworld_zones.json` —
> `zone_resolver.gd` skips an entry only when it has one, and the sole
> flagged entry in that file is `pallor_wastes_approach`
> (`act_iii_started`); the zone's `"act"` field in `overworld.json` is
> read by no runtime code. So an Act I party that walks to tiles
> (30, 48)–(41, 58) draws the marsh roster and can farm `serpent_fang`
> today. This is the same class of build gap as #193 and #310, and it is
> what #286 must decide against: the canon reading, with the build gap
> named. One further caveat on checking that against the
> data: `game/data/encounters/caves_and_grottos.json` carries a
> file-level `"act": "act_i"`, but it is a mixed-act file — the same file
> holds `highcairn_hermit_cave` (rolls `pallor_boar`, an Act III enemy)
> and `corrund_river_cave` (Compact constructs) — so its tag does not
> assign an act to `duskfen_hollow`. Duskfen itself opens on flag 8;
> retagging or splitting that file is #314.
>
> The material appears in this file, which a reader takes for an Act I
> roster, while in canon its earliest supplier is now unambiguously
> behind flag 8 (and in the current build behind nothing at all).
> #286 owns the fix — either give it an Act I source or retier it — and
> this note removes the "maybe Fenmother's Hollow is Act I" escape hatch
> that was blocking that decision. Nothing consumes `serpent_fang` today,
> so the severity stays low.

Recommended party level: 12–15 per
[dungeons-world.md](../dungeons-world.md) § 2 — the party arrives at the
Act I/II transition around level 12. Second dungeon -- water-themed,
teaches status effects, elemental resistance, and the cleansing mechanic.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Marsh Serpent | Beast | 6 | 140 | 0 | 19 | 10 | 14 | 10 | 12 | 6 | 13 | Beast Hide (75%) | Serpent Fang (25%) | — | — | — | — | Fenmother's Hollow F1–F3, Duskfen Marshland |
| Bog Leech | Beast | 7 | 192 | 0 | 19 | 13 | 15 | 11 | 13 | 7 | 14 | Beast Hide (75%) | Leech Ichor (25%) | — | — | — | — | Fenmother's Hollow F1–F2, Duskfen Marshland |
| Drowned Bones | Undead | 7 | 211 | 24 | 19 | 14 | 15 | 11 | 11 | 7 | 14 | Bone Fragment (75%) | Spirit Dust (25%) | Spirit | — | — | Poison, Death | Fenmother's Hollow F1–F2 |
| Swamp Lurker | Beast | 8 | 254 | 0 | 20 | 16 | 17 | 12 | 12 | 13 | 26 | Beast Hide (75%) | Lurker Shell (25%) | — | — | — | — | Fenmother's Hollow F1–F3, Duskfen Marshland |
| Ley Jellyfish | Elemental | 8 | 231 | 28 | 17 | 14 | 19 | 13 | 14 | 13 | 26 | Element Shard (75%) | Elemental Core (25%) | Storm | — | Frost | Petrify | Fenmother's Hollow F2–F3 |
| Polluted Elemental | Elemental | 9 | 273 | 31 | 18 | 15 | 20 | 14 | 15 | 13 | 28 | Element Shard (75%) | Elemental Core (25%) | Flame | — | Frost | Petrify | Fenmother's Hollow F2–F3 |
| Corrupted Spawn | Beast | 10 | 288 | 0 | 27 | 14 | 20 | 14 | 16 | 15 | 30 | Beast Hide (75%) | Dark Scale (25%) | — | — | — | — | Fenmother's Hollow F3 (Wave 4) |
| *Drowned Sentinel* | Construct | 10 | 4,000 | 0 | 24 | 19 | 20 | 14 | 14 | 250 | 50 | Scrap Metal (75%) | Crystal Shard (25%) | Storm | — | — | Poison, Sleep, Confusion, Berserk, Despair | Fenmother's Hollow F2 (mini-boss) |
| *Corrupted Fenmother* | Boss | 12 | 18,000 | 42 | 40 | 24 | 39 | 24 | 20 | 150 | 2,500 | Fenmother's Tear (100%) | — | Flame | Frost | — | Death, Petrify, Stop, Sleep, Confusion | Fenmother's Hollow F3 (boss) |

### Boss Notes — Fenmother's Hollow

For full AI scripts, phase mechanics, and scripted events, see
[bosses.md](bosses.md).

- **Drowned Sentinel** (Mini-Boss) — Lv 10, 4,000 HP, Construct. 1 phase.
- **Corrupted Fenmother** — Lv 12, 18,000 HP, Boss. 3 phases.

---

## Overworld Act I

Overworld enemies of the Valdris region and the outer Thornmere band.
Overworld enemies are generally less dangerous than dungeon enemies at
the same level. This table is also the roster source for the
`thornmere_wilds` zone (see the note below); `ley_scarred_plains` draws
partly on Ember Vein enemies instead, documented in that section above.

> **Thornmere Wilds roster (#270):** the Thornmere Wilds zone
> (`thornmere_wilds` in `game/data/encounters/overworld.json`) draws its
> four groups from the forest members of this roster — Wayward Wolf,
> Wild Boar, Forest Sprite, and Thornback Beetle — so those four list
> Thornmere Wilds among their locations. It previously drew on Marsh
> Serpent and Drowned Bones.
>
> **Why that was wrong, precisely.** `thornmere_wilds` carries
> `danger_increment: 148`, which is [geography.md](../geography.md)'s
> **Forest (light)** band ("Valdris border woods, Wilds edges"); the
> dense-forest band is 380, and that is the separate `deep_thornmere`
> zone. The Wilds region does contain marshland, but the marsh has its
> own zone — `duskfen_marshland`, increment 380 — which
> `overworld_zones.json` matches *before* the outer band. So the marsh
> pair were not "marsh creatures in a forest region"; they were marsh
> creatures in the **light-forest zone** while their own zone sat next
> to it. Drowned Bones is genuinely confined to Fenmother's Hollow
> F1–F2. Marsh Serpent is **not** — it also rolls in `duskfen_marshland`
> and `duskfen_hollow` — so "confined" applies to the pair only within
> the Act I overworld, not absolutely.
>
> **Who is admitted, and how to check it.** The four admitted members are
> the roster's woodland species: two forest-floor Beasts (Wayward Wolf,
> Thornback Beetle), a browsing Beast that ranges the woodland margin
> (Wild Boar), and the Spirit type canon binds to old-growth timber
> (Forest Sprite — of the old-growth timber running between the highlands
> and the Wilds, [geography.md](../geography.md) § Valdris Territory /
> Natural Resources says "the trees are considered ley-line guardians";
> the guardians are the trees, and that is the habitat claim, not a claim
> about the Wilds as a region). Plains Hare is
> excluded as open-ground grazer: it rolls only in `aelhart_valley`
> (farmland) and `roads`. Road Bandit is excluded because Humanoid
> bandits need traffic to rob and the roads carry their own `roads`
> zone. That second exclusion is a zone-scoped judgment, not a claim
> that the Wilds are roadless — canon documents the Wildwood Trail, the
> Diplomatic Road and the Wilds Gate Pass through the region; the point
> is only that no tile resolves to both. The `roads` rects do cut the
> Wilds rect — `[46, 16, 47, 28]` and `[44, 60, 45, 63]` overlap
> `thornmere_wilds` `[8, 28, 100, 62]` on eight tiles — but `roads` is
> entry 3 in `overworld_zones.json` and `thornmere_wilds` entry 7, and
> `zone_resolver.gd` is first-match-wins, so those tiles roll the roads
> roster. Road Bandit therefore already appears where the roads cross
> the Wilds; adding it to the Wilds roster would put it on the
> off-road tiles too.
> (This rule replaces an earlier one phrased as "names a forest habitat
> (Valdris Forest or Forest Edge)", which no reader could check: neither
> string was defined anywhere in the repo — see #288 and
> [README.md](README.md) § Location Vocabulary.)
>
> **Reward effect of the swap.** Weight-expected reward per encounter
> rises from 27.8 exp / 13.4 gold to 49.1 exp / 23.9 gold while
> expected group HP falls from 360 to 332. This is deliberate. The
> marsh pair were high-HP, low-reward enemies, which made the old
> Wilds the stingiest of the Act I *regional* zones: 0.077 exp per
> point of enemy HP against 0.145 in Valdris Highlands, 0.154 in
> `ley_scarred_plains` and 0.152 in Aelhart Valley. The new roster
> lands at 0.148, inside that band. (The `roads` zone is lower still at
> 0.056, but it is `act: all` and tuned around the Act II Road Viper,
> so it is not a like-for-like peer.) Because the encounter increment
> is unchanged and fight length tracks enemy HP, reward *per unit of
> play time* is now in line with the rest of the act rather than half
> of it. The Wilds are therefore not an XP farm — that role stays with
> the Ley Scar in Act III ([progression.md](../progression.md)).
>
> **The hardest fight got harder.** Expected group HP falls, but the
> rare format-4 pack grows from 3 enemies / 491 HP to 4 / 536 HP, and
> the weight-expected enemy *count* rises 2.06 → 2.94. The party meets
> the Wilds straight out of Ironmouth at roughly Lv 5–6, so the routine
> encounter is easier and the rare one is not.
>
> **Adjacent zones.** Thornback Beetle and Wayward Wolf also roll in
> `valdris_highlands`; Thornback Beetle additionally rolls in
> `ley_scarred_plains`. Each lists the zones it actually appears in — a
> forest beetle and a wolf pack ranging the adjacent highland and plains
> terrain need no special sanction.
>
> **Overworld coverage is now complete (#288).** Every
> `overworld.json` zone that rolls an Act I enemy is named in that
> enemy's Location cell and in its `locations` array — including the
> three that were previously missing: `aelhart_valley` (Forest Sprite,
> Wild Boar, Plains Hare), `roads` (Plains Hare, Road Bandit) and
> `duskfen_marshland` (Marsh Serpent, Bog Leech, Swamp Lurker, listed on
> their rows in the Fenmother's Hollow table above).
> `game/tests/test_bestiary_locations.gd` fails if a zone is added
> without the matching Location entry.
>
> **Still not reconciled, and out of scope for #270**, which names only
> `thornmere_wilds`, `ley_scarred_plains` and `valdris_highlands`. These
> are *dungeon floors* rather than overworld zones, so the coverage test
> does not reach them; they are deferred to a follow-up sweep:
> - `wilds_gate_pass` (`mountain_passes.json`) rolls Wayward Wolf, Wild
>   Boar and Road Bandit, none of which list it
> - `duskfen_hollow` and `thornvein_grotto`
>   (`caves_and_grottos.json`) likewise
> - `valdris_catacombs` F1 rolls Bone Warden, which does not list it

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Plains Hare | Beast | 1 | 23 | 0 | 8 | 6 | 7 | 5 | 8 | 1 | 4 | Beast Hide (75%) | Hare Pelt (25%) | — | — | — | — | Aelhart Valley, Roads |
| Thornback Beetle | Beast | 3 | 72 | 0 | 12 | 8 | 10 | 7 | 10 | 5 | 10 | Beast Hide (75%) | Beetle Carapace (25%) | — | — | — | — | Ley-Scarred Plains, Thornmere Wilds, Valdris Highlands |
| Road Bandit | Humanoid | 4 | 96 | 0 | 14 | 9 | 11 | 8 | 11 | 5 | 11 | Potion (75%) | Leather Pouch (25%) | — | — | — | — | Roads |
| Forest Sprite | Spirit | 4 | 96 | 14 | 11 | 9 | 12 | 8 | 11 | 5 | 11 | Ether Wisp (75%) | Spirit Essence (25%) | Ley | — | — | Poison, Petrify | Aelhart Valley, Thornmere Wilds |
| Wild Boar | Beast | 5 | 112 | 0 | 18 | 9 | 13 | 9 | 12 | 10 | 21 | Beast Hide (75%) | Boar Tusk (25%) | — | — | — | — | Aelhart Valley, Thornmere Wilds |
| Wayward Wolf | Beast | 6 | 156 | 0 | 17 | 12 | 14 | 10 | 12 | 11 | 22 | Beast Hide (75%) | Wolf Pelt (25%) | — | — | — | — | Thornmere Wilds, Valdris Highlands |

---

## Ironmouth Docks (Act I — Scene 3 Escape)

> **Zone note:** Ironmouth is the story's opening setting — a Carradan
> Compact mining outpost on the southern border of the Thornmere Wilds
> ([locations.md](../locations.md): "This is where the story begins").
> The party's first destination; a Carradan ambush forces the escape that
> drives them into the Wilds. These two enemies are the Compact soldiers of
> that ambush (the forced Scene 3 encounter is 2× Compact Patrol + 1× Compact
> Scout, flee-disabled, with Lira and Sable joining). They are **early
> deployments of the Soldier / Compact family** (base: Compact Soldier Lv 18,
> documented in [act-ii.md](act-ii.md) / [palette-families.md](palette-families.md)),
> appearing far below their projected level per the README "early deployment"
> rule. Stats are transcribed as-shipped from `game/data/enemies/act_i.json`.
>
> **Tutorial-encounter tuning exception (GAP-028 #250):** these two units are
> intentionally hand-tuned for the opening story beat rather than derived from
> the README stat/reward formulas, so they do **not** follow the curve:
> Compact Patrol's HP (180) is deliberately above the Lv 5 curve (~125) to make
> the scripted ambush a sturdier tutorial wall, and both units' Gold (30/35) is
> set higher than the Low-threat reward multiplier would give (~5–6) to seed the
> player's purse at the game's very start. Exp (18/20) is likewise hand-set. This
> is a deliberate, documented exception — the values are correct as shipped and
> should not be "corrected" to the formula. (Compact Scout's HP 140 is within the
> normal Lv 6 band.)
>
> **Steal (#309):** both units carry the Soldier / Compact family's Humanoid
> steal pair — Potion (75%) common, Gold Pouch (25%) rare — the same pair every
> other Humanoid in the corpus ships, including the family base Compact Soldier
> and Act I's other Humanoid, Road Bandit
> ([economy.md](../economy.md) § Steal Tiers by Enemy Type > 'Humanoid'; the
> rare tier is derived, not tabled, per the enemy-data spec's Steal Mapping
> Rule 2). Until #309 these two shipped `"steal": {}` — an empty object that is
> neither of the two canon shapes — and the `—` this table used to show in their
> Steal column was a transcription of that gap, not a design decision.

Recommended party level: 5–6.

| Name | Type | Lv | HP | MP | ATK | DEF | MAG | MDEF | SPD | Gold | Exp | Steal | Drop | Weak | Resists | Absorbs | Status Immunities | Location(s) |
|------|------|----|----|----|----|-----|-----|------|-----|------|-----|-------|------|------|---------|---------|-------------------|-------------|
| Compact Patrol | Humanoid | 5 | 180 | 0 | 16 | 14 | 8 | 10 | 10 | 30 | 18 | Potion (75%) | Potion (75%) | — | — | — | — | Ironmouth Docks (Scene 3) |
| Compact Scout | Humanoid | 6 | 140 | 0 | 14 | 10 | 8 | 8 | 14 | 35 | 20 | Potion (75%) | Antidote (50%) | — | — | — | — | Ironmouth Docks (Scene 3) |

---

## Act I Summary

- **Total:** 27 enemies (22 regular + 1 unique + 2 mini-bosses + 2 bosses)
- **Type coverage:** Beast (11), Undead (3), Construct (1), Spirit (3),
  Elemental (4), Humanoid (3), Boss (2)
- **Threat spread:** Trivial (4), Low (12), Standard (6), Dangerous (3),
  Boss (2)
- **Level range:** 1–12
- **Families started:** 19 (see [palette-families.md](palette-families.md))
  - Vermin, Mite, Dead, Crystal, Shade, Warden, Wisp, Drake, Serpent,
    Leech, Lurker, Jellyfish, Elemental, Hare, Beetle, Bandit, Sprite,
    Boar, Wolf
  - Compact Patrol / Compact Scout are early deployments of the Soldier
    family (base appears Act II), not a new Act I family.
- **Unique:** The Flickering (1)
- **Mechanics introduced:** Basic combat, swarm encounters, undead rules
  (heal-to-damage), elemental weaknesses, physical resistance (Spirit type),
  status effects (poison, paralysis, despair), AoE-on-death, phase transitions,
  cleansing ritual, dive/surface patterns
