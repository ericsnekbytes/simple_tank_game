class_name GunMortar

extends Node3D

signal fired(bullet)

var start_process = false
var owning_player = null
static var weapon_id = 'GUN_MORTAR'
# ....
var bullet_scn = preload('res://weapons/bullet_mortar.tscn')
# ....
@onready var firing_timer = $FiringTimer
var firing = false:  # There's no device-specific is_action_just_pressed, so we use this
	set(value):
		if value != firing:
			firing = value
			print('Firing %s' % value)
var rounds_per_min = 150
var last_fire_timestamp = 0
var fire_cooldown = 60.0 / rounds_per_min
var enable_auto_fire = true
# ....
@onready var ammo_timer = $AmmoTimer
var ammo_enabled = false
var ammo_count = 3:
	set(value):
		if value < 0:
			value = 0
		if value > max_ammo_count:
			value = max_ammo_count
		ammo_count = value
		#sync_pips()
var max_ammo_count = 3
# ....


# Called when the node enters the scene tree for the first time.
func _ready():
	#enable_auto_fire = false
	firing_timer.wait_time = 60.0 / rounds_per_min
	print('Bgun %s / %s' % [firing_timer.wait_time, rounds_per_min])


func _exit_tree():
	owning_player = null


func fire():
	print('Fire %s' % owning_player)
	var current_time = Time.get_ticks_msec()
	if current_time - last_fire_timestamp >= fire_cooldown:
		if not ammo_enabled or (ammo_enabled and ammo_count > 0):
			#var pcam = owning_player.player_cam
			var bullet = bullet_scn.instantiate()
			bullet.start_process = true
			bullet.owning_player = owning_player
			GameData.global_pivot.add_child(bullet)
			#var bullet_basis = global_basis.rotated(global_basis.y.normalized(), PI / 2.0)
			if owning_player != null:
				var firing_data = owning_player.get_cannon_firing_data()
				bullet.basis = firing_data['global_basis']
				bullet.global_position = firing_data['global_pos'] + (bullet.basis.z * 3)
			#bullet.global_basis = bullet_basis
			#bullet.global_position = Vector3(0, -.5, 0) + global_position + bullet_basis.z#.rotated(global_basis.y.normalized(), PI) * 3
			bullet.linear_velocity = bullet.basis.z*bullet.MAX_SPEED#.rotated(global_basis.y.normalized(), PI) * bullet.MAX_SPEED
			ammo_count -= 1
			ammo_timer.start()


func _on_ammo_timer_timeout():
	ammo_count += 1


func stop():
	firing = false
	firing_timer.stop()


#func sync_pips():
	#if ammo_count == 0:
		#$HUD/Reticule/Pip1.hide()
		#$HUD/Reticule/Pip2.hide()
		#$HUD/Reticule/Pip3.hide()
	#if ammo_count == 1:
		#$HUD/Reticule/Pip1.show()
		#$HUD/Reticule/Pip2.hide()
		#$HUD/Reticule/Pip3.hide()
	#if ammo_count == 2:
		#$HUD/Reticule/Pip1.show()
		#$HUD/Reticule/Pip2.show()
		#$HUD/Reticule/Pip3.hide()
	#if ammo_count == 3:
		#$HUD/Reticule/Pip1.show()
		#$HUD/Reticule/Pip2.show()
		#$HUD/Reticule/Pip3.show()


func set_ui_visible(state):
	if state:
		$HUD.show()
	else:
		$HUD.hide()


func update_pitch_indicator(value: Basis):
	print([value.y.y, value.y.x])
	if value.y.z <0:
		print('+')
		var horizon_delta = 1 - abs(value.y.y)

		# Set above-horizon indicator bars
		$HUD/MortarPitchIndicator/TopFill1.value = horizon_delta
		$HUD/MortarPitchIndicator/TopFill2.value = horizon_delta

		# Set below-horizon indicator bars
		$HUD/MortarPitchIndicator/Lower/LowFill1.value = 0
		$HUD/MortarPitchIndicator/Lower/LowFill2.value = 0
	else:
		print('-')
		var horizon_delta = 1 - abs(value.y.y)

		# Set above-horizon indicator bars
		$HUD/MortarPitchIndicator/TopFill1.value = 0
		$HUD/MortarPitchIndicator/TopFill2.value = 0

		# Set below-horizon indicator bars
		$HUD/MortarPitchIndicator/Lower/LowFill1.value = horizon_delta
		$HUD/MortarPitchIndicator/Lower/LowFill2.value = horizon_delta
		


func _unhandled_input(event):
	if start_process:
		var player_device = InputHandler.get_player_device(owning_player.player_id)
		#print('SH %s // %s // %s // %s' % [owning_player, player_device, event.device, event.is_action('rtrigger')])
		if owning_player != null and player_device != null and event.device == player_device:
			if event.is_pressed() and event.is_action('shoot'):
				if not firing:
					fire()

				firing = true
				if enable_auto_fire:
					firing_timer.start()
			if not event.is_pressed() and event.is_action('shoot'):
				firing = false

				firing_timer.stop()
