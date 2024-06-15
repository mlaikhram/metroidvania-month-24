extends Node2D


func _ready():
	SignalBus.emit_signal("_request_camera", self)
