class_name Projectile2D
extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	linear_velocity = 100 * Vector2.LEFT


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func push_away_from(source_position: Vector2, push_speed: float):
	linear_velocity = push_speed * source_position.direction_to(position)
