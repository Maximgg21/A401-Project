extends Node
## UNLOCK from any scene or script:
##     Achievements.achievement_get(&"slime_achievement")
##
## Achievements reset when the game closes.

signal achievement_unlocked(id: StringName)

const SHOW_LOCKED_PLACEHOLDERS := false

const POPUP_LAYER := 100
const POPUP_MIN_SIZE := Vector2(300, 0)
const POPUP_MARGIN := 16.0
const POPUP_HOLD_SECONDS := 5.0
const POPUP_SLIDE_SECONDS := 0.35

## Add the achievements here. The key is the id you pass to achievement_get(). Example on line 3
const DEFINITIONS := {
	&"achievement_1": {
		"name": "First Achievement",
		"description": "You earned your very first achievement.",
	},
	&"slime_achievement": {
		"name": "Gross, what is this?",
		"description": "Touch the main menu slime",
	},
}

var _unlocked := {}

var _popup: PanelContainer
var _title_label: Label
var _description_label: Label
var _queue: Array[StringName] = []
var _is_showing := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_popup()


func achievement_get(id: StringName) -> void:
	if not DEFINITIONS.has(id):
		push_warning("achievement_get: unknown achievement '%s'" % id)
		return
	if _unlocked.has(id):
		return

	_unlocked[id] = true
	achievement_unlocked.emit(id)
	_queue.append(id)
	if not _is_showing:
		_show_next()


func has_achievement(id: StringName) -> bool:
	return _unlocked.has(id)


func get_unlocked_count() -> int:
	return _unlocked.size()


func get_total_count() -> int:
	return DEFINITIONS.size()


func populate_list(container: Control) -> void:
	for child in container.get_children():
		child.queue_free()

	var shown := 0
	for id: StringName in DEFINITIONS:
		var unlocked := has_achievement(id)
		if not unlocked and not SHOW_LOCKED_PLACEHOLDERS:
			continue
		container.add_child(_make_row(id, unlocked))
		shown += 1

	if shown == 0:
		var empty_label := Label.new()
		empty_label.text = "No achievements unlocked yet."
		container.add_child(empty_label)


func _make_row(id: StringName, unlocked: bool) -> Control:
	var panel := PanelContainer.new()
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var box := VBoxContainer.new()
	margin.add_child(box)

	var name_label := Label.new()
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.text = DEFINITIONS[id]["name"] if unlocked else "???"
	box.add_child(name_label)

	var description_label := Label.new()
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.text = DEFINITIONS[id]["description"] if unlocked else "Locked"
	box.add_child(description_label)

	if not unlocked:
		panel.modulate = Color(1, 1, 1, 0.5)
	return panel


func _build_popup() -> void:
	var layer := CanvasLayer.new()
	layer.layer = POPUP_LAYER
	add_child(layer)

	_popup = PanelContainer.new()
	_popup.modulate.a = 1.0 # 1.0 = solid, 0.0 = invisible
	_popup.custom_minimum_size = POPUP_MIN_SIZE
	_popup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_popup.visible = false
	layer.add_child(_popup)

	var margin := MarginContainer.new()
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_theme_constant_override("margin_left", 12)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_right", 12)
	margin.add_theme_constant_override("margin_bottom", 8)
	_popup.add_child(margin)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	margin.add_child(box)

	var heading := Label.new()
	heading.text = "Achievement Unlocked!"
	heading.add_theme_color_override("font_color", Color(1.0, 0.85, 0.3))
	heading.add_theme_font_size_override("font_size", 30)
	box.add_child(heading)

	_title_label = Label.new()
	_title_label.add_theme_font_size_override("font_size", 25)
	box.add_child(_title_label)

	_description_label = Label.new()
	_description_label.custom_minimum_size.x = POPUP_MIN_SIZE.x - 36  # The number is the left + right margins
	_description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description_label.add_theme_font_size_override("font_size", 18)
	box.add_child(_description_label)


func _show_next() -> void:
	if _queue.is_empty():
		_is_showing = false
		return
	_is_showing = true

	var id: StringName = _queue.pop_front()
	_title_label.text = DEFINITIONS[id]["name"]
	_description_label.text = DEFINITIONS[id]["description"]

	_popup.visible = true
	_popup.reset_size()
	var viewport_width := get_viewport().get_visible_rect().size.x
	_popup.position = Vector2(viewport_width - _popup.size.x - POPUP_MARGIN, -_popup.size.y)

	var tween := create_tween()
	tween.tween_property(_popup, "position:y", POPUP_MARGIN, POPUP_SLIDE_SECONDS).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_OUT)
	tween.tween_interval(POPUP_HOLD_SECONDS)
	tween.tween_property(_popup, "position:y", -_popup.size.y, POPUP_SLIDE_SECONDS).set_trans(
		Tween.TRANS_CUBIC
	).set_ease(Tween.EASE_IN)
	tween.finished.connect(_on_popup_finished)


func _on_popup_finished() -> void:
	_popup.visible = false
	_show_next()
