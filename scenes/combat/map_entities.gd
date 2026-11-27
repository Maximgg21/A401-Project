class_name MapEntities
extends Node2D

const MOVE_TIME := 0
const FADE_TIME := 0

var _manager: CombatManager
var _renderer: MapRenderer
var _views: Dictionary[MapEntity, CombatantView] = { }


func setup(manager: CombatManager, renderer: MapRenderer) -> void:
	_manager = manager
	_renderer = renderer
	manager.entity_moved.connect(_on_entity_moved)
	manager.entity_removed.connect(_on_entity_removed)


# Call after the entity has been placed, so the view can snap to its cell.
func bind_view(entity: Combatant, view: CombatantView) -> void:
	_views[entity] = view
	view.setup(entity)
	view.global_position = _renderer.logical_to_global(_manager.get_cell_of(entity))


func _on_entity_moved(entity: MapEntity, _from: Vector2i, to: Vector2i) -> void:
	var view: CombatantView = _views.get(entity)
	if view == null:
		return
	var tween := create_tween()
	tween.tween_property(view, "global_position", _renderer.logical_to_global(to), MOVE_TIME)
	# TODO: drive the walk animation (HeroView._animate) from the move direction


func _on_entity_removed(entity: MapEntity, _cell: Vector2i) -> void:
	var view: CombatantView = _views.get(entity)
	if view == null:
		return
	_views.erase(entity)
	if entity.current_health == 0:
		await view.play_death()
	var tween := create_tween()
	tween.tween_property(view, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(view.hide)
