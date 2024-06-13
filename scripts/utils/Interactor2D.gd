class_name Interactor2D
extends Area2D


var current_interactible = null


func should_face_interaction():
	return false if !is_instance_valid(current_interactible) else current_interactible.face_center


func get_interaction_position():
	return null if !is_instance_valid(current_interactible) else current_interactible.global_position


func force():
	if owner.has_method("_start_cutscene"):
		owner._start_cutscene()
	else:
		print("owner does not have _start_cutscene")


func prepare():
	current_interactible.hide_popup()
	return current_interactible.get_target_x_position()


func interact(player: Player):
	current_interactible.interact(player)
	current_interactible = null


func has_interaction():
	return is_instance_valid(current_interactible)


func set_current_interactible(interactible: InteractionArea2D):
	print("setting interactible")
	current_interactible = interactible


func exit_interactible(interactible: InteractionArea2D):
	if current_interactible == interactible:
		print("unsetting interactible")
		current_interactible = null
