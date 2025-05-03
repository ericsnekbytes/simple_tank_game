extends Control

signal request_scene(scene_id, args)

var player_count = 2:
	set(value):
		if value > 4:
			value = 4
		if value < 1:
			value = 1
		player_count = value
		pcount_disp.set_text('%d' % player_count)
@onready var pcount_disp = $MarginContainer/VBoxContainer/PlayerCountSettings/HBoxContainer/ColorRect/VBoxContainer/MarginContainer/HBoxContainer/PlayerCountValue
@onready var start_game_btn = $MarginContainer/VBoxContainer/StartGame
@onready var input_timer = $InputTimer


func _ready():
	player_count = player_count
	start_game_btn.grab_focus()


func _on_subt_player_count_pressed():
	player_count -= 1


func _on_add_player_count_pressed():
	player_count += 1


func _on_start_game_pressed():
	request_scene.emit('SOCCER', player_count)


func _on_input_timer_timeout():
	$MarginContainer.process_mode = Node.PROCESS_MODE_INHERIT
