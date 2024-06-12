class_name Hurtbox2D
extends Area2D


@export var can_take_damage = true
@export var can_be_pushed = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if can_take_damage:
		connect("area_entered", self._on_hitbox_entered)
	if can_be_pushed:
		connect("area_entered", self._on_push_circle_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_hitbox_entered(hitbox: Hitbox2D):
	print("area entered")
	if hitbox == null:
		print("not a hitbox")
		return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox)
	else:
		print("owner does not have take_damage")


func _on_push_circle_entered(pushCircle: PushCircle2D):
	print("push circle entered")
	if pushCircle == null:
		print("not a push circle")
		return
		
	if owner.has_method("push_away_from"):
		owner.push_away_from(pushCircle.position, pushCircle.push_speed)
	else:
		print("owner does not have push_away_from")
