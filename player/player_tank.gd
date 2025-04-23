class_name PlayerTank

extends CharacterBody3D

signal died(node)
signal health_changed(value: float)

var player_id := -1
var start_process := false
#@onready var player_cam = $CameraPivot/Camera3D
@onready var cannon = $ModelPivot/CannonPivot
# ....
var enable_health_regen = true
@onready var health_regen_wait = $HealthRegenWait  # Timer to start health regen
@onready var health_regen_uptick = $HealthRegenUptick  # Timer to start health regen
var health_regen_active = false
var health_regen_increment = 1
#var health_regen_period = 500  # Time between health upticks
var last_regen_timestamp = 0
var dead = false
var health: float = 100.0:
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
			print('pHEALTH at 0 %s' % self)
			dead = true
			#death_count += 1
			died.emit(self)
		
		#print("Set health " + str(new_value))
# ....
var GRAVITY_BASE := Vector3(0, -9.8, 0)
var MAX_THRUST := 10
var MAX_SPEED := 10
var MAX_SPIN := PI
var MAX_PITCH := PI
# ....
@onready var gun_rocket = $WeaponPivot/GunRocket
@onready var gun_order = [gun_rocket.weapon_id]
@onready var guns = {
	gun_rocket.weapon_id: gun_rocket,
}
var active_weapon_index = 0:
	set(value):
		prepare_weapon_change()
		active_weapon_index = value % gun_order.size()
		sync_weapon()
# ....
var spawn_position := Vector3.ZERO
var spawn_basis := Basis()


func _ready() -> void:
	# Configure guns
	gun_rocket.owning_player = self
	sync_weapon()

	# Health UI
	health_changed.connect(update_health_label)
	health_changed.emit(health)


func update_health_label(value: float) -> void:
	$Control/HealthBar/HealthFill.value = value


func set_weapon_order(order):
	gun_order = order
	sync_weapon()


func prepare_weapon_change():
	pass
	#if gun_order[active_weapon_index] == gun_grav.weapon_id:
		#gun_grav.force_drop()


func sync_weapon():
	print('Active weapon swap %s / %s' % [active_weapon_index, guns[gun_order[active_weapon_index]]])
	for gun_id in guns:
		var gun = guns[gun_id]
		if gun_id == gun_order[active_weapon_index]:
			gun.start_process = true
			gun.show()
			if gun.is_in_group('gun_has_ui'):
				gun.set_ui_visible(true)
		else:
			gun.hide()
			if gun.is_in_group('gun_has_ui'):
				gun.set_ui_visible(false)
			gun.start_process = false


func _on_health_regen_uptick_timeout() -> void:
	health += health_regen_increment


func _on_health_regen_wait_timeout() -> void:
	health_regen_uptick.start()


func take_hit(damage: float):
	health -= damage
	print('%s take hit %s' % [self, damage])
	#var hit_direction = 1.0 * transform.basis.y.signed_angle_to(hit_position - $Pivot/Camera3D.global_position, transform.basis.z)
	#indicate_damaged.emit(hit_direction)

	#last_hit_by = shooter_id
	#hit_by.emit(self, shooter_id)


func _unhandled_input(event: InputEvent) -> void:
	var current_time = Time.get_ticks_msec()

	var pdev = InputHandler.get_player_device(player_id)
	if event.device == pdev:
		if event.is_action('shoot'):
			if Input.is_action_just_pressed('shoot'):
				print('foobar %s' % self)


func _physics_process(delta: float) -> void:
	if start_process:
		var current_time := Time.get_ticks_msec()

		#if enable_health_regen:
			#if health_regen_active and health < 100 and (current_time - last_regen_timestamp > health_regen_period):
				#health += health_regen_increment
				#last_regen_timestamp = current_time
				#if health >= 100:
					#health_regen_active = false

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
