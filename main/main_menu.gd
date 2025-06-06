extends Control

signal request_scene(scene_id, args)

@onready var menu_cursor := $MenuCursor
@onready var focus_begin = $MarginContainer/VBoxContainer/CampaignBtn


# Called when the node enters the scene tree for the first time.
func _ready():
	GameData.global_pivot = $SubViewportContainer/Level/GlobalPivot
	focus_begin.grab_focus()

	menu_cursor.start_process = true
	menu_cursor.global_position = get_viewport_rect().size / 4.0
	menu_cursor.cursor_moved.connect(handle_cursor_moved)
	menu_cursor.navigate_request.connect(handle_navigate_request)
	menu_cursor.cursor_accept.connect(handle_cursor_accept)
	InputHandler.add_player(menu_cursor.player_id)


func end_game():
	GameData.clear_scene_state()


func get_control_at_coords(coords):
	for node: Control in get_tree().get_nodes_in_group('menu_control'):
		if node.get_global_rect().has_point(coords):
			return node
	return null


func handle_cursor_accept(cursor_node, coords):
	var node = get_control_at_coords(coords)
	if node:
		node.pressed.emit()


func handle_navigate_request():
	focus_begin.grab_focus()


func handle_cursor_moved():
	get_viewport().gui_release_focus()


func _on_free_for_all_btn_pressed():
	end_game()
	request_scene.emit('FREE_FOR_ALL_PREGAME', null)


#func _input(event):
	#if event.is_action('ui_accept'):
		#print('Mainmenu accept')
		#get_viewport().gui_get_focus_owner().pressed.emit()


func _on_exit_btn_pressed() -> void:
	get_tree().quit()


func _on_soccer_btn_pressed() -> void:
	end_game()
	request_scene.emit('SOCCER_PREGAME', null)


func _physics_process(delta):
	InputHandler.poll_for_devices()


func _on_campaign_btn_pressed():
	end_game()
	request_scene.emit('CAMPAIGN', null)
