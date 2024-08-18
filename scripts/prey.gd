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
				is_static = true
			Globals.Foodchain.Wolf:
				animation.play("skunk")
				is_static = false
			Globals.Foodchain.Bear:
				animation.play("wolf")
				is_static = false
			Globals.Foodchain.Human:
				animation.play("carrot")
				is_static = true
		if is_static:
			# Carrots cannot move
			navAgent.avoidance_enabled = false
		else:
			navAgent.avoidance_enabled = true

func _physics_process(_delta: float) -> void:
	# Fixes the crash when reloading the level
	if not is_instance_valid(target):
		return
	if target and not is_static:
		var distance_to_player = global_position.distance_to(target.global_position)
		if distance_to_player < run_distance:
			navAgent.target_position = target.global_position * -1.0
			var direction = global_position.direction_to(
				navAgent.get_next_path_position()
			)
			var new_velocity = direction * move_speed
			if navAgent.avoidance_enabled:
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
