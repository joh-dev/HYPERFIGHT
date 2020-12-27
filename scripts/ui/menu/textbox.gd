extends Sprite

onready var label_text = get_node("label_text")

var messages = []
var curr_message = ""
var char_pos = 0

func _ready():
	label_text.text = ""
	visible = false

func process():
	if curr_message.length() > 0 and char_pos < curr_message.length():
		char_pos += 0.5
		label_text.text = curr_message.substr(0, char_pos)

func next_message():
	label_text.text = ""
	if messages.size() > 0:
		curr_message = messages.pop_front()
		char_pos = 0
		visible = true
	else:
		visible = false

func add_message(message):
	messages.append(message)
