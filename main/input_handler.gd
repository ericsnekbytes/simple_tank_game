extends Node

var tracked_players = {  # Which player owns which device
	#player_id: device_id (starts null)
}
# ....
var poll_freq = 200
var last_poll_timestamp = 0
# ....
const AXIS_INPUT = 0
const BUTTON_INPUT = 1
var valid_commands = {
	'move_yaxis': [AXIS_INPUT, JOY_AXIS_LEFT_Y],
	'move_xaxis': [AXIS_INPUT, JOY_AXIS_LEFT_X],
	'look_yaxis': [AXIS_INPUT, JOY_AXIS_RIGHT_Y],
	'look_xaxis': [AXIS_INPUT, JOY_AXIS_RIGHT_X],
	# ....
	"thrust_up": [AXIS_INPUT, JoyAxis.JOY_AXIS_TRIGGER_RIGHT],
	"thrust_down": [AXIS_INPUT, JoyAxis.JOY_AXIS_TRIGGER_LEFT],
	"spin": [AXIS_INPUT, JoyAxis.JOY_AXIS_LEFT_X],
	#JoyAxis.JOY_AXIS_LEFT_Y: null,
	"roll": [AXIS_INPUT, JoyAxis.JOY_AXIS_RIGHT_X],
	"pitch": [AXIS_INPUT, JoyAxis.JOY_AXIS_RIGHT_Y],
	"shoot_main": [BUTTON_INPUT, JoyButton.JOY_BUTTON_LEFT_SHOULDER],
	"pickup": [BUTTON_INPUT, JoyButton.JOY_BUTTON_X],
	"use": [BUTTON_INPUT, JoyButton.JOY_BUTTON_A],
	"dash_horz": [AXIS_INPUT, JoyAxis.JOY_AXIS_LEFT_X],
	"dash_vert": [AXIS_INPUT, JoyAxis.JOY_AXIS_LEFT_Y],
	"reload": [BUTTON_INPUT, JoyButton.JOY_BUTTON_B],
	"select": [BUTTON_INPUT, JoyButton.JOY_BUTTON_BACK],
}
var empty_player_command_dict = {
	'move_yaxis': null,
	'move_xaxis': null,
	'look_yaxis': null,
	'look_xaxis': null,
	# ....
	"thrust_up": null,
	"thrust_down": null,
	"spin": null,
	"roll": null,
	"pitch": null,
	"shoot_main": null,
	"pickup": null,
	"use": null,
	"dash_horz": null,
	"dash_vert": null,
	"reload": null,
	"select": null,
}
const STICK_DEADZONE = .1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add_player(player_id):
	if player_id not in tracked_players:
		tracked_players[player_id] = null


func remove_player(player_id):
	if player_id in tracked_players:
		tracked_players.erase(player_id)


func clear_tracked_players():
	tracked_players.clear()


func poll_for_devices():
	var current_time = Time.get_ticks_msec()
	if current_time - last_poll_timestamp >= poll_freq:
		find_and_assign_devices()


func get_player_device(player_id):
	if player_id in tracked_players:
		return tracked_players[player_id]
	else:
		return null


func find_and_assign_devices():
	var all_devs = Input.get_connected_joypads()

	# If there are any devices, check/assign them
	if all_devs:
		# Figure out which players need devices and which devices are taken
		var players_needing_devices = {}
		var assigned_devices = {}
		for pid in tracked_players:
			var player_device = tracked_players[pid]

			if player_device== null:
				players_needing_devices[pid] = null
			else:
				assigned_devices[player_device] = null

		# Assign unused devices to players
		for dev in all_devs:
			var deletion_queue = {}
			if dev not in assigned_devices:
				for pid in players_needing_devices:
					tracked_players[pid] = dev
					assigned_devices[dev] = null
					deletion_queue[pid] = null
					break
			for pid in deletion_queue:
				players_needing_devices.erase(pid)


func get_player_command(player_index, command):
	var input_value = null

	if player_index in tracked_players:
		if tracked_players[player_index] != null:
			var input_type = valid_commands[command][0]
			var input_code = valid_commands[command][1]

			# TODO check if joypad is connected before calling?
			var raw_value = null
			if input_type == AXIS_INPUT:
				raw_value = Input.get_joy_axis(tracked_players[player_index], input_code)
			if input_type == BUTTON_INPUT:
				raw_value = Input.is_joy_button_pressed(tracked_players[player_index], input_code)
				input_value = raw_value

			if raw_value != null and input_type == AXIS_INPUT:
				if abs(raw_value) > STICK_DEADZONE:
					input_value = abs(raw_value) - STICK_DEADZONE / (1 - STICK_DEADZONE)
					if raw_value < 0:
						input_value *= -1
	return input_value


func get_command_dict(player_id):
	var command_dict = empty_player_command_dict.duplicate()
	if player_id in tracked_players:
		var player_device = tracked_players[player_id]
		if player_device != null:
			for command in valid_commands:
				var command_type = valid_commands[command][0]
				var command_code = valid_commands[command][1]

				if command_type == AXIS_INPUT:
					#command_dict[command] = Input.get_joy_axis(player_device, command_code
					var value = null
					var raw_value = Input.get_joy_axis(player_device, command_code)
					if raw_value != null and abs(raw_value) > STICK_DEADZONE:
						value = raw_value
					command_dict[command] = value
				elif command_type == BUTTON_INPUT:
					command_dict[command] = Input.is_joy_button_pressed(player_device, command_code)

	return command_dict
