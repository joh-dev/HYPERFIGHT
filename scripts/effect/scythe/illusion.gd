extends Sprite

var fade_amount = 0.1
var move_amount = 5
var alpha = 0.5

func process(curr_frame, frame_delay):
	set_modulate(Color(1, 0, 0, alpha))
	get_material().set_shader_param(global.SHADERPARAM_WHITEAMOUNT, alpha)
	if alpha <= 0:
		queue_free()
	alpha -= fade_amount

func set_palette(player_num):
	global.set_material_palette(material, player_num)
