extends Node3D

signal request_scene(scene_id)


func _ready() -> void:
	for player in [$PlayerTank]:
		player.start_process = true
		GameData.initialize_player(player)


func _physics_process(delta: float) -> void:
	InputHandler.poll_for_devices()
