class_name MemberSlot
extends PanelContainer

signal card_dropped(card: CardData, member_index: int)

var member_index: int = -1

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is CardData

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is CardData:
		card_dropped.emit(data as CardData, member_index)
