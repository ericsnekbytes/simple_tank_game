class_name PlayerTank

extends CharacterBody3D

var player_id = -1
var start_process = false
#@onready var player_cam = $CameraPivot/Camera3D
@onready var cannon = $ModelPivot/CannonPivot
# ....
var GRAVITY_BASE = Vector3(0, -9.8, 0)
var MAX_THRUST = 10
var MAX_SPEED = 10
var MAX_SPIN = PI
var MAX_PITCH = PI


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if start_process:
		var current_time = Time.get_ticks_msec()

		var start_velocity = velocity
		var motion_vector = Vector3.ZERO

		var player_commands = InputHandler.get_command_dict(player_id)
		#print(player_commands)

		var move_forward_back = Vector3.ZERO
		var move_fwd_back_raw = player_commands['move_yaxis']
		if move_fwd_back_raw != null and abs(move_fwd_back_raw) > .1:
			move_forward_back = (global_basis.z * -1) * MAX_THRUST * move_fwd_back_raw
			#move_forward_back = (Vector3.UP.cross(player_cam.basis.x).normalized() * -1) * MAX_THRUST * move_fwd_back_raw

		var move_left_right = Vector3.ZERO
		var move_left_right_raw = player_commands['move_xaxis']
		if move_left_right_raw != null and abs(move_left_right_raw) > .1:
			move_left_right = (global_basis.x * -1) * MAX_THRUST * move_left_right_raw
			#move_left_right = player_cam.basis.x.normalized() * MAX_THRUST * move_left_right_raw
			#print('HORZ %s // %s' % [move_left_right_raw, move_forward_back])

		var look_spin = 0
		var look_spin_raw = player_commands['look_xaxis']
		if look_spin_raw != null and abs(look_spin_raw) > .1:
			look_spin_raw *= -1
			look_spin = look_spin_raw * MAX_SPIN
			#print('SPIN %s // %s' % [look_spin, look_spin_raw])

		var look_pitch = 0
		var look_pitch_raw = player_commands['look_yaxis']
		if look_pitch_raw != null and abs(look_pitch_raw) > .1:
			look_pitch_raw *= -1
			look_pitch = look_pitch_raw * MAX_PITCH
			#print('PITCH %s // %s' % [look_pitch, look_pitch_raw])

		# Sum lateral motion
		var ground_motion = move_left_right + move_forward_back
		# Modify lateral motion/control when not on the ground
		#if (not is_on_floor() and jump_timer.is_stopped()):
			#ground_motion *= .5
			#var decay_duration = air_accel_timer.wait_time - jump_timer.wait_time
			#var decay_fraction = (decay_duration - minf(decay_duration, air_accel_timer.time_left)) / decay_duration
			#ground_motion *= max(.333, decay_fraction)
		if ground_motion.length() > MAX_THRUST:
			ground_motion = ground_motion.normalized() * MAX_THRUST
		## Add sprint
		#if (not sprint_timer.is_stopped()) or sprinting:
			#ground_motion *= 1.5

		# Add gravity vector
		var gravity_vec = GRAVITY_BASE
		#if not is_on_floor():
			#gravity_vec += GRAVITY_BASE * (((current_time - last_on_floor_timestamp) / 1000.0) ** 2)

		# Do rotations, check for and clamp overrotations
		transform = transform.orthonormalized()
		# Do cannon rotation if needed (for mortar shells)
		if false:  # TODO finish arcing mortar gun
			var planned_pitch = cannon.transform.rotated(cannon.basis.x, look_pitch * delta)
			if planned_pitch.basis.y.y > sin(PI / 90.0): # planned_pitch.basis.z.y <= 0 and 
				cannon.rotate(cannon.basis.x * -1, look_pitch * delta)
		rotate(Vector3(0, 1, 0), look_spin * delta)

		# Sum up motion  # TODO
		motion_vector = gravity_vec + ground_motion
		if motion_vector.length() > MAX_SPEED:
			motion_vector = motion_vector.normalized() * MAX_SPEED

		velocity = motion_vector

		move_and_slide()
		#player_cam.global_position = global_position + Vector3(0, 1.65, 0)

		#update_hud()
