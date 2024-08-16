extends CharacterBody2D
class_name Player

@export var move_speed: int = 250

func _ready() -> void:
	print("let's gooooo")
	add_to_group("Player")

func _physics_process(delta: float) -> void:
	velocity = Vector2(0, 0)
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction != Vector2(0, 0):
		velocity = direction.normalized() * move_speed
	move_and_slide()
