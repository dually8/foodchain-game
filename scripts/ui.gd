extends Control
class_name UI

@onready var health_meter: ProgressBar = $VBoxContainer/Health
@onready var hunger_meter: ProgressBar = $VBoxContainer/Hunger
@onready var score_amount: Label = $VBoxContainer/ScoreAmount

var player: Player

func _ready():
	GameManager.player_adjust_hp.connect(update_hp)
	GameManager.player_adjust_hunger.connect(update_hunger)
	GameManager.adjust_score.connect(update_score)
	update_hp(0)
	update_hunger(0)
	update_score(0)

func check_player() -> bool:
	if not player:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player = players[0]
		else:
			# TODO - Maybe retry?
			return false
	return true

func update_hunger(value: int) -> void:
	if not check_player():
		return
	if player.hunger > 0:
		var new_val = 100.0 / float(player.max_hunger) * float(player.hunger)
		hunger_meter.value = new_val
	elif player.hunger <= 0:
		hunger_meter.value = 0.0

func update_hp(_damage: int) -> void:
	if not check_player():
		return
	if player.hp > 0:
		var new_val = 100.0 / float(player.max_hp) * float(player.hp)
		health_meter.value = new_val
	elif player.hp <= 0:
		health_meter.value = 0.0

func update_score(_value: int) -> void:
	score_amount.text = str(GameManager.score)
