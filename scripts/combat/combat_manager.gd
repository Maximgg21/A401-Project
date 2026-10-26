class_name CombatManager
extends Node2D
var entities: Array[Combatant]
var entity_positions: Dictionary[Combatant, Vector2i]
#this will handle things like the map, turn order, movement, attacks, and status effects

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
