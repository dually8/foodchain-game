extends ProgressBar

@export var player: Player

func _ready():
	update()

func update():
	value = player.hp * 100 / player.hp
