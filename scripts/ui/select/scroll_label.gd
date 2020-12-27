extends Label

export var move = Vector2(1, 0)
export var left_border = -100
export var right_border = 100

func _process(delta):
	set_position(get_position() + move * (global.fps * delta))
	if get_position().x <= left_border:
		set_position(Vector2(get_position().x + (right_border - left_border), get_position().y))
	elif get_position().x >= right_border:
		set_position(Vector2(get_position().x - (right_border - left_border), get_position().y))
