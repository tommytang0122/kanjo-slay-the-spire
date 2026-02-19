class_name CardUI
extends PanelContainer

var card_data: CardData
var _playable: bool = true

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

func _update_display() -> void:
	name_label.text = card_data.card_name
	damage_label.text = card_data.description
	cost_label.text = "Cost: %d" % card_data.cost
	match card_data.card_type:
		"attack":
			self_modulate = Color(1.0, 0.85, 0.85)  # red
		"shield_up":
			self_modulate = Color(0.85, 0.85, 1.0)  # blue
		"area_heal":
			self_modulate = Color(0.85, 1.0, 0.85)  # green
		"final_hit":
			self_modulate = Color(1.0, 0.85, 1.0)  # purple
		"two_pair", "four_split", "stack":
			self_modulate = Color(0.95, 0.9, 0.75)  # gold for formations
		_:
			self_modulate = Color(0.9, 0.9, 0.8)  # beige

func set_playable(can_play: bool) -> void:
	_playable = can_play
	_update_playable_display()

func _update_playable_display() -> void:
	modulate.a = 1.0 if _playable else 0.5

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not _playable:
		return null
	var preview := Label.new()
	preview.text = card_data.card_name
	preview.add_theme_font_size_override("font_size", 16)
	set_drag_preview(preview)
	return card_data

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_BEGIN:
		modulate.a = 0.3
	elif what == NOTIFICATION_DRAG_END:
		_update_playable_display()
