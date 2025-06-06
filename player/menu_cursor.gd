extends TextureRect

signal cursor_moved()
signal navigate_request()
signal cursor_accept(node, coords)
signal cursor_reject(node)
signal cursor_use(node)

@export var player_id = -1
var start_process = false
# ....
var MAX_THRUST = 600
var last_cursor_accept_timestamp = 0
var cursor_accept_cooldown = 200
# ....
@export var colorize: Color
@export var label_text: String
# ....
@onready var spawn_position = global_position


func _ready():
	self_modulate = colorize
	$ColorRect.self_modulate = colorize
	if label_text:
		$ColorRect/Label.set_text(label_text)


func set_label(value):
	$ColorRect/Label.set_text(value)


func reset_position():
	global_position = spawn_position


func _unhandled_input(event):
	if start_process:
		var pdev = InputHandler.get_player_device(player_id)
		if event.device == pdev:
			var current_time := Time.get_ticks_msec()
			if not get_viewport().gui_get_focus_owner():
				if event.is_pressed() and (event.is_action('ui_down') or event.is_action('ui_up')):
					navigate_request.emit()
				if event.is_pressed() and event.is_action('ui_accept'):
					if current_time - last_cursor_accept_timestamp >= cursor_accept_cooldown:
						last_cursor_accept_timestamp = current_time
						cursor_accept.emit(self, global_position + (get_rect().size / 2.0))
			if event.is_pressed() and event.is_action('ui_cancel'):
				if current_time - last_cursor_accept_timestamp >= cursor_accept_cooldown:
					last_cursor_accept_timestamp = current_time
					cursor_reject.emit(self)
			if event.is_pressed() and event.is_action('menu_use'):
				if current_time - last_cursor_accept_timestamp >= cursor_accept_cooldown:
					last_cursor_accept_timestamp = current_time
					cursor_use.emit(self)


func _physics_process(delta):
	if start_process:
		var current_time := Time.get_ticks_msec()

		var motion_vector := Vector2.ZERO

		var player_commands = InputHandler.get_command_dict(player_id)

		var move_forward_back := Vector2.ZERO
		var move_fwd_back_raw = player_commands['move_yaxis']
		if move_fwd_back_raw != null and abs(move_fwd_back_raw) > .1:
			move_forward_back = Vector2.DOWN * MAX_THRUST * move_fwd_back_raw
			#move_forward_back = (Vector3.UP.cross(player_cam.basis.x).normalized() * -1) * MAX_THRUST * move_fwd_back_raw

		var move_left_right := Vector2.ZERO
		var move_left_right_raw = player_commands['move_xaxis']
		if move_left_right_raw != null and abs(move_left_right_raw) > .1:
			move_left_right = Vector2.RIGHT * MAX_THRUST * move_left_right_raw
			#move_left_right = player_cam.basis.x.normalized() * MAX_THRUST * move_left_right_raw
			#print('HORZ %s // %s' % [move_left_right_raw, move_forward_back])

		# Sum lateral motion
		motion_vector = move_left_right + move_forward_back
		position += motion_vector * delta
		if not motion_vector.is_zero_approx():
			cursor_moved.emit()
