class_name MapEditorInput
extends Node
## Rudimentary input layer for MapEditor. Translates mouse/keyboard into editor API calls
## and tells the view what to preview. Holds no map data itself.
##
## Controls
##   1-6          tool: Brush, Line, Rect, Fill, Player spawn, Enemy spawn
##   Q / E        previous / next tile type
##   [ / ]        brush radius -/+
##   LMB          paint with selected type (spawn tools: toggle spawn)
##   RMB          erase (paints default_type; spawn tools: remove spawn)
##   Shift        with Rect tool: outline instead of filled
##   Ctrl+Z / Y   undo / redo (Ctrl+Shift+Z also redoes)
##   Ctrl+S       save (asks for a file name the first time); Ctrl+Shift+S = Save As
##   Ctrl+O       open a room through a file dialog
##   Ctrl+N       new empty room
##   P            toggle reachable-tiles preview (ground unit) from hovered tile
##   Mouse wheel  zoom toward the cursor
##   Middle drag  pan
##   Home         frame the whole room

enum Tool {
	BRUSH,
	LINE,
	RECT,
	FILL,
	PLAYER_SPAWN,
	ENEMY_SPAWN,
}

@export var editor: MapEditor
@export var view: MapEditorView
@export var camera: MapEditorCamera
## Folder the file dialogs open in when no file is loaded yet.
@export var start_dir := "res://data/rooms"
@export var reach_preview_movement := 8

var current_tool := Tool.BRUSH
var brush_radius := 0
var type_index := 0

var _dragging := false
var _button := MOUSE_BUTTON_NONE
var _anchor := Vector2i.ZERO
var _last_cell := Vector2i.ZERO
var _stroke_type: MapTileType
var _show_reach := false
var _message := ""
var _save_dialog: FileDialog
var _open_dialog: FileDialog


func _ready() -> void:
	if editor == null:
		editor = get_parent() as MapEditor
	if view == null and editor != null:
		for child in editor.get_children():
			if child is MapEditorView:
				view = child
	if camera == null and editor != null:
		for child in editor.get_children():
			if child is MapEditorCamera:
				camera = child # optional: without one, pan/zoom are simply disabled
	if editor == null or view == null:
		push_error(
			"MapEditorInput: needs a MapEditor and a MapEditorView (siblings under MapEditor work automatically)."
		)
		return
	_save_dialog = _make_dialog(FileDialog.FILE_MODE_SAVE_FILE, "Save room as")
	_save_dialog.file_selected.connect(_on_save_path_chosen)
	_open_dialog = _make_dialog(FileDialog.FILE_MODE_OPEN_FILE, "Open room")
	_open_dialog.file_selected.connect(_on_open_path_chosen)
	editor.map_changed.connect(_on_map_changed)
	editor.tiles_changed.connect(_on_tiles_changed)
	_update_status()


func selected_type() -> MapTileType:
	if editor == null:
		return null
	if editor.available_types.is_empty():
		return editor.default_type
	return editor.available_types[posmod(type_index, editor.available_types.size())]

# --------------------------------------------------------------------- events


func _unhandled_input(event: InputEvent) -> void:
	if editor == null or view == null or editor.map == null:
		return
	if _save_dialog.visible or _open_dialog.visible:
		return
	if event is InputEventMouseButton:
		_on_mouse_button(event as InputEventMouseButton)
	elif event is InputEventMouseMotion:
		_on_mouse_motion(event as InputEventMouseMotion)
	elif event is InputEventKey:
		var key := event as InputEventKey
		if key.pressed and not key.echo:
			_on_key(key)


func _on_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		if camera != null and event.pressed:
			var notches := event.factor if event.factor > 0.0 else 1.0
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				notches = -notches
			camera.zoom_at_screen(get_viewport().get_mouse_position(), notches)
			get_viewport().set_input_as_handled()
		return
	if event.button_index != MOUSE_BUTTON_LEFT and event.button_index != MOUSE_BUTTON_RIGHT:
		return
	if event.pressed:
		if _dragging:
			return # ignore the other button while a stroke is active
		var cell := view.mouse_cell()
		if not editor.in_bounds(cell):
			return
		_begin_stroke(event.button_index, cell)
	elif _dragging and event.button_index == _button:
		_end_stroke(view.mouse_cell())
	get_viewport().set_input_as_handled()
	_update_status()


