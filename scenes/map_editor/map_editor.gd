class_name MapEditor
extends Node2D
# HOW TO USE:
#press f6 to launch the editor. By default it loads the sample map.
#currently only some tile types have a color.
#currently to resize the room, the size of the sample room needs to be changed

#NOTE: I did NOT implement any secrity with this as it is a very simple api to help make rooms
#so be careful when changing files. Almost everything beyond this file is vibecoded so stuff WILL break.
#ALSO: spawn points will represent the positions for the max number of enemies the room can spawn with.
#Encounters with less than the max will choose randomly between their teams' spawn locations

#TODO:
#A proper UI
#render preview
#decorations layer
#non-enemy objects (such as furniture)
#control to change room size

signal map_changed(map: CombatMap) # new / loaded / resized map
signal tiles_changed(positions: Array[Vector2i]) # after every edit, undo, redo
signal spawns_changed
signal history_changed(can_undo: bool, can_redo: bool)

enum SpawnKind {
	NONE,
	PLAYER,
	ENEMY,
}

const MAX_HISTORY := 128
const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

@export var template: RoomTemplate
@export var default_type: MapTileType
@export var default_size := Vector2i(12, 8)
@export var available_types: Array[MapTileType] = []


class TileEdit extends RefCounted:
	var position: Vector2i
	var before: MapTile # may be null if the slot was uninitialised
	var after: MapTile


	func _init(p: Vector2i, b: MapTile, a: MapTile) -> void:
		position = p
		before = b
		after = a


class SpawnEdit extends RefCounted:
	var kind: int # MapEditor.SpawnKind
	var position: Vector2i
	var added: bool


	func _init(k: int, p: Vector2i, a: bool) -> void:
		kind = k
		position = p
		added = a


class Step extends RefCounted:
	var tiles: Array[TileEdit] = []
	var spawns: Array[SpawnEdit] = []


	func is_empty() -> bool:
		return tiles.is_empty() and spawns.is_empty()


var map: CombatMap
var current_path := ""
var player_spawns: Array[Vector2i] = []
var enemy_spawns: Array[Vector2i] = []

var _undo_stack: Array[Step] = []
var _redo_stack: Array[Step] = []
var _open := Step.new()
var _batch_depth := 0
var _dirty: Dictionary[Vector2i, bool] = { }
var _spawns_dirty := false


func _ready() -> void:
	if default_type != null and default_type not in available_types:
		available_types.push_front(default_type)
	if template != null and load_template(template) == OK:
		return
	if default_type != null:
		new_map(default_size.x, default_size.y, default_type)
	else:
		push_warning("MapEditor: assign default_type (and available_types) in the inspector.")

#map lifecycle


func new_map(width: int, height: int, fill_type: MapTileType) -> void:
	if width <= 0 or height <= 0 or fill_type == null:
		push_error("MapEditor.new_map: need positive size and a fill tile type.")
		return
	map = CombatMap.new()
	map.initialize(width, height, fill_type)
	current_path = ""
	player_spawns.clear()
	enemy_spawns.clear()
	clear_history()
	map_changed.emit(map)
	spawns_changed.emit()


func load_template(source: RoomTemplate) -> Error:
	var issues := validate_template(source)
	if not issues.is_empty():
		push_error("MapEditor.load_template: " + "; ".join(issues))
		return ERR_INVALID_DATA
	map = CombatMap.from_template(source)
	current_path = ""
	player_spawns.assign(source.player_spawns)
	enemy_spawns.assign(source.enemy_spawns)
	_prune_spawns()
	if default_type == null:
		default_type = source.tile_palette[0]
	for type in source.tile_palette:
		if type not in available_types:
			available_types.append(type)
	clear_history()
	map_changed.emit(map)
	spawns_changed.emit()
	return OK


func load_from_file(path: String) -> Error:
	if not ResourceLoader.exists(path) and not FileAccess.file_exists(path):
		return ERR_FILE_NOT_FOUND
	var loaded := ResourceLoader.load(path, "", ResourceLoader.CACHE_MODE_IGNORE) as RoomTemplate
	if loaded == null:
		return ERR_FILE_UNRECOGNIZED
	var err := load_template(loaded)
	if err == OK:
		current_path = path
	return err


