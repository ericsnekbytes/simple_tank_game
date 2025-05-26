extends Node

@onready var fps_label = $UI/FpsLabel
@onready var scene_pivot = $ScenePivot
var start_process = false


var scenes = {
	'MAIN_MENU': preload("res://main/main_menu.tscn"),
	'FREE_FOR_ALL_PREGAME': preload("res://worlds/free_for_all/ffa_pregame_menu.tscn"),
	'FREE_FOR_ALL': preload("res://worlds/free_for_all/free_for_all.tscn"),
	'SOCCER_PREGAME': preload('res://worlds/soccer/soccer_pregame_menu.tscn'),
	'SOCCER': preload('res://worlds/soccer/soccer.tscn'),
}


# Called when the node enters the scene tree for the first time.
func _ready():
	start_process = true

	GameData.initialize_config()

	if GameData.debug_on:
		fps_label.show()
	load_scene('MAIN_MENU', null)


func load_scene(scene_id, args=null):
	if scene_id in scenes:
		print('LOAD SCN %s' % scene_id)
		if scene_pivot.get_child_count() > 0:
			var old_scene = scene_pivot.get_child(0)
			old_scene.process_mode = Node.PROCESS_MODE_DISABLED
			old_scene.queue_free()
		var new_scene = scenes[scene_id].instantiate()
		if args != null:
			new_scene.game_options = args
		new_scene.request_scene.connect(load_scene)
		scene_pivot.add_child(new_scene)


func _unhandled_input(event):
	if event.is_action('escape'):
		if $ScenePivot.get_child_count() > 0:
			var current_scene = $ScenePivot.get_child(0)
			current_scene.process_mode = Node.PROCESS_MODE_DISABLED
			GameData.clear_scene_state()
			current_scene.request_scene.emit('MAIN_MENU')


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if start_process and GameData.debug_on:
		fps_label.set_text('FPS: %s' % Engine.get_frames_per_second())
