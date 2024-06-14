extends Node

@export var transition_rect: TextureRect

@onready var main_level = $Level


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._request_load_flashback.connect(_load_flashback)


func _load_flashback(scene: PackedScene):
	var tween = get_tree().create_tween()
	tween.tween_property(transition_rect, "modulate", Color.WHITE, 0.5).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(_switch_to_flashback.bind(scene))
	tween.tween_property(transition_rect, "modulate", Color.TRANSPARENT, 0.5).set_trans(Tween.TRANS_QUAD).set_delay(1.5)
	
	#await get_tree().create_timer(3).timeout
	#scene_instance.queue_free()
	#
	#await get_tree().create_timer(0.1).timeout
	#
	#main_level.set_physics_process(PROCESS_MODE_INHERIT)
	#add_child(main_level)
	#main_level.show()
	#SignalBus.emit_signal("_cutscene_ended")

func _switch_to_flashback(scene: PackedScene):
	main_level.hide()
	main_level.set_physics_process(PROCESS_MODE_DISABLED)
	remove_child(main_level)
	var scene_instance = scene.instantiate()
	add_child(scene_instance)
	#var tween = get_tree().create_tween()
	
