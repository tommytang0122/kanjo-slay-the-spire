class_name TurnSystem
extends Node

signal phase_changed(phase: Phase)

enum Phase {
	PLAYER_START,
	PLAYER_TURN,
	ENEMY_ACTION,
	BATTLE_WON,
	BATTLE_LOST,
}

var current_phase: Phase = Phase.PLAYER_START
var turn_number: int = 0

func start_battle() -> void:
	turn_number = 1
	_set_phase(Phase.PLAYER_START)

func begin_player_turn() -> void:
	_set_phase(Phase.PLAYER_TURN)

func end_player_turn() -> void:
	_set_phase(Phase.ENEMY_ACTION)

func begin_next_turn() -> void:
	turn_number += 1
	_set_phase(Phase.PLAYER_START)

func battle_won() -> void:
	_set_phase(Phase.BATTLE_WON)

func battle_lost() -> void:
	_set_phase(Phase.BATTLE_LOST)

func _set_phase(phase: Phase) -> void:
	current_phase = phase
	phase_changed.emit(phase)
