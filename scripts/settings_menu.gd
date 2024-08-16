extends CanvasLayer
class_name SettingsMenu

signal settings_menu_closed

@onready var master_bus_id = AudioServer.get_bus_index("Master")
@onready var music_bus_id = AudioServer.get_bus_index("Music")
@onready var sfx_bus_id = AudioServer.get_bus_index("SFX")
@onready var user_settings: UserSettings = null

var available_resolutions: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1920, 1080),
]

func _ready() -> void:
	user_settings = UserSettings.load_or_create()
	_load_settings()

func _load_settings() -> void:
	if not user_settings:
		return
	%MasterVolumeSlider.value = user_settings.master_volume
	%MusicVolumeSlider.value = user_settings.music_volume
	%SFXVolumeSlider.value = user_settings.sfx_volume
	%FullscreenCheckbox.button_pressed = user_settings.fullscreen
	%ResolutionDropdown.selected = available_resolutions.find(user_settings.resolution)

func _set_volume(index: int, value: float) -> void:
	AudioServer.set_bus_volume_db(index, linear_to_db(value))
	AudioServer.set_bus_mute(index, value < 0.05)

func _on_master_volume_slider_value_changed(value: float) -> void:
	#AudioManager
	# TODO: Manage this through audio server?
	_set_volume(master_bus_id, value)

func _on_music_volume_slider_value_changed(value: float) -> void:
	_set_volume(music_bus_id, value)


func _on_sfx_volume_slider_value_changed(value: float) -> void:
	_set_volume(sfx_bus_id, value)

func _on_fullscreen_checkbox_toggled(toggled_on: bool) -> void:
	if toggled_on:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED


func _on_resolution_dropdown_item_selected(index: int) -> void:
	var resolution = available_resolutions[index]
	if not resolution:
		push_error("Error selecting resolution")
		return
	get_window().size = resolution


func _on_close_button_pressed() -> void:
	_close_menu()

func _on_save_button_pressed() -> void:
	user_settings.master_volume = %MasterVolumeSlider.value
	user_settings.music_volume = %MusicVolumeSlider.value
	user_settings.sfx_volume = %SFXVolumeSlider.value
	user_settings.fullscreen = %FullscreenCheckbox.button_pressed
	user_settings.resolution = available_resolutions[%ResolutionDropdown.selected]
	user_settings.save()
	_close_menu()

func _close_menu() -> void:
	if get_tree().paused:
		get_tree().paused = false
	settings_menu_closed.emit()
