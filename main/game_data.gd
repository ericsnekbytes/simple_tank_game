extends Node

var active_players = {}
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


func clear_game_state():
	InputHandler.clear_tracked_players()
	global_pivot = null


func initialize_player(node):
	var player_id = get_unique_id()
	node.player_id = player_id
	InputHandler.add_player(player_id)
