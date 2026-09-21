extends Node

@onready var back_button: Button = $VBoxContainer/BackButton
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
