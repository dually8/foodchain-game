extends Node

var settings_menu_scene: PackedScene = preload("res://ui/menus/settings_menu.tscn")
var settings_menu: SettingsMenu = null
var game_over_scene: PackedScene = preload("res://scenes/game_over.tscn")
var game_over_menu: GameOver = null

enum Foodchain {
	Carrot,
	Skunk,
	Wolf,
	Bear,
	Human
}

enum FacingDirection {
	NORTH,
	SOUTH,
	EAST,
	WEST
}

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

func open_game_over() -> void:
	if not game_over_menu:
		game_over_menu = game_over_scene.instantiate()
		game_over_menu.on_retry_game.connect(close_game_over)
		var layers = get_tree().get_nodes_in_group("CanvasLayer") as Array[CanvasLayer]
		if layers.size() > 0:
			var first = layers[0] as CanvasLayer
			first.add_child(game_over_menu)
	else:
		push_warning("Game over menu already exists")
	get_tree().paused = true

func close_game_over() -> void:
	if game_over_menu:
		var layers = get_tree().get_nodes_in_group("CanvasLayer") as Array[CanvasLayer]
		if layers.size() > 0:
			var first = layers[0] as CanvasLayer
			first.remove_child(game_over_menu)
		game_over_menu = null
		get_tree().paused = false
