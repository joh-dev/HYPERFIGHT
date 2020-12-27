extends UiMenuButton

func setting_slide_left():
	if global.host_page > 1:
		global.host_page -= 1
	set_label_text()

func setting_slide_right():
	if global.host_page < global.host_max_page:
		global.host_page += 1
	set_label_text()

func check_slide_edges():
	if global.host_page == global.host_max_page:
		frame = 3
	elif global.host_page == 1:
		frame = 2
	else:
		frame = 1

func set_label_text():
	label.text = "Page " + str(global.host_page) + "/" + str(global.host_max_page)