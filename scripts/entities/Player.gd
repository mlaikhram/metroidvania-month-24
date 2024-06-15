class_name Player
extends CharacterBody2D

enum player_state {
	IDLE,
	DAMAGED,
	CUTSCENE,
	DAGGER,
	WIND_SPELL,
	ICE_SPELL
}

enum movement_type {
	ANY,
	AERIAL,
	NONE,
	UNCONTROLLED
}

@export var has_dagger = false
@export var has_wind_spell = false
@export var has_ice_spell = false

@export var wind_gust: PackedScene 
@export var ice_statue: PackedScene

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _interactor = $Interactor2D
@onready var _spirit = get_node_or_null("Spirit")
@onready var _dagger_hit = $DaggerHit

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_FALL_SPEED = 800.0
const COYOTE_TIME = 0.08

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var current_state = player_state.IDLE
var seconds_since_action_start = 0
var seconds_since_started_falling = 0

var current_wind_gust: Node2D
var current_ice_statue: Node2D
var move_to_position_x = 0


func _ready():
	SignalBus._unlocked_feature.connect(_unlocked_item)
	SignalBus._cutscene_ended.connect(_on_cutscene_ended)
	_animated_sprite.animation_finished.connect(self._on_animation_finished)
	
	_dagger_hit.set_process(false)
	
	SignalBus.emit_signal("_request_camera", self)

func _physics_process(delta):
	match current_state:
		player_state.IDLE:
			_idle_physics_process(delta)
		player_state.DAMAGED:
			_damaged_physics_process(delta)
		player_state.CUTSCENE:
			_cutscene_physics_process(delta)
		player_state.DAGGER:
			_dagger_physics_process(delta)
		player_state.WIND_SPELL:
			_wind_spell_physics_process(delta)
		player_state.ICE_SPELL:
			_ice_spell_physics_process(delta)
			
	move_and_slide()


func _base_movement(delta, do_gravity = true, flip_on_back = true, movement = movement_type.ANY, override_direction = 0):
	if is_on_floor():
		seconds_since_started_falling = 0
	else:
		seconds_since_started_falling += delta
	
	# Add the gravity.
	if do_gravity && not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = minf(velocity.y, MAX_FALL_SPEED)

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("player_left", "player_right") if override_direction == 0 else float(override_direction)
	if direction && (movement == movement_type.ANY || (movement == movement_type.AERIAL && not is_on_floor())):
		velocity.x = (1 if direction > 0 else -1) * SPEED
		
		if flip_on_back && ((is_facing_right() && direction < 0) || (!is_facing_right() && direction > 0)):
			scale.x = -1

	elif movement != movement_type.UNCONTROLLED:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	return direction


func _on_cutscene_ended():
	if current_state == player_state.CUTSCENE:
		SignalBus.emit_signal("_request_camera", self)
		current_state = player_state.IDLE
		_interactor.end_interaction()


func _on_animation_finished():
	match current_state:
		player_state.DAMAGED, player_state.DAGGER, player_state.WIND_SPELL, player_state.ICE_SPELL:
			current_state = player_state.IDLE
	

func _idle_physics_process(delta):
	var direction = _base_movement(delta)
	if not is_on_floor() && velocity.y > 0:
		_animated_sprite.play("fall")
	elif is_on_floor() && direction:
		_animated_sprite.play("run")
	elif is_on_floor():
		_animated_sprite.play("idle")
		
	# Handle cutscene.
	if _interactor.has_interaction() && Input.is_action_just_pressed("player_interact"):
		_start_cutscene()
	
	# Handle jump.
	elif Input.is_action_just_pressed("player_jump") and seconds_since_started_falling <= COYOTE_TIME:
		velocity.y = JUMP_VELOCITY
		_animated_sprite.play("jump")
		
	# Handle attacks.
	elif Input.is_action_just_pressed("player_attack"):
		# Handle wind spell.
		if has_wind_spell && Input.is_action_pressed("player_up"):
			_start_wind_spell()
		# Handle dagger.
		elif has_dagger:
			_start_dagger()
		
	# Handle utilities.
	elif Input.is_action_just_pressed("player_utility"):
		# Handle ice spell.
		if has_ice_spell && Input.is_action_pressed("player_down"):
			_start_ice_spell()


func _start_damaged():
	_animated_sprite.play("damaged")
	
	_dagger_hit.hide()
	_dagger_hit.set_process_mode(Node.PROCESS_MODE_DISABLED)
		
	current_state = player_state.DAMAGED
	seconds_since_action_start = 0


func _damaged_physics_process(delta):
	_base_movement(delta, true, true, movement_type.UNCONTROLLED)


func _start_cutscene():
	move_to_position_x = _interactor.prepare()
	current_state = player_state.CUTSCENE
	seconds_since_action_start = 0


func _cutscene_physics_process(delta):
	var difference_to_target_x = move_to_position_x - global_position.x
	if abs(difference_to_target_x) > 3:
		var direction = _base_movement(delta, true, true, movement_type.ANY, 1 if difference_to_target_x > 0 else -1)
		if not is_on_floor() && velocity.y > 0:
			_animated_sprite.play("fall")
		elif is_on_floor() && direction:
			_animated_sprite.play("run")
			
	else:
		_animated_sprite.play("idle")
		_base_movement(delta, true, true, movement_type.NONE)
			
		if _interactor.has_interaction() && \
			((_interactor.should_face_interaction() && \
				((global_position.x > _interactor.get_interaction_position().x && is_facing_right()) || \
				(global_position.x < _interactor.get_interaction_position().x && !is_facing_right()))) || \
			(!_interactor.should_face_interaction() && \
				((global_position.x < _interactor.get_interaction_position().x && is_facing_right()) || \
				(global_position.x > _interactor.get_interaction_position().x && !is_facing_right())))):
			scale.x = -1
			
		elif _interactor.has_interaction():
			_interactor.interact(self)
		

