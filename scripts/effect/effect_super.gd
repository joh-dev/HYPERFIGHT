extends Effect

func _ready():
	frame_delay_override = true

func process(curr_frame, frame_delay):
	rotation_degrees += 15 * scale.x
	
	.process(curr_frame, frame_delay)

func on_anim_finished(anim_name):
	game.set_zero_delay()
	queue_free()
