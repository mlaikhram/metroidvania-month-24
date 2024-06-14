extends Node2D


@export var projectile: PackedScene = null
@export var velocity: Vector2 = Vector2.ZERO
@export var degrees_of_error = 0.0
@export var x_offset = 0.0
@export var x_error = 0.0
@export var y_offset = 0.0
@export var y_error = 0.0
@export var fire_rate = 0.0
@export var on_duration = 1.0
@export var off_duration = 1.0
@export var offset = 0.0


var spray_cooldown = 0.0
var fire_cooldown = 0.0

func _ready():
	spray_cooldown = offset
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if spray_cooldown <= 0.0:
		if fire_cooldown <= 0.0:
			var projectile_instance = projectile.instantiate()
			add_child(projectile_instance)
			projectile_instance.position = Vector2(x_offset, y_offset)
			projectile_instance.position += Vector2(randf() * 2.0 * x_error - x_error, randf() * 2.0 * y_error - y_error)
			projectile_instance.linear_velocity = velocity.rotated(rotation).rotated(deg_to_rad(randf() * 2.0 * degrees_of_error - degrees_of_error))
			fire_cooldown += 1.0 / fire_rate
		
		fire_cooldown -= delta
	
	if spray_cooldown <= -on_duration:
		spray_cooldown += on_duration + off_duration
		
	spray_cooldown -= delta
