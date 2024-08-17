extends CharacterBody2D

var target: Player = null
var attack_distance: int = 20
var chase_distance: int = 400
var move_speed: int = 100
var attack_rate: float = 1.0
var attack_damage: int = 100
var ready_to_chase: bool = false
var is_paused: bool = false

@onready var timer: Timer = %Timer
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var navAgent: NavigationAgent2D = %NavigationAgent2D
@onready var animation: AnimatedSprite2D = $Animation

func _ready() -> void:
	add_to_group("Predator")
	timer.timeout.connect(_on_timer_timeout)
	timer.wait_time = attack_rate
	timer.start()
	attack_cooldown.timeout.connect(_on_cooldown)
	attack_cooldown.wait_time = attack_rate
	
	# Find the player in the scene
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		target = players[0] as Player
	call_deferred("_nav_setup")
	set_model()

func _nav_setup() -> void:
	await get_tree().physics_frame
	ready_to_chase = true

func _physics_process(_delta: float) -> void:
	if target and ready_to_chase and not is_paused:
		navAgent.target_position = target.position
		var direction = global_position.direction_to(navAgent.get_next_path_position())
		velocity = direction * move_speed
		move_and_slide()
	#if target:
		#var distance_to_player = position.distance_to(target.position)
		#if distance_to_player > attack_distance and distance_to_player < chase_distance:
			#var direction = (target.position - position).normalized()
			#velocity = direction * move_speed
			#move_and_slide()

func _on_timer_timeout() -> void:
	if target and not is_paused:
		var distance_to_player = position.distance_to(target.position)
		if distance_to_player <= attack_distance:
			GameManager.player_adjust_hp.emit(target.hp - attack_damage)
			is_paused = true
			attack_cooldown.start()

func _on_cooldown() -> void:
	is_paused = false

func set_model() -> void:
	if not target:
		return
	match target.current_model:
		Globals.Foodchain.Skunk:
			animation.play("wolf")
		Globals.Foodchain.Wolf:
			animation.play("bear")
		Globals.Foodchain.Bear:
			animation.play("human_idle_down")
		Globals.Foodchain.Human:
			animation.play("bear")


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
