class_name MapEditorPreview
extends Node
## Adds a "Preview" toggle to the map editor. While on, the flat editing view is hidden,
## the real MapRenderer is shown with the current room, and editing is paused (the
## camera still pans and zooms). Toggle with the button or the V key.

@export var editor: MapEditor
@export var view: MapEditorView
@export var input: MapEditorInput
@export var renderer: MapRenderer
## Optional: assign a Button from your own UI scene. If empty, a default one is
## created in the top-right corner.
@export var button: Button

var previewing := false


func _ready() -> void:
	if editor == null:
		editor = get_parent() as MapEditor
	if editor == null:
		push_error("MapEditorPreview: assign `editor` or make this node a child of MapEditor.")
		return
	for child in editor.get_children():
		if view == null and child is MapEditorView:
			view = child
		elif input == null and child is MapEditorInput:
			input = child
		elif renderer == null and child is MapRenderer:
			renderer = child
	if view == null or renderer == null:
		push_error(
			"MapEditorPreview: needs a MapEditorView and a MapRenderer (children of MapEditor are found automatically)."
		)
		return

	if button == null:
		button = _make_default_button()
	button.toggle_mode = true
	button.focus_mode = Control.FOCUS_NONE # so Space/Enter never re-trigger it while editing
	button.toggled.connect(_on_button_toggled)

	editor.map_changed.connect(_on_map_changed)
	renderer.visible = false


func _unhandled_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key == null or not key.pressed or key.echo or key.is_command_or_control_pressed():
		return
	if key.keycode == KEY_V:
		set_preview(not previewing)
		get_viewport().set_input_as_handled()


func set_preview(on: bool) -> void:
	if view == null or renderer == null or previewing == on:
		return
	if on and editor.map == null:
		button.set_pressed_no_signal(false)
		return
	previewing = on
	if on:
		renderer.render_map(editor.map)
	renderer.visible = on
	view.visible = not on # the view's HUD sits on its own CanvasLayer, so it stays visible
	if input != null:
		input.set_editing_enabled(not on)
	button.set_pressed_no_signal(on)


func _on_button_toggled(on: bool) -> void:
	set_preview(on)


func _on_map_changed(map: CombatMap) -> void:
	if previewing:
		renderer.render_map(map)


func _make_default_button() -> Button:
	var layer := CanvasLayer.new()
	add_child(layer)
	var preview_button := Button.new()
	preview_button.text = "Preview (V)"
	preview_button.tooltip_text = "Show the rendered room. Editing is paused while previewing."
	layer.add_child(preview_button)
	preview_button.anchor_left = 1.0
	preview_button.anchor_right = 1.0
	preview_button.offset_left = -128.0
	preview_button.offset_right = -8.0
	preview_button.offset_top = 8.0
	preview_button.offset_bottom = 40.0
	return preview_button
