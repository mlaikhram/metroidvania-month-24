class_name RequestableCamera2D
extends Camera2D


var target_object: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._request_camera.connect(_follow_target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(target_object):
		global_position = target_object.global_position


func _follow_target(target: Node2D):
	print("received camera request: " + str(target))
	target_object = target
