extends Control

var combat_deck: CombatDeck
var hero: Hero

@onready var hand_view: HandView = %HandView


func _ready() -> void:
	combat_deck = CombatDeck.new()
	hero = RunState.hero
	combat_deck.hand_changed.connect(hand_view.display_hand)
	hand_view.card_clicked.connect(_on_card_clicked)
	_start_turn()


func _on_card_clicked(card: Card) -> void:
	if hero.spend_energy(card.data.cost):
		combat_deck.discard_one(card)


func _end_turn() -> void:
	combat_deck.discard_all()
	_start_turn()


func _start_turn() -> void:
	combat_deck.draw(5) # TODO: change default to a constant, probably in hero.gd
	hero.start_turn()
