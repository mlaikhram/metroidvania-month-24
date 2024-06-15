extends Node2D


@export var feature: Constants.feature_flag
@export var mana_orb: PackedScene
@export var max_mana = 10
@export var velocity: Vector2 = Vector2.ZERO
@export var degrees_of_error = 0.0
@export var x_offset = 0.0
@export var x_error = 0.0
@export var y_offset = 0.0
@export var y_error = 0.0
@export var animations: Array[AnimatedSprite2D]

@onready var mana_sprite = $Mana

var current_mana: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	if feature == Constants.feature_flag.NONE || !PlayerData.has_feature(feature):
		current_mana = max_mana
		mana_sprite.modulate = Constants.POWERED_MANA_COLOR
	else:
		for animation in animations:
			animation.play("broken")
		set_script(null)


func take_damage(hitbox):
	print("hit mana seal: " + str(hitbox.damage))
	var remaining_mana = current_mana - hitbox.damage
	var orbs_to_release = hitbox.damage if remaining_mana >= 0 else current_mana
	current_mana = max(0, remaining_mana)
	
	for n in orbs_to_release:
		var orb = mana_orb.instantiate()
		call_deferred("add_child", orb)
		orb.position = Vector2(x_offset, y_offset)
		orb.position += Vector2(randf() * 2.0 * x_error - x_error, randf() * 2.0 * y_error - y_error)
		orb.linear_velocity = velocity.rotated(rotation).rotated(deg_to_rad(randf() * 2.0 * degrees_of_error - degrees_of_error))

	if current_mana == 0:
		for animation in animations:
			animation.play("broken")
		
		if feature != Constants.feature_flag.NONE && !PlayerData.has_feature(feature):
			SignalBus.emit_signal("_unlocked_feature", feature)
			
		set_script(null)
