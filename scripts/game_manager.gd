extends Node

signal player_adjust_hp(value: int)
signal player_adjust_hunger(value: int)

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
