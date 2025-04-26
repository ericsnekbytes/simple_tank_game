class_name GunBlocks

extends Node3D

signal fired(bullet)

var start_process = false
var owning_player = null
static var weapon_id = 'GUN_BLOCKS'
# ....
var block_scn = preload('res://environment/blocks/craft_cube.tscn')
var block_preview_scn = preload('res://environment/blocks/craft_cube_preview.tscn')
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
var max_ammo_count = 3
# ....
var preview_enabled = false
@onready var preview_block = $CraftCubePreview


# Called when the node enters the scene tree for the first time.
func _ready():
	#enable_auto_fire = false
	firing_timer.wait_time = 60.0 / rounds_per_min
	print('Bgun %s / %s' % [firing_timer.wait_time, rounds_per_min])


func _exit_tree():
	owning_player = null


#func set_preview_state(state):
	#preview_enabled = state
	#if state:
		#if not cursor_node:
			#cursor_node = cursor_scn.instantiate()
			#pivot.add_child(cursor_node)
		#preview_block = preview_block_scn.instantiate()
		##preview_block.get_node('CollisionShape3D').disabled = true
		##preview_block.get_node('block_model_5x1y5z/Cube').set_surface_override_material(0, preview_mat)
		#pivot.add_child(preview_block)
		#set_preview_home()
		#cursor_node.show()
	#else:
		#if preview_block != null:
			#preview_block.queue_free()
			#preview_block = null
		#if cursor_node != null:
			#cursor_node.hide()


func alt_fire():
	print('DELETE cube')
	var test_position = $Cursor.global_position #+ Vector3(.5, .5, .5)
	#test_position.x = roundf(test_position.x)
	#test_position.y = roundf(test_position.y)
	#test_position.z = roundf(test_position.z)

	$Cursor/Eraser.global_position = test_position

	#var ENV_LAYER = 1
	var CRAFT_BLK_LAYER = 8
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape = $Cursor/Eraser.shape
	params.collision_mask = CRAFT_BLK_LAYER
	#params.transform = $Cursor/Eraser.global_transform
	params.transform.origin = test_position
	var nearby_items = get_world_3d().direct_space_state.intersect_shape(params)
	#print('Nearby %s' % [nearby_items])
	var tracked_items = {}
	for info in nearby_items:
		var item = info['collider']
		print('Found nearby item %s' % info)
		if item.is_in_group('craft_blk'):
			print('take hit %s' % item)
			if item not in tracked_items:
				item.queue_free()
			tracked_items[item] = true


func fire():
	var current_time = Time.get_ticks_msec()

	var block = block_scn.instantiate()
	GameData.global_pivot.add_child(block)
	block.global_position = $Cursor.global_position + Vector3(-.5, 0, -.5)
	block.global_position.x = roundf(block.global_position.x)
	block.global_position.y = roundf(block.global_position.y)
	block.global_position.z = roundf(block.global_position.z)

	#return block
	
	######################################################
	
	#print('Fire %s' % owning_player)
	#var current_time = Time.get_ticks_msec()
	#if current_time - last_fire_timestamp >= fire_cooldown:
		#if not ammo_enabled or (ammo_enabled and ammo_count > 0):
			##var pcam = owning_player.player_cam
			#var bullet = bullet_scn.instantiate()
			#bullet.start_process = true
			#bullet.owning_player = owning_player
			#GameData.global_pivot.add_child(bullet)
			#var bullet_basis = global_basis.rotated(global_basis.y.normalized(), PI / 2.0)
			#bullet.global_basis = bullet_basis
			#bullet.global_position = Vector3(0, -.5, 0) + global_position + bullet_basis.z#.rotated(global_basis.y.normalized(), PI) * 3
			#bullet.velocity = bullet_basis.z*bullet.MAX_SPEED#.rotated(global_basis.y.normalized(), PI) * bullet.MAX_SPEED
			#ammo_count -= 1
			#ammo_timer.start()


func _on_ammo_timer_timeout():
	ammo_count += 1


func set_ui_visible(state):
	if state:
		$HUD.show()
	else:
		$HUD.hide()


func set_gun_active(state):
	if state:
		show()
	else:
		hide()
		firing = false
		firing_timer.stop()


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

			if event.is_pressed() and event.is_action('shoot_alt'):
				if not firing:
					alt_fire()


func update_preview():
	preview_block.global_basis = Basis()
	preview_block.global_position = $Cursor.global_position + Vector3(-.5, 0, -.5)
	preview_block.global_position.x = roundf(preview_block.global_position.x)
	preview_block.global_position.y = roundf(preview_block.global_position.y)
	preview_block.global_position.z = roundf(preview_block.global_position.z)


func _physics_process(delta: float) -> void:
	if start_process:
		update_preview()
