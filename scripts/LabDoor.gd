extends Node2D


@export var feature: Constants.feature_flag
@export var invert_feature_check = false

@onready var _door = $Door
@onready var _door_animated_sprite = $Door/AnimatedSprite2D
@onready var _dust = get_node_or_null("Dust")


# Called when the node enters the scene tree for the first time.
func _ready():
	open()


func open():
	var tween = get_tree().create_tween()
	tween.tween_callback(_dust.play.bind("default"))
	tween.tween_property(_door, "global_position", Vector2(global_position.x, global_position.y + 320), 3).set_trans(Tween.TRANS_LINEAR).set_delay(1)
	tween.parallel().tween_callback(_door_animated_sprite.play.bind("open")).set_delay(1)
	tween.tween_property(_dust, "modulate", Color.TRANSPARENT, 1)
	tween.tween_callback(_dust.play.bind("none"))
