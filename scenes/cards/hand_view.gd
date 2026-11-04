class_name HandView
extends Control

signal card_clicked(card: Card)

const CARD := preload("res://scenes/cards/card_view.tscn")
const CARD_SIZE := CardView.SIZE
const CARD_SCALE := 0.7
const MAX_HAND_SIZE := 10
const SMALL_HAND := { "overlap": 0.85, "angle": 5.0, "drop": 4.0 }
const FULL_HAND := { "overlap": 0.55, "angle": 3.0, "drop": 3.0 }

var card_hovered: CardView


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


func display_hand(hand: Array[Card]) -> void:
	card_hovered = null
	var nodes = get_children()
	for node in nodes:
		node.queue_free()

	var hand_size := hand.size()
	var ratio := inverse_lerp(1, MAX_HAND_SIZE, hand_size)
	var overlap := lerpf(SMALL_HAND.overlap, FULL_HAND.overlap, ratio)
	var angle := lerpf(SMALL_HAND.angle, FULL_HAND.angle, ratio)
	var drop := lerpf(SMALL_HAND.drop, FULL_HAND.drop, ratio)

	for card_i in hand_size:
		var card_view: CardView = CARD.instantiate()
		card_view.card = hand[card_i]

		# Card positioning in the hand
		card_view.scale = Vector2(CARD_SCALE, CARD_SCALE)
		card_view.z_index = card_i
		var offset := (card_i - (hand_size - 1) / 2.0)
		var card_pos_x := (CARD_SIZE.x * overlap * CARD_SCALE * offset) - CARD_SIZE.x / 2
		var card_pos_y := -CARD_SIZE.y + offset * offset * drop
		card_view.position = Vector2(card_pos_x, card_pos_y)
		card_view.rotation_degrees = offset * angle

		add_child(card_view)
