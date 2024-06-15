extends Node2D

@export var checkpoint: Constants.checkpoint
@export var flashback_scene: PackedScene = null

@onready var sparkles: Node2D = $Sparkles
@onready var interaction_area: InteractionArea2D = $InteractionArea2D


func force_flashback():
	return interaction_area.feature != Constants.feature_flag.NONE && !PlayerData.has_feature(interaction_area.feature)

#func _physics_process(_delta):
	#if is_active && Input.is_action_just_pressed("player_interact"):
		#print("returning camera")
		#SignalBus.emit_signal("_cutscene_ended")
		#is_active = false

func _on_interaction_over():
	sparkles.show()


func _on_player_interacted(_player: Player):
	print("interacted with the checkpoint")
	sparkles.hide()
	SignalBus.emit_signal("_request_camera", self)
	if is_instance_valid(flashback_scene) && force_flashback():
		await get_tree().create_timer(1).timeout
		SignalBus.emit_signal("_request_load_flashback", flashback_scene)
	else:
		pass # TODO: dialogue box to save and replay flashback if applicable
