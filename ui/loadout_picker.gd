extends Control

@export var owning_player = null:
	set(value):
		print('Setmeta %s' % owning_player)
		owning_player = value
		# Set a player ID on controls to help restrict clicks to only the owning player
		for node in get_tree().get_nodes_in_group("menu_control"):
			if is_ancestor_of(node):
				node.set_meta('owning_player_id', owning_player.player_id)
var weapon_order = [null, null, null, null]
var current_slot = 0
@onready var slots = [
	$MarginContainer/EquippedWeapons/Container/ControlsSlot1/Slot1,
	$MarginContainer/EquippedWeapons/Container/ControlsSlot2/Slot2,
	$MarginContainer/EquippedWeapons/Container/ControlsSlot3/Slot3,
	$MarginContainer/EquippedWeapons/Container/ControlsSlot4/Slot4,
]
@onready var guns = {
	GunRocket.weapon_id: $GunPivot/GunRocket,
	GunMortar.weapon_id: $GunPivot/GunMortar,
	GunBlocks.weapon_id: $GunPivot/GunBlocks,
}
@onready var rows = [
	$MarginContainer/WeaponPicker/HBoxContainer,
	#$MarginContainer/WeaponPicker/HBoxContainer2,
	#$MarginContainer/WeaponPicker/HBoxContainer3,
]
var gun_selector_scn = preload('res://ui/weapon_selector.tscn')


func _ready():
	# Discard the placeholder gun selectors
	for row in rows:
		for child in row.get_children():
			child.queue_free()
	# ....
	# Add guns to the top row
	for gun in $GunPivot.get_children():
		var selector: WeaponSelector = gun_selector_scn.instantiate()
		$MarginContainer/WeaponPicker/HBoxContainer.add_child(selector)
		selector.weapon_id = gun.weapon_id
		selector.set_gun_icon(gun.get_icon())
		selector.set_gun_text(gun.display_name)
		selector.assign_slot.connect(handle_slot_assign)

	$MarginContainer/WeaponPicker.process_mode = Node.PROCESS_MODE_DISABLED


func handle_slot_assign(weapon_id):
	print('Assign to slot %s' % weapon_id)
	if weapon_id in guns:
		slots[current_slot].set_text(guns[weapon_id].display_name)
		weapon_order[current_slot] = weapon_id
	set_show_weapon_picker(false)


func set_show_weapon_picker(state: bool):
	if state:
		$MarginContainer/EquippedWeapons.process_mode = Node.PROCESS_MODE_DISABLED
		$MarginContainer/EquippedWeapons.hide()
		$MarginContainer/WeaponPicker.process_mode = Node.PROCESS_MODE_INHERIT
		$MarginContainer/WeaponPicker.show()
	else:
		$MarginContainer/EquippedWeapons.process_mode = Node.PROCESS_MODE_INHERIT
		$MarginContainer/EquippedWeapons.show()
		$MarginContainer/WeaponPicker.process_mode = Node.PROCESS_MODE_DISABLED
		$MarginContainer/WeaponPicker.hide()


func configure_slot(slot_index):
	# Hide the slot list and show the weapon picker so the user
	# can select one of the available weapoons for that slot
	set_show_weapon_picker(true)
	current_slot = slot_index


func handle_weapon_picked(weapon_id):
	pass


func _on_slot_1_pressed():
	configure_slot(0)


func _on_slot_2_pressed():
	configure_slot(1)


func _on_slot_3_pressed():
	configure_slot(2)


func _on_slot_4_pressed():
	configure_slot(3)
