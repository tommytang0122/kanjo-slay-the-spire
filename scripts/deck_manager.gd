class_name DeckManager
extends Node

signal hand_updated(hand: Array[CardData])

var draw_pile: Array[CardData] = []
var hand: Array[CardData] = []
var discard_pile: Array[CardData] = []

func setup(deck: Array[CardData]) -> void:
	draw_pile.clear()
	hand.clear()
	discard_pile.clear()
	for card in deck:
		draw_pile.append(card)
	_shuffle_draw_pile()

func draw_cards(count: int) -> void:
	for i in count:
		if draw_pile.is_empty():
			_reshuffle_discard_into_draw()
		if draw_pile.is_empty():
			break
		hand.append(draw_pile.pop_back())
	hand_updated.emit(hand)

func play_card(card: CardData) -> void:
	var idx := hand.find(card)
	if idx == -1:
		return
	hand.remove_at(idx)
	discard_pile.append(card)
	hand_updated.emit(hand)

func discard_hand() -> void:
	discard_pile.append_array(hand)
	hand.clear()
	hand_updated.emit(hand)

func _shuffle_draw_pile() -> void:
	draw_pile.shuffle()

func _reshuffle_discard_into_draw() -> void:
	draw_pile.append_array(discard_pile)
	discard_pile.clear()
	_shuffle_draw_pile()
