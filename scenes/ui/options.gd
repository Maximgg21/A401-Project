extends Control

const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"
const SHAKE_PREVIEW_STRENGTH := 8.0
const SHAKE_PREVIEW_SECONDS := 0.3

@onready var fullscreen_toggle: CheckButton = %FullscreenToggle
@onready var screen_shake_toggle: CheckButton = %ScreenShakeToggle
@onready var volume_slider: HSlider = %VolumeSlider
@onready var volume_value: Label = %VolumeValue
@onready var reset_button: Button = %ResetButton
@onready var back_button: Button = %BackButton


func _ready() -> void:
	volume_slider.min_value = 0.0
	volume_slider.max_value = 100.0
	volume_slider.step = 1.0

	_refresh_from_settings()

	fullscreen_toggle.toggled.connect(_on_fullscreen_toggled)
	screen_shake_toggle.toggled.connect(_on_screen_shake_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	reset_button.pressed.connect(_on_reset_pressed)
	back_button.pressed.connect(_go_back)

	fullscreen_toggle.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_go_back()


func _exit_tree() -> void:
	Settings.flush()


func _refresh_from_settings() -> void:
	fullscreen_toggle.set_pressed_no_signal(Settings.fullscreen)
	screen_shake_toggle.set_pressed_no_signal(Settings.screen_shake_enabled)
	volume_slider.set_value_no_signal(Settings.master_volume * 100.0)
	_update_value_labels()


func _update_value_labels() -> void:
	volume_value.text = "%d%%" % roundi(Settings.master_volume * 100.0)


func _on_fullscreen_toggled(enabled: bool) -> void:
	Settings.fullscreen = enabled


func _on_screen_shake_toggled(enabled: bool) -> void:
	Settings.screen_shake_enabled = enabled
	if enabled:
		# A small demo so the player feels what they just turned on.
		ScreenShake.shake(SHAKE_PREVIEW_STRENGTH, SHAKE_PREVIEW_SECONDS)


func _on_volume_changed(value: float) -> void:
	Settings.master_volume = value / 100.0
	_update_value_labels()


func _on_reset_pressed() -> void:
	Settings.reset_to_defaults()
	_refresh_from_settings()


func _go_back() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
