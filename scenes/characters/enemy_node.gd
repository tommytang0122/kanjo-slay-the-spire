class_name EnemyNode
extends Node2D

signal hp_changed(current_hp: int, max_hp: int)
signal died
signal intent_changed(intent: String)

var max_hp: int = 1
var current_hp: int = 1
var attack_damage: int = 8
var action_pattern: Array[String] = ["attack", "wait", "attack"]
var action_index: int = 0

@onready var intent_label: Label = $IntentLabel

func setup(data: CharacterData) -> void:
	max_hp = data.max_hp
	current_hp = max_hp
	hp_changed.emit(current_hp, max_hp)
	_update_intent()

func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	if current_hp <= 0:
		died.emit()

func get_current_intent() -> String:
	return action_pattern[action_index]

func execute_action() -> int:
	## Returns damage dealt (0 if waiting)
	var action := action_pattern[action_index]
	action_index = (action_index + 1) % action_pattern.size()
	_update_intent()
	if action == "attack":
		return attack_damage
	return 0

func _update_intent() -> void:
	var intent := get_current_intent()
	var display: String
	if intent == "attack":
		display = "Attack %d" % attack_damage
	else:
		display = "Waiting..."
	intent_changed.emit(display)
	if intent_label:
		intent_label.text = display
