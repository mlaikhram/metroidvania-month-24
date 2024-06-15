extends Sprite2D


@export var item_feature: Constants.feature_flag


# Called when the node enters the scene tree for the first time.
func _ready():
	if PlayerData.has_feature(item_feature):
		modulate = "0000003c"
	else:
		SignalBus._unlocked_feature.connect(_check_for_fade_out)


func _check_for_fade_out(feature):
	if feature == item_feature:
		modulate = "0000003c"
		SignalBus._unlocked_feature.disconnect(_check_for_fade_out)
