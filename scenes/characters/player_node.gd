class_name PlayerNode
extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal shield_changed(current_shield: int)
signal died

var max_hp: int = 1
var current_hp: int = 1
var shield: int = 0
var is_alive: bool = true
var role: String = ""
var member_index: int = -1

func setup(data: CharacterData) -> void:
	max_hp = data.max_hp
	current_hp = max_hp
	role = data.role
	shield = 0
	is_alive = true
	hp_changed.emit(current_hp, max_hp)
	shield_changed.emit(shield)

func take_damage(amount: int) -> void:
	var remaining := amount
	if shield > 0:
		var absorbed := mini(shield, remaining)
		shield -= absorbed
		remaining -= absorbed
		shield_changed.emit(shield)
	current_hp = max(0, current_hp - remaining)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		is_alive = false
		died.emit()

func heal(amount: int) -> void:
	if not is_alive:
		return
	current_hp = mini(current_hp + amount, max_hp)
	hp_changed.emit(current_hp, max_hp)

func add_shield(amount: int) -> void:
	if not is_alive:
		return
	shield += amount
	shield_changed.emit(shield)
