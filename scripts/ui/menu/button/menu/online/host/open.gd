extends UiMenuButton

func setting_slide_left():
	if global.host_open > global.LOBBY_OPEN.invite:
		global.host_open -= 1
	set_label_text()

func setting_slide_right():
	if global.host_open < global.LOBBY_OPEN.public:
		global.host_open += 1
	set_label_text()

func check_slide_edges():
	if global.host_open == global.LOBBY_OPEN.public:
		frame = 3
	elif global.host_open == global.LOBBY_OPEN.invite:
		frame = 2
	else:
		frame = 1

func set_label_text():
	label.text = "Join: "
	match global.host_open:
		global.LOBBY_OPEN.invite:
			label.text += "Invite"
		global.LOBBY_OPEN.friends:
			label.text += "Friends"
		global.LOBBY_OPEN.public:
			label.text += "Public"

func check_page():
	return page == global.host_page
