class_name Hand
extends HBoxContainer

signal card_clicked(instance: CardInstance)

const CARD := preload("res://scenes/cards/card.tscn")


func display_hand(hand: Array[CardInstance]) -> void:
	var nodes = get_children()
	for node in nodes:
		node.queue_free()

	for instance in hand:
		var card = CARD.new()
		card.data = instance.data
		card.clicked.connect(_on_card_clicked.bind(instance))


func _on_card_clicked(card: CardInstance) -> void:
	print(card.get_index())
