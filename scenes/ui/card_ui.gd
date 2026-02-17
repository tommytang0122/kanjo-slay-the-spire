class_name CardUI
extends PanelContainer

signal card_clicked(card: CardData)

var card_data: CardData

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var damage_label: Label = $VBoxContainer/DamageLabel
@onready var cost_label: Label = $VBoxContainer/CostLabel

func setup(data: CardData) -> void:
	card_data = data
	if name_label:
		_update_display()

func _ready() -> void:
	if card_data:
		_update_display()
	gui_input.connect(_on_gui_input)

func _update_display() -> void:
	name_label.text = card_data.card_name
	damage_label.text = card_data.description
	cost_label.text = "Cost: %d" % card_data.cost
	if card_data.card_type == "attack":
		self_modulate = Color(1.0, 0.85, 0.85)
	else:
		self_modulate = Color(0.85, 0.85, 1.0)

func set_playable(can_play: bool) -> void:
	modulate.a = 1.0 if can_play else 0.5
	mouse_filter = Control.MOUSE_FILTER_STOP if can_play else Control.MOUSE_FILTER_IGNORE

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(card_data)
