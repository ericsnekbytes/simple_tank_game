extends Control

signal end_sequence()

var interaction_started = false
@onready var title_text = $Title
@onready var sub_text = $Subtext
@onready var fade_timer = $FadeInTimer
@export var show_subtext = true
@export_multiline var title_string = '':
	set(value):
		title_string = value
		if title_text:
			$Title.set_text(value)
@export_multiline var subtext_string = '':
	set(value):
		subtext_string = value
		if sub_text:
			$Subtext.set_text(value)
var fade_duration = 1.0  # Seconds
var fade_in_velocity = 0
var hover_velocity = 0
var move_offscreen_velocity = 0
var finished = false


# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize to proper value
	title_text.set_text(title_string)
	sub_text.set_text(subtext_string)

	# Make velocity relative to screen width
	fade_in_velocity = get_viewport_rect().size.x / 4.0
	hover_velocity = get_viewport_rect().size.x / 48.0
	move_offscreen_velocity = get_viewport_rect().size.x / .5

	# Start hidden, then reposition and animate
	title_text.hide()
	# Set opacity to zero on start, then fade in
	title_text.modulate = Color(1.0, 1.0, 1.0, 0.0)
	
	fade_timer.wait_time = fade_duration
	# Move the title and subtext to the sides, then animate them in
	# toward the center, one above the other...then move them vertically off screen
	title_text.global_position.x = 0 - (title_text.size.x / 2.0)

	if sub_text:
		sub_text.hide()
		sub_text.modulate = Color(1.0, 1.0, 1.0, 0.0)
		sub_text.global_position.x = get_viewport_rect().size.x - (sub_text.size.x / 2.0)

	if not show_subtext:
		$Subtext.queue_free()
		sub_text = null

	#start()


func start():
	interaction_started = true
	fade_timer.start()
	title_text.show()
	if sub_text:
		sub_text.show()


#func set_title_text(value: String):
	#title_text.set_text(value)
#
#
#func set_sub_text(value: String):
	#sub_text.set_text(value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if interaction_started:
		if not finished:

			if (title_text.global_position.x + title_text.size.x) < 0:
				finished = true
				end_sequence.emit()
				hide()
				process_mode = PROCESS_MODE_DISABLED
				return

			title_text.modulate.a = 1.0 * (fade_duration - fade_timer.time_left) / fade_duration

			var xmove: float = 0.0
			if (title_text.global_position.x + (title_text.size.x / 2.0)) > (9.0 * get_viewport_rect().size.x / 16.0):
				xmove = move_offscreen_velocity * delta
			elif (title_text.global_position.x + (title_text.size.x / 2.0)) < (7.0 * get_viewport_rect().size.x / 16.0):
				xmove = fade_in_velocity * delta
			else:
				xmove = hover_velocity * delta
			title_text.position.x += xmove

			if sub_text:
				sub_text.modulate.a = 1.0 * (fade_duration - fade_timer.time_left) / fade_duration
				sub_text.position.x -= xmove

		#var subtext_xmove: float = 0.0
		#if (sub_text.global_position.x + (sub_text.size.x / 2.0)) > (9.0 * get_viewport_rect().size.x / 16.0):
			#subtext_xmove = fade_in_velocity * delta
		#elif (sub_text.global_position.x + (sub_text.size.x / 2.0)) < (7.0 * get_viewport_rect().size.x / 16.0):
			#subtext_xmove = move_offscreen_velocity * delta
		#else:
			#subtext_xmove = hover_velocity * delta
		#sub_text.position.x -= subtext_xmove

		#var title_ydisplace = abs(center_pos.y) - abs(title_text.position.y)
		#if title_ydisplace:
			#pass
