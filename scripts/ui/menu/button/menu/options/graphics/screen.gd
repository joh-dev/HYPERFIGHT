extends UiMenuButton

func setting_slide_left():
	if global.screen_type > global.SCREEN.window:
		global.screen_type -= 1
		global.set_screen_type()
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if global.screen_type < global.SCREEN.full:
		global.screen_type += 1
		global.set_screen_type()
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.screen_type == global.SCREEN.full:
		frame = 3
	elif global.screen_type == global.SCREEN.window:
		frame = 2
	else:
		frame = 1

func set_label_text():
	match global.screen_type:
		global.SCREEN.window:
			label.text = "Windowed 1x"
		global.SCREEN.window2x:
			label.text = "Windowed 2x"
		global.SCREEN.window3x:
			label.text = "Windowed 3x"
		global.SCREEN.window4x:
			label.text = "Windowed 4x"
		global.SCREEN.full:
			label.text = "Fullscreen"
