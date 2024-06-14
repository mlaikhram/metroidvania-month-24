extends Node2D


@export var flashback_scene: PackedScene = null
@export var force_flashback = false


var is_active = false


#func _physics_process(_delta):
	#if is_active && Input.is_action_just_pressed("player_interact"):
		#print("returning camera")
		#SignalBus.emit_signal("_cutscene_ended")
		#is_active = false


func _on_player_interacted(_player: Player):
	print("interacted with the checkpoint")
	is_active = true
	SignalBus.emit_signal("_request_camera", self)
	if is_instance_valid(flashback_scene) && force_flashback:
		await get_tree().create_timer(1).timeout
		SignalBus.emit_signal("_request_load_flashback", flashback_scene)
	# TODO: single camera at the root level with reference to player
	# camera default follows the player
	# interaction points send a signal to request the camera
	# they are also responsible for releasing the camera

