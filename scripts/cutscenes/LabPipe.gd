extends Node


@onready var left_wire = $LeftPipeWire
@onready var right_wire = $RightPipeWire
@onready var poison_flow = $PoisonFlow
@onready var cover_tiles = $TileMap

var is_left_cut = false
var is_right_cut = false

func _single_item_destroyed(destructible: Node2D):
	if destructible.get_parent() == left_wire:
		is_left_cut = true
	elif destructible.get_parent() == right_wire:
		is_right_cut = true
	
	if is_left_cut && is_right_cut:
		var tween = get_tree().create_tween()
		tween.tween_property(poison_flow, "modulate", Color.TRANSPARENT, 1)
		tween.tween_callback(poison_flow.queue_free)
		tween.tween_property(cover_tiles, "modulate", Color.TRANSPARENT, 2).set_delay(0.8)
		tween.tween_callback(cover_tiles.queue_free)
