extends Sprite

onready var chat_label = get_node("chat_label")
onready var line_edit = get_node("line_edit")
onready var menu_yesno = get_node("../menu_yesno")

func _ready():
	chat_label.text = ""
	line_edit.editable = false
	line_edit.visible = false

func _process(delta):
	if Input.is_action_just_pressed(global.INPUT_PLAYER1 + global.INPUT_ACTION_START) and visible and not menu_yesno.active:
		line_edit.editable = !line_edit.editable
		line_edit.visible = line_edit.editable
		var editing = line_edit.editable
		if editing:
			line_edit.grab_focus()
		else:
			if not line_edit.text.empty():
				global.send_lobby_chat_msg(line_edit.text)
				update_text()
			line_edit.text = ""

func update_text():
	chat_label.text = global.lobby_chat_msg
	if chat_label.get_line_count() > chat_label.max_lines_visible:
		chat_label.lines_skipped = chat_label.get_line_count() - chat_label.max_lines_visible

func is_active():
	return line_edit.visible
