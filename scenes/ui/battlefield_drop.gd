class_name BattlefieldDrop
extends ColorRect

signal card_played_on_field(card: CardData)

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if not data is CardData:
		return false
	# Reject cards that need an ally target (e.g. stack)
	var card := data as CardData
	return card.target_mode != "ally"

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is CardData:
		card_played_on_field.emit(data as CardData)
