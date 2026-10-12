extends Control
## Needs the "Achievements" autoload to be enabled.

const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"


func _ready() -> void:
	_build_background()
	_build_layout()


func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.329, 0.0, 0.023, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	move_child(bg, 0)


func _build_layout() -> void:
	var root_vbox := VBoxContainer.new()
	root_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_vbox.add_theme_constant_override("separation", 12)
	root_vbox.offset_left = 20
	root_vbox.offset_top = 20
	root_vbox.offset_right = -20
	root_vbox.offset_bottom = -20
	add_child(root_vbox)

	var header := HBoxContainer.new()
	root_vbox.add_child(header)

	var title := Label.new()
	title.text = "Achievements"
	title.add_theme_font_size_override("font_size", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var back_button := Button.new()
	back_button.text = "Back"
	back_button.pressed.connect(_on_back_pressed)
	header.add_child(back_button)

	var count_label := Label.new()
	count_label.text = (
		"%d / %d unlocked" % [Achievements.get_unlocked_count(), Achievements.get_total_count()]
	)
	root_vbox.add_child(count_label)

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	root_vbox.add_child(scroll)

	var list := VBoxContainer.new()
	list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list.add_theme_constant_override("separation", 10)
	scroll.add_child(list)

	Achievements.populate_list(list)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
