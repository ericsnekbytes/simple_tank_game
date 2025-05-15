extends Node3D

signal preparing_weapon_change()
signal request_gun_ui_attach(node)

var owning_player = null
var start_process := false
var _lock_inputs := false
# ....
@onready var gun_rocket = $GunPivot/GunRocket
@onready var gun_mortar = $GunPivot/GunMortar
@onready var gun_blocks = $GunPivot/GunBlocks
@onready var gun_order = [gun_rocket.weapon_id, gun_mortar.weapon_id, gun_blocks.weapon_id]
@onready var guns = {
	gun_rocket.weapon_id: gun_rocket,
	gun_mortar.weapon_id: gun_mortar,
	gun_blocks.weapon_id: gun_blocks,
}
var active_weapon_index = 0:
	set(value):
		prepare_weapon_change()
		active_weapon_index = value % gun_order.size()
		sync_weapon()


func initialize():
	# Configure guns
	gun_rocket.owning_player = owning_player
	gun_mortar.owning_player = owning_player
	request_gun_ui_attach.emit(gun_mortar.get_ui_pips())
	gun_blocks.owning_player = owning_player
	#cannon_pitch_changed.connect(gun_mortar.update_pitch_indicator)
	sync_weapon()


func handle_cannon_pitch_changed(value):
	gun_mortar.update_pitch_indicator(value)


func set_lock_inputs(state):
	if state:
		_lock_inputs = true
		var gun = guns[gun_order[active_weapon_index]]
		gun.start_process = false
	else:
		_lock_inputs = false
		var gun = guns[gun_order[active_weapon_index]]
		gun.start_process = true


func set_weapon_order(order):
	gun_order = order
	sync_weapon()


func prepare_weapon_change():
	preparing_weapon_change.emit()


func sync_weapon():
	#print('Active weapon swap %s / %s' % [active_weapon_index, guns[gun_order[active_weapon_index]]])
	for gun_id in guns:
		var gun = guns[gun_id]
		if gun_id == gun_order[active_weapon_index]:
			gun.start_process = true
			gun.set_gun_active(true)
			if gun.is_in_group('gun_has_ui'):
				gun.set_ui_visible(true)
		else:
			gun.set_gun_active(false)
			if gun.is_in_group('gun_has_ui'):
				gun.set_ui_visible(false)
			gun.start_process = false
