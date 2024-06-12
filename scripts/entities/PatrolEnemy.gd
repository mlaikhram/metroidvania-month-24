extends CharacterBody2D


const MAX_FALL_SPEED = 800.0

@export var speed = 200
@export var edge_detecting_x_distance = 0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_facing_right = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = minf(velocity.y, MAX_FALL_SPEED)
		
	if is_on_wall() || _is_near_edge():
		scale.x = -1
		is_facing_right = !is_facing_right
		
	velocity.x = (1 if is_facing_right else -1) * speed
	
	move_and_slide()


func _is_near_edge():
	if edge_detecting_x_distance <= 0 || !is_on_floor():
		return false
		
	var space_state = get_world_2d().direct_space_state
	var x_position = global_position.x + (edge_detecting_x_distance if is_facing_right else -edge_detecting_x_distance)
	var edge_raycast = PhysicsRayQueryParameters2D.create(Vector2(x_position, global_position.y - 4), Vector2(x_position, global_position.y + 4))
	var edge_result = space_state.intersect_ray(edge_raycast)
	
	return not edge_result


func take_damage(hitbox):
	print("killed me")
	queue_free()

