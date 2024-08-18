extends CharacterBody2D

var target: Player = null
var attack_distance: int = 20
var chase_distance: int = 400
var move_speed: int = 100
var attack_rate: float = 1.0
var attack_damage: int = 100
var ready_to_chase: bool = false
const footstep_interval: float = 0.5
var footstep_timer: float = 0.0
var is_in_range: bool = false
var can_attack: bool = true

@onready var attackTimer: Timer = $AttackTimer
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var navAgent: NavigationAgent2D = %NavigationAgent2D
@onready var animation: AnimatedSprite2D = $Animation
@onready var footsteps: AudioStreamPlayer2D = $Footsteps
@onready var attackRange: Area2D = $AttackRange

func _ready() -> void:
	add_to_group("Predator")
	attackTimer.timeout.connect(_on_attack_timer_timeout)
	attackTimer.wait_time = attack_rate
	attackTimer.start()
	attack_cooldown.timeout.connect(_on_attack_cooldown)
	attack_cooldown.wait_time = attack_rate
	# Make this one shot so that it does not continually loop
	# and we can restart it on demand
	attack_cooldown.one_shot = true

	# Find the player in the scene
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		target = players[0] as Player
	call_deferred("_nav_setup")
	set_model()

func _nav_setup() -> void:
	await get_tree().physics_frame
	ready_to_chase = true

func _play_footsteps() -> void:
	if footstep_timer <= 0.0:
		footsteps.play()
		footstep_timer = footstep_interval

func _physics_process(delta: float) -> void:
	# Fixes the crash when reloading the level
	if not is_instance_valid(target):
		return
	footstep_timer -= delta
	if target and ready_to_chase:
		navAgent.target_position = target.position
		var direction = global_position.direction_to(navAgent.get_next_path_position())
		if direction != Vector2.ZERO:
			_play_footsteps()
		navAgent.set_velocity(direction * move_speed)
		move_and_slide()

func _on_attack_timer_timeout() -> void:
	# Fixes the crash when reloading the level
	if not is_instance_valid(target):
		return
	if target and can_attack and is_in_range:
		GameManager.player_adjust_hp.emit(target.hp - attack_damage)
		can_attack = false
		attack_cooldown.start()

func _on_attack_cooldown() -> void:
	can_attack = true

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
			var anim = get_random_animation()
			animation.play(anim)
	set_attack_range()

func set_attack_range() -> void:
	# 30px if bear, 20px for everything else
	var collision = attackRange.get_child(0) as CollisionShape2D
	var shape = collision.shape as CircleShape2D
	if animation.animation == "bear":
		shape.radius = 30.0
	else:
		shape.radius = 20.0


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func get_random_animation() -> String:
	var rand_anim: Array[String] = ["bear", "wolf", "skunk"]
	randomize()
	var index = randi() % rand_anim.size()
	return rand_anim[index]


func _on_attack_range_body_entered(body: Node2D) -> void:
	if body is Player:
		is_in_range = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	if body is Player:
		is_in_range = false
