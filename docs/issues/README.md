# Pendulum of Despair — Gap Issues

Design-vs-implementation gaps for the Godot project, produced by the
`pod-gap-analysis` ultracode workflow on 2026-06-27. Each row links to a full
issue file. 🏔️ marks an **epic** (large multi-week content/feature work).

**91 issues.** These are migrated to GitHub Issues for tracking;
this directory is the durable, reviewable source.

## Summary

Consolidated 119 raw domain-agent gaps into 91 deduplicated master issues (GAP-001..GAP-091), grouped by area and ordered by severity within area. 14 are marked epic=true (coarse, multi-week content/system gaps): GAP-002 (unique character commands), GAP-016 (crafting), GAP-029/030/031 (continental overworld / transport / dynamic world), GAP-044 (sidequests), GAP-047 (Acts II-IV narrative & scene wiring), GAP-048/049 (dungeons / faction cities), GAP-078/079/080 (music+audio assets / corruption evolution / leitmotifs), GAP-082 (art assets), GAP-091 (post-game).

KEY MERGES across domains: status-effect infliction (combat+tracker -> GAP-003); dual-tech combos (combat+tracker -> GAP-005); ATB/Patience config (save+combat -> GAP-007); combat interaction/buff multipliers + enemy type-traits, same inert damage_calculator params (combat+enemies -> GAP-008); boss AI stub + telegraph + Ember Drake + data-driven interpreter (combat+enemies+tracker -> GAP-009); Cael's hidden spike, one bug seen two ways (combat+progression -> GAP-010); shop sell (items+ui+tracker -> GAP-017); FFR death-persistence (save+arch -> GAP-066); auto-save (save+tracker -> GAP-068); save Copy/Delete (ui+save -> GAP-069); key rebinding (save+ui -> GAP-073); music+audio asset epics merged (GAP-078); Ley Stag bonding folded into transport (GAP-030); rest-AC + device reconfig folded into crafting (GAP-016); level-up notification folded into Battle Results (GAP-062); the four dialogue animation gaps merged (GAP-039); the dead config toggles merged (GAP-074).

BLOCKERS (2): GAP-001 magic command non-functional, GAP-002 six unique character commands route to basic attack — together the combat system's headline features are non-functional despite the tracker marking battle "MOSTLY COMPLETE".

VERIFIED FALSE-COMPLETIONS in the trackers (kept with concrete evidence): ATB formula "complete" but constants diverge ~4x (GAP-006); enemy "type rules complete" but only status immunities ship (GAP-008); shop "buy/sell complete" but buy-only (GAP-017); overworld encounter tables "done" but 12/13 zones unreachable (GAP-026); Cael spike "complete" as +10% damage not the designed stat deltas (GAP-010); Save System "complete with durable XP write-back" but FFR merge is all stubs (GAP-066); cutscene gap 3.7 "complete" without the Act-IV border flicker (GAP-041).

Several Act-I-scope content items were deliberately kept CONCRETE (not folded into the Acts II-IV epic) because their givers/maps are already in the slice and they are individually actionable: Aelhart start-location divergence (GAP-050), Thornwatch (GAP-051), Roothollow/Maren's Refuge/Duskfen/Ironmouth/Valdris-Crown interiors (GAP-052..056). docs/issues/ confirmed empty — this is the initial master list.

## Issues

