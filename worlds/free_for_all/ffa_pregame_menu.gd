extends Control

signal request_scene(scene_id, args)

var player_count = 2:
	set(value):
		if value > 4:
			value = 4
		if value < 1:
			value = 1
		player_count = value
		handle_player_count_changed()
		pcount_disp.set_text('%d' % player_count)
@onready var pcount_disp = $MarginContainer/VBoxContainer/PlayerCountSettings/HBoxContainer/ColorRect/VBoxContainer/MarginContainer/HBoxContainer/PlayerCountValue
@onready var start_game_btn = $MarginContainer/VBoxContainer/StartGame
@onready var input_timer = $InputTimer
# ....
@onready var menu_cursor := $MenuCursor
@onready var menu_cursor2 := $MenuCursor2
@onready var menu_cursor3 := $MenuCursor3
@onready var menu_cursor4 := $MenuCursor4
@onready var menu_cursors = [
	menu_cursor,
	menu_cursor2,
	menu_cursor3,
	menu_cursor4
]
@onready var focus_begin = $MarginContainer/VBoxContainer/StartGame


func _ready():
	player_count = player_count
	start_game_btn.grab_focus()

	for menu_cursor in menu_cursors:
		menu_cursor.start_process = true
		menu_cursor.cursor_moved.connect(handle_cursor_moved)
		menu_cursor.navigate_request.connect(handle_navigate_request)
		menu_cursor.cursor_accept.connect(handle_cursor_accept)
		GameData.initialize_player(menu_cursor)


func end_game():
	GameData.clear_scene_state()


func get_control_at_coords(coords):
	for node: Control in get_tree().get_nodes_in_group('menu_control'):
		if node.get_global_rect().has_point(coords):
			return node
	return null


func handle_player_count_changed():
	for i in range(menu_cursors.size()):
		var cursor: TextureRect = menu_cursors[i]
		if i < player_count:
			cursor.show()
			if not cursor.get_parent():
				add_child(cursor)
				cursor.reset_position()
		else:
			cursor.hide()
			if cursor.get_parent():
				remove_child(cursor)


func handle_cursor_accept(coords):
	var node = get_control_at_coords(coords)
	if node:
		node.pressed.emit()


func handle_navigate_request():
	focus_begin.grab_focus()


func handle_cursor_moved():
	get_viewport().gui_release_focus()


func _on_subt_player_count_pressed():
	player_count -= 1


func _on_add_player_count_pressed():
	player_count += 1


func _on_start_game_pressed():
	end_game()
	request_scene.emit('FREE_FOR_ALL', player_count)


func _on_input_timer_timeout():
	$MarginContainer.process_mode = Node.PROCESS_MODE_INHERIT


func _physics_process(delta):
	InputHandler.poll_for_devices()
