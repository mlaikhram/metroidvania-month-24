extends Node


var feature_flags: Dictionary


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._unlocked_feature.connect(_update_feature_flag)


func _update_feature_flag(flag):
	
