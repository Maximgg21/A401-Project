extends Node
## Shakes the 2D view for a moment. Call it from anywhere:
##     ScreenShake.shake()  # default hit
##     ScreenShake.shake(14.0, 0.5)  # big hit: strength in pixels, duration in seconds
##
## Does nothing when the player has turned Screen Shake off in Options.
##
## It nudges the viewport's canvas transform, which moves everything on the default
## canvas layer (the game world and the combat HUD). Nodes on their own CanvasLayer,
## like the achievement popup and the brightness overlay, stay put.
## The project has no Camera2D yet. If one is added, it overwrites the canvas
## transform, so change _set_offset() to move the camera's offset instead.

const DEFAULT_STRENGTH := 8.0
const DEFAULT_DURATION := 0.3

var _strength := 0.0
var _duration := 0.0
var _time_left := 0.0
var _base_origin := Vector2.ZERO


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)


func shake(strength: float = DEFAULT_STRENGTH, duration: float = DEFAULT_DURATION) -> void:
	if not Settings.screen_shake_enabled or duration <= 0.0:
		return

	if _time_left > 0.0:
		# Already shaking: only take over if the new shake beats what is left of this one.
		var remaining_strength := _strength * _time_left / _duration
		if strength <= remaining_strength:
			return
	else:
		_base_origin = get_viewport().canvas_transform.origin

	_strength = strength
	_duration = duration
	_time_left = duration
	set_process(true)


func _process(delta: float) -> void:
	_time_left -= delta
	# Also stops straight away if Screen Shake gets switched off mid-shake.
	if _time_left <= 0.0 or not Settings.screen_shake_enabled:
		_time_left = 0.0
		_set_offset(Vector2.ZERO)
		set_process(false)
		return

	var falloff := _time_left / _duration
	var jitter := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
	_set_offset(jitter * _strength * falloff)


func _set_offset(offset: Vector2) -> void:
	var viewport := get_viewport()
	var canvas_transform := viewport.canvas_transform
	canvas_transform.origin = _base_origin + offset
	viewport.canvas_transform = canvas_transform
