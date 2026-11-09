extends Control

@export var manager: CombatManager

@onready var hand_view: HandView = %HandView
@onready var energy_label: Label = %EnergyLabel
@onready var draw_pile_label: Label = %DrawPileLabel
@onready var discard_pile_label: Label = %DiscardPileLabel


func _ready() -> void:
	manager.deck.hand_changed.connect(hand_view.display_hand)
	manager.deck.piles_changed.connect(_on_piles_changed)
	manager.hero.energy_changed.connect(_on_energy_changed)
	hand_view.card_clicked.connect(_on_card_clicked)


func _on_end_turn() -> void:
	manager.end_turn()


func _on_energy_changed() -> void:
	energy_label.text = "%d/%d" % [manager.hero.current_energy, manager.hero.max_energy]


func _on_card_clicked(card: Card) -> void:
	manager.play_card(card)


func _on_piles_changed(draw_count: int, discard_count: int) -> void:
	draw_pile_label.text = str(draw_count)
	discard_pile_label.text = str(discard_count)
