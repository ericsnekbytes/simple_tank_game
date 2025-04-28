extends RigidBody3D

var last_touched_by = -1


func _on_body_shape_entered(body_rid: RID, body: Node, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group('player'):
		print('BALL TOUCH BY %s' % body)
		last_touched_by = body.team_id