#Returns null if the working map is structurally invalid.
#Palette = distinct tile types in order of first appearance.
func to_template() -> RoomTemplate:
	if not validate().is_empty():
		return null
	var result := RoomTemplate.new()
	result.width = map.width
	result.height = map.height

	var palette: Array[MapTileType] = []
	var index_of: Dictionary[MapTileType, int] = { }
	var indices := PackedInt32Array()
	indices.resize(map.tiles.size())
	for i in map.tiles.size():
		var type := map.tiles[i].type
		if not index_of.has(type):
			index_of[type] = palette.size()
			palette.append(type)
		indices[i] = index_of[type]

	result.tile_palette = palette
	result.tile_indices = indices
	result.player_spawns.assign(player_spawns)
	result.enemy_spawns.assign(enemy_spawns)
	return result


#MapTileType resources should be saved as their own .tres files so the template
#stores references instead of embedding a copy of each type.
func save_to_file(path: String) -> Error:
	var result := to_template()
	if result == null:
		return ERR_INVALID_DATA
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var err := ResourceSaver.save(result, path)
	if err == OK:
		current_path = path
	return err


#Resizes keeping the top-left corner fixed.
func resize(new_width: int, new_height: int, fill_type: MapTileType) -> void:
	if map == null or new_width <= 0 or new_height <= 0 or fill_type == null:
		push_error("MapEditor.resize: invalid arguments.")
		return
	var resized := CombatMap.new()
	resized.initialize(new_width, new_height, fill_type)
	for y in mini(map.height, new_height):
		for x in mini(map.width, new_width):
			var pos := Vector2i(x, y)
			var tile := map.get_tile(pos)
			if tile != null:
				resized.set_tile(pos, tile)
	map = resized
	_prune_spawns()
	clear_history()
	map_changed.emit(map)
	spawns_changed.emit()

#validation (vibecoded so it might not work)


static func validate_template(t: RoomTemplate) -> PackedStringArray:
	var issues := PackedStringArray()
	if t == null:
		issues.append("Template is null.")
		return issues
	if t.width <= 0 or t.height <= 0:
		issues.append("Template has non-positive dimensions.")
		return issues
	if t.tile_indices.size() != t.width * t.height:
		issues.append(
			"tile_indices.size() (%d) != width * height (%d)."
			% [t.tile_indices.size(), t.width * t.height]
		)
		return issues
	if t.tile_palette.is_empty():
		issues.append("tile_palette is empty.")
		return issues
	for type in t.tile_palette:
		if type == null:
			issues.append("tile_palette contains a null entry.")
			return issues
	for index in t.tile_indices:
		if index < 0 or index >= t.tile_palette.size():
			issues.append("tile_indices contains out-of-range palette index %d." % index)
			return issues
	return issues


#Structural problems with the working map (empty = fine). Blocks saving.
@warning_ignore("integer_division")
func validate() -> PackedStringArray:
	var issues := PackedStringArray()
	if map == null:
		issues.append("No map loaded.")
		return issues
	if map.width <= 0 or map.height <= 0:
		issues.append("Map has non-positive dimensions.")
		return issues
	if map.tiles.size() != map.width * map.height:
		issues.append(
			"tiles.size() (%d) != width * height (%d)." % [map.tiles.size(), map.width * map.height]
		)
		return issues
	for i in map.tiles.size():
		var tile := map.tiles[i]
		if tile == null or tile.type == null:
			issues.append(
				"Missing tile or tile type at %s." % Vector2i(i % map.width, i / map.width)
			)
	return issues


#problems that should not block saving.
func get_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	if map == null:
		return warnings
	if player_spawns.is_empty():
		warnings.append("No player spawns.")
	if enemy_spawns.is_empty():
		warnings.append("No enemy spawns.")
	for kind in [SpawnKind.PLAYER, SpawnKind.ENEMY]:
		for pos in _spawn_list(kind):
			var type := get_tile_type(pos)
			if type == null or type.traversability == MapTile.Traversability.NONE:
				warnings.append(
					"%s spawn at %s is on an impassable tile." % [SpawnKind.keys()[kind], pos]
				)
	return warnings

# other stuff


func in_bounds(pos: Vector2i) -> bool:
	return map != null and map.in_bounds(pos)


func get_tile_type(pos: Vector2i) -> MapTileType:
	if map == null:
		return null
	var tile: MapTile = map.get_tile(pos)
	if tile == null:
		return null
	return tile.type


