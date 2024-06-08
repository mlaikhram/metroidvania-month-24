extends Node

@onready var _animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	_animated_sprite.animation_finished.connect(self._on_animation_finished)


func _on_animation_finished():
	_animated_sprite.hide()
	_animated_sprite.set_process_mode(Node.PROCESS_MODE_DISABLED)


func play_dagger():
	_animated_sprite.set_process_mode(Node.PROCESS_MODE_ALWAYS)
	_animated_sprite.show()
	_animated_sprite.play("dagger")

