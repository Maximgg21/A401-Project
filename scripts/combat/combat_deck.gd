class_name CombatDeck
extends RefCounted

signal piles_changed(draw_count: int, discard_count: int)
signal hand_changed(hand: Array[Card])

var draw_pile: Array[Card]
var hand: Array[Card]
var discard_pile: Array[Card]

var rng := RunState.rng


func _init() -> void:
	for card in RunState.deck:
		draw_pile.append(card)
	_shuffle()


func _emit_changes() -> void:
	hand_changed.emit(hand)
	piles_changed.emit(draw_pile.size(), discard_pile.size())


func draw(amount: int) -> void:
	if draw_pile.is_empty() and discard_pile.is_empty():
		return
	for i in amount:
		if draw_pile.is_empty() and discard_pile.is_empty():
			break
		if draw_pile.is_empty():
			# Previous check confirmed there are still cards in the discard pile
			_shuffle()
		hand.push_back(draw_pile.pop_back())
	_emit_changes()


func discard_one(card: Card) -> void:
	if card not in hand:
		return
	discard_pile.append(card)
	hand.erase(card)
	_emit_changes()


func discard_all() -> void:
	discard_pile.append_array(hand)
	hand.clear()
	_emit_changes()


func _shuffle() -> void:
	draw_pile.append_array(discard_pile)
	discard_pile.clear()

	var n := draw_pile.size()
	for i in range(n - 1, 0, -1): # Fisher–Yates shuffle
		var j: int = rng.randi_range(0, i)
		var temp := draw_pile[j]
		draw_pile[j] = draw_pile[i]
		draw_pile[i] = temp
	piles_changed.emit(draw_pile.size(), discard_pile.size())