func get_spawn_at(pos: Vector2i) -> SpawnKind:
	if pos in player_spawns:
		return SpawnKind.PLAYER
	if pos in enemy_spawns:
		return SpawnKind.ENEMY
	return SpawnKind.NONE


#Runs the pathfinder from a start tile
func preview_reachable(
	start: Vector2i,
	movement_type: Combatant.Movement,
	max_movement: int,
) -> Dictionary:
	var probe := Combatant.new()
	probe.movement_type = movement_type
	return CombatPathfinder.new().find_reachable_tiles(map, start, max_movement, probe)


#4-connected line (so it works as a walkable corridor with 4-way movement). Not clipped to the map.
func get_line_cells(a: Vector2i, b: Vector2i) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	var d := (b - a).abs()
	var step := Vector2i(signi(b.x - a.x), signi(b.y - a.y))
	var err := d.x - d.y
	var p := a
	while true:
		cells.append(p)
		if p == b:
			break
		var e2 := 2 * err
		var moved_x := false
		var moved_y := false
		if e2 > -d.y:
			err -= d.y
			p.x += step.x
			moved_x = true
		if e2 < d.x:
			err += d.x
			p.y += step.y
			moved_y = true
		if moved_x and moved_y:
			cells.append(Vector2i(p.x, p.y - step.y))
	return cells


#Rectangle cells (filled or outline), clipped to the map.
func get_rect_cells(a: Vector2i, b: Vector2i, filled: bool = true) -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	if map == null:
		return cells
	var lo := Vector2i(mini(a.x, b.x), mini(a.y, b.y))
	var hi := Vector2i(maxi(a.x, b.x), maxi(a.y, b.y))
	for y in range(maxi(lo.y, 0), mini(hi.y, map.height - 1) + 1):
		for x in range(maxi(lo.x, 0), mini(hi.x, map.width - 1) + 1):
			if filled or x == lo.x or x == hi.x or y == lo.y or y == hi.y:
				cells.append(Vector2i(x, y))
	return cells

#tile editing API


func set_tile_type(pos: Vector2i, type: MapTileType) -> bool:
	_begin_op()
	var changed := _set_type(pos, type)
	_end_op()
	return changed


func paint_line(from: Vector2i, to: Vector2i, type: MapTileType) -> int:
	_begin_op()
	var count := 0
	for cell in get_line_cells(from, to):
		if _set_type(cell, type):
			count += 1
	_end_op()
	return count


func paint_rect(a: Vector2i, b: Vector2i, type: MapTileType, filled: bool = true) -> int:
	_begin_op()
	var count := 0
	for cell in get_rect_cells(a, b, filled):
		if _set_type(cell, type):
			count += 1
	_end_op()
	return count


#Radius 0 = single tile.
func paint_brush(center: Vector2i, radius: int, type: MapTileType) -> int:
	_begin_op()
	var count := 0
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			if dx * dx + dy * dy <= radius * radius:
				if _set_type(center + Vector2i(dx, dy), type):
					count += 1
	_end_op()
	return count


## 4-directional fill of all connected tiles sharing the start tile's type.
func flood_fill(start: Vector2i, type: MapTileType) -> int:
	if not in_bounds(start):
		return 0
	var origin := get_tile_type(start)
	if origin == type:
		return 0
	_begin_op()
	var count := 0
	var visited: Dictionary[Vector2i, bool] = { start: true }
	var stack: Array[Vector2i] = [start]
	while not stack.is_empty():
		var current: Vector2i = stack.pop_back()
		if _set_type(current, type):
			count += 1
		for dir in DIRECTIONS:
			var next := current + dir
			if visited.has(next) or not map.in_bounds(next):
				continue
			if get_tile_type(next) != origin:
				continue
			visited[next] = true
			stack.push_back(next)
	_end_op()
	return count

#spawn API


## A tile holds at most one spawn. Setting a spawn replaces any existing one on that tile;
## SpawnKind.NONE removes it. Returns true if anything changed.
func set_spawn(pos: Vector2i, kind: SpawnKind) -> bool:
	if not in_bounds(pos):
		return false
	var current := get_spawn_at(pos)
	if current == kind:
		return false
	_begin_op()
	if current != SpawnKind.NONE:
		_apply_spawn(current, pos, false, true)
	if kind != SpawnKind.NONE:
		_apply_spawn(kind, pos, true, true)
	_end_op()
	return true


