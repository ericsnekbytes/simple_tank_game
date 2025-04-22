extends Control

signal request_scene(scene_id, args)


# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.global_pivot = $SubViewportContainer/Level/GlobalPivot
	$MarginContainer/VBoxContainer/SinglePlayerBtn.grab_focus()


func _on_single_player_btn_pressed():
	request_scene.emit('FREE_FOR_ALL')


func _on_two_player_btn_pressed():
	request_scene.emit('FREE_FOR_ALL')


func _input(event):
	if event.is_action('ui_accept'):
		print('Mainmenu accept')
		get_viewport().gui_get_focus_owner().pressed.emit()
