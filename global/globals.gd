extends Node

var settings_menu_scene: PackedScene = preload("res://ui/menus/settings_menu.tscn")
var settings_menu: SettingsMenu = null

func open_settings_menu():
	if not settings_menu:
		settings_menu = settings_menu_scene.instantiate()
		settings_menu.settings_menu_closed.connect(close_settings_menu)
		get_tree().root.add_child(settings_menu)
	else:
		push_warning("Settings menu already exists in the scene")

func close_settings_menu():
	if settings_menu:
		get_tree().root.remove_child(settings_menu)
		settings_menu = null
