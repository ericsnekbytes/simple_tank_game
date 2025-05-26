extends Button

class_name WeaponSelector

signal assign_slot(weapon_id)

var weapon_id = ''
@onready var gun_icon = $MarginContainer/VBoxContainer/HBoxContainer/GunIcon


func set_gun_icon(icon: Texture2D):
	gun_icon.texture = icon


func set_gun_text(text: String):
	$MarginContainer/VBoxContainer/GunText.set_text(text)


func _on_pressed():
	print('WEP CLICKED')
	assign_slot.emit(weapon_id)
