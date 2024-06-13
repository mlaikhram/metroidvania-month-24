extends Node2D


@export var flashback_scene: PackedScene = null
@export var force_flashback = false


var is_active = false


func _physics_process(delta):
	if is_active && Input.is_action_just_pressed("player_interact"):
		print("returning camera")
		SignalBus.emit_signal("_cutscene_ended")
		is_active = false


func _on_player_interacted(_player: Player):
	print("interacted with the checkpoint")
	is_active = true
	SignalBus.emit_signal("_request_camera", self)
	# TODO: single camera at the root level with reference to player
	# camera default follows the player
	# interaction points send a signal to request the camera
	# they are also responsible for releasing the camera

