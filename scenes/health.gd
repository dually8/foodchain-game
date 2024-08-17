extends ProgressBar

@export var player: Player

func _ready():
	GameManager.player_take_damage.connect(update)
	update()

func update():
	value = player.hp * 100 / player.hp
