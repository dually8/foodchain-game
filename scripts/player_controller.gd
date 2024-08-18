extends CharacterBody2D
class_name Player

@export var move_speed: int = 250
@export var current_model: Globals.Foodchain
@export var _camera: Camera2D
@onready var hunger_timer: Timer = $HungerTimer
@onready var area2d: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $Animation
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D
@onready var footsteps: AudioStreamPlayer = $Footsteps

var attack_damage: int = 100
var hp: int = 300
var max_hp: int = 300
var hunger: int = 500
var max_hunger: int = 500
var hunger_drain: int = 50
var available_prey: Array[Prey] = []
const footstep_interval: float = 0.5
var footstep_timer: float = 0.0

func _ready() -> void:
	add_to_group("Player")
	GameManager.player_adjust_hp.connect(_on_player_take_damage)
	hunger_timer.wait_time = 1.0 # run every second
	hunger_timer.timeout.connect(_update_hunger)
	hunger_timer.start()
	area2d.body_entered.connect(_on_body_entered)
	area2d.body_exited.connect(_on_body_exited)
	set_model(current_model)
	if not _camera:
		push_error("NEED TO ATTACH A CAMERA TO THE PLAYER!!!")
	else:
		_camera.enabled = true
		_camera.make_current()

func _process(_delta: float) -> void:
	_camera.position = position

func _physics_process(delta: float) -> void:
	velocity = Vector2(0, 0)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	footstep_timer -= delta
	if direction != Vector2(0, 0):
		velocity = direction.normalized() * move_speed
		_play_footsteps()
	handle_animation()
	move_and_slide()

func _play_footsteps() -> void:
	if footstep_timer <= 0.0:
		footsteps.play()
		footstep_timer = footstep_interval

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Globals.open_settings_menu()
		get_tree().paused = true
	if event.is_action_pressed("attack"):
		try_attack()

func try_attack() -> void:
	if available_prey.size() > 0:
		var first_prey = available_prey[0]
		AudioManager.play_chomp()
		if first_prey.is_eaten():
			_update_hunger(true)
			GameManager.adjust_score.emit(10)

func _on_player_take_damage(new_hp: int) -> void:
	if hp > 0:
		hp = new_hp
		print(hp)
	if hp <= 0:
		print("ded lol")
		# TODO - Swap to new predator and update HP/Hunger
		switch_to_next_predator()
		reset_stats()

func reset_stats() -> void:
	hp = max_hp
	hunger = max_hunger
	GameManager.player_adjust_hunger.emit(hunger)
	GameManager.player_adjust_hp.emit(max_hp)

func _update_hunger(did_eat: bool = false) -> void:
	if did_eat:
		hunger = max_hunger
	if hunger > 0:
		hunger -= hunger_drain
	else:
		# TODO - Show game over menu
		return
	GameManager.player_adjust_hunger.emit(hunger)

func _on_body_entered(body: Node2D) -> void:
	if body is Prey and not has_prey(body):
		available_prey.append(body as Prey)

func _on_body_exited(body: Node2D) -> void:
	if body is Prey and has_prey(body):
		available_prey.remove_at(available_prey.find(body))

func has_prey(prey: Prey) -> bool:
	return available_prey.find(prey) > -1

func switch_to_next_predator() -> void:
	match current_model:
		Globals.Foodchain.Carrot:
			set_model(Globals.Foodchain.Skunk)
		Globals.Foodchain.Skunk:
			set_model(Globals.Foodchain.Wolf)
		Globals.Foodchain.Wolf:
			set_model(Globals.Foodchain.Bear)
		Globals.Foodchain.Bear:
			set_model(Globals.Foodchain.Human)
		Globals.Foodchain.Human:
			# TODO - End game
			print("You're finally dead!")
	# TODO - Remove all predators and prey
	GameManager.reset_predators_and_prey()
	# Let spawners spawn new ones

func set_model(model: Globals.Foodchain) -> void:
	current_model = model
	match model:
		Globals.Foodchain.Skunk:
			# Set animation to skunk
			set_animation("skunk")
		Globals.Foodchain.Wolf:
			# Set animation to wolf
			set_animation("wolf")
		Globals.Foodchain.Bear:
			# Set animation to bear
			set_animation("bear")
		Globals.Foodchain.Human:
			# Set animation to human
			set_animation("human_idle_down")
	set_area_radius()
	set_collision()

func set_animation(animation_name: String) -> void:
	sprite.play(animation_name)

func handle_animation() -> void:
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

	if current_model == Globals.Foodchain.Human:
		if velocity.x > 0 or velocity.x < 0:
			set_animation("human_run_side")
		if velocity.y > 0:
			set_animation("human_run_down")
		if velocity.y < 0:
			set_animation("human_run_up")

func set_area_radius() -> void:
	match current_model:
		Globals.Foodchain.Bear:
			var shape = collision.shape as CircleShape2D
			shape.radius = 21
		_:
			var shape = collision.shape as CircleShape2D
			shape.radius = 14

func set_collision() -> void:
	match current_model:
		Globals.Foodchain.Bear:
			$SmallCollision.disabled = true
			$BearCollision.disabled = false
			$HumanCollision.disabled = true
		Globals.Foodchain.Human:
			$SmallCollision.disabled = true
			$BearCollision.disabled = true
			$HumanCollision.disabled = false
		_:
			$SmallCollision.disabled = false
			$BearCollision.disabled = true
			$HumanCollision.disabled = true
