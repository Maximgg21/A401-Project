extends Node2D

const PAUSE_MENU := preload("res://scenes/ui/pause_menu.tscn")


func _ready() -> void:
	add_child(PAUSE_MENU.instantiate())
