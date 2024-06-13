class_name InteractionArea2D
extends Area2D


@export var action_name = "interact"
@export var target_x_distance = 0
@export var face_center = true
@export var force_interaction = false

@onready var interaction_popup: Label = $Popup


func _ready():
	connect("area_entered", self._on_interaction_area_entered)
	connect("area_exited", self._on_interaction_area_exited)


func interact(player: Player):
	get_parent()._on_player_interacted(player)


func hide_popup():
	interaction_popup.hide()
	

func _on_interaction_area_entered(interactor):
	if interactor == null || !interactor is Interactor2D:
		return
	
	interactor.set_current_interactible(self)
	if force_interaction:
		interactor.force()
	else:
		interaction_popup.show()

func _on_interaction_area_exited(interactor):
	if interactor == null || !interactor is Interactor2D:
		return
	
	interaction_popup.hide()
	interactor.exit_interactible(self)


func get_target_x_position():
	return global_position.x + target_x_distance

