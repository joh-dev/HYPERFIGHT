extends UiMenuButton

func setting_slide_left():
	if global.host_match_limit > 0:
		global.host_match_limit -= 1
	set_label_text()

func setting_slide_right():
	if global.host_match_limit < 5:
		global.host_match_limit += 1
	set_label_text()

func check_slide_edges():
	if global.host_match_limit == 5:
		frame = 3
	elif global.host_match_limit == 0:
		frame = 2
	else:
		frame = 1

func set_label_text():
	label.text = "Stay Lim.: "
	if global.host_match_limit > 0:
		label.text += str(global.host_match_limit)
	else:
		label.text += "None"

func check_page():
	return page == global.host_page
