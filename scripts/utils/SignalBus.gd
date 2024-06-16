extends Node


signal _request_camera(node: Node2D)
signal _cutscene_ended()
signal _request_load_flashback(scene: PackedScene)
signal _request_load_main_level(flashback: Node2D)
signal _unlocked_feature(feature: Constants.feature_flag)
signal _saved_game(checkpoint: Constants.checkpoint)
signal _switched_biome()
