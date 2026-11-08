class_name CombatManager
extends Node2D
var entities: Array[Combatant]
var entity_positions: Dictionary[Combatant, Vector2i]
var hero: Hero
var deck: CombatDeck
var dummy: Combatant
#this will handle things like the map, turn order, movement, attacks, and status effects


func _ready() -> void:
	deck = CombatDeck.new()
	hero = RunState.hero
	dummy = Combatant.new()
	dummy.max_health = 20
	dummy.current_health = 20


func end_turn() -> void:
	deck.discard_all()
	start_turn()


func start_turn() -> void:
	deck.draw(5) # TODO: change default to a constant, probably in hero.gd
	hero.start_turn()


func start_combat() -> void:
	start_turn()


func play_card(card: Card) -> void:
	var context := EffectContext.new(hero, dummy)
	if hero.spend_energy(card.data.cost):
		for effect in card.data.effects:
			effect.apply(context)
		deck.discard_one(card)
		print(dummy.current_health)

#step 1. enter combat
#		recieve trigger to enter combat (perhaps a godot signal)
#		play a cool animation (optional)
#		load combatmap
#		lock objects into the grid (1 entity per tile?), nearest tile, bias bottom right
#		determine turn order

#step 2. for each entity that has a turn, play their turn (turn count begins at the start of initiative)
#		actions and movement can be done at any time, but not at the same time.
#		it may be more fun to have dedicated movement phases, but that can be complicated for the player

#step 3. end combat
#		when all enemies or pc (player character) is dead, end combat
#		if pc dies, go to fail state
#		if all enemies die, exit combat and go to map
