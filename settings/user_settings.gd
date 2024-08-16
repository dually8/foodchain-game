extends Resource
class_name UserSettings

@export_range(0,1,.05) var master_volume: float = 1.0
@export_range(0,1,.05) var music_volume: float = 1.0
@export_range(0,1,.05) var sfx_volume: float = 1.0
@export var fullscreen: bool = false
@export var resolution: Vector2i = Vector2i(1280, 720)

const SAVE_PATH: String = "user://settings.cfg"

func save() -> void:
	var config = ConfigFile.new()
	config.set_value("display", "fullscreen", self.fullscreen)
	config.set_value("display", "resolution", self.resolution)
	config.set_value("audio", "master_volume", self.master_volume)
	config.set_value("audio", "music_volume", self.music_volume)
	config.set_value("audio", "sfx_volume", self.sfx_volume)
	config.save(SAVE_PATH)

static func load_or_create() -> UserSettings:
	var user_settings: UserSettings = UserSettings.new()
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) == OK:
		print("Got user settings")
		user_settings.fullscreen = config.get_value("display", "fullscreen", false)
		user_settings.resolution = config.get_value("display", "resolution", Vector2i(1280, 720))
		user_settings.master_volume = config.get_value("audio", "master_volume", 1.0)
		user_settings.music_volume = config.get_value("audio", "music_volume", 1.0)
		user_settings.sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
	return user_settings
