class_name MapEditorCamera
extends Camera2D
## Camera for the map editor. Holds no input handling: MapEditorInput calls these methods.
## Keep position smoothing and drag margins OFF so pan/zoom math stays exact.

@export var min_zoom := 0.25
@export var max_zoom := 4.0
## Zoom multiplier per mouse-wheel notch.
@export var zoom_step := 1.1
## Screen pixels of padding kept around the room when framing it.
@export var frame_margin := 48.0
## Framing never zooms in past this, so tiny rooms don't become giant.
@export var max_frame_zoom := 2.0


## Moves the view by a mouse movement given in screen pixels (drag direction = content direction).
func pan_by_screen(screen_delta: Vector2) -> void:
	global_position -= screen_delta / zoom


## Zooms toward a screen position, keeping the world point under it fixed.
## Positive notches zoom in, negative zoom out.
func zoom_at_screen(screen_pos: Vector2, notches: float) -> void:
	var old_zoom := zoom.x
	var new_zoom := clampf(old_zoom * pow(zoom_step, notches), min_zoom, max_zoom)
	if is_equal_approx(new_zoom, old_zoom):
		return
	var offset := screen_pos - get_viewport_rect().size * 0.5
	var world_point := global_position + offset / old_zoom
	zoom = Vector2.ONE * new_zoom
	global_position = world_point - offset / new_zoom


## Centers and zooms so the given global-space rectangle fits on screen.
func frame_rect(rect: Rect2) -> void:
	var available := get_viewport_rect().size - Vector2.ONE * frame_margin * 2.0
	if rect.size.x <= 0.0 or rect.size.y <= 0.0 or available.x <= 0.0 or available.y <= 0.0:
		return
	var fit := minf(available.x / rect.size.x, available.y / rect.size.y)
	zoom = Vector2.ONE * clampf(fit, min_zoom, minf(max_zoom, max_frame_zoom))
	global_position = rect.get_center()
