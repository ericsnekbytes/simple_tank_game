# Scene that adds

extends SubViewportContainer

var player_node = null
var player_gui = null
@onready var subvp = $SubViewport
@export var auto_grab_player_node = true


func _ready():
	size_flags_horizontal = SizeFlags.SIZE_EXPAND_FILL

	if auto_grab_player_node:
		var player_node = get_node('Player')
		subvp.add_child(player_node)


#func destroy_and_replace_player():
	#if is_instance_valid(player_node):
		#player_node.queue_free()
		#player_node = null
#
		#var new_player =  player_scn.instantiate()
		#player_node = new_player
		#player_changed.emit(new_player)


func destroy_player():
	for pnode in $SubViewport/PlayerPivot.get_children():
		pnode.call_deferred('queue_free')

	player_node = null


#func new_player():
	#var new_node =  player_scn.instantiate()
	#player_node = new_node
	#$SubViewport.add_child(new_node)
	##player_changed.emit(new_player)
	#return new_node


func assign_player(node):
	destroy_player()

	player_node = node
	$SubViewport/PlayerPivot.add_child(node)


func assign_gui(node):
	destroy_gui()

	player_gui = node
	$SubViewport/GuiPivot.add_child(node)


func destroy_gui():
	for gui in $SubViewport/GuiPivot.get_children():
		gui.call_deferred('queue_free')

	player_gui = null


func get_player():
	return player_node
