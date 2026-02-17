class_name DeckManager
extends Node

signal hand_updated(hand: Array[CardData])

const HAND_SIZE := 4

var queue: Array[CardData] = []

var hand: Array[CardData]:
	get:
		var result: Array[CardData] = []
		for i in mini(HAND_SIZE, queue.size()):
			result.append(queue[i])
		return result

func setup(deck: Array[CardData]) -> void:
	queue.clear()
	for card in deck:
		queue.append(card)
	hand_updated.emit(hand)

func play_card(card: CardData) -> void:
	var idx := -1
	for i in mini(HAND_SIZE, queue.size()):
		if queue[i] == card:
			idx = i
			break
	if idx == -1:
		return
	var played := queue[idx]
	queue.remove_at(idx)
	queue.append(played)
	hand_updated.emit(hand)
