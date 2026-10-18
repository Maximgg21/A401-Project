class_name HandView
extends HBoxContainer

signal card_clicked(card: Card)

const CARD := preload("res://scenes/cards/card_view.tscn")


func display_hand(hand: Array[Card]) -> void:
	var nodes = get_children()
	for node in nodes:
		node.queue_free()

	for card in hand:
		var card_view: CardView = CARD.instantiate()
		card_view.data = card.data
		card_view.clicked.connect(_on_card_clicked.bind(card))
		add_child(card_view)


func _on_card_clicked(card: Card) -> void:
	card_clicked.emit(card)
