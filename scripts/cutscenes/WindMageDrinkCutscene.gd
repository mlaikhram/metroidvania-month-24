extends Node


@export var scripted_death_cutscene: PackedScene
@export var wind_book_prop: Node2D


func _on_interaction_over():
	print("ending drink interaction")
	var next_cutscene = scripted_death_cutscene.instantiate()
	next_cutscene.global_position = Vector2(24108, 480)
	next_cutscene.wind_book_prop = wind_book_prop
	owner.add_child(next_cutscene)
	
	queue_free()


func _on_player_interacted(player: Player):
	print("interacting drinking " + player.name)
	var tween = get_tree().create_tween()
	tween.tween_callback(player._animated_sprite.play.bind("drink"))
	tween.tween_callback(player._animated_sprite.play.bind("idle")).set_delay(3)
	tween.tween_callback(SignalBus.emit_signal.bind("_cutscene_ended"))
	
