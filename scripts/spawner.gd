class_name Spawner
extends Node2D

@export var pp_scene: PackedScene
@export var max_spawn: int = 3
@export var spawn_group: String = "Predator"
var spawn_nodes: Array[Node2D] = []
@onready var timer: Timer = $SpawnTimer
@onready var notifier: VisibleOnScreenNotifier2D = $OnScreenNotifier

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not pp_scene:
		push_warning("You need a scene to spawn!")
		return
	notifier.screen_entered.connect(_on_screen_entered)
	notifier.screen_exited.connect(_on_screen_exited)
	_init_timer()

func _init_timer() -> void:
	timer.timeout.connect(_on_spawn_timer_timeout)
	get_tree().create_timer(1.0).timeout.connect(_start_timer)
	
func _start_timer() -> void:
	# Don't start the timer if this node is visible
	if notifier.is_on_screen():
		return
	timer.start()

func _on_screen_entered() -> void:
	_start_timer()

func _on_screen_exited() -> void:
	timer.stop()

func _on_spawn_timer_timeout() -> void:
	if not notifier.is_on_screen():
		return
	var current_spawn_count =  get_tree().get_node_count_in_group(spawn_group)
	if current_spawn_count < max_spawn:
		var pp: CharacterBody2D = pp_scene.instantiate()
		pp.position = position
		get_tree().root.add_child(pp)
