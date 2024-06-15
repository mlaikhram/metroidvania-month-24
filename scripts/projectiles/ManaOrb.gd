extends RigidBody2D


@export var amount = 1

@onready var area = $Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.1).timeout
	set_collision_mask_value(1, true)
	area.connect("body_entered", self._on_body_entered)


func _on_body_entered(player):
	if player != null && !player is Player:
		return
	
	player.increase_mana(amount)
	queue_free()
