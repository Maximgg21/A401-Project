class_name CombatHud
extends Control

@export var manager: CombatManager

var selected_card: Card
var selected_target: Combatant

@onready var hand_view: HandView = %HandView
@onready var energy_label: Label = %EnergyLabel
@onready var draw_pile_label: Label = %DrawPileLabel
@onready var discard_pile_label: Label = %DiscardPileLabel
@onready var target_arrow: TargetArrow = %TargetArrow


func _ready() -> void:
	manager.deck.hand_changed.connect(hand_view.display_hand)
	manager.deck.piles_changed.connect(_on_piles_changed)
	manager.hero.energy_changed.connect(_on_energy_changed)
	hand_view.card_clicked.connect(_on_card_clicked)


func _input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if not mouse:
		return
	if mouse.button_index == MOUSE_BUTTON_LEFT:
		if mouse.pressed:
			# Clicked on nothing while a card is selected
			if selected_card and not selected_target:
				deselect()
				get_viewport().set_input_as_handled()
		else:
			_on_mouse_released()
	elif mouse.button_index == MOUSE_BUTTON_RIGHT and not mouse.pressed:
		deselect()


func deselect() -> void:
	selected_card = null
	target_arrow.stop()
	hand_view.deselect()


func _on_end_turn() -> void:
	manager.end_turn()


func _on_energy_changed() -> void:
	energy_label.text = "%d/%d" % [manager.hero.current_energy, manager.hero.max_energy]


func _on_card_clicked(card: CardView) -> void:
	## Click to target and play
	if not card.card.data.needs_target():
		manager.play_card(card.card)
		deselect()
		return

	selected_card = card.card
	var start_point := Vector2(card.size.x / 2, 0)
	start_point = card.get_global_transform() * start_point
	target_arrow.start(start_point)


func _on_target_hovered(combatant: Combatant) -> void:
	selected_target = combatant


func _on_target_unhovered() -> void:
	selected_target = null


func _on_mouse_released() -> void:
	if selected_card and selected_target:
		manager.play_card(selected_card, selected_target)
		deselect()


func _on_piles_changed(draw_count: int, discard_count: int) -> void:
	draw_pile_label.text = str(draw_count)
	discard_pile_label.text = str(discard_count)
