extends CharacterBody2D
class_name Player

@export var move_speed: int = 250
@onready var hunger_timer: Timer = $HungerTimer
@onready var area2d: Area2D = $Area2D
@onready var sprite: AnimatedSprite2D = $Animation
@onready var collision: CollisionShape2D = $Area2D/CollisionShape2D

var attack_damage: int = 100
var hp: int = 300
var max_hp: int = 300
var hunger: int = 500
var max_hunger: int = 500
var hunger_drain: int = 50
var available_prey: Array[Prey] = []
var current_model: Globals.Foodchain = Globals.Foodchain.Skunk

func _ready() -> void:
	add_to_group("Player")
	GameManager.player_adjust_hp.connect(_on_player_take_damage)
	hunger_timer.wait_time = 1.0 # run every second
	hunger_timer.timeout.connect(_update_hunger)
	hunger_timer.start()
	area2d.body_entered.connect(_on_body_entered)
	area2d.body_exited.connect(_on_body_exited)

func _physics_process(delta: float) -> void:
	velocity = Vector2(0, 0)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2(0, 0):
		velocity = direction.normalized() * move_speed
	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Globals.open_settings_menu()
		get_tree().paused = true
	if event.is_action_pressed("attack"):
		try_attack()

func try_attack() -> void:
	if available_prey.size() > 0:
		var first_prey = available_prey[0]
		# TODO - Play chomp sound
		if first_prey.is_eaten():
			_update_hunger(true)

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
		print("You starved")
		# TODO - Show game over menu
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
