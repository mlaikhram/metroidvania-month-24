extends Node2D


@export var rotation_speed = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotation_degrees += rotation_speed * delta
