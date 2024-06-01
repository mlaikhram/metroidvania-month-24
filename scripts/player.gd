extends CharacterBody2D

enum player_state {
	IDLE,
	DAGGER
}

enum movement_type {
	ANY,
	AERIAL,
	NONE
}

@onready var _animated_sprite = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_facing_right = true
var current_state = player_state.IDLE
var seconds_since_action_start = 0

func _ready():
	_animated_sprite.animation_finished.connect(self._on_animation_finished)
	
	$DaggerHit.set_process(false)

func _physics_process(delta):
	match current_state:
		player_state.IDLE:
			_idle_physics_process(delta)
		player_state.DAGGER:
			_dagger_physics_process(delta)
			
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
		player_state.DAGGER:
			current_state = player_state.IDLE
	

func _idle_physics_process(delta):
	var direction = _base_movement(delta)
	if is_on_floor() && direction:
		_animated_sprite.play("run")
	elif is_on_floor():
		_animated_sprite.play("idle")
	
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_animated_sprite.play("jump")
		
	# Handle dagger.
	elif Input.is_action_just_pressed("player_attack"):
		_animated_sprite.play("dagger")
		$DaggerHit.set_process_mode(Node.PROCESS_MODE_ALWAYS)
		$DaggerHit.show()
		current_state = player_state.DAGGER
		seconds_since_action_start = 0


func _dagger_physics_process(delta):
	var direction = _base_movement(delta, true, false, movement_type.AERIAL)
	
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	seconds_since_action_start += delta
	if seconds_since_action_start > 0.1:
		$DaggerHit.hide()
		$DaggerHit.set_process_mode(Node.PROCESS_MODE_DISABLED)
	
