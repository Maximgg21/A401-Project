extends Control

var combat_deck: CombatDeck
var hero: Hero

@onready var hand_view: HandView = %HandView
@onready var energy_label: Label = %EnergyLabel
@onready var draw_pile_label: Label = %DrawPileLabel
@onready var discard_pile_label: Label = %DiscardPileLabel


func _ready() -> void:
	combat_deck = CombatDeck.new()
	hero = RunState.hero

	combat_deck.hand_changed.connect(hand_view.display_hand)
	combat_deck.piles_changed.connect(_on_piles_changed)

	hand_view.card_clicked.connect(_on_card_clicked)
	hero.energy_changed.connect(_on_energy_changed)

	_start_turn()


func _on_card_clicked(card: Card) -> void:
	if hero.spend_energy(card.data.cost):
		combat_deck.discard_one(card)


func _on_energy_changed() -> void:
	energy_label.text = "%d/%d" % [hero.current_energy, hero.max_energy]


func _on_piles_changed(draw_count: int, discard_count: int) -> void:
	draw_pile_label.text = str(draw_count)
	discard_pile_label.text = str(discard_count)


func _end_turn() -> void:
	combat_deck.discard_all()
	_start_turn()


func _start_turn() -> void:
	combat_deck.draw(5) # TODO: change default to a constant, probably in hero.gd
	hero.start_turn()
