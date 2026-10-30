class_name BattleStatusNotices
extends RefCounted
## What the player is told when a status lands on, is kept off, or leaves a
## combatant: the registry's battle-dialogue lines and the floating markers.
## The battle manager wires BattleState's status signals and each enemy's
## status_applied here.
##
## Extracted from battle_manager.gd (GAP-087) so the manager keeps the ATB loop
## and the command dispatch.

const StatusEffects = preload("res://scripts/combat/status_effects.gd")

var _battle: Node


func _init(battle: Node) -> void:
	_battle = battle


## Tell the player a status just landed on a party member (#299). Routed through
## the one registry table so the wording is battle-dialogue.md
## § Status Effect Notifications rather than a per-caller invention, and so
## every path that lands a status on the PARTY announces it the same way,
## whatever inflicted it. A status with no canonical line lands silently.
func party_applied(slot: int, status_name: String) -> void:
	var state: Node = _battle.get_battle_state()
	var nm: String = state.get_member(slot).get("character_data", {}).get("name", "???")
	var line: String = StatusEffects.application_notice(status_name, nm)
	if not line.is_empty():
		_battle.message.emit(line)


## Worn gear kept a status off a party member (#512): the same "Immune" marker an
## immune enemy shows, and no line, since nothing landed.
func party_blocked(slot: int, _status_name: String) -> void:
	_battle.damage_dealt.emit("party_%d" % slot, 0, "immune")


## A status left a party member by a cure ([param cured]) or by running out
## (#515). A cure says "Poison was cured!"; an expiry says the status's own
## "wears off" line where battle-dialogue.md gives one, else nothing. A waking hit
## and a KO end a status by neither path, so they add no line here.
func party_ended(_slot: int, status_name: String, cured: bool) -> void:
	var line: String = StatusEffects.wears_off_notice(status_name)
	if cured:
		line = StatusEffects.cure_notice(status_name)
	if not line.is_empty():
		_battle.message.emit(line)


## Enemy-side mirror of party_applied (#439), wired to each enemy's
## own status_applied, so a status spell, a spell's rider or any later path
## shows the same marker and reads the same registry line.
func enemy_applied(status_name: String, _duration: int, enemy: Node) -> void:
	var idx: int = _battle.get_enemies().find(enemy)
	if idx < 0:
		return
	_battle.resync_enemy_atb(idx)
	_battle.damage_dealt.emit("enemy_%d" % idx, 0, "status")
	var line: String = StatusEffects.application_notice(status_name, enemy.get_display_name())
	if not line.is_empty():
		_battle.message.emit(line)
