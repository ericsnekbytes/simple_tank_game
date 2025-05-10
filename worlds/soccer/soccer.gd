extends Node3D

signal request_scene(scene_id)
signal stats_changed()

@onready var players = [
	$SplitScreenContainer/TopRow/SvpCont1/SubViewport/Player1,
	$SplitScreenContainer/TopRow/SvpCont2/SubViewport/Player2,
	$SplitScreenContainer/BottomRow/SvpCont3/SubViewport/Player3,
	$SplitScreenContainer/BottomRow/SvpCont4/SubViewport/Player4,
]
var player_count := 4
# ....
var score_gui_scn = preload('res://ui/point_display.tscn')
var scoreboard_scn = preload("res://ui/game_stats.tscn")
# ....
var endgame_stats = null


func _ready() -> void:
	GameData.global_pivot = $GlobalPivot

	for player in players:
		player.start_process = true
		GameData.initialize_player(player)
		player.spawn_position = player.global_position
		player.spawn_basis = player.global_basis
		player.died.connect(handle_player_death)

		var score_gui := score_gui_scn.instantiate()
		player.add_gui(score_gui)
		player.score_changed.connect(score_gui.set_value)
		player.score_changed.emit(player.score)

		var scoreboard_gui := scoreboard_scn.instantiate()
		scoreboard_gui.fetch_game_stats_func = get_game_stats
		stats_changed.connect(scoreboard_gui.sync_stats)
		player.died.connect(handle_stat_change)
		player.score_changed.connect(handle_stat_change)
		player.add_gui(scoreboard_gui)
		player.user_select.connect(scoreboard_gui.toggle_game_stats)


func handle_stat_change(_value):
	stats_changed.emit()


func get_game_stats():
	if endgame_stats:
		# When game ends, scores/stats are frozen
		return endgame_stats

	var player_data = {
		# Looks like
		# player_idnum1: [2, 1, 3],
		# player_idnum2: [5, 4, 8],
	}
	var game_stats = {
		'headers': ['Player', 'Score', 'Deaths'],
		'player_data': player_data
	}
	for player in players:
		var pid = player.player_id
		var pname = player.name
		var score = player.score
		var deaths = player.death_count
		var player_stats = [pname, score, deaths]

		player_data[player.player_id] = player_stats
	return game_stats


#func get_spawn_info_from_id(player_id):
	##print('SCENR get spawn info (%s) // %s' % [player_id, spawn_nodes])
	#var spawn_node = null
	#var points = spawn_nodes
	#spawn_node = points[player_id % points.size()]
#
	#return spawn_node


func prepare_split_screen():
	var player_ids = []
	for player in players:
		player_ids.append(player.player_id)

	if player_count == 4:
		return
	if player_count == 3:
		$SplitScreenContainer/BottomRow/SvpCont4.call_deferred('queue_free')
		$SplitScreenContainer/BottomRow/SvpCont3.set_stretch_ratio(2)

		var leftpad = Control.new()
		leftpad.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND
		leftpad.size_flags_vertical = Control.SizeFlags.SIZE_EXPAND
		leftpad.set_stretch_ratio(1)
		$SplitScreenContainer/BottomRow.add_child(leftpad)
		$SplitScreenContainer/BottomRow.move_child(leftpad, 0)
		var rightpad = Control.new()
		rightpad.size_flags_horizontal = Control.SizeFlags.SIZE_EXPAND
		rightpad.size_flags_vertical = Control.SizeFlags.SIZE_EXPAND
		rightpad.set_stretch_ratio(1)
		$SplitScreenContainer/BottomRow.add_child(rightpad)

	if player_count == 2:
		$SplitScreenContainer/BottomRow.call_deferred('queue_free')
	if player_count == 1:
		$SplitScreenContainer/BottomRow.call_deferred('queue_free')
		$SplitScreenContainer/TopRow/SvpCont2.call_deferred('queue_free')

	# Remove deleted players from end of player list and InputHandler tracking
	for excess_count in range(GameData.MAX_PCOUNT - player_count):
		var excess_player_id = player_ids.pop_back()
		if excess_player_id != null:
			InputHandler.remove_player(excess_player_id)
		players.pop_back()


func set_player_count(count: int):
	player_count = count
	prepare_split_screen()


func handle_player_death(pnode: PlayerTank):
	pnode.global_position = pnode.spawn_position + Vector3(0, 3, 0)
	pnode.global_basis = pnode.spawn_basis
	pnode.health = 100
	pnode.dead = false
	pnode.reset_body()


func end_game():
	print('ENDGAME')
	GameData.clear_scene_state()
	request_scene.emit('MAIN_MENU', null)
	# TODO clean up scoreboard cyclical reference


func _physics_process(delta: float) -> void:
	InputHandler.poll_for_devices()


func _on_killbox_body_entered(body: Node3D) -> void:
	if body.is_in_group('player'):
		body.take_hit(105)
	if body.is_in_group('soccer_ball'):
		body.transform = Transform3D()
		body.transform.origin = Vector3(0, 6, 0)
		body.linear_velocity = Vector3.ZERO
		body.angular_velocity = Vector3.ZERO


func _on_goal_body_entered(body: Node3D) -> void:
	if body.is_in_group('soccer_ball'):
		print('Goal enter by %s' % body)
		if body.last_touched_by != -1:
			#print('TOUCH %s %s' % [body.last_touched_by])
			print('xx')
			for player in players:
				if player.team_id == body.last_touched_by:
					player.score += 1
					print('aaa1')
		else:
			print('yy')
			for player in players:
				if player.player_id == body.last_touched_by:
					player.score += 1
					print('bbb1')
