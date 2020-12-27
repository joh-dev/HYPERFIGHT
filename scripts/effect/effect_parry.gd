extends Effect

func _ready():
	frame_delay_override = true

func on_anim_finished(anim_name):
	game.set_zero_delay()
	queue_free()
