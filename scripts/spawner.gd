class_name Spawner
extends Node2D

# Prey/Predator node
@export var pp_scene: PackedScene
# Maximum number of spawns (prey or predators)
@export var max_spawn: int = 3
# Default group to put spawns under
@export var spawn_group: String = "Predator"
@onready var timer: Timer = $SpawnTimer
# Used for seeing if the player's camera can see the spawner
@onready var notifier: VisibleOnScreenNotifier2D = $OnScreenNotifier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not pp_scene:
		push_warning("You need a scene to spawn!")
		return
	notifier.screen_entered.connect(_on_screen_entered)
	notifier.screen_exited.connect(_on_screen_exited)
	_init_timer()

# Connect the timeout signal to the spawner function
# and start the timer if the player cannot see the spawner
func _init_timer() -> void:
	timer.timeout.connect(_on_spawn_timer_timeout)
	get_tree().create_timer(1.0).timeout.connect(
		func ():
			if not notifier.is_on_screen():
				timer.start()
	)

# Stop the spawner if the area IS visible
func _on_screen_entered() -> void:
	timer.stop()

# Start the spawner if the area IS NOT visible
func _on_screen_exited() -> void:
	timer.start()

func _on_spawn_timer_timeout() -> void:
	# Do nothing if the spawner is visible
	if notifier.is_on_screen():
		return
	var current_spawn_count =  get_tree().get_node_count_in_group(spawn_group)
	if current_spawn_count < max_spawn:
		# We label as CharacterBody2D since both prey/predator inherit from it
		var pp: CharacterBody2D = pp_scene.instantiate()
		var offset_x: float = randf_range(-5.0, 5.0)
		var offset_y: float = randf_range(-5.0, 5.0)
		pp.position = Vector2(position.x + offset_x, position.y + offset_y)
		get_tree().root.add_child(pp)
