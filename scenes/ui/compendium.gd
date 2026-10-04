extends Control

const MAIN_MENU_PATH := "res://scenes/ui/main_menu.tscn"
const ICON_SIZE := Vector2(64, 64)
const GRID_COLUMNS := 5

# The Cards tab is different from the other tabs. It pulls cards from data/cards
const CARDS_DATA_PATH := "res://data/cards"
const CARD_SCENE := preload("res://scenes/cards/card.tscn")
const CARD_MIN_SIZE := Vector2(160, 220)
const CARD_GRID_COLUMNS := 4

# Manual Data Entry Portion

# --- Characters ---
var character_1_name := "Alex"
var character_1_icon: Texture2D = null
var character_1_info := "Default guy"

var character_2_name := ""
var character_2_icon: Texture2D = null
var character_2_info := ""

var character_3_name := ""
var character_3_icon: Texture2D = null
var character_3_info := ""

var character_4_name := ""
var character_4_icon: Texture2D = null
var character_4_info := ""

var character_5_name := ""
var character_5_icon: Texture2D = null
var character_5_info := ""

# --- Upgrades ---
var upgrade_1_name := "Attack Speed Up"
var upgrade_1_icon: Texture2D = null
var upgrade_1_info := "Increases Attack Speed by 10%"

var upgrade_2_name := ""
var upgrade_2_icon: Texture2D = null
var upgrade_2_info := ""

var upgrade_3_name := ""
var upgrade_3_icon: Texture2D = null
var upgrade_3_info := ""

var upgrade_4_name := ""
var upgrade_4_icon: Texture2D = null
var upgrade_4_info := ""

var upgrade_5_name := ""
var upgrade_5_icon: Texture2D = null
var upgrade_5_info := ""

var upgrade_6_name := ""
var upgrade_6_icon: Texture2D = null
var upgrade_6_info := ""

var upgrade_7_name := ""
var upgrade_7_icon: Texture2D = null
var upgrade_7_info := ""

var upgrade_8_name := ""
var upgrade_8_icon: Texture2D = null
var upgrade_8_info := ""

var upgrade_9_name := ""
var upgrade_9_icon: Texture2D = null
var upgrade_9_info := ""

var upgrade_10_name := ""
var upgrade_10_icon: Texture2D = null
var upgrade_10_info := ""

var upgrade_11_name := ""
var upgrade_11_icon: Texture2D = null
var upgrade_11_info := ""

var upgrade_12_name := ""
var upgrade_12_icon: Texture2D = null
var upgrade_12_info := ""

var upgrade_13_name := ""
var upgrade_13_icon: Texture2D = null
var upgrade_13_info := ""

var upgrade_14_name := ""
var upgrade_14_icon: Texture2D = null
var upgrade_14_info := ""

var upgrade_15_name := ""
var upgrade_15_icon: Texture2D = null
var upgrade_15_info := ""

var upgrade_16_name := ""
var upgrade_16_icon: Texture2D = null
var upgrade_16_info := ""

var upgrade_17_name := ""
var upgrade_17_icon: Texture2D = null
var upgrade_17_info := ""

var upgrade_18_name := ""
var upgrade_18_icon: Texture2D = null
var upgrade_18_info := ""

var upgrade_19_name := ""
var upgrade_19_icon: Texture2D = null
var upgrade_19_info := ""

var upgrade_20_name := ""
var upgrade_20_icon: Texture2D = null
var upgrade_20_info := ""

# --- Enemies ---
var enemy_1_name := "Slime"
var enemy_1_icon: Texture2D = preload("res://assets/art/mobs/test_slime/slime.jpeg")
var enemy_1_info := """Hp: 10
Def: 0
Atk: 5
Speed: Slow"""

var enemy_2_name := ""
var enemy_2_icon: Texture2D = null
var enemy_2_info := ""

var enemy_3_name := ""
var enemy_3_icon: Texture2D = null
var enemy_3_info := ""

var enemy_4_name := ""
var enemy_4_icon: Texture2D = null
var enemy_4_info := ""

var enemy_5_name := ""
var enemy_5_icon: Texture2D = null
var enemy_5_info := ""

var enemy_6_name := ""
var enemy_6_icon: Texture2D = null
var enemy_6_info := ""

var enemy_7_name := ""
var enemy_7_icon: Texture2D = null
var enemy_7_info := ""

var enemy_8_name := ""
var enemy_8_icon: Texture2D = null
var enemy_8_info := ""

var enemy_9_name := ""
var enemy_9_icon: Texture2D = null
var enemy_9_info := ""

var enemy_10_name := ""
var enemy_10_icon: Texture2D = null
var enemy_10_info := ""

var enemy_11_name := ""
var enemy_11_icon: Texture2D = null
var enemy_11_info := ""

