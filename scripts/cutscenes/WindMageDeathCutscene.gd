extends Node


@export var wind_book_prop: Node2D


func _on_player_interacted(player: Player):
	var tween = get_tree().create_tween()
	tween.tween_callback(_player_fall.bind(player))
	tween.parallel().tween_callback(wind_book_prop.show).set_delay(1.25)
	tween.tween_callback(_end_flashback).set_delay(1.6)


func _player_fall(player: Player):
	player._animated_sprite.play("scripted_death")
	player.set_script(null)


func _end_flashback():
	SignalBus.emit_signal("_request_camera", wind_book_prop)
	SignalBus.emit_signal("_request_camera", self)
	await get_tree().create_timer(3).timeout
	SignalBus.emit_signal("_request_load_main_level", get_parent())
