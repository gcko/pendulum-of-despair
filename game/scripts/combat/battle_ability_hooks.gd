extends RefCounted
## The modules holding in-force ability and buff state (#158), in the order
## BattleState fans each of its seams out to them. Every one answers on_damage,
## on_fainted, on_status, on_turn_begin, on_turn_end and stat_pct, so no seam
## names one. A new command's hook joins here, and battle_state.gd never changes
## for it.
##
## Order matters where two hooks touch one quantity: BattleBuffs' Regen follows
## BattleRally's Second Wind, since the stronger regen applies (battle_buffs.gd).

const HOOKS: Array = [
	preload("res://scripts/combat/battle_rally.gd"),
	preload("res://scripts/combat/battle_bulwark.gd"),
	preload("res://scripts/combat/battle_forgewright.gd"),
	preload("res://scripts/combat/battle_buffs.gd"),
	preload("res://scripts/combat/battle_tricks.gd"),
	preload("res://scripts/combat/battle_spiritcall.gd"),
]