func _start_dagger():
	_animated_sprite.play("dagger")
	if is_instance_valid(_spirit):
		_spirit.play_dagger()
	_dagger_hit.set_process_mode(Node.PROCESS_MODE_INHERIT)
	_dagger_hit.show()
	current_state = player_state.DAGGER
	seconds_since_action_start = 0


func _dagger_physics_process(delta):
	_base_movement(delta, true, false, movement_type.AERIAL)
	
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and seconds_since_started_falling <= COYOTE_TIME:
		velocity.y = JUMP_VELOCITY
	
	seconds_since_action_start += delta
	if seconds_since_action_start >= 0.1:
		_dagger_hit.hide()
		_dagger_hit.set_process_mode(Node.PROCESS_MODE_DISABLED)


func _start_wind_spell():
	if is_instance_valid(current_wind_gust):
		return
	
	_animated_sprite.play("wind_spell")
	current_state = player_state.WIND_SPELL
	seconds_since_action_start = 0


func _wind_spell_physics_process(delta):
	var direction = _base_movement(delta, true, false)
	
	# Handle jump.
	if Input.is_action_just_pressed("player_jump") and seconds_since_started_falling <= COYOTE_TIME:
		velocity.y = JUMP_VELOCITY
	
	seconds_since_action_start += delta
	if seconds_since_action_start >= 0.2 && not is_instance_valid(current_wind_gust):
		current_wind_gust = wind_gust.instantiate()
		owner.add_child(current_wind_gust)
		current_wind_gust.position = global_position
		current_wind_gust.position.x += 16 if is_facing_right() else -16
		current_wind_gust.position.y -= 32
		current_wind_gust.get_node("FadeOutAnimatedSprite2D").flip_h = not is_facing_right()
		current_wind_gust.linear_velocity = (100 if !direction else 300) * (Vector2.RIGHT if is_facing_right() else Vector2.LEFT)
		seconds_since_action_start = -100


func _start_ice_spell():
	_animated_sprite.play("ice_spell")
		
	# determine if player needs to move (is against an obstruction)
	var space_state = get_world_2d().direct_space_state
	var final_x = global_position.x + (48 if is_facing_right() else -48)
	
	var bottom_raycast = PhysicsRayQueryParameters2D.create(Vector2(global_position.x, global_position.y - 16), Vector2(final_x, global_position.y - 16))
	bottom_raycast.exclude = [self]

	var top_raycast = PhysicsRayQueryParameters2D.create(Vector2(global_position.x, global_position.y - 48), Vector2(final_x, global_position.y - 48))
	top_raycast.exclude = [self]
	
	if is_instance_valid(current_ice_statue):
		bottom_raycast.exclude = [self, current_ice_statue]
		top_raycast.exclude = [self, current_ice_statue]
		current_ice_statue.queue_free()
		
	var bottom_result = space_state.intersect_ray(bottom_raycast)
	var top_result = space_state.intersect_ray(top_raycast)
		
	var closest_obstruction_x_distance = minf(abs((final_x if not bottom_result else bottom_result.position.x) - global_position.x), abs((final_x if not top_result else top_result.position.x) - global_position.x))
	var move_to_x_distance = closest_obstruction_x_distance - 48
	move_to_position_x = global_position.x + (move_to_x_distance if is_facing_right() else -move_to_x_distance)
	
	current_state = player_state.ICE_SPELL
	seconds_since_action_start = 0
	

func _ice_spell_physics_process(delta):
	_base_movement(delta, true, false, movement_type.NONE)
	
	# slide toward proper position to make room for ice statue
	if (is_facing_right() && global_position.x > move_to_position_x) || (not is_facing_right() && global_position.x < move_to_position_x):
		velocity += global_position.direction_to(Vector2(move_to_position_x, global_position.y)) * 256
	else:
		global_position = Vector2(move_to_position_x, global_position.y)
	
	seconds_since_action_start += delta
	if seconds_since_action_start >= 0.2 && not is_instance_valid(current_ice_statue):
		current_ice_statue = ice_statue.instantiate()
		owner.add_child(current_ice_statue)
		current_ice_statue.position = global_position
		current_ice_statue.position.x += 32 if is_facing_right() else -32
		current_ice_statue.get_node("AnimatedSprite2D").flip_h = not is_facing_right()
		seconds_since_action_start = -100


func take_damage(hitbox):
	if current_state == player_state.CUTSCENE:
		return
	#current_health -= hitbox.damage
	#if current_health <= 0:
		#queue_free()

	print("player taking damage: " + str(hitbox.damage))
	if is_instance_valid(_spirit):
		_spirit.stop()
	var direction = -1 if hitbox.global_position.x >= global_position.x else 1
	velocity = Vector2(direction * 250, -200)
	if ((is_facing_right() && direction > 0) || (!is_facing_right() && direction < 0)):
		scale.x = -1
	
	_start_damaged()
	
	
func _unlocked_item(has_item: Constants.feature_flag):
	match has_item:
		Constants.feature_flag.HAS_DAGGER:
			has_dagger = true
			PlayerData.save_game(Constants.checkpoint.DAGGER)
		Constants.feature_flag.HAS_WIND_SPELL:
			has_wind_spell = true
			PlayerData.save_game(Constants.checkpoint.WIND_SPELL)
		Constants.feature_flag.HAS_ICE_SPELL:
			has_ice_spell = true
			PlayerData.save_game(Constants.checkpoint.ICE_SPELL)


func is_facing_right():
	# godot is stupid
	return scale.y == 1