func toggle_spawn(pos: Vector2i, kind: SpawnKind) -> bool:
	if get_spawn_at(pos) == kind:
		return set_spawn(pos, SpawnKind.NONE)
	return set_spawn(pos, kind)

#history


func begin_batch() -> void:
	_batch_depth += 1


func end_batch() -> void:
	_batch_depth = maxi(_batch_depth - 1, 0)
	if _batch_depth == 0:
		_commit_batch()


func can_undo() -> bool:
	return _batch_depth == 0 and not _undo_stack.is_empty()


func can_redo() -> bool:
	return _batch_depth == 0 and not _redo_stack.is_empty()


func undo() -> bool:
	if not can_undo():
		return false
	var step: Step = _undo_stack.pop_back()
	for i in range(step.tiles.size() - 1, -1, -1):
		var edit := step.tiles[i]
		map.set_tile(edit.position, edit.before)
		_dirty[edit.position] = true
	for i in range(step.spawns.size() - 1, -1, -1):
		var spawn := step.spawns[i]
		_apply_spawn(spawn.kind, spawn.position, not spawn.added, false)
	_redo_stack.push_back(step)
	_flush()
	_emit_history()
	return true


func redo() -> bool:
	if not can_redo():
		return false
	var step: Step = _redo_stack.pop_back()
	for edit in step.tiles:
		map.set_tile(edit.position, edit.after)
		_dirty[edit.position] = true
	for spawn in step.spawns:
		_apply_spawn(spawn.kind, spawn.position, spawn.added, false)
	_undo_stack.push_back(step)
	_flush()
	_emit_history()
	return true


func clear_history() -> void:
	_undo_stack.clear()
	_redo_stack.clear()
	_open = Step.new()
	_batch_depth = 0
	_dirty.clear()
	_spawns_dirty = false
	_emit_history()

#internals


func _begin_op() -> void:
	begin_batch()


func _end_op() -> void:
	_flush()
	end_batch()


func _set_type(pos: Vector2i, type: MapTileType) -> bool:
	if map == null or not map.in_bounds(pos):
		return false
	if type == null:
		push_error("MapEditor: refusing to paint a null tile type.")
		return false
	var before: MapTile = map.get_tile(pos)
	if before != null and before.type == type:
		return false
	var after := MapTile.new() #fresh instance per tile: tiles are never shared
	after.type = type
	map.set_tile(pos, after)
	_open.tiles.append(TileEdit.new(pos, before, after))
	_dirty[pos] = true
	return true


func _apply_spawn(kind: int, pos: Vector2i, add: bool, record: bool) -> void:
	var list := _spawn_list(kind)
	if add:
		if pos not in list:
			list.append(pos)
	else:
		list.erase(pos)
	if record:
		_open.spawns.append(SpawnEdit.new(kind, pos, add))
	_spawns_dirty = true


func _spawn_list(kind: int) -> Array[Vector2i]:
	match kind:
		SpawnKind.PLAYER:
			return player_spawns
		SpawnKind.ENEMY:
			return enemy_spawns
	push_error("MapEditor: no spawn list for SpawnKind.NONE.")
	var empty: Array[Vector2i] = []
	return empty


func _prune_spawns() -> void:
	_prune_list(player_spawns)
	_prune_list(enemy_spawns)


func _prune_list(list: Array[Vector2i]) -> void:
	for i in range(list.size() - 1, -1, -1):
		if not map.in_bounds(list[i]):
			list.remove_at(i)


func _commit_batch() -> void:
	if _open.is_empty():
		return
	_undo_stack.push_back(_open)
	_open = Step.new()
	_redo_stack.clear()
	if _undo_stack.size() > MAX_HISTORY:
		_undo_stack.pop_front()
	_emit_history()


func _flush() -> void:
	if not _dirty.is_empty():
		var positions: Array[Vector2i] = []
		positions.assign(_dirty.keys())
		_dirty.clear()
		tiles_changed.emit(positions)
	if _spawns_dirty:
		_spawns_dirty = false
		spawns_changed.emit()


func _emit_history() -> void:
	history_changed.emit(can_undo(), can_redo())
