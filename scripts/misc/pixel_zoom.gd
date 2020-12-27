extends Node

onready var viewport = get_viewport()

func _ready():
	get_tree().connect("screen_resized", self, "_screen_resized")
	viewport.size = global.viewport_size

func _screen_resized():
	viewport.size = global.viewport_size
	viewport.set_attach_to_screen_rect(Rect2(Vector2(0, 0), OS.get_window_size()))