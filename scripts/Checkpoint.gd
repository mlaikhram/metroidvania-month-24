extends Node


@export var flashback_scene: PackedScene = null
@export var force_flashback = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_player_interacted(player: Player):
	print("interacted with the checkpoint")
