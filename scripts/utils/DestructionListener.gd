extends Node

@export var require_all_destroyed = true
@export var destructibles: Array[Node] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	for destructible in destructibles:
		# destructible.destroy.connect(_on_destructible_destroyed(destructible))
		destructible.destroyed.connect(func(): _on_destructible_destroyed(destructible))


func _on_destructible_destroyed(destructible):
	print("recieved destruction signal")
	if !require_all_destroyed:
		get_parent()._single_item_destroyed(destructible)
		
	destructibles.erase(destructible)
	
	if require_all_destroyed && destructibles.is_empty():
		get_parent()._all_items_destroyed()
