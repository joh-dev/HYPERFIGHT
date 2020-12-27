extends UiMenuButton

func get_edit_text():
	return global.find_password

func set_edit_text():
	.set_edit_text()
	global.find_password = line_edit.text
