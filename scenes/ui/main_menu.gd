extends Node

func _ready() -> void:
	pass

# Drag and drop game scene into the () of change_scene_to_file("") when it gets made
func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/game.tscn")
# GAME SCENE GOES HERE -------------^

func _on_compendium_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/compendium.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
