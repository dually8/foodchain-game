class_name GameOver
extends Control

signal on_retry_game

@onready var score_amount: Label = $VBoxContainer/ScoreContainer/FinalScoreAmount
@onready var retry_button: Button = $VBoxContainer/ButtonContainer/RetryButton
@onready var exit_button: Button = $VBoxContainer/ButtonContainer/ExitButton

func _ready() -> void:
	if GameManager.is_running_in_browser:
		# Disable the exit button
		exit_button.disabled = true
		exit_button.visible = false
	retry_button.grab_focus()
	score_amount.text = str(GameManager.score)


func _on_retry_button_pressed() -> void:
	on_retry_game.emit()
	GameManager._reset_score()
	SceneManager.change_scene("res://scenes/level_01.tscn")


func _on_exit_button_pressed() -> void:
	get_tree().quit()
