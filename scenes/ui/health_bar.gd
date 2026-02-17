class_name HealthBar
extends Control

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var label: Label = $Label

func update_hp(current_hp: int, max_hp: int) -> void:
	progress_bar.max_value = max_hp
	progress_bar.value = current_hp
	label.text = "%d / %d" % [current_hp, max_hp]
