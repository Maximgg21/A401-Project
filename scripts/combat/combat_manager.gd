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


func play_card(card: Card) -> void:
	if hero.spend_energy(card.data.cost):
		var context := EffectContext.new(hero, enemy)
		for effect in card.data.effects:
			effect.apply(context)
		deck.discard_one(card)
		print(enemy.current_health)
