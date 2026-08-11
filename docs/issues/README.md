# Pendulum of Despair — Gap Issues

Design-vs-implementation gaps for the Godot project, produced by a 14-agent
`pod-gap-analysis` ultracode workflow, then **adversarially re-verified** by a
12-agent fresh-eyes pass. Each row links to a full issue file. 🏔️ = epic.

## Verification summary

- **91 issues** analyzed → **86 CONFIRMED**, **1 already done** (GAP-004,
  equipment bonuses ARE applied in battle), **4 overstated** (refined).
- **8 resolved in this pass**: 7 safe fixes applied (GAP-012, 023, 046, 067,
  085, 088, 090) + 1 already-done (GAP-004).
- The remaining **83 are real, open gaps** (incl. 14 epics) migrated to GitHub
  Issues for tracking. This directory is the durable, reviewable source.

**Headline:** the combat system marked "complete" is a basic-attack shell —
Magic (GAP-001), the six character commands (GAP-002), status infliction
(GAP-003), and dual-techs (GAP-005) are unwired.

## Gap-analysis summary

Consolidated 119 raw domain-agent gaps into 91 deduplicated master issues (GAP-001..GAP-091), grouped by area and ordered by severity within area. 14 are marked epic=true (coarse, multi-week content/system gaps): GAP-002 (unique character commands), GAP-016 (crafting), GAP-029/030/031 (continental overworld / transport / dynamic world), GAP-044 (sidequests), GAP-047 (Acts II-IV narrative & scene wiring), GAP-048/049 (dungeons / faction cities), GAP-078/079/080 (music+audio assets / corruption evolution / leitmotifs), GAP-082 (art assets), GAP-091 (post-game).

KEY MERGES across domains: status-effect infliction (combat+tracker -> GAP-003); dual-tech combos (combat+tracker -> GAP-005); ATB/Patience config (save+combat -> GAP-007); combat interaction/buff multipliers + enemy type-traits, same inert damage_calculator params (combat+enemies -> GAP-008); boss AI stub + telegraph + Ember Drake + data-driven interpreter (combat+enemies+tracker -> GAP-009); Cael's hidden spike, one bug seen two ways (combat+progression -> GAP-010); shop sell (items+ui+tracker -> GAP-017); FFR death-persistence (save+arch -> GAP-066); auto-save (save+tracker -> GAP-068); save Copy/Delete (ui+save -> GAP-069); key rebinding (save+ui -> GAP-073); music+audio asset epics merged (GAP-078); Ley Stag bonding folded into transport (GAP-030); rest-AC + device reconfig folded into crafting (GAP-016); level-up notification folded into Battle Results (GAP-062); the four dialogue animation gaps merged (GAP-039); the dead config toggles merged (GAP-074).

BLOCKERS (2): GAP-001 magic command non-functional, GAP-002 six unique character commands route to basic attack — together the combat system's headline features are non-functional despite the tracker marking battle "MOSTLY COMPLETE".

VERIFIED FALSE-COMPLETIONS in the trackers (kept with concrete evidence): ATB formula "complete" but constants diverge ~4x (GAP-006); enemy "type rules complete" but only status immunities ship (GAP-008); shop "buy/sell complete" but buy-only (GAP-017); overworld encounter tables "done" but 12/13 zones unreachable (GAP-026); Cael spike "complete" as +10% damage not the designed stat deltas (GAP-010); Save System "complete with durable XP write-back" but FFR merge is all stubs (GAP-066); cutscene gap 3.7 "complete" without the Act-IV border flicker (GAP-041).

Several Act-I-scope content items were deliberately kept CONCRETE (not folded into the Acts II-IV epic) because their givers/maps are already in the slice and they are individually actionable: Aelhart start-location divergence (GAP-050), Thornwatch (GAP-051), Roothollow/Maren's Refuge/Duskfen/Ironmouth/Valdris-Crown interiors (GAP-052..056). docs/issues/ confirmed empty — this is the initial master list.

## Issues

