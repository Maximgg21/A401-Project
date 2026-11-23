#this will handle things like the map, turn order, movement, attacks, and status effects
class_name CombatManager
extends Node2D

enum State {
	SETUP,
	PLAYER_TURN,
	ENEMY_TURN,
	WIN,
	LOSE, #these last two can perhaps be replaces with a more general 'cleaup' state
}

signal state_changed(new_state: State)
signal entity_placed(entity: MapEntity, cell: Vector2i)
signal entity_moved(entity: MapEntity, from: Vector2i, to: Vector2i)
signal entity_removed(entity: MapEntity, cell: Vector2i)
signal combat_ended(victory: bool)
signal reachable_changed(costs: Dictionary)

const ORC := preload("res://data/enemies/orc.tres")

var state: State = State.SETUP
var map: CombatMap
var entities: Array[MapEntity]
var hero: Hero
var enemy: Enemy
var deck: CombatDeck
var is_moving := false

# lookup tables
var _cell_of: Dictionary[MapEntity, Vector2i] = { }
var _entity_at: Dictionary[Vector2i, MapEntity] = { }

var _pathfinder := CombatPathfinder.new()
var _costs: Dictionary[Vector2i, int] = { }
var _came_from: Dictionary[Vector2i, Vector2i] = { }


func _ready() -> void:
	deck = CombatDeck.new()
	hero = RunState.hero
	print("CombatManager._init, RunState.hero = ", RunState.hero, " | hero = ", hero)


func setup(new_map: CombatMap) -> void:
	#TODO: Append all EnemyData and other objects to entities
	map = new_map
	enemy = Enemy.new(ORC)
	entities.append(enemy)


func end_turn() -> void:
	if state != State.PLAYER_TURN:
		return
	if state != State.PLAYER_TURN or is_moving:
		return
	deck.discard_all()
	_set_state(State.ENEMY_TURN)
	await _run_enemy_turn()
	# If combat ended during the enemy phase, state is VICTORY/DEFEAT.
	if state == State.ENEMY_TURN:
		start_turn()


func _run_enemy_turn() -> void:
	for e in get_enemies():
		if state != State.ENEMY_TURN:
			return
		# TODO: needs enemy ai :pleading:
		await get_tree().create_timer(0.3).timeout


func start_turn() -> void:
	hero.start_turn()
	_set_state(State.PLAYER_TURN)
	deck.draw(5) # TODO: change default to a constant, probably in hero.gd


func start_combat() -> void:
	start_turn()


func play_card(card: Card) -> void:
	if hero.spend_energy(card.data.cost):
		var context := EffectContext.new(hero, enemy)
		for effect in card.data.effects:
			effect.apply(context)
		deck.discard_one(card)
		print(enemy.current_health)


func _set_state(new_state: State) -> void:
	state = new_state
	state_changed.emit(new_state)
	refresh_reachable()


func get_enemies() -> Array[Enemy]:
	var result: Array[Enemy] = []
	for e in entities:
		if e is Enemy and not (e.current_health == 0):
			result.append(e)
	return result


# movement stuff
func get_cell_of(entity: MapEntity) -> Vector2i:
	return _cell_of.get(entity, Vector2i(-1, -1))


func get_entity_at(cell: Vector2i) -> MapEntity:
	return _entity_at.get(cell)


func can_enter(entity: MapEntity, cell: Vector2i) -> bool:
	if not map.in_bounds(cell) or _entity_at.has(cell):
		return false
	var tile := map.get_tile(cell)
	if tile == null or tile.type == null:
		return false
	# TODO: also reject chasm/bars (allow flying over chasms) using entity.movement_type
	return tile.type.render_type != MapTile.RenderType.WALL


func place_entity(entity: MapEntity, cell: Vector2i) -> bool:
	if not can_enter(entity, cell):
		push_error("Can't place %s at %s" % [entity, cell])
		return false
	_cell_of[entity] = cell
	_entity_at[cell] = entity
	entity_placed.emit(entity, cell)
	return true


func move_entity(entity: MapEntity, to: Vector2i) -> bool:
	if not _cell_of.has(entity) or not can_enter(entity, to):
		return false
	var from := _cell_of[entity]
	_entity_at.erase(from)
	_cell_of[entity] = to
	_entity_at[to] = entity
	entity_moved.emit(entity, from, to)
	return true


func remove_entity(entity: MapEntity) -> void:
	if not _cell_of.has(entity):
		return
	var cell := _cell_of[entity]
	_cell_of.erase(entity)
	_entity_at.erase(cell)
	entity_removed.emit(entity, cell)


func refresh_reachable() -> void:
	_costs = { }
	_came_from = { }
	if state == State.PLAYER_TURN and not is_moving:
		var start := get_cell_of(hero)
		var result := _pathfinder.find_reachable_tiles(
			map,
			start,
			hero.movement,
			hero,
			_blocked_cells(hero),
		)
		_costs = result.costs
		_came_from = result.came_from
		_costs.erase(start) # don't highlight the tile you're standing on
	reachable_changed.emit(_costs)


func _blocked_cells(except: MapEntity) -> Dictionary:
	var blocked := { }
	for cell in _entity_at:
		if _entity_at[cell] != except:
			blocked[cell] = true
	return blocked


func move_hero(target: Vector2i) -> void:
	if state != State.PLAYER_TURN or is_moving or not _costs.has(target):
		return
	var path := _pathfinder.reconstruct_path(_came_from, get_cell_of(hero), target)
	var total := _costs[target]
	if path.is_empty() or not hero.spend_movement(total):
		return

	is_moving = true
	refresh_reachable() # hides the overlay while walking
	for cell in path:
		if not move_entity(hero, cell):
			break
	is_moving = false
	refresh_reachable()
