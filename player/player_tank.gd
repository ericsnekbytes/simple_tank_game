class_name PlayerTank

extends CharacterBody3D

signal died(node)
signal health_changed(value: float)
signal cannon_pitch_changed(value: float)
signal score_changed(value)
signal user_select()

var player_id := -1
@export var team_id = -1
var start_process := false
var _lock_inputs := false
#@onready var player_cam = $CameraPivot/Camera3D
@onready var cannon = $ModelPivot/CannonPivot
@onready var cannon_pivot = $ModelPivot/CannonPivot
@onready var cannon_spawn_pos = cannon_pivot.global_position
@onready var cannon_spawn_basis = cannon_pivot.basis
# ....
var enable_health_regen = true
@onready var health_regen_wait = $HealthRegenWait  # Timer to start health regen
@onready var health_regen_uptick = $HealthRegenUptick  # Timer to start health regen
var health_regen_active = false
var health_regen_increment = 5
#var health_regen_period = 500  # Time between health upticks
var last_regen_timestamp = 0
var dead = false
var death_count = 0
var last_hit_by = null:
	set(value):
		last_hit_by = value
var health = 100.0:
	get:
		return health
	set(value):
		var new_value = value
		if new_value > 100:
			new_value = 100
		if new_value < 0:
			new_value = 0
		health = new_value
		if health < 100.0:
			if enable_health_regen:
				if health_regen_uptick.is_stopped():
					health_regen_wait.start()
		else:
			if enable_health_regen:
				health_regen_uptick.stop()
				health_regen_wait.stop()
		health_changed.emit(new_value)
		if new_value <= 0:
			#print('pHEALTH at 0 %s' % self)
			dead = true
			death_count += 1
			died.emit(self)
		#print("Set health " + str(new_value))
# ....
@onready var gun_handler = $WeaponPivot/GunHandler
# ....
var score := 0:
	set(value):
		score = value
		score_changed.emit(value)
# ....
@onready var player_cam = $CameraPivot/Camera3D
@onready var cam_pivot = $CameraPivot
@onready var cam_position_vector = $CameraPivot/Camera3D.position - cam_pivot.position
@onready var cam_spawn_basis = $CameraPivot/Camera3D.basis
@onready var cam_zoom_val = [1, 2, 3, 4]
var cam_zoom_index = 0
var last_cam_zoom_timestamp= -1
var cam_zoom_cooldown = 200
# ....
@onready var effect_timer = $Hud/EffectIndicator/EffectTimer
@export var effect_curve: Curve
@onready var effect_indicator = $Hud/EffectIndicator
# ....
var GRAVITY_BASE := Vector3(0, -9.8, 0)
var MAX_THRUST := 10
var MAX_SPEED := 10
var MAX_SPIN := PI
var MAX_PITCH := PI
# ....
var spawn_position := Vector3.ZERO
var spawn_basis := Basis()
# ....
@export var hide_gui_on_ready = false


func _ready() -> void:
	# Set up guns
	gun_handler.owning_player = self
	gun_handler.request_gun_ui_attach.connect(add_gui)
	gun_handler.preparing_weapon_change.connect(handle_preparing_weapon_change)
	cannon_pitch_changed.connect(gun_handler.handle_cannon_pitch_changed)
	gun_handler.initialize()

	# Health UI
	health_changed.connect(update_health_label)
	health_changed.emit(health)

	if not hide_gui_on_ready:
		$Hud.show()


func set_lock_inputs(state):
	gun_handler.set_lock_inputs(state)


func handle_preparing_weapon_change():
	if gun_handler.gun_order[gun_handler.active_weapon_index] == gun_handler.gun_mortar.weapon_id:
		#cannon_pivot.global_position = cannon_spawn_pos
		cannon_pivot.basis = cannon_spawn_basis
		#gun_mortar.visible = true


func update_hud():
	if not effect_timer.is_stopped():
		effect_indicator.show()
		effect_indicator.self_modulate.a = 1.0 - ((effect_timer.wait_time - effect_timer.time_left) / effect_timer.wait_time)
	else:
		effect_indicator.hide()


func show_effect_indicator(color_string=null):
	#print('Show effect %s' % Time.get_ticks_msec())
	effect_timer.start()
	if color_string != null:
		var color = Color(color_string)
		var clear_variant = Color(color)
		clear_variant.a = 0
		effect_indicator.texture.gradient.set_color(0, color)
		effect_indicator.texture.gradient.set_color(1, clear_variant)


func update_health_label(value: float) -> void:
	$Hud/HealthBar/HealthFill.value = value


func set_weapon_order(order):
	gun_handler.set_weapon_order(order)


func get_cannon_firing_data():
	return {'global_pos': cannon_pivot.global_position, 'global_basis': cannon_pivot.global_basis}


func _on_health_regen_uptick_timeout() -> void:
	health += health_regen_increment


func _on_health_regen_wait_timeout() -> void:
	health_regen_uptick.start()
	last_hit_by = null


func take_hit(damage: float, aggressor=null):
	#print('TAKEHIT %s / %s' % [damage, aggressor])
	health -= damage
	if aggressor:
		last_hit_by = aggressor
	show_effect_indicator()
	#var hit_direction = 1.0 * transform.basis.y.signed_angle_to(hit_position - $Pivot/Camera3D.global_position, transform.basis.z)
	#indicate_damaged.emit(hit_direction)

	#last_hit_by = shooter_id
	#hit_by.emit(self, shooter_id)


func hide_gui():
	$Hud.hide()


func add_gui(node):
	if node.get_parent():
		node.reparent($Hud)
	else:
		$Hud.add_child(node)