| ID | Area | Severity | Effort | Status | Title |
|----|------|----------|--------|--------|-------|
| [GAP-001](GAP-001-magic-command-is-non-functional-in-battle-spell-su.md) | Combat | BLOCKER | M | open | Magic command is non-functional in battle — spell submenu never populated |
| [GAP-002](GAP-002-six-unique-character-commands-bulwark-rally-forgew.md) 🏔️ | Combat | HIGH | XL | open | Six unique character commands (Bulwark/Rally/Forgewright/Spiritcall/Tricks/Arcanum) not implemented in battle |
| [GAP-003](GAP-003-status-effect-infliction-is-never-wired-into-comba.md) | Combat | HIGH | M | open | Status-effect infliction is never wired into combat actions |
| [GAP-007](GAP-007-atb-mode-battle-speed-patience-mode-config-never-r.md) | Combat | HIGH | M | open | ATB Mode / Battle Speed / Patience Mode config never reaches the battle system |
| [GAP-011](GAP-011-ley-crystal-progression-uses-a-flat-while-equipped.md) | Progression | HIGH | L | open | Ley Crystal progression uses a flat while-equipped bonus instead of permanent per-level-up accumulation (Esper/Magicite model) |
| [GAP-016](GAP-016-entire-crafting-forging-system-arcanite-forging-un.md) 🏔️ | Items/Economy | HIGH | XL | open | Entire crafting/forging system (Arcanite Forging) unimplemented — data exists, zero gameplay |
| [GAP-017](GAP-017-shop-has-no-sell-mode-and-no-buy-sell-exit-entry-p.md) | Items/Economy | HIGH | L | open | Shop has no Sell mode and no Buy/Sell/Exit entry prompt |
| [GAP-019](GAP-019-crafting-materials-inventory-bucket-never-populate.md) | Items/Economy | HIGH | M | open | Crafting materials inventory bucket never populated; material drops land in consumables and become unusable |
| [GAP-020](GAP-020-permanent-stat-capsules-have-no-effect-write-a-fie.md) | Items/Economy | HIGH | S | open | Permanent stat capsules have no effect (write a field nothing reads; wiped on level-up) |
| [GAP-024](GAP-024-enemy-special-abilities-absent-from-data-regular-e.md) | Enemies | HIGH | L | open | Enemy special abilities absent from data; regular-enemy AI can only basic-attack or defend |
| [GAP-029](GAP-029-continental-overworld-unbuilt-60x40-act-i-screen-v.md) 🏔️ | Exploration | HIGH | XL | open | Continental overworld unbuilt — 60x40 Act-I screen vs designed 128x96 free-scroll continent |
| [GAP-030](GAP-030-transport-vehicle-system-entirely-missing-ley-stag.md) 🏔️ | Exploration | HIGH | L | open | Transport/vehicle system entirely missing (Ley Stag, rail, ferry, Linewalk) |
| [GAP-031](GAP-031-act-based-dynamic-world-transformations-not-implem.md) 🏔️ | Exploration | HIGH | XL | open | Act-based dynamic world transformations not implemented — all locations are single Act-I state |
| [GAP-037](GAP-037-choice-consequences-flag-set-score-not-wired-for-s.md) | Dialogue | HIGH | M | open | Choice consequences (flag_set/score) not wired for standalone NPC/zone/auto-sequence dialogue |
| [GAP-038](GAP-038-numeric-score-increment-clamp-not-implemented-scor.md) | Dialogue | HIGH | M | open | Numeric score increment + clamp not implemented — score choices overwrite instead of accumulate |
| [GAP-044](GAP-044-sidequest-system-entirely-absent-no-schema-no-jour.md) 🏔️ | Story | HIGH | XL | open | Sidequest system entirely absent: no schema, no journal, 0 of 26 quests wired (givers already placed) |
| [GAP-047](GAP-047-epic-acts-ii-iv-interlude-epilogue-narrative-scene.md) 🏔️ | World/Story | HIGH | XL | open | EPIC: Acts II–IV + Interlude + Epilogue narrative, scene wiring, NPCs, and world-state transitions unimplemented |
| [GAP-066](GAP-066-faint-and-fast-reload-death-persistence-is-entirel.md) | Save | HIGH | L | open | Faint-and-Fast-Reload death-persistence is entirely stubbed (XP/level-ups/restore/flags are no-ops) |
| [GAP-067](GAP-067-dialogue-and-cutscenes-read-bundled-defaults-json.md) | Save | HIGH | S | ✅ fixed | Dialogue and cutscenes read bundled defaults.json instead of the player's saved config |
| [GAP-078](GAP-078-epic-music-audio-assets-are-placeholders-5-silent.md) 🏔️ | Audio | HIGH | XL | open | EPIC: Music + audio assets are placeholders (5 silent tracks vs ~70-80 designed; ~51 SFX, 12 ambient missing) |
| [GAP-005](GAP-005-12-dual-tech-combos-are-entirely-unimplemented-com.md) | Combat | MEDIUM | L | open | 12 dual-tech combos are entirely unimplemented (combos.json unused) |
| [GAP-006](GAP-006-atb-battle-speed-factors-diverge-from-combat-formu.md) | Combat | MEDIUM | S | open | ATB battle-speed factors diverge from combat-formulas.md (~4x slower than documented) |
| [GAP-008](GAP-008-combat-interaction-buff-type-trait-multipliers-are.md) | Combat | MEDIUM | L | open | Combat interaction/buff/type-trait multipliers are never applied (damage_calculator params always neutral) |
| [GAP-009](GAP-009-boss-ai-is-stubbed-hardcoded-data-driven-phase-scr.md) | Combat | MEDIUM | L | open | Boss AI is stubbed/hardcoded; data-driven phase scripts, telegraphs, and Ember Drake kit missing |
| [GAP-012](GAP-012-party-join-level-omits-the-design-mandated-1.md) | Progression | MEDIUM | S | ✅ fixed | Party join level omits the design-mandated '-1' |
| [GAP-013](GAP-013-narrative-milestone-stat-spike-system-is-unimpleme.md) | Progression | MEDIUM | L | open | Narrative milestone stat-spike system is unimplemented (no framework; 11 of 12 spikes absent) |
| [GAP-014](GAP-014-ley-crystal-negative-effects-and-special-rule-crys.md) | Progression | MEDIUM | L | open | Ley Crystal negative effects and special-rule crystals have data but no mechanics |
| [GAP-018](GAP-018-shop-buy-mode-missing-descriptions-stat-comparison.md) | Items/Economy | MEDIUM | L | open | Shop Buy mode missing descriptions, stat comparison, compat icons, affordability greying, owned-qty, quantity selector |
| [GAP-021](GAP-021-several-battle-utility-field-item-effects-are-unim.md) | Items/Economy | MEDIUM | M | open | Several battle-utility/field item effects are unimplemented stubs |
| [GAP-022](GAP-022-caldera-employee-card-25-discount-not-applied-at-r.md) | Items/Economy | MEDIUM | S | open | Caldera Employee Card 25% discount not applied at runtime |
| [GAP-025](GAP-025-random-encounter-increment-ignores-act-scale-and-l.md) | Encounters | MEDIUM | M | open | Random-encounter increment ignores act_scale and location_mod |
| [GAP-026](GAP-026-overworld-per-tile-encounter-zones-not-implemented.md) | Encounters | MEDIUM | M | open | Overworld per-tile encounter zones not implemented; 12 of 13 zones are unreachable dead data |
| [GAP-032](GAP-032-region-boundary-banners-not-implemented.md) | Exploration | MEDIUM | S | open | Region boundary banners not implemented |
| [GAP-033](GAP-033-overworld-map-screen-menu-parchment-map-discovery.md) | Exploration | MEDIUM | M | open | Overworld map screen (menu parchment map + discovery) not implemented |
| [GAP-034](GAP-034-per-biome-weather-atmospheric-effects-and-story-ov.md) | Exploration | MEDIUM | M | open | Per-biome weather/atmospheric effects and story overrides not implemented |
| [GAP-036](GAP-036-cutscene-player-ignores-entry-condition-field-all.md) | Dialogue | MEDIUM | M | open (overstated) | Cutscene player ignores entry condition field — all scripted entries play unconditionally |
| [GAP-039](GAP-039-dialogue-animation-system-when-timing-stubbed-stan.md) | Dialogue | MEDIUM | M | open | Dialogue animation system: when-timing stubbed, standalone routing unconnected, clear/hold-reset missing |
| [GAP-042](GAP-042-npc-dialogue-resolver-silently-drops-all-default-l.md) | Story | MEDIUM | M | open | NPC dialogue resolver silently drops all default lines except the last |
| [GAP-043](GAP-043-act-ii-diplomatic-mission-content-is-reachable-com.md) | Story | MEDIUM | S | open | Act II diplomatic-mission content is reachable/completable during Act I with no story gating |
| [GAP-045](GAP-045-npc-act-state-dialogue-variants-unreachable-condit.md) | Story | MEDIUM | M | open | NPC act-state dialogue variants unreachable: conditions on flags never set anywhere |
| [GAP-048](GAP-048-epic-world-dungeons-3-20-and-all-6-city-dungeons-2.md) 🏔️ | World | MEDIUM | XL | open | EPIC: World dungeons 3-20 and all 6 city dungeons + ~20 secret passages unbuilt |
| [GAP-049](GAP-049-epic-faction-cities-settlements-largely-unbuilt-10.md) 🏔️ | World | MEDIUM | XL | open | EPIC: Faction cities/settlements largely unbuilt (10 Carradan, Highcairn, Greyvale, 5 Thornmere settlements, full Duskfen) |
| [GAP-050](GAP-050-aelhart-starting-village-not-built-new-game-starts.md) | World | MEDIUM | L | open | Aelhart starting village not built; new game starts in Ember Vein F1, contradicting the design |
| [GAP-051](GAP-051-thornwatch-border-garrison-act-i-location-2-not-bu.md) | World | MEDIUM | L | open | Thornwatch border garrison (Act I location #2) not built |
| [GAP-052](GAP-052-roothollow-built-as-a-2-npc-stub-vs-a-10-structure.md) | World | MEDIUM | L | open | Roothollow built as a 2-NPC stub vs. a 10-structure root-warren settlement |
| [GAP-053](GAP-053-maren-s-refuge-missing-its-basement-library-and-lo.md) | World | MEDIUM | M | open | Maren's Refuge missing its basement library and lore layer |
| [GAP-055](GAP-055-ironmouth-implemented-as-an-escape-corridor-diverg.md) | World | MEDIUM | M | open | Ironmouth implemented as an escape corridor, diverging from the designed Carradan port city |
| [GAP-056](GAP-056-valdris-crown-act-i-interiors-deferred-chapel-cael.md) | World | MEDIUM | M | open (overstated) | Valdris Crown Act-I interiors deferred: Chapel, Cael's Quarters, Court interiors |
| [GAP-057](GAP-057-hp-mp-solid-pixel-bars-missing-in-battle-party-pan.md) | UI | MEDIUM | M | resolved (PR #275) | HP/MP solid pixel fill bars in battle party panel and main menu |
| [GAP-058](GAP-058-32x32-character-portraits-and-menu-walking-sprites.md) | UI | MEDIUM | L | open | 32x32 character portraits and menu walking sprites not implemented in any menu/HUD |
| [GAP-059](GAP-059-unified-8x8-status-effect-icon-system-not-rendered.md) | UI | MEDIUM | L | open | Unified 8x8 status-effect icon system not rendered anywhere |
| [GAP-060](GAP-060-abilities-screen-lacks-character-specific-ui-and-s.md) | UI | MEDIUM | M | open | Abilities screen lacks character-specific UI and shows hardcoded resource values |
| [GAP-061](GAP-061-equip-stat-comparison-shows-only-6-stats-missing-h.md) | UI | MEDIUM | M | open | Equip stat comparison shows only 6 stats; missing HP/MP rows, EVA/MEVA/CRIT deltas, element/status info line |
| [GAP-062](GAP-062-battle-results-screen-no-level-up-notification-fan.md) | UI | MEDIUM | M | open | Battle Results screen: no level-up notification/fanfare, no per-section advance, raw item_id shown |
| [GAP-068](GAP-068-auto-save-triggers-are-not-wired-into-exploration.md) | Save | MEDIUM | S | open | Auto-save triggers are not wired into exploration |
| [GAP-069](GAP-069-save-screen-copy-and-delete-operations-have-no-rea.md) | Save | MEDIUM | M | open | Save-screen Copy and Delete operations have no reachable UI path |
| [GAP-070](GAP-070-playtime-is-never-incremented-during-gameplay.md) | Save | MEDIUM | S | open | Playtime is never incremented during gameplay |
| [GAP-071](GAP-071-color-blind-mode-config-toggle-has-no-runtime-effe.md) | Save | MEDIUM | L | open | Color-Blind Mode config toggle has no runtime effect |
| [GAP-072](GAP-072-sfx-captions-not-implemented.md) | Save | MEDIUM | M | open | SFX Captions not implemented |
| [GAP-073](GAP-073-keyboard-rebinding-key-config-sub-screen-not-imple.md) | Save | MEDIUM | M | open | Keyboard rebinding / Key Config sub-screen not implemented |
| [GAP-079](GAP-079-epic-corruption-evolution-system-music-ambient-uni.md) 🏔️ | Audio | MEDIUM | L | open | EPIC: Corruption Evolution System (music + ambient) unimplemented in AudioManager |
| [GAP-080](GAP-080-epic-character-leitmotif-system-and-motif-layering.md) 🏔️ | Audio | MEDIUM | XL | open | EPIC: Character Leitmotif System and motif-layering rules have no engine or asset support |
| [GAP-082](GAP-082-epic-all-art-assets-are-placeholders-no-real-sprit.md) 🏔️ | Art | MEDIUM | XL | open | EPIC: All art assets are placeholders (no real sprites, biome tilesets, UI frames, or status icons) |
| [GAP-083](GAP-083-savemanager-core-logic-ffr-migration-validation-co.md) | Tests | MEDIUM | M | open | SaveManager core logic (FFR, migration, validation, corrupt-load) has no unit tests |
| [GAP-004](GAP-004-equipment-stat-bonuses-are-never-applied-in-battle.md) | Combat | LOW | M | ✅ already done | Equipment stat bonuses are never applied in battle |
| [GAP-010](GAP-010-cael-s-hidden-act-i-spike-implemented-as-hardcoded.md) | Combat | LOW | S | open | Cael's hidden Act I spike implemented as hardcoded +10% physical damage instead of ATK+2/MAG+2/SPD+1 |
| [GAP-015](GAP-015-crystal-xp-distribution-ignores-reserve-wearers-an.md) | Progression | LOW | S | open | Crystal XP distribution ignores reserve wearers and KO status |
| [GAP-023](GAP-023-equipment-data-counts-exceed-and-diverge-from-stal.md) | Items/Economy | LOW | S | ✅ fixed | Equipment data counts exceed and diverge from stale tracker figures |
| [GAP-027](GAP-027-formation-overrides-preemptive-charm-sable-s-coin.md) | Encounters | LOW | S | open | Formation overrides (Preemptive Charm, Sable's Coin) not implemented |
| [GAP-028](GAP-028-undocumented-act-i-enemies-in-data-compact-patrol.md) | Enemies | LOW | S | open | Undocumented Act I enemies in data (Compact Patrol, Compact Scout) absent from bestiary |
| [GAP-035](GAP-035-overworld-save-points-missing-camera-edge-boundari.md) | Exploration | LOW | S | open | Overworld save points missing; camera edge boundaries not enforced |
| [GAP-040](GAP-040-speaker-name-tag-diverges-from-design-inline-speak.md) | Dialogue | LOW | S | open | Speaker name tag diverges from design — inline 'SPEAKER:' prefix instead of inset tag (SpeakerLabel dead) |
| [GAP-041](GAP-041-cael-s-act-iv-grey-border-flicker-only-specified-d.md) | Dialogue | LOW | S | open | Cael's Act IV grey border flicker (only specified dialogue-box visual variation) not implemented |
| [GAP-046](GAP-046-duplicate-divergent-chancellor-haren-dialogue-file.md) | Story | LOW | S | ✅ fixed | Duplicate, divergent Chancellor Haren dialogue files — placed NPC uses the thin stub |
| [GAP-054](GAP-054-duskfen-settlement-unbuilt-only-the-spirit-shrine.md) | World | LOW | L | open | Duskfen settlement unbuilt — only the spirit-shrine hub exists |
| [GAP-063](GAP-063-maren-s-battle-weave-gauge-and-guest-npc-5th-party.md) | UI | LOW | M | partial (PR #275; guest row moved to #272) | Maren's Weave Gauge shipped; guest-NPC 5th party row deferred |
| [GAP-064](GAP-064-window-color-config-sliders-update-preview-only-ne.md) | UI | LOW | M | open | Window Color config sliders update preview only — never applied to live UI chrome |
| [GAP-065](GAP-065-item-screen-rendered-as-single-column-without-item.md) | UI | LOW | M | open | Item screen rendered as single column without item icons (design specifies two-column grid) |
| [GAP-074](GAP-074-multiple-config-toggles-persist-but-have-no-runtim.md) | Save | LOW | M | open | Multiple config toggles persist but have no runtime consumers (High-Res Text, Mono Audio, Transition Style, Screen Shake, always-on cues) |
| [GAP-075](GAP-075-inn-rest-flow-diverges-from-spec-no-confirmation-p.md) | Save | LOW | S | open | Inn rest flow diverges from spec (no confirmation prompt, no Rest & Save; save-point device reconfiguration missing) |
| [GAP-076](GAP-076-corruption-detection-save-validation-only-type-che.md) | Save | LOW | S | open | Corruption-detection save validation only type-checks meta and world |
| [GAP-077](GAP-077-config-persistence-is-owned-by-partystate-inventor.md) | Architecture | LOW | M | open | Config persistence is owned by PartyState/inventory_helpers, not SaveManager (responsibility split) |
| [GAP-081](GAP-081-enter-pallor-pallor-wastes-audio-transition-unimpl.md) | Audio | LOW | S | open | enter_pallor() / Pallor Wastes audio transition unimplemented — CROSSFADE_PALLOR constants are dead code |
| [GAP-084](GAP-084-architecture-doc-enemy-schema-diverges-from-actual.md) | Docs | LOW | S | resolved (#235; steal half of the claim was false) | Architecture doc enemy schema diverges from actual JSON data and runtime code |
| [GAP-085](GAP-085-godot-engine-version-mismatch-project-on-4-7-all-d.md) | Docs | LOW | S | ✅ fixed | Godot engine version mismatch: project on 4.7, all docs say 4.6 |
| [GAP-086](GAP-086-inventory-helpers-gd-placed-in-scripts-autoload-bu.md) | Code structure | LOW | S | resolved (Issue #236) | inventory_helpers.gd placed in scripts/autoload/ but is a static helper, not an autoload |
| [GAP-087](GAP-087-multiple-core-files-exceed-the-stated-400-line-str.md) | Code structure | LOW | L | open | Multiple core files exceed the stated ~400-line structure target |
| [GAP-088](GAP-088-resolution-accessibility-doc-divergence-impl-on-12.md) | Docs | LOW | S | ✅ fixed | Resolution/accessibility doc divergence: impl on 1280x720 native + 4x zoom, docs still assume 320x180 integer scaling |
| [GAP-089](GAP-089-design-docs-magic-md-abilities-md-still-mostly-com.md) | Docs | LOW | M | partial (magic.md COMPLETE; 9 ability magnitudes still open) | Design docs magic.md/abilities.md still MOSTLY COMPLETE (numeric balance) but JSON + battle already consume them |
| [GAP-090](GAP-090-music-md-self-contradicts-on-a-game-over-music-cue.md) | Docs | LOW | S | ✅ fixed | music.md self-contradicts on a 'game over' music cue |
| [GAP-091](GAP-091-epic-post-game-content-unbuilt-dreamer-s-fault-bos.md) 🏔️ | Post-game | LOW | L | open | EPIC: Post-game content unbuilt (Dreamer's Fault, boss rush, The Lingering, completion tracking) |
