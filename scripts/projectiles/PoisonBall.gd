class_name PoisonBall
extends RigidBody2D


@onready var fadeout_animated_sprite = $FadeOutAnimatedSprite2D
@onready var hitbox = $Hitbox2D
@onready var hurtbox = $Hurtbox2D


func _ready():
	await get_tree().create_timer(0.1).timeout
	hurtbox.set_collision_mask_value(1, true)


func on_hit(_body):
	linear_velocity = Vector2.ZERO
	fadeout_animated_sprite.set_time_left(min(fadeout_animated_sprite.time_left, 0.5))


func push_away_from(source_position: Vector2, push_speed: float):
	hitbox.set_process_mode(Node.PROCESS_MODE_DISABLED)
	hurtbox.set_collision_mask_value(1, true)
	linear_velocity = push_speed * source_position.direction_to(global_position)
	fadeout_animated_sprite.set_time_left(min(fadeout_animated_sprite.time_left, 0.5))
