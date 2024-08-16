extends Control
class_name MainMenu

@onready var start_button: Button = %Start

var settings_menu: SettingsMenu = null

func _ready() -> void:
	start_button.grab_focus()


func _on_start_pressed() -> void:
	#SceneManager.change_scene("/path/to/first_level")
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	Globals.open_settings_menu()
	get_tree().paused = true

func _on_exit_pressed() -> void:
	get_tree().quit()
