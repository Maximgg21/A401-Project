class_name MapEditorView
extends Node2D
## Rudimentary renderer for MapEditor: flat colored squares, grid, spawn markers and
## a few overlays. Placeholder for your real rendering system. It only READS from
## the editor and redraws when the editor's signals fire.

@export var editor: MapEditor
@export var tile_size := 32
@export var show_grid := true
@export var show_costs := true

var hover_cell := Vector2i(-1, -1)

var _preview: Array[Vector2i] = []
var _reach: Dictionary = { }
var _hud := Label.new()


func _ready() -> void:
	if editor == null:
		editor = get_parent() as MapEditor
	if editor == null:
		push_error("MapEditorView: assign `editor` or make this node a child of MapEditor.")
		return
	editor.map_changed.connect(_on_map_changed)
	editor.tiles_changed.connect(_on_tiles_changed)
	editor.spawns_changed.connect(queue_redraw)

	# HUD lives on its own CanvasLayer so it stays put if a Camera2D moves the map.
	var layer := CanvasLayer.new()
	add_child(layer)
	layer.add_child(_hud)
	_hud.position = Vector2(8, 8)
	_hud.add_theme_color_override("font_outline_color", Color.BLACK)
	_hud.add_theme_constant_override("outline_size", 3)

# ------------------------------------------------------------------ view API


## Cell under the mouse, in this node's local space (works with cameras / offsets).
func mouse_cell() -> Vector2i:
	var p := get_local_mouse_position()
	return Vector2i(floori(p.x / tile_size), floori(p.y / tile_size))


func set_hover(cell: Vector2i) -> void:
	if cell != hover_cell:
		hover_cell = cell
		queue_redraw()


func set_preview(cells: Array[Vector2i]) -> void:
	_preview = cells
	queue_redraw()


func clear_preview() -> void:
	_preview = []
	queue_redraw()


## costs: Dictionary of Vector2i -> int (as returned in CombatPathfinder's "costs").
func set_reach(costs: Dictionary) -> void:
	_reach = costs
	queue_redraw()


func set_status(text: String) -> void:
	_hud.text = text

# ------------------------------------------------------------------- drawing


func _on_map_changed(_map: CombatMap) -> void:
	_preview = []
	_reach = { }
	queue_redraw()


func _on_tiles_changed(_positions: Array[Vector2i]) -> void:
	queue_redraw() # fine for prototype-sized rooms; redraw only dirty cells later if needed


func _draw() -> void:
	if editor == null or editor.map == null:
		return
	var map := editor.map
	var ts := float(tile_size)
	var font := ThemeDB.fallback_font

	# Tiles
	for y in map.height:
		for x in map.width:
			var cell := Vector2i(x, y)
			var tile := map.get_tile(cell)
			var type: MapTileType = tile.type if tile != null else null
			var rect := _cell_rect(cell)
			draw_rect(rect, _color_for(type))
			if show_costs and type != null and type.movement_cost != 1:
				draw_string(
					font,
					rect.position + Vector2(3, 13),
					str(type.movement_cost),
					HORIZONTAL_ALIGNMENT_LEFT,
					-1,
					11,
					Color(1, 1, 1, 0.85),
				)

	# Reachable-tiles overlay
	for key in _reach:
		var cell: Vector2i = key
		var rect := _cell_rect(cell)
		draw_rect(rect, Color(1, 0.9, 0.2, 0.35))
		draw_string(
			font,
			rect.position + Vector2(3, ts - 5),
			str(_reach[key]),
			HORIZONTAL_ALIGNMENT_LEFT,
			-1,
			11,
			Color.BLACK,
		)

	# Grid
	if show_grid:
		var line_color := Color(0, 0, 0, 0.25)
		for x in map.width + 1:
			draw_line(Vector2(x * ts, 0), Vector2(x * ts, map.height * ts), line_color)
		for y in map.height + 1:
			draw_line(Vector2(0, y * ts), Vector2(map.width * ts, y * ts), line_color)

	# Spawns
	for cell in editor.player_spawns:
		_draw_spawn(cell, Color(0.2, 0.9, 0.3))
	for cell in editor.enemy_spawns:
		_draw_spawn(cell, Color(0.95, 0.25, 0.25))

	# Drag preview (line / rect)
	for cell in _preview:
		draw_rect(_cell_rect(cell), Color(1, 1, 1, 0.35))

	# Hover outline
	if editor.in_bounds(hover_cell):
		draw_rect(_cell_rect(hover_cell), Color.WHITE, false, 2.0)


func _cell_rect(cell: Vector2i) -> Rect2:
	return Rect2(Vector2(cell) * tile_size, Vector2(tile_size, tile_size))


func _draw_spawn(cell: Vector2i, color: Color) -> void:
	var center := _cell_rect(cell).get_center()
	var radius := tile_size * 0.3
	draw_circle(center, radius, color)
	draw_arc(center, radius, 0.0, TAU, 24, Color.BLACK, 2.0)


## Placeholder colors derived from existing data (terrain + traversability).
## Replace with real art lookups in your actual renderer.
func _color_for(type: MapTileType) -> Color:
	if type == null:
		return Color.MAGENTA # missing type: loud on purpose
	var color: Color
	match type.terrain:
		MapTile.Terrain.STONE:
			color = Color(0.55, 0.55, 0.58)
		MapTile.Terrain.WOOD:
			color = Color(0.55, 0.38, 0.20)
		MapTile.Terrain.WATER:
			color = Color(0.20, 0.40, 0.75)
		_:
			color = Color.GRAY
	match type.traversability:
		MapTile.Traversability.NONE:
			color = color.darkened(0.65)
		MapTile.Traversability.FLYING:
			color = color.lerp(Color(0.35, 0.15, 0.45), 0.6)
	return color
