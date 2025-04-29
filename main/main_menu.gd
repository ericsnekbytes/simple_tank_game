extends Control

signal request_scene(scene_id, args)


# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.global_pivot = $SubViewportContainer/Level/GlobalPivot
	$MarginContainer/VBoxContainer/SinglePlayerBtn.grab_focus()
	
	for player in [$SubViewportContainer/Level/Node3D/Player1, $SubViewportContainer/Level/Node3D/Player2, $SubViewportContainer/Level/Node3D/Player3, $SubViewportContainer/Level/Node3D/Player4]:
		player.hide_gui()


func _on_single_player_btn_pressed():
	request_scene.emit('FREE_FOR_ALL', 1)


func _on_two_player_btn_pressed():
	request_scene.emit('FREE_FOR_ALL', 2)


func _on_three_player_btn_pressed() -> void:
	request_scene.emit('FREE_FOR_ALL', 3)


func _input(event):
	if event.is_action('ui_accept'):
		print('Mainmenu accept')
		get_viewport().gui_get_focus_owner().pressed.emit()


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_soccer_btn_pressed() -> void:
	request_scene.emit('SOCCER', 2)
