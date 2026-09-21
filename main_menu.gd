extends Node

func _ready() -> void:
	pass

# Drag and drop game scene into the () of change_scene_to_file("") when it gets made
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("")
# GAME SCENE GOES HERE -------------^

func _on_compendium_pressed() -> void:
	get_tree().change_scene_to_file("res://compendium.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
