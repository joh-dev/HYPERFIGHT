extends Sprite

export var color = Color()

onready var color_pattern = get_node("color_pattern")

var active = false

func _ready():
	color_pattern.set_modulate(color)
	color_pattern.region_rect.size.x = 0

func _process(delta):
	if active and color_pattern.region_rect.size.x < 256:
		color_pattern.region_rect.size.x += 32 * (global.fps * delta)

func activate():
	active = true
