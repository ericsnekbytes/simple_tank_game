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
var ammo_enabled = true
var max_ammo_count = 2
var ammo_count = max_ammo_count:
	set(value):
		if value < 0:
			value = 0
		if value > max_ammo_count:
			value = max_ammo_count
		ammo_count = value
		if value < max_ammo_count:
			ammo_timer.start()
		else:
			ammo_timer.stop()
		sync_pips()
# ....
@onready var hud = $Hud
@onready var pip1 = $Hud/AmmoPips/Pip1
@onready var pip2 = $Hud/AmmoPips/Pip2
@onready var pip1b = $Hud/AmmoPipsExtra/Pip1B
@onready var pip2b = $Hud/AmmoPipsExtra/Pip2B
@onready var topfill1 = $Hud/MortarPitchIndicator/TopFill1
@onready var topfill2 = $Hud/MortarPitchIndicator/TopFill2
@onready var lowfill1 = $Hud/MortarPitchIndicator/Lower/LowFill1
@onready var lowfill2 = $Hud/MortarPitchIndicator/Lower/LowFill2


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


func set_gun_active(state):
	if state:
		show()
	else:
		hide()
		firing = false
		firing_timer.stop()


func sync_pips():
	print('Sync pip %s' % ammo_count)
	if ammo_count == 0:
		pip1.hide()
		pip1b.hide()
		pip2.hide()
		pip2b.hide()
	if ammo_count == 1:
		pip1.show()
		pip1b.show()
		pip2.hide()
		pip2b.hide()
	if ammo_count == 2:
		pip1.show()
		pip1b.show()
		pip2.show()
		pip2b.show()


func set_ui_visible(state):
	if state:
		hud.show()
	else:
		hud.hide()


func get_ui_pips():
	return $Hud/AmmoPips


func get_ui():
	return $Hud


func update_pitch_indicator(value: Basis):
	if value.y.z <0:
		var horizon_delta = 1 - abs(value.y.y)

		# Set above-horizon indicator bars
		topfill1.value = horizon_delta
		topfill2.value = horizon_delta

		# Set below-horizon indicator bars
		lowfill1.value = 0
		lowfill2.value = 0
	else:
		var horizon_delta = 1 - abs(value.y.y)

		# Set above-horizon indicator bars
		topfill1.value = 0
		topfill2.value = 0

		# Set below-horizon indicator bars
		lowfill1.value = horizon_delta
		lowfill2.value = horizon_delta


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
