class_name CardData
extends Resource

enum CardType { ATTACK, SKILL, MOVE, POWER }
enum CardRarity { COMMON, UNCOMMON, RARE, LEGENDARY, MYTHIC }

@export var id: StringName
@export var name: String
@export var cost: int
@export var type: CardType
@export var rarity: CardRarity
@export var art: Texture2D

@export_group("Effects")
@export var effects: Array[CardEffect] = []
@export_multiline var description_override: String = ""


func get_description() -> String:
	if description_override:
		return description_override
	var lines: PackedStringArray = []
	for effect in effects:
		lines.append(effect.get_description())
	return "\n".join(lines)
