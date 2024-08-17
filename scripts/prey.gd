extends CharacterBody2D

@export var is_static: bool = false

@onready var navAgent: NavigationAgent2D = %NavigationAgent2D

var target: Player = null
var run_distance: int = 400
var move_speed: int = 75

func _ready() -> void:
	add_to_group("Prey")
	# Find the player in the scene
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		target = players[0] as Player
	if target:
		print("found player!")

func _physics_process(_delta: float) -> void:
	#if target and not is_static and not navAgent.is_navigation_finished():
		#navAgent.target_position = target.position
			#var direction = global_position.direction_to(navAgent.get_next_path_position())
			#velocity = direction * move_speed
			#move_and_slide()
	if target and not is_static:
		var distance_to_player = position.distance_to(target.position)
		if distance_to_player < run_distance:
			var direction = (target.position - position).normalized() * -1
			velocity = direction * move_speed
			move_and_slide()
