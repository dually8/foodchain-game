extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var target: Player = null
var attack_distance: int = 80
var chase_distance: int = 400
var move_speed: int = 150

func _ready() -> void:
	# Find the player in the scene
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		target = players[0] as Player
	if target:
		print("found player!")

func _physics_process(_delta: float) -> void:
	if target:
		var distance_to_player = position.distance_to(target.position)

		if distance_to_player > attack_distance and distance_to_player < chase_distance:
			var direction = (target.position - position).normalized()
			velocity = direction * move_speed
			move_and_slide()
