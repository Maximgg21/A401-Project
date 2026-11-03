class_name HandView
extends Control

signal card_clicked(card: Card)

const CARD := preload("res://scenes/cards/card_view.tscn")
const CARD_SIZE := CardView.SIZE
const CARD_SCALE := 0.5
const OVERLAP := 0.8

var card_hovered: CardView


func display_hand(hand: Array[Card]) -> void:
	card_hovered = null
	var nodes = get_children()
	for node in nodes:
		node.queue_free()

	for card_i in hand.size():
		var card_view: CardView = CARD.instantiate()
		card_view.scale = Vector2(CARD_SCALE, CARD_SCALE)
		# Position of the card in the hand
		var card_pos := (CARD_SIZE[0] * OVERLAP * CARD_SCALE * (card_i - (hand.size() - 1) / 2.0))
		card_view.card = hand[card_i]
		card_view.z_index = card_i
		card_view.position = Vector2(
			card_pos - CARD_SIZE[0] / 2,
			card_view.position[1] - CARD_SIZE[1],
		)
		add_child(card_view)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_pos = get_local_mouse_position()
		var prev_card_hovered = card_hovered
		card_hovered = null

		for card in get_children():
			if card.get_rect().has_point(mouse_pos):
				if not card_hovered or card.z_index > card_hovered.z_index:
					card_hovered = card

		if prev_card_hovered and prev_card_hovered != card_hovered:
			prev_card_hovered.set_hovered(false)
		if card_hovered and card_hovered != prev_card_hovered:
			card_hovered.set_hovered(true)

	if (
		event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed and card_hovered
	):
		card_clicked.emit(card_hovered.card)
