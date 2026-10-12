extends Node

const STARTER_DECK_DATA: DeckData = preload("res://data/decks/starter_deck.tres")

var rng := RandomNumberGenerator.new()
var deck: Array[CardInstance]


func _ready() -> void:
	start_run()


func start_run(custom_seed: int = -1) -> void:
	if custom_seed != -1:
		rng.seed = custom_seed
	else:
		rng.seed = randi()

	deck.clear()
	for data in STARTER_DECK_DATA.cards:
		deck.append(CardInstance.new(data))
