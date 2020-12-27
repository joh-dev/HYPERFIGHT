extends UiMenuButton

func check_page():
	return page == global.host_page

func get_edit_text():
	return global.host_name

func set_edit_text():
	.set_edit_text()
	global.host_name = line_edit.text