func reset_body():
	$ModelPivot/Body.basis = Basis()
	last_hit_by = null


func _unhandled_input(event: InputEvent) -> void:
	var current_time = Time.get_ticks_msec()

	if not _lock_inputs:
		var pdev = InputHandler.get_player_device(player_id)
		if event.device == pdev:
			#if event.is_action('shoot'):
				#if Input.is_action_just_pressed('shoot'):
					#print('foobar %s' % self)
			if event.is_pressed() and event.is_action('swap_gun'):
				gun_handler.active_weapon_index += 1
			if event.is_action('cam_action'):
				if current_time - last_cam_zoom_timestamp > cam_zoom_cooldown:
					cam_zoom_index = (cam_zoom_index + 1) % cam_zoom_val.size()

					if cam_zoom_val[cam_zoom_index] == 4:
						player_cam.basis = $CameraPivot/FpvPivot.basis
						player_cam.position = $CameraPivot/FpvPivot.position
						cam_zoom_index = cam_zoom_index % cam_zoom_val.size()
					else:
						player_cam.basis = cam_spawn_basis
						player_cam.position = cam_zoom_val[cam_zoom_index] * cam_position_vector
					last_cam_zoom_timestamp = current_time
			if event.is_action('user_select') and event.is_pressed():
				user_select.emit()


func _physics_process(delta: float) -> void:
	if start_process:
		var current_time := Time.get_ticks_msec()

		var start_velocity := velocity
		var motion_vector := Vector3.ZERO

		var player_commands = InputHandler.get_command_dict(player_id)
		#print(player_commands)

		var move_forward_back := Vector3.ZERO
		var move_fwd_back_raw = player_commands['move_yaxis']
		if move_fwd_back_raw != null and abs(move_fwd_back_raw) > .1:
			move_forward_back = (global_basis.z * -1) * MAX_THRUST * move_fwd_back_raw
			#move_forward_back = (Vector3.UP.cross(player_cam.basis.x).normalized() * -1) * MAX_THRUST * move_fwd_back_raw

		var move_left_right := Vector3.ZERO
		var move_left_right_raw = player_commands['move_xaxis']
		if move_left_right_raw != null and abs(move_left_right_raw) > .1:
			move_left_right = (global_basis.x * -1) * MAX_THRUST * move_left_right_raw
			#move_left_right = player_cam.basis.x.normalized() * MAX_THRUST * move_left_right_raw
			#print('HORZ %s // %s' % [move_left_right_raw, move_forward_back])

		var look_spin := 0
		var look_spin_raw = player_commands['look_xaxis']
		if look_spin_raw != null and abs(look_spin_raw) > .1:
			look_spin_raw *= -1
			look_spin = look_spin_raw * MAX_SPIN
			#print('SPIN %s // %s' % [look_spin, look_spin_raw])

		var look_pitch := 0
		var look_pitch_raw = player_commands['look_yaxis']
		if look_pitch_raw != null and abs(look_pitch_raw) > .1:
			look_pitch_raw *= -1
			look_pitch = look_pitch_raw * MAX_PITCH
			#print('PITCH %s // %s' % [look_pitch, look_pitch_raw])

		# Sum lateral motion
		var ground_motion := move_left_right + move_forward_back
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
		var gravity_vec := GRAVITY_BASE
		#if not is_on_floor():
			#gravity_vec += GRAVITY_BASE * (((current_time - last_on_floor_timestamp) / 1000.0) ** 2)

		# Do rotations, check for and clamp overrotations
		transform = transform.orthonormalized()
		# Do cannon rotation if needed (for mortar shells)
		if gun_handler.gun_order[gun_handler.active_weapon_index] == gun_handler.gun_mortar.weapon_id:  # TODO finish arcing mortar gun
			var planned_pitch = cannon_pivot.basis.rotated(cannon.basis.x * -1, look_pitch * delta)
			# Check for valid pitch angles by inspecting the y/up vector.
			# The up vector has a y component that is very close to zero when
			# the pitch angle is all the way up or down (1 degree from horizontal is used here).
			if planned_pitch.y.y > sin(PI / 90): # planned_pitch.basis.z.y <= 0 and 
				cannon_pivot.basis = planned_pitch
			cannon_pitch_changed.emit(cannon_pivot.basis)
		rotate(Vector3(0, 1, 0), look_spin * delta)

		# Sum up motion  # TODO
		motion_vector = gravity_vec + ground_motion
		if motion_vector.length() > MAX_SPEED:
			motion_vector = motion_vector.normalized() * MAX_SPEED
		# Spin tank body to direction of motion
		if not ground_motion.is_zero_approx():
			var new_body_basis = Basis.IDENTITY
			new_body_basis.y = Vector3(0, 1, 0)
			new_body_basis.z = ground_motion.normalized()
			new_body_basis.x = new_body_basis.y.cross(new_body_basis.z)
			$ModelPivot/Body.global_basis = new_body_basis

		velocity = motion_vector

		move_and_slide()
		
		#var collision_info = move_and_collide(velocity)
		#if collision_info:
			#var collider = collision_info.get_collider()
			##print(collider)
			#var collide_norm = collision_info.get_normal()
			##var collide_pt = collision_info.get_position()
#
			#if collider.is_in_group('soccer_ball'):
				#print('TOUCH BALL %s' % team_id)
				#collider.last_touched_by = team_id
			#velocity = velocity.slide(collide_norm)
			#move_and_slide()
		
		#player_cam.global_position = global_position + Vector3(0, 1.65, 0)

		update_hud()
