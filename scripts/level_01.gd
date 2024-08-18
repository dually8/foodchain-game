extends Node2D

var tween: Tween
@onready var music: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	tween = get_tree().create_tween()
	music.volume_db = -100
	tween.tween_property(music, "volume_db",-10.0, 1.0)
	music.play()
