extends CharacterBody2D
class_name Prey

@export var is_static: bool = false

@onready var navAgent: NavigationAgent2D = %NavigationAgent2D
@onready var animation: AnimatedSprite2D = $Animation

var target: Player = null
var run_distance: int = 400
var move_speed: int = 75
var hp: int = 2

func _ready() -> void:
	add_to_group("Prey")
	# Find the player in the scene
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		target = players[0] as Player
	if target:
		print("found player!")
		_set_model()
	call_deferred("_nav_setup")

func _nav_setup() -> void:
	await get_tree().physics_frame

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
	if target and not is_static:
		var distance_to_player = global_position.distance_to(target.global_position)
		if distance_to_player < run_distance:
			navAgent.target_position = target.global_position * -1.0
			var direction = global_position.direction_to(
				navAgent.get_next_path_position()
			)
			var new_velocity = direction * move_speed
			navAgent.set_velocity(new_velocity)
	move_and_slide()

func is_eaten() -> bool:
	if hp > 0:
		hp -= 1
		return false
	call_deferred("destroy")
	return true

func destroy() -> void:
	queue_free()

func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
