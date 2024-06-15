class_name MinecartShortcut2D
extends RigidBody2D

@onready var block_zone = get_node_or_null("BlockZone")

func _all_items_destroyed():
	call_deferred("set_freeze_enabled", false)
	if is_instance_valid(block_zone):
		block_zone.queue_free()
	
