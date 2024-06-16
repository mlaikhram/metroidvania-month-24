extends Node


@export var stuck_dagger_prop: Node2D

@export var monkey_projectile: PackedScene
@export var flying_dagger: PackedScene


var flying_dagger_instance: RigidBody2D


func _on_player_interacted(player: Player):
	var monkey_projectile_instance = monkey_projectile.instantiate()
	owner.add_child(monkey_projectile_instance)
	monkey_projectile_instance.global_position = Vector2(3336, -516)
	
	var tween = get_tree().create_tween()
	tween.tween_property(monkey_projectile_instance, "global_position", Vector2(2685, -148), 0.3).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_impact_with_player.bind(player))
	tween.parallel().tween_property(monkey_projectile_instance, "global_position", Vector2(2550, -89), 0.3).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_end_flashback).set_delay(1.6)


func _impact_with_player(player: Player):
	player._animated_sprite.play("scripted_death")
	player.set_script(null)
	flying_dagger_instance = flying_dagger.instantiate()
	owner.add_child(flying_dagger_instance)
	flying_dagger_instance.global_position = Vector2(2655, -64)
	flying_dagger_instance.linear_velocity = Vector2(2390.625, -824)


func _end_flashback():
	flying_dagger_instance.queue_free()
	stuck_dagger_prop.show()
	SignalBus.emit_signal("_request_camera", stuck_dagger_prop)
	await get_tree().create_timer(3).timeout
	SignalBus.emit_signal("_request_load_main_level", owner)
