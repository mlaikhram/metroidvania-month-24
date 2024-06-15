class_name InteractionArea2D
extends Area2D


@export var feature: Constants.feature_flag
@export var target_x_distance = 0
@export var face_center = true
@export var force_interaction = false

@onready var interaction_popup: Label = get_node_or_null("Popup")


func _ready():
	connect("area_entered", self._on_interaction_area_entered)
	connect("area_exited", self._on_interaction_area_exited)


func interact(player: Player):
	get_parent()._on_player_interacted(player)


func end_interaction():
	if feature != Constants.feature_flag.NONE && !PlayerData.has_feature(feature):
		SignalBus.emit_signal("_unlocked_feature", feature)
		
	get_parent()._on_interaction_over()
	if is_instance_valid(interaction_popup):
		interaction_popup.show()

func hide_popup():
	if is_instance_valid(interaction_popup):
		interaction_popup.hide()
	

func _on_interaction_area_entered(interactor):
	if interactor == null || !interactor is Interactor2D:
		return
	
	print("interaction area entered")
	if interactor.set_current_interactible(self):
		if force_interaction:
			interactor.force()
		elif is_instance_valid(interaction_popup):
			interaction_popup.show()

func _on_interaction_area_exited(interactor):
	if interactor == null || !interactor is Interactor2D:
		return
	
	if is_instance_valid(interaction_popup):
		interaction_popup.hide()
	interactor.exit_interactible(self)


func get_target_x_position():
	return global_position.x + target_x_distance

