extends Control

var combat_deck: CombatDeck = CombatDeck.new()
@onready var hand: Hand = %Hand


func _ready() -> void:
	combat_deck.hand_changed.connect(hand.display_hand)
