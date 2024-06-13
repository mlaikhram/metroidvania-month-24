class_name DestructibleSprite2D
extends Sprite2D

signal destroyed

@export var hitbox_tags: Array[String] = []

func take_damage(hitbox):
	print("tile taking " + hitbox.tag + " damage: " + str(hitbox.damage))
	if hitbox_tags.has(hitbox.tag):
		destroy()


func destroy():
	# TODO: particles and sound etc
	print("destroyed vine/web")
	destroyed.emit()
	queue_free()

