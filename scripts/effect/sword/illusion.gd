extends Sprite

var fade_amount = 0.2
var move_amount = 5
var alpha = 1 - fade_amount
var left = false

func process(curr_frame, frame_delay):
	set_modulate(Color(1, 1, 1, alpha))
	if alpha <= 0:
		queue_free()
	alpha -= fade_amount
	if left:
		position.x -= move_amount
	else:
		position.x += move_amount

func set_palette(player_num):
	global.set_material_palette(material, player_num)
