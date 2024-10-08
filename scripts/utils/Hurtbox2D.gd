class_name Hurtbox2D
extends Area2D


@export var can_take_damage = true
@export var can_be_pushed = false
@export var can_be_hit_by_bodies = false


# Called when the node enters the scene tree for the first time.
func _ready():
	if can_take_damage:
		connect("area_entered", self._on_hitbox_entered)
	if can_be_pushed:
		connect("area_entered", self._on_push_circle_entered)
	if can_be_hit_by_bodies:
		connect("body_entered", self._on_body_entered)


func _on_hitbox_entered(hitbox):
	if hitbox == null || !hitbox is Hitbox2D:
		return
	
	if owner.has_method("take_damage"):
		owner.take_damage(hitbox)
	else:
		print("owner does not have take_damage")


func _on_push_circle_entered(pushCircle):
	if pushCircle == null || !pushCircle is PushCircle2D:
		return
		
	if owner.has_method("push_away_from"):
		owner.push_away_from(pushCircle.global_position, pushCircle.push_speed)
	else:
		print("owner does not have push_away_from")

func _on_body_entered(body):
	if owner.has_method("on_hit"):
		owner.on_hit(body)
