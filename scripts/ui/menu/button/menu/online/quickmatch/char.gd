extends UiMenuButton

onready var button_onlinepalette = get_node("../button_onlinepalette")

func setting_slide_left():
	if global.online_char > global.CHAR.goto:
		global.online_char -= 1
		if global.online_char == global.CHAR.darkgoto and not global.unlock_char_darkgoto:
			global.online_char -= 1
		change_palette_button()
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if global.online_char < global.CHAR.random:
		global.online_char += 1
		if global.online_char == global.CHAR.darkgoto and not global.unlock_char_darkgoto:
			global.online_char += 1
		change_palette_button()
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.online_char == global.CHAR.random:
		frame = 3
	elif global.online_char == global.CHAR.goto:
		frame = 2
	else:
		frame = 1

func change_palette_button():
	if button_onlinepalette != null:
		global.online_palette = -1
		button_onlinepalette.set_label_text()

func set_label_text():
	label.text = "Ch: " + global.get_char_real_name(global.online_char)
