class_name Hurtbox2D
extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", self._on_area_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_entered(hitbox: Hitbox2D):
	print("area entered")
	if hitbox == null:
		print("not a hitbox")
		return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox.damage)
	else:
		print("owner does not have take_damage")