func _on_mouse_motion(event: InputEventMouseMotion) -> void:
	var panning := camera != null and (event.button_mask & MOUSE_BUTTON_MASK_MIDDLE) != 0
	if panning:
		camera.pan_by_screen(event.relative)
	var cell := view.mouse_cell()
	view.set_hover(cell)
	if _show_reach:
		_refresh_reach()
	if _dragging and not panning:
		match current_tool:
			Tool.BRUSH:
				# Interpolate between mouse events so fast drags leave no gaps.
				for c in editor.get_line_cells(_last_cell, cell):
					editor.paint_brush(c, brush_radius, _stroke_type)
				_last_cell = cell
			Tool.LINE, Tool.RECT:
				_update_preview(_clamp_to_map(cell))
	_update_status()


func _on_key(event: InputEventKey) -> void:
	if _dragging:
		return
	_message = ""
	var handled := true
	if event.is_command_or_control_pressed():
		match event.keycode:
			KEY_Z:
				if event.shift_pressed:
					editor.redo()
				else:
					editor.undo()
			KEY_Y:
				editor.redo()
			KEY_S:
				if event.shift_pressed:
					_save_as()
				else:
					_save()
			KEY_O:
				_open()
			KEY_N:
				editor.new_map(editor.default_size.x, editor.default_size.y, editor.default_type)
			_:
				handled = false
	else:
		match event.keycode:
			KEY_1:
				current_tool = Tool.BRUSH
			KEY_2:
				current_tool = Tool.LINE
			KEY_3:
				current_tool = Tool.RECT
			KEY_4:
				current_tool = Tool.FILL
			KEY_5:
				current_tool = Tool.PLAYER_SPAWN
			KEY_6:
				current_tool = Tool.ENEMY_SPAWN
			KEY_Q:
				_cycle_type(-1)
			KEY_E:
				_cycle_type(1)
			KEY_BRACKETLEFT:
				brush_radius = maxi(brush_radius - 1, 0)
			KEY_BRACKETRIGHT:
				brush_radius = mini(brush_radius + 1, 8)
			KEY_HOME:
				_frame_map()
			KEY_P:
				_show_reach = not _show_reach
				_refresh_reach()
			_:
				handled = false
	if handled:
		get_viewport().set_input_as_handled()
		_update_status()

# --------------------------------------------------------------------- strokes


func _begin_stroke(button: int, cell: Vector2i) -> void:
	_message = ""
	_dragging = true
	_button = button
	_anchor = cell
	_last_cell = cell
	var erase := button == MOUSE_BUTTON_RIGHT
	_stroke_type = editor.default_type if erase else selected_type()

	match current_tool:
		Tool.BRUSH:
			editor.begin_batch() # whole drag = one undo step
			editor.paint_brush(cell, brush_radius, _stroke_type)
		Tool.LINE, Tool.RECT:
			_update_preview(cell)
		Tool.FILL:
			editor.flood_fill(cell, _stroke_type)
			_dragging = false
		Tool.PLAYER_SPAWN, Tool.ENEMY_SPAWN:
			var kind: MapEditor.SpawnKind = MapEditor.SpawnKind.PLAYER
			if current_tool == Tool.ENEMY_SPAWN:
				kind = MapEditor.SpawnKind.ENEMY
			if erase:
				editor.set_spawn(cell, MapEditor.SpawnKind.NONE)
			else:
				editor.toggle_spawn(cell, kind)
			_dragging = false


func _end_stroke(cell: Vector2i) -> void:
	var end := _clamp_to_map(cell)
	match current_tool:
		Tool.BRUSH:
			editor.end_batch()
		Tool.LINE:
			editor.paint_line(_anchor, end, _stroke_type)
		Tool.RECT:
			editor.paint_rect(_anchor, end, _stroke_type, _rect_filled())
	view.clear_preview()
	_dragging = false
	_button = MOUSE_BUTTON_NONE


func _update_preview(cell: Vector2i) -> void:
	if current_tool == Tool.LINE:
		view.set_preview(editor.get_line_cells(_anchor, cell))
	else:
		view.set_preview(editor.get_rect_cells(_anchor, cell, _rect_filled()))


func _rect_filled() -> bool:
	return not Input.is_key_pressed(KEY_SHIFT)


func _clamp_to_map(cell: Vector2i) -> Vector2i:
	return Vector2i(
		clampi(cell.x, 0, editor.map.width - 1),
		clampi(cell.y, 0, editor.map.height - 1),
	)

# ------------------------------------------------------------------- helpers


