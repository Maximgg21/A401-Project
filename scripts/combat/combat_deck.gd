class_name CombatDeck
extends RefCounted

signal hand_changed(hand: Array[CardInstance])

var draw_pile: Array[CardInstance]
var hand: Array[CardInstance]
var discard_pile: Array[CardInstance]

var rng := RunState.rng


func _init() -> void:
	for card in RunState.deck:
		draw_pile.append(card)
	_shuffle()


func draw_cards(amount) -> void:
	if draw_pile.is_empty() and discard_pile.is_empty():
		return
	for i in amount:
		if draw_pile.is_empty() and discard_pile.is_empty():
			break
		if draw_pile.is_empty():
			# Previous check confirmed there are still cards in the discard pile
			_shuffle()
		hand.push_back(draw_pile.pop_back())
	hand_changed.emit(hand)


func discard_card(card: CardInstance) -> void:
	if card not in hand:
		return
	discard_pile.append(card)
	hand.erase(card)
	hand_changed.emit(hand)


func discard_all() -> void:
	discard_pile.append_array(hand)
	hand.clear()
	hand_changed.emit(hand)


func _shuffle() -> void:
	draw_pile.append_array(discard_pile)
	discard_pile.clear()

	var n := draw_pile.size()
	for i in range(n - 1, 0, -1): # Fisher–Yates shuffle
		var j := rng.randi_range(0, i)
		var temp := draw_pile[j]
		draw_pile[j] = draw_pile[i]
		draw_pile[i] = temp
