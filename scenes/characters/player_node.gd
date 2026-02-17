class_name PlayerNode
extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal died

var max_hp: int = 1
var current_hp: int = 1

func setup(data: CharacterData) -> void:
	max_hp = data.max_hp
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		died.emit()
