class_name PauseMenu
extends CanvasLayer

const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"
const OPTIONS_SCENE := preload("res://scenes/ui/options.tscn")

@onready var panel: Control = %Panel
@onready var resume_button: Button = %ResumeButton
@onready var options_button: Button = %OptionsButton
@onready var quit_button: Button = %QuitButton

var _options: OptionsScreen


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = GameSettings.OVERLAY_LAYER
	hide()
	resume_button.pressed.connect(resume)
	options_button.pressed.connect(_open_options)
	quit_button.pressed.connect(_quit_to_main_menu)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or _options:
		return
	get_viewport().set_input_as_handled()
	if get_tree().paused:
		resume()
	else:
		pause()


func pause() -> void:
	get_tree().paused = true
	show()
	resume_button.grab_focus()


func resume() -> void:
	get_tree().paused = false
	hide()


func _open_options() -> void:
	_options = OPTIONS_SCENE.instantiate() as OptionsScreen
	_options.closed.connect(_close_options)
	panel.hide()
	add_child(_options)


func _close_options() -> void:
	_options.queue_free()
	_options = null
	panel.show()
	options_button.grab_focus()


func _quit_to_main_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
