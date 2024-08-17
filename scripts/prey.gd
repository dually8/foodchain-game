extends CharacterBody2D
class_name Prey

@export var is_static: bool = false

@onready var navAgent: NavigationAgent2D = %NavigationAgent2D
@onready var animation: AnimatedSprite2D = $Animation

var target: Player = null
var run_distance: int = 400
var move_speed: int = 75
var hp: int = 3

func _ready() -> void:
	add_to_group("Prey")
	# Find the player in the scene
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		target = players[0] as Player
	if target:
		print("found player!")
		_set_model()

func _set_model() -> void:
	if target:
		match target.current_model:
			Globals.Foodchain.Skunk:
				animation.play("carrot")
			Globals.Foodchain.Wolf:
				animation.play("skunk")
			Globals.Foodchain.Bear:
				animation.play("wolf")
			Globals.Foodchain.Human:
				animation.play("bear")
		if target.current_model == Globals.Foodchain.Skunk:
			# Carrots cannot move
			is_static = true
		else:
			is_static = false

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

func is_eaten() -> bool:
	if hp > 0:
		hp -= 1
		return false
	call_deferred("destroy")
	return true

func destroy() -> void:
	queue_free()