var enemy_12_name := ""
var enemy_12_icon: Texture2D = null
var enemy_12_info := ""

var enemy_13_name := ""
var enemy_13_icon: Texture2D = null
var enemy_13_info := ""

var enemy_14_name := ""
var enemy_14_icon: Texture2D = null
var enemy_14_info := ""

var enemy_15_name := ""
var enemy_15_icon: Texture2D = null
var enemy_15_info := ""

# UI Portion
# ----
var detail_popup: PopupPanel
var detail_icon: TextureRect
var detail_name_label: Label
var detail_info_box: TextEdit


func _ready() -> void:
	_build_background()
	_build_layout()


func _build_background() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.1, 0.1, 0.12)
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
	title.text = "Compendium"
	title.add_theme_font_size_override("font_size", 28)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var back_button := Button.new()
	back_button.text = "Back"
	back_button.pressed.connect(_on_back_pressed)
	header.add_child(back_button)

	var tabs := TabContainer.new()
	tabs.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root_vbox.add_child(tabs)

	var characters_tab := _build_characters_tab()
	characters_tab.name = "Characters"
	tabs.add_child(characters_tab)

	var upgrades_tab := _build_upgrades_tab()
	upgrades_tab.name = "Upgrades"
	tabs.add_child(upgrades_tab)

	var cards_tab := _build_cards_tab()
	cards_tab.name = "Cards"
	tabs.add_child(cards_tab)

	var enemies_tab := _build_enemies_tab()
	enemies_tab.name = "Enemies"
	tabs.add_child(enemies_tab)

	_build_detail_popup()


func _new_grid(columns: int = GRID_COLUMNS, h_separation: int = 10, v_separation: int = 10) -> GridContainer:
	var grid := GridContainer.new()
	grid.columns = columns
	grid.add_theme_constant_override("h_separation", h_separation)
	grid.add_theme_constant_override("v_separation", v_separation)
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return grid


func _make_icon_button(
	display_number: int, entry_name: String, entry_icon: Texture2D, entry_info: String
) -> Button:
	var button := Button.new()
	button.custom_minimum_size = ICON_SIZE
	button.add_theme_constant_override("icon_max_width", int(ICON_SIZE.x))
	if entry_icon:
		button.icon = entry_icon
	else:
		button.text = str(display_number)
	button.pressed.connect(_on_icon_pressed.bind(entry_name, entry_icon, entry_info))
	return button


func _build_characters_tab() -> Control:
	var scroll := ScrollContainer.new()
	var grid := _new_grid()

	grid.add_child(_make_icon_button(1, character_1_name, character_1_icon, character_1_info))
	grid.add_child(_make_icon_button(2, character_2_name, character_2_icon, character_2_info))
	grid.add_child(_make_icon_button(3, character_3_name, character_3_icon, character_3_info))
	grid.add_child(_make_icon_button(4, character_4_name, character_4_icon, character_4_info))
	grid.add_child(_make_icon_button(5, character_5_name, character_5_icon, character_5_info))

	scroll.add_child(grid)
	return scroll


func _build_upgrades_tab() -> Control:
	var scroll := ScrollContainer.new()
	var grid := _new_grid()

	grid.add_child(_make_icon_button(1, upgrade_1_name, upgrade_1_icon, upgrade_1_info))
	grid.add_child(_make_icon_button(2, upgrade_2_name, upgrade_2_icon, upgrade_2_info))
	grid.add_child(_make_icon_button(3, upgrade_3_name, upgrade_3_icon, upgrade_3_info))
	grid.add_child(_make_icon_button(4, upgrade_4_name, upgrade_4_icon, upgrade_4_info))
	grid.add_child(_make_icon_button(5, upgrade_5_name, upgrade_5_icon, upgrade_5_info))
	grid.add_child(_make_icon_button(6, upgrade_6_name, upgrade_6_icon, upgrade_6_info))
	grid.add_child(_make_icon_button(7, upgrade_7_name, upgrade_7_icon, upgrade_7_info))
	grid.add_child(_make_icon_button(8, upgrade_8_name, upgrade_8_icon, upgrade_8_info))
	grid.add_child(_make_icon_button(9, upgrade_9_name, upgrade_9_icon, upgrade_9_info))
	grid.add_child(_make_icon_button(10, upgrade_10_name, upgrade_10_icon, upgrade_10_info))
	grid.add_child(_make_icon_button(11, upgrade_11_name, upgrade_11_icon, upgrade_11_info))
	grid.add_child(_make_icon_button(12, upgrade_12_name, upgrade_12_icon, upgrade_12_info))
	grid.add_child(_make_icon_button(13, upgrade_13_name, upgrade_13_icon, upgrade_13_info))
	grid.add_child(_make_icon_button(14, upgrade_14_name, upgrade_14_icon, upgrade_14_info))
	grid.add_child(_make_icon_button(15, upgrade_15_name, upgrade_15_icon, upgrade_15_info))
	grid.add_child(_make_icon_button(16, upgrade_16_name, upgrade_16_icon, upgrade_16_info))
	grid.add_child(_make_icon_button(17, upgrade_17_name, upgrade_17_icon, upgrade_17_info))
	grid.add_child(_make_icon_button(18, upgrade_18_name, upgrade_18_icon, upgrade_18_info))
	grid.add_child(_make_icon_button(19, upgrade_19_name, upgrade_19_icon, upgrade_19_info))
	grid.add_child(_make_icon_button(20, upgrade_20_name, upgrade_20_icon, upgrade_20_info))

	scroll.add_child(grid)
	return scroll


