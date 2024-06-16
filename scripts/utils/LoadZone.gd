class_name LoadZone2D
extends Area2D


@export var loaded_biome: Constants.Biome
@export var scene_contents: PackedScene


func _ready():
	body_entered.connect(_player_entered)
	

func _player_entered(player):
	if player == null || !player is Player:
		return
	
	if PlayerData.current_biome != loaded_biome:
		SignalBus.emit_signal("_switched_biome", loaded_biome)
	
