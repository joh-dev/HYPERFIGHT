extends UiMenuButton

func setting_slide_left():
	if global.host_max_players > 2:
		global.host_max_players -= 1
	set_label_text()

func setting_slide_right():
	if global.host_max_players < 8:
		global.host_max_players += 1
	set_label_text()

func check_slide_edges():
	if global.host_max_players == 8:
		frame = 3
	elif global.host_max_players == 2:
		frame = 2
	else:
		frame = 1

func set_label_text():
	label.text = "Max Players: " + str(global.host_max_players)

func check_page():
	return page == global.host_page
