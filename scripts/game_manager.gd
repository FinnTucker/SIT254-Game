extends Node

signal start_game

var score = 0
@onready var score_label: Label = $ScoreLabel
@onready var HUD: CanvasLayer = $"."
@onready var progress_bar: ProgressBar = $ProgressBar

func new_game():
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	
func game_over():
	$HUD.show_game_over()

func add_point():
	score += 1
	print(score)
	score_label.text = "You collected " + str(score) + " coins." 

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.text = "Dodge the Creeps!"
	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()

func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()
