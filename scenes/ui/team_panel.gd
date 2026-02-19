class_name TeamPanel
extends VBoxContainer

signal card_dropped_on_member(card: CardData, member_index: int)

const ROLE_COLORS := {
	"tank": Color(0.2, 0.4, 0.8),
	"healer": Color(0.2, 0.8, 0.3),
	"dps1": Color(0.8, 0.6, 0.2),
	"dps2": Color(0.7, 0.2, 0.7),
}

var _slots: Array[MemberSlot] = []
var _hp_bars: Array[ProgressBar] = []
var _hp_labels: Array[Label] = []
var _shield_labels: Array[Label] = []

func setup_members(member_data: Array[CharacterData]) -> void:
	for child in get_children():
		child.queue_free()
	_slots.clear()
	_hp_bars.clear()
	_hp_labels.clear()
	_shield_labels.clear()

	for i in member_data.size():
		var data := member_data[i]
		var slot := _create_member_slot(i, data)
		add_child(slot)
		slot.card_dropped.connect(_on_slot_card_dropped)
		_slots.append(slot)

func _create_member_slot(index: int, data: CharacterData) -> MemberSlot:
	var panel := MemberSlot.new()
	panel.custom_minimum_size = Vector2(200, 50)
	panel.name = "MemberSlot%d" % index
	panel.member_index = index

	var hbox := HBoxContainer.new()
	hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(hbox)

	# Role color indicator
	var color_rect := ColorRect.new()
	color_rect.custom_minimum_size = Vector2(12, 40)
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	color_rect.color = ROLE_COLORS.get(data.role, Color.WHITE)
	hbox.add_child(color_rect)

	var vbox := VBoxContainer.new()
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	# Name label
	var name_label := Label.new()
	name_label.text = data.character_name
	name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(name_label)

	# HP bar
	var hp_bar := ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(120, 16)
	hp_bar.max_value = data.max_hp
	hp_bar.value = data.max_hp
	hp_bar.show_percentage = false
	hp_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(hp_bar)
	_hp_bars.append(hp_bar)

	# HP text + shield
	var info_hbox := HBoxContainer.new()
	info_hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(info_hbox)

	var hp_label := Label.new()
	hp_label.text = "%d / %d" % [data.max_hp, data.max_hp]
	hp_label.add_theme_font_size_override("font_size", 12)
	hp_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_hbox.add_child(hp_label)
	_hp_labels.append(hp_label)

	var shield_label := Label.new()
	shield_label.text = ""
	shield_label.add_theme_font_size_override("font_size", 12)
	shield_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	info_hbox.add_child(shield_label)
	_shield_labels.append(shield_label)

	return panel

func update_member_hp(index: int, current: int, max_val: int) -> void:
	if index < 0 or index >= _hp_bars.size():
		return
	_hp_bars[index].max_value = max_val
	_hp_bars[index].value = current
	_hp_labels[index].text = "%d / %d" % [current, max_val]
	if current <= 0:
		_slots[index].modulate = Color(0.4, 0.4, 0.4)

func update_member_shield(index: int, shield_val: int) -> void:
	if index < 0 or index >= _shield_labels.size():
		return
	if shield_val > 0:
		_shield_labels[index].text = " [%d]" % shield_val
	else:
		_shield_labels[index].text = ""

func _on_slot_card_dropped(card: CardData, member_index: int) -> void:
	card_dropped_on_member.emit(card, member_index)
