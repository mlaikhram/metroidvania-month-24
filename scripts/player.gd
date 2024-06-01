extends CharacterBody2D

@onready var _animated_sprite = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_facing_right = true

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("player_left", "player_right")
	if direction:
		velocity.x = direction * SPEED
		if is_on_floor():
			_animated_sprite.play("run")
			
		if (is_facing_right && direction < 0) || (!is_facing_right && direction > 0):
			scale.x = -1
			is_facing_right = !is_facing_right
		# _animated_sprite.flip_h = direction < 0
		# if abs(direction) >= 0.001:
			# scale.x *= sign(direction)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			_animated_sprite.play("idle")

	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_animated_sprite.play("jump")
		
	# Handle dagger.
	elif Input.is_action_just_pressed("player_attack"):
		_animated_sprite.play("dagger")

	move_and_slide()
