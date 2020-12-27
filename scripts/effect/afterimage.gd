extends Sprite

var fade_amount = 0.04
var alpha = 1 - fade_amount

func _ready():
	z_index = -100

func process(curr_frame, frame_delay):
	set_modulate(Color(1, 1, 1, alpha))
	if alpha <= 0:
		queue_free()
	alpha -= fade_amount

func set_palette(player_num):
	global.set_material_palette(material, player_num)
	
	set_modulate(Color(1, 1, 1, alpha))
