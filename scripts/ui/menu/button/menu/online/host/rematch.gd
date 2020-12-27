extends UiMenuButton

func setting_slide_left():
	if global.host_rematch > global.LOBBY_REMATCH.none:
		global.host_rematch -= 1
	set_label_text()

func setting_slide_right():
	if global.host_rematch < global.LOBBY_REMATCH.inf:
		global.host_rematch += 1
	set_label_text()

func check_slide_edges():
	if global.host_rematch == global.LOBBY_REMATCH.inf:
		frame = 3
	elif global.host_rematch == global.LOBBY_REMATCH.none:
		frame = 2
	else:
		frame = 1

func set_label_text():
	label.text = "Rematch: "
	match global.host_rematch:
		global.LOBBY_REMATCH.none:
			label.text += "None"
		global.LOBBY_REMATCH.bo3:
			label.text += "Bo3"
		global.LOBBY_REMATCH.bo5:
			label.text += "Bo5"
		global.LOBBY_REMATCH.inf:
			label.text += "Inf"

func check_page():
	return page == global.host_page