extends CharacterBody2D

var target: Player = null
var attack_distance: int = 20
var chase_distance: int = 400
var move_speed: int = 100
var attack_rate: float = 1.0
var attack_damage: int = 1

@onready var timer: Timer = %Timer

func _ready() -> void:
	add_to_group("Predator")
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = attack_rate
	timer.start()
	# Find the player in the scene
	var players = get_tree().get_nodes_in_group("Prey")
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

func _on_timer_timeout() -> void:
	if target:
		var distance_to_player = position.distance_to(target.position)
		print("Distance to player: " + str(distance_to_player))
		if distance_to_player <= attack_distance:
			print("attack the player!")
			GameManager.player_take_damage.emit(attack_damage)
