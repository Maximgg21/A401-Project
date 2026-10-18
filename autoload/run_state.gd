extends Node

const STARTER_HERO: HeroData = preload("res://data/heroes/starter_hero.tres")

var rng := RandomNumberGenerator.new()
var deck: Array[Card]
var hero: Hero


func _ready() -> void:
	start_run()


func start_run(custom_seed: int = -1) -> void:
	if custom_seed != -1:
		rng.seed = custom_seed
	else:
		rng.seed = randi()

	hero = Hero.new(STARTER_HERO)

	deck.clear()
	for card_data in hero.data.starting_deck.cards:
		deck.append(Card.new(card_data))
