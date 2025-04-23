class_name ExpDecal

extends Node3D

@export var fade_curve: Curve
@onready var fade_timer = $FadeTimer
@onready var decal = $ExpDecal
var fade_out = false


func _on_life_timer_timeout():
	fade_out = true
	fade_timer.start()


func _physics_process(delta):
	if fade_out:
		if fade_timer.is_stopped():
			call_deferred('queue_free')
		else:
			decal.modulate.a = fade_curve.sample((fade_timer.wait_time - fade_timer.time_left) / fade_timer.wait_time)
