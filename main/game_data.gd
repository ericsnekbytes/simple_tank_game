extends Node

var player_scene_data = {}
var unique_id = -1
var global_pivot = null:
	set(value):
		global_pivot = value
#var debug_on = true
var debug_on = false
var rng = RandomNumberGenerator.new()
var MAX_PCOUNT = 4


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


func get_unique_id():
	unique_id += 1
	return unique_id


func clear_scene_state():
	InputHandler.clear_tracked_players()
	player_scene_data.clear()
	global_pivot = null


func get_player_data(player_id: int):
	if player_id in player_scene_data:
		return player_scene_data[player_id]
	return null


func delete_player(player_id: int):
	InputHandler.remove_player(player_id)
	player_scene_data.erase(player_id)


func initialize_player(node):
	var player_id = get_unique_id()
	node.player_id = player_id
	player_scene_data[player_id] = {}
	InputHandler.add_player(player_id)

	return player_id
