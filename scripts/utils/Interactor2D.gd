class_name Interactor2D
extends Area2D


var current_interactible = null
var is_interacting = false


func should_face_interaction():
	return false if !is_instance_valid(current_interactible) else current_interactible.face_center


func get_interaction_position():
	return null if !is_instance_valid(current_interactible) else current_interactible.global_position


func force():
	if !is_interacting:
		if owner.has_method("_start_cutscene"):
			owner._start_cutscene()
		else:
			print("owner does not have _start_cutscene")


func prepare():
	if !is_interacting:
		current_interactible.hide_popup()
		return current_interactible.get_target_x_position()


func interact(player: Player):
	print("interacted")
	if !is_interacting:
		current_interactible.interact(player)
		is_interacting = true
		
		
func end_interaction():
	current_interactible.end_interaction()
	current_interactible = null
	is_interacting = false


func has_interaction():
	return is_instance_valid(current_interactible)


func set_current_interactible(interactible: InteractionArea2D):
	if !is_interacting:
		print("setting interactible")
		current_interactible = interactible
		return true
	return false


func exit_interactible(interactible: InteractionArea2D):
	if !is_interacting && current_interactible == interactible:
		print("unsetting interactible")
		current_interactible = null
