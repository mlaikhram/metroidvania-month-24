extends Node


@export var music_list: Array[AudioStream]

@onready var player_1: AudioStreamPlayer = $MusicPlayer1
@onready var player_2: AudioStreamPlayer = $MusicPlayer2

func _ready():
	SignalBus._switched_biome.connect(_switch_song)


func _switch_song(next_song: Constants.Biome):
	var current_pos = player_1.get_playback_position()
	player_1.set_stream(music_list[next_song])
	player_1.play(current_pos)
