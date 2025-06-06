extends Node3D

signal request_scene(scene_id)

@onready var players = [
	$SplitScreenContainer/TopRow/SvpCont1/SubViewport/Player1,
	$SplitScreenContainer/TopRow/SvpCont2/SubViewport/Player2,
	$SplitScreenContainer/BottomRow/SvpCont3/SubViewport/Player3,
	$SplitScreenContainer/BottomRow/SvpCont4/SubViewport/Player4,
]
var player_count := 4:
	set(value):
		player_count = value
var scene_options = {}


func _ready() -> void:
	GameData.global_pivot = $GlobalPivot

	for player: PlayerTank in players:
		GameData.initialize_player(player)
		player.spawn_position = player.global_position
		player.spawn_basis = player.global_basis
		player.died.connect(handle_player_death)
		#player.set_lock_inputs(true)

	set_scene_options(scene_options)
	begin_play()


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


func set_scene_options(options):
	if 'player_count' in options:
		set_player_count(options['player_count'])
	if 'player_loadouts' in options:
		var loadouts = options['player_loadouts']
		for i in range(players.size()):
			if i < player_count:
				players[i].set_weapon_order(loadouts[i])


func _on_killbox_body_entered(body: Node3D) -> void:
	if body.is_in_group('player'):
		body.take_hit(105)


func begin_play():
	for player in players:
		player.start_process = true
		player.set_lock_inputs(false)


func handle_player_death(pnode: PlayerTank):
	pnode.global_position = pnode.spawn_position + Vector3(0, 3, 0)
	pnode.global_basis = pnode.spawn_basis
	pnode.health = 100
	pnode.dead = false
	pnode.reset_body()


func end_game():
	GameData.clear_scene_state()
	request_scene.emit('MAIN_MENU', null)


func _physics_process(delta: float) -> void:
	InputHandler.poll_for_devices()
