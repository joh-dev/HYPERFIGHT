extends UiMenuButton

signal find_page_changed

func setting_slide_left():
	if global.find_page > 1:
		global.find_page -= 1
		emit_signal("find_page_changed")
	set_label_text()

func setting_slide_right():
	if global.find_page < global.find_max_page:
		global.find_page += 1
		emit_signal("find_page_changed")
	set_label_text()

func check_slide_edges():
	if global.find_page == global.find_max_page and global.find_max_page > 1:
		frame = 3
	elif global.find_page == 1 and global.find_max_page > 1:
		frame = 2
	else:
		frame = 1

func set_label_text():
	label.text = "Page " + str(global.find_page) + "/" + str(global.find_max_page)