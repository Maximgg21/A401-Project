class_name CardView
extends Control

const SIZE := Vector2(220.0, 300.0)
const RARITY_COLORS := {
	# TODO: color the card by rarity
	CardData.CardRarity.COMMON: Color("6f776fff"),
	CardData.CardRarity.UNCOMMON: Color("5967a2ff"),
	CardData.CardRarity.RARE: Color("407f40ff"),
	CardData.CardRarity.LEGENDARY: Color("b66f12ff"),
	CardData.CardRarity.MYTHIC: Color("6e0f7aff"),
}

@export var data: CardData:
	set(value):
		data = value
		if is_node_ready():
			_refresh()

var card: Card:
	set(value):
		card = value
		if card:
			data = card.data

var _tween: Tween
var _base_z_index: int
var _base_angle: float
var _base_scale: Vector2

@onready var _body: PanelContainer = %Body
@onready var _name_label: Label = %NameLabel
@onready var _description_label: Label = %DescriptionLabel
@onready var _cost_label: Label = %CostLabel
@onready var _type_label: Label = %TypeLabel
@onready var _art: TextureRect = %Art


func _ready() -> void:
	custom_minimum_size = SIZE
	_base_z_index = z_index
	_base_angle = rotation
	_base_scale = scale
	_refresh()


func _restart_tween() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()


func _refresh() -> void:
	_name_label.text = data.name
	_description_label.text = data.get_description()
	_cost_label.text = str(data.cost)
	_type_label.text = CardData.CardType.find_key(data.type).capitalize()
	_art.texture = data.art


func set_hovered(hovered: bool):
	_restart_tween()
	if hovered:
		scale = _base_scale + Vector2(0.2, 0.2)
		z_index = 100
		rotation = 0.0
	else:
		_tween.tween_property(self, "scale", _base_scale, 0.2)
		z_index = _base_z_index
		rotation = _base_angle
