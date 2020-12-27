extends UiMenuButton

func setting_slide_left():
	if global.music_volume > 0:
		global.music_volume -= 1
	global.set_music_volume()
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if global.music_volume < 10:
		global.music_volume += 1
	global.set_music_volume()
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.music_volume == 10:
		frame = 3
	elif global.music_volume == 0:
		frame = 2
	else:
		frame = 1

func set_label_text():
	label.text = "Music Volume: " + str(global.music_volume)