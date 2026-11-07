extends Node

const SAVE_PATH := "user://settings.cfg"
const SECTION := "settings"
const SAVE_DELAY_SECONDS := 0.5

const DEFAULT_FULLSCREEN := false
const DEFAULT_SCREEN_SHAKE := true
const DEFAULT_MASTER_VOLUME := 1.0

const OVERLAY_LAYER := 128

var fullscreen := DEFAULT_FULLSCREEN:
	set(value):
		if value == fullscreen:
			return
		fullscreen = value
		_apply_fullscreen()
		_queue_save()

var screen_shake_enabled := DEFAULT_SCREEN_SHAKE:
	set(value):
		if value == screen_shake_enabled:
			return
		screen_shake_enabled = value
		_queue_save()

var master_volume := DEFAULT_MASTER_VOLUME:
	set(value):
		value = clampf(value, 0.0, 1.0)
		if is_equal_approx(value, master_volume):
			return
		master_volume = value
		_apply_master_volume()
		_queue_save()

var _loading := false
var _dirty := false
var _save_timer: Timer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_save_timer()
	_load_from_disk()
	_apply_all()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_EXIT_TREE:
		flush()


func reset_to_defaults() -> void:
	fullscreen = DEFAULT_FULLSCREEN
	screen_shake_enabled = DEFAULT_SCREEN_SHAKE
	master_volume = DEFAULT_MASTER_VOLUME


func save() -> void:
	_dirty = false
	_save_timer.stop()

	var config := ConfigFile.new()
	config.set_value(SECTION, "fullscreen", fullscreen)
	config.set_value(SECTION, "screen_shake_enabled", screen_shake_enabled)
	config.set_value(SECTION, "master_volume", master_volume)

	var error := config.save(SAVE_PATH)
	if error != OK:
		push_warning("Settings: could not save %s (error %d)" % [SAVE_PATH, error])


func flush() -> void:
	if _dirty:
		save()


func _build_save_timer() -> void:
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = SAVE_DELAY_SECONDS
	_save_timer.timeout.connect(flush)
	add_child(_save_timer)


func _load_from_disk() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return 

	_loading = true
	fullscreen = bool(config.get_value(SECTION, "fullscreen", DEFAULT_FULLSCREEN))
	screen_shake_enabled = bool(
		config.get_value(SECTION, "screen_shake_enabled", DEFAULT_SCREEN_SHAKE)
	)
	master_volume = float(config.get_value(SECTION, "master_volume", DEFAULT_MASTER_VOLUME))
	_loading = false


func _queue_save() -> void:
	if _loading:
		return
	_dirty = true
	_save_timer.start()


func _apply_all() -> void:
	_apply_fullscreen()
	_apply_master_volume()


func _apply_fullscreen() -> void:
	var mode := DisplayServer.WINDOW_MODE_WINDOWED
	if fullscreen:
		mode = DisplayServer.WINDOW_MODE_FULLSCREEN
	DisplayServer.window_set_mode(mode)


func _apply_master_volume() -> void:
	var bus := AudioServer.get_bus_index(&"Master")
	AudioServer.set_bus_mute(bus, master_volume <= 0.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(master_volume, 0.0001)))
