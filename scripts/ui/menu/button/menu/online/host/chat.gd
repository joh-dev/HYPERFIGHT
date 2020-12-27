extends UiMenuButton

func setting_slide_left():
	if global.host_chat:
		global.host_chat = false
	set_label_text()
	check_slide_edges()

func setting_slide_right():
	if not global.host_chat:
		global.host_chat = true
	set_label_text()
	check_slide_edges()

func check_slide_edges():
	if global.host_chat:
		frame = 3
	else:
		frame = 2

func set_label_text():
	if global.host_chat:
		label.text = "Chat: Enabled"
	else:
		label.text = "Chat: Disabled"

func check_page():
	return page == global.host_page