| ID | Area | Severity | Type | Effort | Title |
|----|------|----------|------|--------|-------|
| [GAP-001](GAP-001-magic-command-is-non-functional-in-battle-spell-su.md) | Combat | BLOCKER | partial-impl | M | Magic command is non-functional in battle — spell submenu never populated |
| [GAP-002](GAP-002-six-unique-character-commands-bulwark-rally-forgew.md) 🏔️ | Combat | BLOCKER | missing-feature | XL | Six unique character commands (Bulwark/Rally/Forgewright/Spiritcall/Tricks/Arcanum) not implemented in battle |
| [GAP-003](GAP-003-status-effect-infliction-is-never-wired-into-comba.md) | Combat | HIGH | partial-impl | M | Status-effect infliction is never wired into combat actions |
| [GAP-004](GAP-004-equipment-stat-bonuses-are-never-applied-in-battle.md) | Combat | HIGH | partial-impl | M | Equipment stat bonuses are never applied in battle |
| [GAP-005](GAP-005-12-dual-tech-combos-are-entirely-unimplemented-com.md) | Combat | HIGH | missing-feature | L | 12 dual-tech combos are entirely unimplemented (combos.json unused) |
| [GAP-006](GAP-006-atb-battle-speed-factors-diverge-from-combat-formu.md) | Combat | HIGH | design-divergence | S | ATB battle-speed factors diverge from combat-formulas.md (~4x slower than documented) |
| [GAP-007](GAP-007-atb-mode-battle-speed-patience-mode-config-never-r.md) | Combat | HIGH | partial-impl | M | ATB Mode / Battle Speed / Patience Mode config never reaches the battle system |
| [GAP-011](GAP-011-ley-crystal-progression-uses-a-flat-while-equipped.md) | Progression | HIGH | design-divergence | L | Ley Crystal progression uses a flat while-equipped bonus instead of permanent per-level-up accumulation (Esper/Magicite model) |
| [GAP-016](GAP-016-entire-crafting-forging-system-arcanite-forging-un.md) 🏔️ | Items/Economy | HIGH | missing-feature | XL | Entire crafting/forging system (Arcanite Forging) unimplemented — data exists, zero gameplay |
| [GAP-017](GAP-017-shop-has-no-sell-mode-and-no-buy-sell-exit-entry-p.md) | Items/Economy | HIGH | missing-feature | L | Shop has no Sell mode and no Buy/Sell/Exit entry prompt |
| [GAP-018](GAP-018-shop-buy-mode-missing-descriptions-stat-comparison.md) | Items/Economy | HIGH | partial-impl | L | Shop Buy mode missing descriptions, stat comparison, compat icons, affordability greying, owned-qty, quantity selector |
| [GAP-019](GAP-019-crafting-materials-inventory-bucket-never-populate.md) | Items/Economy | HIGH | bug | M | Crafting materials inventory bucket never populated; material drops land in consumables and become unusable |
| [GAP-020](GAP-020-permanent-stat-capsules-have-no-effect-write-a-fie.md) | Items/Economy | HIGH | bug | S | Permanent stat capsules have no effect (write a field nothing reads; wiped on level-up) |
| [GAP-024](GAP-024-enemy-special-abilities-absent-from-data-regular-e.md) | Enemies | HIGH | missing-feature | L | Enemy special abilities absent from data; regular-enemy AI can only basic-attack or defend |
| [GAP-029](GAP-029-continental-overworld-unbuilt-60x40-act-i-screen-v.md) 🏔️ | Exploration | HIGH | missing-feature | XL | Continental overworld unbuilt — 60x40 Act-I screen vs designed 128x96 free-scroll continent |
| [GAP-030](GAP-030-transport-vehicle-system-entirely-missing-ley-stag.md) 🏔️ | Exploration | HIGH | missing-feature | L | Transport/vehicle system entirely missing (Ley Stag, rail, ferry, Linewalk) |
| [GAP-031](GAP-031-act-based-dynamic-world-transformations-not-implem.md) 🏔️ | Exploration | HIGH | missing-feature | XL | Act-based dynamic world transformations not implemented — all locations are single Act-I state |
| [GAP-036](GAP-036-cutscene-player-ignores-entry-condition-field-all.md) | Dialogue | HIGH | partial-impl | M | Cutscene player ignores entry condition field — all scripted entries play unconditionally |
| [GAP-037](GAP-037-choice-consequences-flag-set-score-not-wired-for-s.md) | Dialogue | HIGH | bug | M | Choice consequences (flag_set/score) not wired for standalone NPC/zone/auto-sequence dialogue |
| [GAP-038](GAP-038-numeric-score-increment-clamp-not-implemented-scor.md) | Dialogue | HIGH | missing-feature | M | Numeric score increment + clamp not implemented — score choices overwrite instead of accumulate |
| [GAP-042](GAP-042-npc-dialogue-resolver-silently-drops-all-default-l.md) | Story | HIGH | bug | M | NPC dialogue resolver silently drops all default lines except the last |
| [GAP-043](GAP-043-act-ii-diplomatic-mission-content-is-reachable-com.md) | Story | HIGH | design-divergence | S | Act II diplomatic-mission content is reachable/completable during Act I with no story gating |
| [GAP-044](GAP-044-sidequest-system-entirely-absent-no-schema-no-jour.md) 🏔️ | Story | HIGH | missing-feature | XL | Sidequest system entirely absent: no schema, no journal, 0 of 26 quests wired (givers already placed) |
| [GAP-047](GAP-047-epic-acts-ii-iv-interlude-epilogue-narrative-scene.md) 🏔️ | World/Story | HIGH | missing-feature | XL | EPIC: Acts II–IV + Interlude + Epilogue narrative, scene wiring, NPCs, and world-state transitions unimplemented |
| [GAP-048](GAP-048-epic-world-dungeons-3-20-and-all-6-city-dungeons-2.md) 🏔️ | World | HIGH | missing-feature | XL | EPIC: World dungeons 3-20 and all 6 city dungeons + ~20 secret passages unbuilt |
| [GAP-049](GAP-049-epic-faction-cities-settlements-largely-unbuilt-10.md) 🏔️ | World | HIGH | missing-feature | XL | EPIC: Faction cities/settlements largely unbuilt (10 Carradan, Highcairn, Greyvale, 5 Thornmere settlements, full Duskfen) |
| [GAP-050](GAP-050-aelhart-starting-village-not-built-new-game-starts.md) | World | HIGH | design-divergence | L | Aelhart starting village not built; new game starts in Ember Vein F1, contradicting the design |
| [GAP-057](GAP-057-hp-mp-solid-pixel-bars-missing-in-battle-party-pan.md) | UI | HIGH | design-divergence | M | HP/MP solid pixel bars missing in battle party panel and main menu (numeric text only) |
| [GAP-066](GAP-066-faint-and-fast-reload-death-persistence-is-entirel.md) | Save | HIGH | partial-impl | L | Faint-and-Fast-Reload death-persistence is entirely stubbed (XP/level-ups/restore/flags are no-ops) |
| [GAP-067](GAP-067-dialogue-and-cutscenes-read-bundled-defaults-json.md) | Save | HIGH | bug | S | Dialogue and cutscenes read bundled defaults.json instead of the player's saved config |
| [GAP-078](GAP-078-epic-music-audio-assets-are-placeholders-5-silent.md) 🏔️ | Audio | HIGH | missing-feature | XL | EPIC: Music + audio assets are placeholders (5 silent tracks vs ~70-80 designed; ~51 SFX, 12 ambient missing) |
| [GAP-008](GAP-008-combat-interaction-buff-type-trait-multipliers-are.md) | Combat | MEDIUM | partial-impl | L | Combat interaction/buff/type-trait multipliers are never applied (damage_calculator params always neutral) |
| [GAP-009](GAP-009-boss-ai-is-stubbed-hardcoded-data-driven-phase-scr.md) | Combat | MEDIUM | design-divergence | L | Boss AI is stubbed/hardcoded; data-driven phase scripts, telegraphs, and Ember Drake kit missing |
| [GAP-012](GAP-012-party-join-level-omits-the-design-mandated-1.md) | Progression | MEDIUM | bug | S | Party join level omits the design-mandated '-1' |
| [GAP-013](GAP-013-narrative-milestone-stat-spike-system-is-unimpleme.md) | Progression | MEDIUM | missing-feature | L | Narrative milestone stat-spike system is unimplemented (no framework; 11 of 12 spikes absent) |
| [GAP-014](GAP-014-ley-crystal-negative-effects-and-special-rule-crys.md) | Progression | MEDIUM | partial-impl | L | Ley Crystal negative effects and special-rule crystals have data but no mechanics |
| [GAP-021](GAP-021-several-battle-utility-field-item-effects-are-unim.md) | Items/Economy | MEDIUM | partial-impl | M | Several battle-utility/field item effects are unimplemented stubs |
| [GAP-022](GAP-022-caldera-employee-card-25-discount-not-applied-at-r.md) | Items/Economy | MEDIUM | missing-feature | S | Caldera Employee Card 25% discount not applied at runtime |
| [GAP-025](GAP-025-random-encounter-increment-ignores-act-scale-and-l.md) | Encounters | MEDIUM | design-divergence | M | Random-encounter increment ignores act_scale and location_mod |
| [GAP-026](GAP-026-overworld-per-tile-encounter-zones-not-implemented.md) | Encounters | MEDIUM | partial-impl | M | Overworld per-tile encounter zones not implemented; 12 of 13 zones are unreachable dead data |
| [GAP-032](GAP-032-region-boundary-banners-not-implemented.md) | Exploration | MEDIUM | missing-feature | S | Region boundary banners not implemented |
| [GAP-033](GAP-033-overworld-map-screen-menu-parchment-map-discovery.md) | Exploration | MEDIUM | missing-feature | M | Overworld map screen (menu parchment map + discovery) not implemented |
| [GAP-034](GAP-034-per-biome-weather-atmospheric-effects-and-story-ov.md) | Exploration | MEDIUM | missing-feature | M | Per-biome weather/atmospheric effects and story overrides not implemented |
| [GAP-039](GAP-039-dialogue-animation-system-when-timing-stubbed-stan.md) | Dialogue | MEDIUM | partial-impl | M | Dialogue animation system: when-timing stubbed, standalone routing unconnected, clear/hold-reset missing |
| [GAP-045](GAP-045-npc-act-state-dialogue-variants-unreachable-condit.md) | Story | MEDIUM | partial-impl | M | NPC act-state dialogue variants unreachable: conditions on flags never set anywhere |
| [GAP-051](GAP-051-thornwatch-border-garrison-act-i-location-2-not-bu.md) | World | MEDIUM | missing-feature | L | Thornwatch border garrison (Act I location #2) not built |
| [GAP-052](GAP-052-roothollow-built-as-a-2-npc-stub-vs-a-10-structure.md) | World | MEDIUM | partial-impl | L | Roothollow built as a 2-NPC stub vs. a 10-structure root-warren settlement |
| [GAP-053](GAP-053-maren-s-refuge-missing-its-basement-library-and-lo.md) | World | MEDIUM | partial-impl | M | Maren's Refuge missing its basement library and lore layer |
| [GAP-054](GAP-054-duskfen-settlement-unbuilt-only-the-spirit-shrine.md) | World | MEDIUM | partial-impl | L | Duskfen settlement unbuilt — only the spirit-shrine hub exists |
| [GAP-055](GAP-055-ironmouth-implemented-as-an-escape-corridor-diverg.md) | World | MEDIUM | design-divergence | M | Ironmouth implemented as an escape corridor, diverging from the designed Carradan port city |
| [GAP-056](GAP-056-valdris-crown-act-i-interiors-deferred-chapel-cael.md) | World | MEDIUM | partial-impl | M | Valdris Crown Act-I interiors deferred: Chapel, Cael's Quarters, Court interiors |
| [GAP-058](GAP-058-32x32-character-portraits-and-menu-walking-sprites.md) | UI | MEDIUM | missing-feature | L | 32x32 character portraits and menu walking sprites not implemented in any menu/HUD |
| [GAP-059](GAP-059-unified-8x8-status-effect-icon-system-not-rendered.md) | UI | MEDIUM | missing-feature | L | Unified 8x8 status-effect icon system not rendered anywhere |
| [GAP-060](GAP-060-abilities-screen-lacks-character-specific-ui-and-s.md) | UI | MEDIUM | partial-impl | M | Abilities screen lacks character-specific UI and shows hardcoded resource values |
| [GAP-061](GAP-061-equip-stat-comparison-shows-only-6-stats-missing-h.md) | UI | MEDIUM | partial-impl | M | Equip stat comparison shows only 6 stats; missing HP/MP rows, EVA/MEVA/CRIT deltas, element/status info line |
| [GAP-062](GAP-062-battle-results-screen-no-level-up-notification-fan.md) | UI | MEDIUM | partial-impl | M | Battle Results screen: no level-up notification/fanfare, no per-section advance, raw item_id shown |
| [GAP-068](GAP-068-auto-save-triggers-are-not-wired-into-exploration.md) | Save | MEDIUM | partial-impl | S | Auto-save triggers are not wired into exploration |
| [GAP-069](GAP-069-save-screen-copy-and-delete-operations-have-no-rea.md) | Save | MEDIUM | partial-impl | M | Save-screen Copy and Delete operations have no reachable UI path |
| [GAP-070](GAP-070-playtime-is-never-incremented-during-gameplay.md) | Save | MEDIUM | bug | S | Playtime is never incremented during gameplay |
| [GAP-071](GAP-071-color-blind-mode-config-toggle-has-no-runtime-effe.md) | Save | MEDIUM | missing-feature | L | Color-Blind Mode config toggle has no runtime effect |
| [GAP-072](GAP-072-sfx-captions-not-implemented.md) | Save | MEDIUM | missing-feature | M | SFX Captions not implemented |
| [GAP-073](GAP-073-keyboard-rebinding-key-config-sub-screen-not-imple.md) | Save | MEDIUM | missing-feature | M | Keyboard rebinding / Key Config sub-screen not implemented |
| [GAP-079](GAP-079-epic-corruption-evolution-system-music-ambient-uni.md) 🏔️ | Audio | MEDIUM | missing-feature | L | EPIC: Corruption Evolution System (music + ambient) unimplemented in AudioManager |
| [GAP-080](GAP-080-epic-character-leitmotif-system-and-motif-layering.md) 🏔️ | Audio | MEDIUM | missing-feature | XL | EPIC: Character Leitmotif System and motif-layering rules have no engine or asset support |
| [GAP-082](GAP-082-epic-all-art-assets-are-placeholders-no-real-sprit.md) 🏔️ | Art | MEDIUM | missing-feature | XL | EPIC: All art assets are placeholders (no real sprites, biome tilesets, UI frames, or status icons) |
| [GAP-083](GAP-083-savemanager-core-logic-ffr-migration-validation-co.md) | Tests | MEDIUM | test-gap | M | SaveManager core logic (FFR, migration, validation, corrupt-load) has no unit tests |
| [GAP-084](GAP-084-architecture-doc-enemy-schema-diverges-from-actual.md) | Docs | MEDIUM | doc-inconsistency | S | Architecture doc enemy schema diverges from actual JSON data and runtime code |
| [GAP-010](GAP-010-cael-s-hidden-act-i-spike-implemented-as-hardcoded.md) | Combat | LOW | design-divergence | S | Cael's hidden Act I spike implemented as hardcoded +10% physical damage instead of ATK+2/MAG+2/SPD+1 |
| [GAP-015](GAP-015-crystal-xp-distribution-ignores-reserve-wearers-an.md) | Progression | LOW | partial-impl | S | Crystal XP distribution ignores reserve wearers and KO status |
| [GAP-023](GAP-023-equipment-data-counts-exceed-and-diverge-from-stal.md) | Items/Economy | LOW | doc-inconsistency | S | Equipment data counts exceed and diverge from stale tracker figures |
| [GAP-027](GAP-027-formation-overrides-preemptive-charm-sable-s-coin.md) | Encounters | LOW | partial-impl | S | Formation overrides (Preemptive Charm, Sable's Coin) not implemented |
| [GAP-028](GAP-028-undocumented-act-i-enemies-in-data-compact-patrol.md) | Enemies | LOW | doc-inconsistency | S | Undocumented Act I enemies in data (Compact Patrol, Compact Scout) absent from bestiary |
| [GAP-035](GAP-035-overworld-save-points-missing-camera-edge-boundari.md) | Exploration | LOW | partial-impl | S | Overworld save points missing; camera edge boundaries not enforced |
| [GAP-040](GAP-040-speaker-name-tag-diverges-from-design-inline-speak.md) | Dialogue | LOW | design-divergence | S | Speaker name tag diverges from design — inline 'SPEAKER:' prefix instead of inset tag (SpeakerLabel dead) |
| [GAP-041](GAP-041-cael-s-act-iv-grey-border-flicker-only-specified-d.md) | Dialogue | LOW | missing-feature | S | Cael's Act IV grey border flicker (only specified dialogue-box visual variation) not implemented |
| [GAP-046](GAP-046-duplicate-divergent-chancellor-haren-dialogue-file.md) | Story | LOW | data-error | S | Duplicate, divergent Chancellor Haren dialogue files — placed NPC uses the thin stub |
| [GAP-063](GAP-063-maren-s-battle-weave-gauge-and-guest-npc-5th-party.md) | UI | LOW | missing-feature | M | Maren's battle Weave Gauge and guest-NPC 5th party row not implemented |
| [GAP-064](GAP-064-window-color-config-sliders-update-preview-only-ne.md) | UI | LOW | design-divergence | M | Window Color config sliders update preview only — never applied to live UI chrome |
| [GAP-065](GAP-065-item-screen-rendered-as-single-column-without-item.md) | UI | LOW | design-divergence | M | Item screen rendered as single column without item icons (design specifies two-column grid) |
| [GAP-074](GAP-074-multiple-config-toggles-persist-but-have-no-runtim.md) | Save | LOW | partial-impl | M | Multiple config toggles persist but have no runtime consumers (High-Res Text, Mono Audio, Transition Style, Screen Shake, always-on cues) |
| [GAP-075](GAP-075-inn-rest-flow-diverges-from-spec-no-confirmation-p.md) | Save | LOW | design-divergence | S | Inn rest flow diverges from spec (no confirmation prompt, no Rest & Save; save-point device reconfiguration missing) |
| [GAP-076](GAP-076-corruption-detection-save-validation-only-type-che.md) | Save | LOW | partial-impl | S | Corruption-detection save validation only type-checks meta and world |
| [GAP-077](GAP-077-config-persistence-is-owned-by-partystate-inventor.md) | Architecture | LOW | design-divergence | M | Config persistence is owned by PartyState/inventory_helpers, not SaveManager (responsibility split) |
| [GAP-081](GAP-081-enter-pallor-pallor-wastes-audio-transition-unimpl.md) | Audio | LOW | partial-impl | S | enter_pallor() / Pallor Wastes audio transition unimplemented — CROSSFADE_PALLOR constants are dead code |
| [GAP-085](GAP-085-godot-engine-version-mismatch-project-on-4-7-all-d.md) | Docs | LOW | doc-inconsistency | S | Godot engine version mismatch: project on 4.7, all docs say 4.6 |
| [GAP-086](GAP-086-inventory-helpers-gd-placed-in-scripts-autoload-bu.md) | Code structure | LOW | design-divergence | S | inventory_helpers.gd placed in scripts/autoload/ but is a static helper, not an autoload |
| [GAP-087](GAP-087-multiple-core-files-exceed-the-stated-400-line-str.md) | Code structure | LOW | partial-impl | L | Multiple core files exceed the stated ~400-line structure target |
| [GAP-088](GAP-088-resolution-accessibility-doc-divergence-impl-on-12.md) | Docs | LOW | doc-inconsistency | S | Resolution/accessibility doc divergence: impl on 1280x720 native + 4x zoom, docs still assume 320x180 integer scaling |
| [GAP-089](GAP-089-design-docs-magic-md-abilities-md-still-mostly-com.md) | Docs | LOW | doc-inconsistency | M | Design docs magic.md/abilities.md still MOSTLY COMPLETE (numeric balance) but JSON + battle already consume them |
| [GAP-090](GAP-090-music-md-self-contradicts-on-a-game-over-music-cue.md) | Docs | LOW | doc-inconsistency | S | music.md self-contradicts on a 'game over' music cue |
| [GAP-091](GAP-091-epic-post-game-content-unbuilt-dreamer-s-fault-bos.md) 🏔️ | Post-game | LOW | missing-feature | L | EPIC: Post-game content unbuilt (Dreamer's Fault, boss rush, The Lingering, completion tracking) |
