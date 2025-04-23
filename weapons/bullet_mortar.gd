extends RigidBody3D

signal item_capture(node)

var owning_player = null
var start_process = false
# ....
var MAX_SPEED = 12
# ....
var decal_scn = preload("res://environment/exp_decal.tscn")
var triggered = false
# ...
@export var explosion_curve: Curve
@onready var explosion_radius = 4.0  # MATCH THE COLLISION SHAPE
var explode_force = 45
#var sphere_scn = preload("res://art/models/sphere.tscn")
# ....
var in_motion = true  # We stop motion and hide the rocket to do a flash/detonation
@export var flash_curve: Curve
@onready var impact_timer = $ImpactTimer
@onready var detonate_flash = $DetonationFlash
#@onready var sparks = $DetonateSparks
var damage = 55


func _ready():
	$DeathTimer.start()


func _exit_tree():
	owning_player = null


func _on_death_timer_timeout():
	if start_process:
		call_deferred('queue_free')


func _on_impact_timer_timeout():
	call_deferred('queue_free')


func deactivate():
	$MeshInstance3D.hide()
	$CollisionShape3D.disabled = true
	#linear_velocity = Vector3.ZERO
	freeze = true
	in_motion = false


func impact():
	deactivate()
	impact_timer.start()
	$DetonationFlash.show()
	#sparks.emitting = true



#func _xphysics_process(delta):
	#if start_process:
		#var current_time = Time.get_ticks_msec()
#
		#if not impact_timer.is_stopped():
			#detonate_flash.light_intensity_lumens = flash_curve.sample(
				#(impact_timer.wait_time - impact_timer.time_left) / impact_timer.wait_time
			#)
#
		#if in_motion:
			#var collision_info = move_and_collide(velocity * delta)
			#if collision_info:
				#print('REG Rocket hit')
				#var collider = collision_info.get_collider()
				#if collider:
					#print('Rnd collide %s' % collider)
					#if collider.is_in_group('player'):
						#collider.take_hit(damage)
					#
					## ..................
					##var ITEMS_LAYER = 8
					##var params = PhysicsShapeQueryParameters3D.new()
					##params.shape = $ExplosionChecker/CollisionShape3D.shape
					##params.collision_mask = ITEMS_LAYER
					##params.transform = $ExplosionChecker/CollisionShape3D.global_transform
					##var nearby_items = get_world_3d().direct_space_state.intersect_shape(params)
					###print('Nearby %s' % [nearby_items])
					##for info in nearby_items:
						##var item = info['collider']
						##print('Found nearby item %s' % item)
						##var explosion_to_item = item.global_position - collision_info.get_position()
						##var lateral_disp = Vector3(explosion_to_item.x, 0, explosion_to_item.z)
						##var lateral_decay = explosion_curve.sample(
							##minf(explosion_radius, abs(lateral_disp.length())) / explosion_radius
						##)
						##var lateral_force = lateral_disp.normalized() * explode_force * lateral_decay
						##var vertical_disp = Vector3(0, explosion_to_item.y, 0)
						##var vertical_decay = explosion_curve.sample(
							##(minf(explosion_radius, abs(vertical_disp.length())) / explosion_radius)
						##) * minf(1, lateral_decay + .5)
						##var vertical_force = (
							##abs(vertical_disp.normalized())
							##* vertical_decay
							##* explode_force * .3
						##)
						###print('Disp %s / %s' % [vertical_disp, lateral_disp])
						##item.last_touch_by = owning_player
						##print('Decay v%s / h%s' % [vertical_decay, lateral_decay])
						##if item.carried_by:
							##print('aaa')
							##item.force_drop()
							###item.carried_by.carried_item = null  # The carrier gun drops the item
							##item.pick_up_for(GameData.global_pivot)
							###item.carried_by = null  # The item no longer considers itself carried
##
							##item.queued_motion = lateral_force + vertical_force
						##else:
							##print('bbb')
							##item.apply_impulse(
								##lateral_force + vertical_force
							##)
					## ..................
#
					## TODO fix
					### Add an explosion decal/scorch mark
					##var rng = RandomNumberGenerator.new()  # TODO refactor
					##var hit_normal = collision_info.get_normal().normalized()
					##var hit_pos = collision_info.get_position()
					##var decal: Node3D = decal_scn.instantiate()
					##GameData.global_pivot.add_child(decal)
					##decal.show()
					##decal.global_position = global_position
					###print('Decal %s / %s' % [global_position, decal.global_position])
					###print('  hit_pos %s' % hit_pos)
					###print('  hit_norm %s' % hit_normal)
					##var z_diff_axis = decal.basis.z.cross(hit_normal).normalized()
					###print('  z_diff_axis %s' % z_diff_axis)
					##if is_equal_approx(z_diff_axis.length(), 1.0):
						##var z_diff = decal.basis.z.signed_angle_to(hit_normal, z_diff_axis)
						###print('  z_diff %s' % z_diff)
						##if not is_equal_approx(z_diff, 0):
							###print('  zZ')
							##decal.basis = decal.basis.rotated(z_diff_axis, z_diff)
					##decal.rotate(decal.basis.z,  rng.randf_range(0, PI * 2))
#
					##sparks.global_position = hit_pos
#
					#impact()


func detonate():
	#var ENV_LAYER = 1
	var PLAYER_LAYER = 2
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape = $ExplosionChecker/CollisionShape3D.shape
	params.collision_mask = PLAYER_LAYER
	params.transform = $ExplosionChecker/CollisionShape3D.global_transform
	var nearby_items = get_world_3d().direct_space_state.intersect_shape(params)
	#print('Nearby %s' % [nearby_items])
	var colliding_players = {}
	for info in nearby_items:
		var item = info['collider']
		print('Found nearby item %s' % info)
		if item.is_in_group('player') and item != owning_player:
			if not item.dead:
				print('take hit %s' % item)
				if item not in colliding_players:
					item.take_hit(damage)
				colliding_players[item] = true
	queue_free()


func _on_body_entered(body: Node) -> void:
	if in_motion:
		print('Bomb collide %s' % body)
		in_motion = false
		detonate()
