extends Node

signal player_adjust_hp(value: int)
signal player_adjust_hunger(value: int)
signal adjust_score(value: int)

var score: int = 0

func _ready() -> void:
	_reset_score()
	self.adjust_score.connect(_on_score_update)
	
func _reset_score() -> void:
	score = 0
	
func _on_score_update(value: int) -> void:
	score += value
	print("Score is " + str(score))

func reset_predators_and_prey() -> void:
	# Find all predators
	var preds = get_tree().get_nodes_in_group("Predator")
	for p in preds:
		if p:
			p.queue_free()
	var preys = get_tree().get_nodes_in_group("Prey")
	for p in preys:
		if p:
			p.queue_free()
