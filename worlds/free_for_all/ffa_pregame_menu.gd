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
@onready var pcount_disp = $MarginContainer2/Splitter/GamemodeSettings/HBoxContainer/GameModeSettings/PlayerCountSettings/HBoxContainer/ColorRect/VBoxContainer/MarginContainer/HBoxContainer/PlayerCountValue
@onready var start_game_btn = $MarginContainer2/Splitter/GamemodeSettings/HBoxContainer/GameModeSettings/StartGame
@onready var input_timer = $InputTimer
# ....
@onready var svp_cont1 = $MarginContainer2/Splitter/SplitScreenContainer/TopRow/P1Cont
@onready var loadout1 = $MarginContainer2/Splitter/SplitScreenContainer/TopRow/P1Cont/Container/LoadoutPicker1
@onready var svp_cont2 = $MarginContainer2/Splitter/SplitScreenContainer/TopRow/P2Cont
@onready var loadout2 = $MarginContainer2/Splitter/SplitScreenContainer/TopRow/P2Cont/Container/LoadoutPicker2
@onready var svp_cont3 = $MarginContainer2/Splitter/SplitScreenContainer/BottomRow/P3Cont
@onready var loadout3 = $MarginContainer2/Splitter/SplitScreenContainer/BottomRow/P3Cont/Container/LoadoutPicker3
@onready var svp_cont4 = $MarginContainer2/Splitter/SplitScreenContainer/BottomRow/P4Cont
@onready var loadout4 = $MarginContainer2/Splitter/SplitScreenContainer/BottomRow/P4Cont/Container/LoadoutPicker4
@onready var left_pad = $MarginContainer2/Splitter/SplitScreenContainer/BottomRow/LeftPad
@onready var right_pad = $MarginContainer2/Splitter/SplitScreenContainer/BottomRow/RightPad
@onready var svp_containers = [
	svp_cont1,
	svp_cont2,
	svp_cont3,
	svp_cont4,
]
@onready var bottom_row = $MarginContainer2/Splitter/SplitScreenContainer/BottomRow
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
@onready var focus_begin = $MarginContainer2/Splitter/GamemodeSettings/HBoxContainer/GameModeSettings/StartGame


func _ready():
	player_count = player_count
	start_game_btn.grab_focus()

	for cursor in menu_cursors:
		cursor.start_process = true
		cursor.cursor_moved.connect(handle_cursor_moved)
		cursor.navigate_request.connect(handle_navigate_request)
		cursor.cursor_accept.connect(handle_cursor_accept)
		cursor.cursor_reject.connect(handle_cursor_reject)
		GameData.initialize_player(cursor)
	loadout1.owning_player = menu_cursor
	loadout2.owning_player = menu_cursor2
	loadout3.owning_player = menu_cursor3
	loadout4.owning_player = menu_cursor4
	


func end_game():
	process_mode = Node.PROCESS_MODE_DISABLED
	GameData.clear_scene_state()


func get_control_at_coords(coords):
	for node: Control in get_tree().get_nodes_in_group('menu_control'):
		if node.get_global_rect().has_point(coords):
			if not node.is_visible_in_tree():
				continue
			return node
	return null


func prepare_split_screen():
	#var player_ids = []
	#for player in players:
		#player_ids.append(player.player_id)

	# Prep each player svport
	for i in range(svp_containers.size()):
		var player_svport: MarginContainer = svp_containers[i]
		if i < player_count:
			player_svport.process_mode = Node.PROCESS_MODE_INHERIT
			player_svport.show()
		else:
			player_svport.process_mode = Node.PROCESS_MODE_DISABLED
			player_svport.hide()

	# Handle player count layout changes (3rd player svport gets equal sizing
	# of players 1 and 2 for instance)
	if player_count == 4:
		bottom_row.show()
		svp_cont3.set_stretch_ratio(1)
		left_pad.hide()
		right_pad.hide()
	if player_count == 3:
		bottom_row.show()
		svp_cont3.set_stretch_ratio(1)
		#left_pad.show()
		#right_pad.show()

		#var leftpad = Control.new()
		#leftpad.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND
		#leftpad.size_flags_vertical = Control.SizeFlags.SIZE_EXPAND
		#leftpad.set_stretch_ratio(1)
		#$SplitScreenContainer/BottomRow.add_child(leftpad)
		#$SplitScreenContainer/BottomRow.move_child(leftpad, 0)
		#var rightpad = Control.new()
		#rightpad.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND
		#rightpad.size_flags_vertical = Control.SizeFlags.SIZE_EXPAND
		#rightpad.set_stretch_ratio(1)
		#$SplitScreenContainer/BottomRow.add_child(rightpad)

	if player_count == 2:
		bottom_row.hide()
	if player_count == 1:
		bottom_row.hide()
		#$SplitScreenContainer/BottomRow.call_deferred('queue_free')
		#$SplitScreenContainer/TopRow/SvpCont2.call_deferred('queue_free')

	## Remove deleted players from end of player list and InputHandler tracking
	#for excess_count in range(GameData.MAX_PCOUNT - player_count):
		#var excess_player_id = player_ids.pop_back()
		#if excess_player_id != null:
			#InputHandler.remove_player(excess_player_id)
		#players.pop_back()


func handle_player_count_changed():
	prepare_split_screen()
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


func handle_cursor_use(node):
	pass


func handle_cursor_reject(node):
	if node.player_id == menu_cursor.player_id:
		loadout1.set_show_weapon_picker(false)
	if node.player_id == menu_cursor2.player_id:
		loadout2.set_show_weapon_picker(false)
	if node.player_id == menu_cursor3.player_id:
		loadout3.set_show_weapon_picker(false)
	if node.player_id == menu_cursor4.player_id:
		loadout4.set_show_weapon_picker(false)


func handle_cursor_accept(cursor, coords):
	var node = get_control_at_coords(coords)
	if node:
		if node.has_meta('owning_player_id'):
			var pid = node.get_meta('owning_player_id')
			if pid == cursor.player_id:
				node.pressed.emit()
		else:
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
	$MarginContainer2/Splitter/GamemodeSettings.process_mode = Node.PROCESS_MODE_INHERIT


func _physics_process(delta):
	InputHandler.poll_for_devices()
