class_name HandUI
extends HBoxContainer

signal card_selected(card: CardData)

const CARD_UI_SCENE := preload("res://scenes/ui/card_ui.tscn")

var current_energy: int = 0

func update_hand(hand: Array[CardData]) -> void:
	_clear_cards()
	for card_data in hand:
		var card_ui: CardUI = CARD_UI_SCENE.instantiate()
		add_child(card_ui)
		card_ui.setup(card_data)
		card_ui.card_clicked.connect(_on_card_clicked)
	_refresh_playable()

func update_energy(current: int, _max: int) -> void:
	current_energy = current
	_refresh_playable()

func _refresh_playable() -> void:
	for child in get_children():
		if child is CardUI:
			child.set_playable(current_energy >= child.card_data.cost)

func _clear_cards() -> void:
	for child in get_children():
		child.queue_free()

func _on_card_clicked(card: CardData) -> void:
	card_selected.emit(card)