func _frame_map() -> void:
	if camera == null or view == null or editor.map == null:
		return
	var room_size := Vector2(editor.map.width, editor.map.height) * view.tile_size * view.global_scale
	camera.frame_rect(Rect2(view.global_position, room_size))


func _cycle_type(step: int) -> void:
	var count := editor.available_types.size()
	if count > 0:
		type_index = posmod(type_index + step, count)


func _make_dialog(mode: FileDialog.FileMode, dialog_title: String) -> FileDialog:
	var dialog := FileDialog.new()
	dialog.access = FileDialog.ACCESS_RESOURCES
	dialog.file_mode = mode
	dialog.title = dialog_title
	dialog.filters = PackedStringArray(["*.tres ; Room template"])
	dialog.size = Vector2i(720, 460)
	add_child(dialog) # hidden until popup_centered()
	return dialog


func _dialog_dir() -> String:
	var dir := start_dir
	if not editor.current_path.is_empty():
		dir = editor.current_path.get_base_dir()
	DirAccess.make_dir_recursive_absolute(dir)
	return dir


## Saves to the current file, or opens Save As if the room has no file yet.
func _save() -> void:
	if editor.current_path.is_empty():
		_save_as()
	else:
		_write(editor.current_path)


func _save_as() -> void:
	_save_dialog.current_dir = _dialog_dir()
	if editor.current_path.is_empty():
		_save_dialog.current_file = "new_room.tres"
	else:
		_save_dialog.current_file = editor.current_path.get_file()
	_save_dialog.popup_centered() # the dialog itself asks before overwriting


func _open() -> void:
	_open_dialog.current_dir = _dialog_dir()
	_open_dialog.popup_centered()


func _on_save_path_chosen(path: String) -> void:
	if path.get_extension().is_empty():
		path += ".tres"
	_write(path)
	_update_status()


func _on_open_path_chosen(path: String) -> void:
	var err := editor.load_from_file(path)
	if err == OK:
		_message = "Opened %s" % path
	else:
		_message = "Open failed: %s" % error_string(err)
	_update_status()


func _write(path: String) -> void:
	var err := editor.save_to_file(path)
	if err != OK:
		_message = "Save failed: %s" % error_string(err)
		return
	_message = "Saved %s" % path
	var warnings := editor.get_warnings()
	if not warnings.is_empty():
		_message += "\nWarnings: " + "; ".join(warnings)


func _refresh_reach() -> void:
	var cell := view.hover_cell
	if not _show_reach or not editor.in_bounds(cell):
		view.set_reach({ })
		return
	var result := editor.preview_reachable(cell, Combatant.Movement.GROUND, reach_preview_movement)
	view.set_reach(result["costs"])


func _on_map_changed(_map: CombatMap) -> void:
	_frame_map()
	_refresh_reach()
	_update_status()


func _on_tiles_changed(_positions: Array[Vector2i]) -> void:
	if _show_reach:
		_refresh_reach()


func _describe(type: MapTileType) -> String:
	if type == null:
		return "(none: set default_type / available_types)"
	var type_name := type.resource_path.get_file().get_basename()
	if type_name.is_empty():
		type_name = "unsaved type"
	return "%s [%s, %s, cost %d]" % [
		type_name,
		MapTile.Terrain.keys()[type.terrain],
		MapTile.Traversability.keys()[type.traversability],
		type.movement_cost,
	]


func _update_status() -> void:
	if view == null:
		return
	var tool_name: String = Tool.keys()[current_tool]
	var lines := PackedStringArray()
	lines.append("Tool: %s   brush radius: %d" % [tool_name.capitalize(), brush_radius])
	lines.append("Tile: %s" % _describe(selected_type()))
	lines.append("Cell: %s" % view.hover_cell)
	var file_text := "(unsaved)"
	if not editor.current_path.is_empty():
		file_text = editor.current_path
	lines.append("File: %s" % file_text)
	if editor.map == null:
		lines.append("NO MAP: assign default_type (and available_types) on the MapEditor node.")
	if not _message.is_empty():
		lines.append(_message)
	lines.append(
		"[1-6] tool  [Q/E] tile type  [ [ ] ] brush size  LMB paint / RMB erase  Shift = outline rect"
	)
	lines.append("Wheel zoom  Middle-drag pan  Home frame room")
	lines.append(
		"Ctrl+Z/Y undo/redo  Ctrl+S save  Ctrl+Shift+S save as  Ctrl+O open  Ctrl+N new  P reachable preview"
	)
	view.set_status("\n".join(lines))
