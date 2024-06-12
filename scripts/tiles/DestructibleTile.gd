extends CanvasItem

@export var hitbox_tags: Array[String] = []

func take_damage(hitbox):
	print("tile taking " + hitbox.tag + " damage: " + str(hitbox.damage))
	if hitbox_tags.has(hitbox.tag):
		queue_free()

func _exit_tree():
	print("destroyed vine/web on screen? " + str(is_visible_in_tree()))
