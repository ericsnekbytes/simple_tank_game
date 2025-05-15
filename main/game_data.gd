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
# ....
const SAVE_FILE_NAME = 'user://heckin_bytes.saveydoodles'
const EMPTY_CONFIG_DICT = {
	'version': '0.1',
	#'graphics': {
		#'vsync': DEFAULT_VSYNC,
		#'max_fps': DEFAULT_MAX_FPS,
	#},
	#'empty_schema': {}
}
var game_config_data = EMPTY_CONFIG_DICT.duplicate(true)
	#get():  # Return a read-only copy
		#return game_config_data.duplicate(true)
# ....
var gamemode_data = {}  # Runtime gamemode data for the active game


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


func initialize_config():
	game_config_data = fetch_config_data()
	load_config_data()


func create_empty_config():
	var config_data = EMPTY_CONFIG_DICT.duplicate(true)
	## Store an empty schema for this config version in the config file just in case
	#config_data['empty_schema'] = EMPTY_CONFIG_DICT.duplicate(true)
	return config_data


func validate_config(config_data):
	# TODO
	return {'status': 'success', 'value': config_data}


func write_config_data(config_data=null):
	if config_data == null:
		config_data = game_config_data

	var config_string = JSON.stringify(config_data)
	var config_file = FileAccess.open(SAVE_FILE_NAME, FileAccess.WRITE)
	config_file.store_string(config_string)
	print('WRITE config %s' % config_data)
	config_file.flush()


func fetch_config_data(create_on_missing=true):
	var config_data = create_empty_config()
	var json = JSON.new()
	var config_text = ''
	if FileAccess.file_exists(SAVE_FILE_NAME):
		config_text = FileAccess.open(SAVE_FILE_NAME, FileAccess.READ).get_as_text()
		var parse_result = json.parse(config_text)
		if parse_result == OK:
			var raw_config_data = json.data
			var cleaned_data = validate_config(raw_config_data)
			if cleaned_data['status'] == 'success':
				config_data = cleaned_data['value']
	else:
		if create_on_missing:
			# TODO tell user?
			write_config_data()  # Write the empty config

	return config_data


func load_config_data(config_data=null):
	if config_data == null:
		config_data = game_config_data
	#var graphics_data = config_data['graphics']
	#GameUtils.configure_graphics(graphics_data)