func _build_cards_tab() -> Control:
	var scroll := ScrollContainer.new()

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	scroll.add_child(margin)

	var grid := _new_grid(CARD_GRID_COLUMNS, 24, 24)
	margin.add_child(grid)

	var dir := DirAccess.open(CARDS_DATA_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var card_data := load(CARDS_DATA_PATH + "/" + file_name) as CardData
				if card_data:
					var card_instance: CardView = CARD_SCENE.instantiate()
					card_instance.custom_minimum_size = CARD_MIN_SIZE
					card_instance.data = card_data
					grid.add_child(card_instance)
				else:
					push_warning("File did not load as CardData: %s" % file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_warning("Could not open folder: %s" % CARDS_DATA_PATH)

	return scroll


func _build_enemies_tab() -> Control:
	var scroll := ScrollContainer.new()
	var grid := _new_grid()

	grid.add_child(_make_icon_button(1, enemy_1_name, enemy_1_icon, enemy_1_info))
	grid.add_child(_make_icon_button(2, enemy_2_name, enemy_2_icon, enemy_2_info))
	grid.add_child(_make_icon_button(3, enemy_3_name, enemy_3_icon, enemy_3_info))
	grid.add_child(_make_icon_button(4, enemy_4_name, enemy_4_icon, enemy_4_info))
	grid.add_child(_make_icon_button(5, enemy_5_name, enemy_5_icon, enemy_5_info))
	grid.add_child(_make_icon_button(6, enemy_6_name, enemy_6_icon, enemy_6_info))
	grid.add_child(_make_icon_button(7, enemy_7_name, enemy_7_icon, enemy_7_info))
	grid.add_child(_make_icon_button(8, enemy_8_name, enemy_8_icon, enemy_8_info))
	grid.add_child(_make_icon_button(9, enemy_9_name, enemy_9_icon, enemy_9_info))
	grid.add_child(_make_icon_button(10, enemy_10_name, enemy_10_icon, enemy_10_info))
	grid.add_child(_make_icon_button(11, enemy_11_name, enemy_11_icon, enemy_11_info))
	grid.add_child(_make_icon_button(12, enemy_12_name, enemy_12_icon, enemy_12_info))
	grid.add_child(_make_icon_button(13, enemy_13_name, enemy_13_icon, enemy_13_info))
	grid.add_child(_make_icon_button(14, enemy_14_name, enemy_14_icon, enemy_14_info))
	grid.add_child(_make_icon_button(15, enemy_15_name, enemy_15_icon, enemy_15_info))

	scroll.add_child(grid)
	return scroll


func _build_detail_popup() -> void:
	detail_popup = PopupPanel.new()
	detail_popup.size = Vector2(360, 320)
	add_child(detail_popup)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 8)
	vbox.offset_left = 12
	vbox.offset_top = 12
	vbox.offset_right = -12
	vbox.offset_bottom = -12
	detail_popup.add_child(vbox)

	detail_icon = TextureRect.new()
	detail_icon.custom_minimum_size = Vector2(64, 64)
	detail_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	detail_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	vbox.add_child(detail_icon)

	detail_name_label = Label.new()
	detail_name_label.add_theme_font_size_override("font_size", 20)
	vbox.add_child(detail_name_label)

	# A plain text box for the info - can hold anything: stats, lore, notes.
	detail_info_box = TextEdit.new()
	detail_info_box.editable = false
	detail_info_box.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	detail_info_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(detail_info_box)

	var close_button := Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(func(): detail_popup.hide())
	vbox.add_child(close_button)


func _on_icon_pressed(entry_name: String, entry_icon: Texture2D, entry_info: String) -> void:
	detail_name_label.text = entry_name if entry_name != "" else "???"
	detail_info_box.text = entry_info if entry_info != "" else "No data added yet."
	detail_icon.texture = entry_icon
	detail_popup.popup_centered()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
