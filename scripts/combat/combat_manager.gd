#this will handle things like the map, turn order, movement, attacks, and status effects
class_name CombatManager
extends Node2D

const ORC := preload("res://data/enemies/orc.tres")

var entities: Array[MapEntity]
var hero: Hero
var enemy: Enemy
var deck: CombatDeck


func _ready() -> void:
	deck = CombatDeck.new()
	hero = RunState.hero
	enemy = Enemy.new(ORC)
	entities.append(enemy)


func end_turn() -> void:
	deck.discard_all()
	start_turn()


func start_turn() -> void:
	deck.draw(5) # TODO: change default to a constant, probably in hero.gd
	hero.start_turn()


func start_combat() -> void:
	#TODO: Append all EnemyData and other objects to entities
	start_turn()


func play_card(card: Card, target: MapEntity = null) -> void:
	if card.data.needs_target():
		if target == null or target.team not in [MapEntity.Team.ENEMY, MapEntity.Team.NEUTRAL]:
			ScreenShake.shake()
			return

	if hero.spend_energy(card.data.cost):
		var context := EffectContext.new(hero, target)
		for effect in card.data.effects:
			effect.apply(context)
		deck.discard_one(card)
		print(enemy.current_health)
