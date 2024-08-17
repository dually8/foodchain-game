extends CharacterBody2D
class_name Player

@export var move_speed: int = 250
var attack_damage: int = 100
var hp: int = 300
var hunger: int = 500
var hunger_drain: int = 50

func _ready() -> void:
	print("let's gooooo")
	add_to_group("Prey")
	GameManager.player_take_damage.connect(_on_player_take_damage)

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

func _on_player_take_damage(damage: int) -> void:
	print("taking damage!")
	if hp > 0:
		hp -= damage
		print(hp)
	if hp <= 0:
		print("ded lol")

func _hunger_damage():
	while hunger > 0:
		hunger -= hunger_drain
		print(hunger)
