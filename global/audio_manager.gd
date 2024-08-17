extends Node

var _sfx_stream: AudioStreamPlayer
var _music_stream: AudioStreamPlayer
var _chomp_sound: AudioStreamOggVorbis

func _ready() -> void:
	# Initialize sounds
	_chomp_sound = preload("res://assets/sound/chomp.ogg")
	# Initialize audio streams
	_sfx_stream = AudioStreamPlayer.new()
	_sfx_stream.bus = "SFX"
	_music_stream = AudioStreamPlayer.new()
	_music_stream.bus = "Music"
	add_child(_sfx_stream)
	add_child(_music_stream)

func play_chomp() -> void:
	if not _sfx_stream.playing:
		_sfx_stream.stream = _chomp_sound
		_sfx_stream.play()
