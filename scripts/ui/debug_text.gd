extends Node2D

onready var label = get_node("debug_layer/Label")

var alpha = 3

func _process(delta):
	alpha -= delta
	var set_alpha = 1
	if alpha < 1:
		set_alpha = alpha
	label.set_modulate(Color(1, 1, 1, set_alpha))
	if alpha <= 0:
		queue_free()

func set_position(new_pos):
	label.rect_position = new_pos

func get_position():
	return label.rect_position

func set_text(text):
	label.text = text
