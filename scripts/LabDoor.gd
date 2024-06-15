extends Node2D


@export var feature: Constants.feature_flag

@onready var cover_tilemap: TileMap = get_node_or_null("TileMap")
@onready var _door = $Door
@onready var _door_animated_sprite = $Door/AnimatedSprite2D
@onready var _dust = get_node_or_null("Dust")


# Called when the node enters the scene tree for the first time.
func _ready():
	if feature != Constants.feature_flag.NONE && PlayerData.has_feature(feature):
		if is_instance_valid(cover_tilemap):
			cover_tilemap.queue_free()
		_door.global_position = Vector2(global_position.x, global_position.y + 320)
		_door_animated_sprite.play("open")
	else:
		SignalBus._unlocked_feature.connect(_unlocked_door)


func _unlocked_door(new_feature: Constants.feature_flag):
	if feature == new_feature:
		if is_instance_valid(cover_tilemap):
			cover_tilemap.queue_free()
		var tween = get_tree().create_tween()
		tween.tween_callback(_dust.play.bind("default"))
		tween.tween_property(_door, "global_position", Vector2(global_position.x, global_position.y + 320), 3).set_trans(Tween.TRANS_LINEAR).set_delay(1)
		tween.parallel().tween_callback(_door_animated_sprite.play.bind("open")).set_delay(1)
		tween.tween_property(_dust, "modulate", Color.TRANSPARENT, 0.5)
		tween.tween_callback(_dust.play.bind("none"))
