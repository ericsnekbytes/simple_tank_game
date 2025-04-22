extends Node3D

signal request_scene(scene_id)

@onready var players = [
	$SplitScreenContainer/TopRow/SvpCont1/SubViewport/PlayerTank,
	$SplitScreenContainer/TopRow/SvpCont2/SubViewport/PlayerTank,
	$SplitScreenContainer/BottomRow/SvpCont3/SubViewport/PlayerTank,
	$SplitScreenContainer/BottomRow/SvpCont4/SubViewport/PlayerTank,
]
var player_count = 4


func _ready() -> void:
	for player in players:
		player.start_process = true
		GameData.initialize_player(player)


func prepare_split_screen():
	var player_ids = []
	for player in players:
		player_ids.append(player.player_id)

	if player_count == 4:
		return
	if player_count == 3:
		$SplitScreenContainer/BottomRow/SvpCont4.call_deferred('queue_free')
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


func _physics_process(delta: float) -> void:
	InputHandler.poll_for_devices()
