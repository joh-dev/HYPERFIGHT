extends Sprite

export var click_rect = Rect2()
export var label_text = ""
export var link = ""

onready var label = get_node("Label")

var hovering = false
var activated = false

func _ready():
	label.text = label_text

func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and activated and hovering:
		OS.shell_open(link)

func _process(delta):
	var hover_rect = Rect2(click_rect.position + position, click_rect.size)
	hovering = hover_rect.has_point(get_viewport().get_mouse_position() - Vector2(get_viewport().size.x / 2, get_viewport().size.y / 2))
	if hovering and activated:
		label.add_color_override("font_color", Color(0.5, 1, 0.5))
	else:
		label.add_color_override("font_color", Color(1, 1, 1))
