class_name FadeOutAnimatedSprite2D
extends AnimatedSprite2D


@export var time_to_fade_out = 10

var time_left = time_to_fade_out
var starting_a = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	time_left = time_to_fade_out
	starting_a = self_modulate.a


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print("time left: " + str(time_left))
	if time_left <= 0:
		print("faded out")
		owner.queue_free()
	else:
		time_left -= delta
		var new_a = (time_left / time_to_fade_out) * starting_a
		self_modulate.a = maxf(new_a, 0)
	
