extends UiMenuButton

func setting_slide_left():
	if global.online_palette > -1:
		global.online_palette -= 1
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if global.online_palette < global.get_char_max_palette(global.online_char):
		global.online_palette += 1
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.online_char == global.CHAR.random:
		frame = 1
	else:
		if global.online_palette == global.get_char_max_palette(global.online_char):
			frame = 3
		elif global.online_palette == -1:
			frame = 2
		else:
			frame = 1

func set_label_text():
	if global.online_char == global.CHAR.random:
		label.text = "Color: RANDOM"
	else:
		label.text = "Color: " + str(global.online_palette + 2)