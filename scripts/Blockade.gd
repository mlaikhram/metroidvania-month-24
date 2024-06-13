extends Node

@export var max_health = 10

var current_health = max_health


# Called when the node enters the scene tree for the first time.
func _ready():
	current_health = max_health
	print("ice statue health: " + str(current_health))


func take_damage(hitbox):
	current_health -= hitbox.damage
	if current_health <= 0:
		queue_free()
