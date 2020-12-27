extends UiMenuButton

func setting_slide_left():
	if global.host_rotation > global.LOBBY_ROTATION.win:
		global.host_rotation -= 1
	set_label_text()

func setting_slide_right():
	if global.host_rotation < global.LOBBY_ROTATION.none:
		global.host_rotation += 1
	set_label_text()

func check_slide_edges():
	if global.host_rotation == global.LOBBY_ROTATION.none:
		frame = 3
	elif global.host_rotation == global.LOBBY_ROTATION.win:
		frame = 2
	else:
		frame = 1

func set_label_text():
	label.text = "Rot.: "
	match global.host_rotation:
		global.LOBBY_ROTATION.win:
			label.text += "Win Stay"
		global.LOBBY_ROTATION.lose:
			label.text += "Lose Stay"
		global.LOBBY_ROTATION.none:
			label.text += "None Stay"

func check_page():
	return page == global.host_page