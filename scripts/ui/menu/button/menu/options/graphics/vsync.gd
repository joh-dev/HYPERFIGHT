extends UiMenuButton

func setting_slide_left():
	if global.vsync:
		global.vsync = false
	global.set_vsync()
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if not global.vsync:
		global.vsync = true
	global.set_vsync()
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.vsync:
		frame = 3
	else:
		frame = 2

func set_label_text():
	if global.vsync:
		label.text = "Vsync: On"
	else:
		label.text = "Vsync: Off"