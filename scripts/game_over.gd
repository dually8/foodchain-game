class_name GameOver
extends Control

signal on_retry_game

@onready var score_amount: Label = $VBoxContainer/ScoreContainer/FinalScoreAmount
@onready var retry_button: Button = $VBoxContainer/ButtonContainer/RetryButton

func _ready() -> void:
	retry_button.grab_focus()
	score_amount.text = str(GameManager.score)


func _on_retry_button_pressed() -> void:
	on_retry_game.emit()
	SceneManager.change_scene("res://scenes/level_01.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
