class_name CardView
extends Control

const RARITY_COLORS := {
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

@onready var _body: Panel = %Body
@onready var _name_label: Label = %NameLabel
@onready var _description_label: Label = %DescriptionLabel
@onready var _cost_label: Label = %CostLabel
@onready var _type_label: Label = %TypeLabel


func _ready() -> void:
	_refresh()


func _refresh():
	_name_label.text = data.name
	_description_label.text = data.get_description()
	_cost_label.text = str(data.cost)
	_type_label.text = CardData.CardType.find_key(data.type).capitalize()
