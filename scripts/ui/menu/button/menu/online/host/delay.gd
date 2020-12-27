extends UiMenuButton

func setting_slide_left():
	if global.host_delay > 0:
		global.host_delay -= 1
	set_label_text()

func setting_slide_right():
	if global.host_delay < 12:
		global.host_delay += 1
	set_label_text()

func check_slide_edges():
	if global.host_delay == 12:
		frame = 3
	elif global.host_delay == 0:
		frame = 2
	else:
		frame = 1

func set_label_text():
	if global.host_delay >= 1:
		label.text = "Delay: " + str(global.host_delay) + "f"
	else:
		label.text = "Delay: Auto"

func check_page():
	return page == global.host_page