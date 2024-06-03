extends CharacterBody2D

enum player_state {
	IDLE,
	DAGGER,
	WIND_SPELL,
	ICE_SPELL
}

enum movement_type {
	ANY,
	AERIAL,
	NONE
}

@export var wind_gust: PackedScene 
@export var ice_statue: PackedScene

@onready var _animated_sprite = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_facing_right = true
var current_state = player_state.IDLE
var seconds_since_action_start = 0

var current_wind_gust: Node2D
var current_ice_statue: Node2D
var move_to_position_x = 0

func _ready():
	_animated_sprite.animation_finished.connect(self._on_animation_finished)
	
	$DaggerHit.set_process(false)

func _physics_process(delta):
	match current_state:
		player_state.IDLE:
			_idle_physics_process(delta)
		player_state.DAGGER:
			_dagger_physics_process(delta)
		player_state.WIND_SPELL:
			_wind_spell_physics_process(delta)
		player_state.ICE_SPELL:
			_ice_spell_physics_process(delta)
			
	move_and_slide()


func _base_movement(delta, do_gravity = true, flip_on_back = true, movement = movement_type.ANY):
	# Add the gravity.
	if do_gravity && not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("player_left", "player_right")
	if direction && (movement == movement_type.ANY || (movement == movement_type.AERIAL && not is_on_floor())):
		velocity.x = direction * SPEED
			
		if flip_on_back && ((is_facing_right && direction < 0) || (!is_facing_right && direction > 0)):
			scale.x = -1
			is_facing_right = !is_facing_right

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	return direction


func _on_animation_finished():
	print("animation ended: " + _animated_sprite.animation)
	match current_state:
		player_state.DAGGER, player_state.WIND_SPELL, player_state.ICE_SPELL:
			current_state = player_state.IDLE
	

func _idle_physics_process(delta):
	var direction = _base_movement(delta)
	if not is_on_floor() && velocity.y > 0:
		_animated_sprite.play("fall")
	elif is_on_floor() && direction:
		_animated_sprite.play("run")
	elif is_on_floor():
		_animated_sprite.play("idle")
	
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_animated_sprite.play("jump")
		
	# Handle attacks.
	elif Input.is_action_just_pressed("player_attack"):
		# Handle wind spell.
		if Input.is_action_pressed("player_up"):
			_start_wind_spell(delta)
		# Handle dagger.
		else:
			_start_dagger(delta)
		
	# Handle utilities.
	elif Input.is_action_just_pressed("player_utility"):
		# Handle ice spell.
		if Input.is_action_pressed("player_down"):
			_start_ice_spell(delta)


func _start_dagger(delta):
	_animated_sprite.play("dagger")
	$DaggerHit.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	$DaggerHit.show()
	current_state = player_state.DAGGER
	seconds_since_action_start = 0


func _dagger_physics_process(delta):
	_base_movement(delta, true, false, movement_type.AERIAL)
	
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	seconds_since_action_start += delta
	if seconds_since_action_start >= 0.1:
		$DaggerHit.hide()
		$DaggerHit.set_process_mode(Node.PROCESS_MODE_DISABLED)


func _start_wind_spell(delta):
	if is_instance_valid(current_wind_gust):
		return
	
	_animated_sprite.play("wind_spell")
	current_state = player_state.WIND_SPELL
	seconds_since_action_start = 0


func _wind_spell_physics_process(delta):
	_base_movement(delta, true, false)
	
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	seconds_since_action_start += delta
	if seconds_since_action_start >= 0.2 && not is_instance_valid(current_wind_gust):
		current_wind_gust = wind_gust.instantiate()
		owner.add_child(current_wind_gust)
		current_wind_gust.position = global_position
		current_wind_gust.position.x += 16 if is_facing_right else -16
		current_wind_gust.position.y -= 32
		current_wind_gust.get_node("FadeOutAnimatedSprite2D").flip_h = not is_facing_right
		current_wind_gust.linear_velocity = 50 * (Vector2.RIGHT if is_facing_right else Vector2.LEFT) + 10 * Vector2.UP
		seconds_since_action_start = -100


func _start_ice_spell(delta):
	_animated_sprite.play("ice_spell")
	if is_instance_valid(current_ice_statue):
		current_ice_statue.queue_free()
		
	# determine if player needs to move (is against an obstruction)
	var space_state = get_world_2d().direct_space_state
	var final_x = global_position.x + (48 if is_facing_right else -48)
	
	var bottom_raycast = PhysicsRayQueryParameters2D.create(Vector2(global_position.x, global_position.y - 16), Vector2(final_x, global_position.y - 16))
	bottom_raycast.exclude = [self, current_ice_statue]
	var bottom_result = space_state.intersect_ray(bottom_raycast)
	
	var top_raycast = PhysicsRayQueryParameters2D.create(Vector2(global_position.x, global_position.y - 48), Vector2(final_x, global_position.y - 48))
	top_raycast.exclude = [self, current_ice_statue]
	var top_result = space_state.intersect_ray(top_raycast)
	
	var closest_obstruction_x_distance = minf(abs((final_x if not bottom_result else bottom_result.position.x) - global_position.x), abs((final_x if not top_result else top_result.position.x) - global_position.x))
	print("closest obstruction distance from me: " + str(closest_obstruction_x_distance))
	var move_to_x_distance = closest_obstruction_x_distance - 48
	move_to_position_x = global_position.x + (move_to_x_distance if is_facing_right else -move_to_x_distance)
	
	current_state = player_state.ICE_SPELL
	seconds_since_action_start = 0
	

func _ice_spell_physics_process(delta):
	_base_movement(delta, true, false, movement_type.NONE)
	
	# slide toward proper position to make room for ice statue
	if (is_facing_right && global_position.x > move_to_position_x) || (not is_facing_right && global_position.x < move_to_position_x):
		velocity += global_position.direction_to(Vector2(move_to_position_x, global_position.y)) * 256
	else:
		global_position = Vector2(move_to_position_x, global_position.y)
	
	seconds_since_action_start += delta
	if seconds_since_action_start >= 0.2 && not is_instance_valid(current_ice_statue):
		current_ice_statue = ice_statue.instantiate()
		owner.add_child(current_ice_statue)
		current_ice_statue.position = global_position
		current_ice_statue.position.x += 32 if is_facing_right else -32
		current_ice_statue.get_node("AnimatedSprite2D").flip_h = not is_facing_right
		seconds_since_action_start = -100
