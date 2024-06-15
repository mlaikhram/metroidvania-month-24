extends Node

signal _start_saving
signal _finish_saving


var feature_flags: Dictionary = {}
var last_checkpoint: Constants.checkpoint = Constants.checkpoint.NONE

var strength_shards: Dictionary = {}
var health_shards: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus._unlocked_feature.connect(_update_feature_flag)


func has_feature(flag: Constants.feature_flag):
	return feature_flags.has(flag)


func _update_feature_flag(flag: Constants.feature_flag):
	feature_flags[flag] = true
	

func save_game(checkpoint: Constants.checkpoint):
	last_checkpoint = checkpoint
	var tween = get_tree().create_tween()
	tween.tween_callback(emit_signal.bind("_start_saving"))
	tween.tween_callback(_write_to_file)
	tween.tween_callback(emit_signal.bind("_finish_saving"))


func _write_to_file():
	pass
