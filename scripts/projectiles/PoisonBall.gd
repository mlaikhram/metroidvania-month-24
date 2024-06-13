class_name PoisonBall
extends RigidBody2D


@onready var fadeout_animated_sprite = $FadeOutAnimatedSprite2D


func on_hit(_body):
	linear_velocity = Vector2.ZERO
	fadeout_animated_sprite.set_time_left(min(fadeout_animated_sprite.time_left, 0.5))


func push_away_from(source_position: Vector2, push_speed: float):
	linear_velocity = push_speed * source_position.direction_to(position)
	fadeout_animated_sprite.set_time_left(min(fadeout_animated_sprite.time_left, 0.5))
	if owner.has_method("_on_pushed_away"):
		owner._on_pushed_away(source_position, push_speed)
