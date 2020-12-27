extends UiMenuButton

func setting_slide_left():
	if global.sfx_volume > 0:
		global.sfx_volume -= 1
	global.set_sfx_volume()
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if global.sfx_volume < 10:
		global.sfx_volume += 1
	global.set_sfx_volume()
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.sfx_volume == 10:
		frame = 3
	elif global.sfx_volume == 0:
		frame = 2
	else:
		frame = 1

func set_label_text():
	label.text = "SFX Volume: " + str(global.sfx_volume)