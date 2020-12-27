extends UiMenuButton

func setting_slide_left():
	global.show_hitboxes = false
	check_slide_edges()

func setting_slide_right():
	global.show_hitboxes = true
	check_slide_edges()

func check_slide_edges():
	set_label_text()
	if global.show_hitboxes:
		frame = 3
	else:
		frame = 2

func set_label_text():
	if global.show_hitboxes:
		label.text = "Hitboxes: Show"
	else:
		label.text = "Hitboxes: Hide"